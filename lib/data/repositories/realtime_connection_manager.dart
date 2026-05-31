import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/connection_status.dart';
import '../../core/monitoring/error_reporter.dart';
import '../supabase/supabase_client.dart';

typedef RoomStateRefresh = Future<void> Function();

/// Gestisce il lifecycle del [RealtimeChannel] con retry, polling e recovery.
class RealtimeConnectionManager {
  RealtimeConnectionManager({SupabaseClient? client})
      : _client = client ?? supabase;

  final SupabaseClient _client;
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  RealtimeChannel? _channel;
  Timer? _retryTimer;
  Timer? _pollingTimer;
  String? _roomId;
  RoomStateRefresh? _onStateRefresh;

  int _retryCount = 0;
  int _pollFailures = 0;
  bool _isSubscribed = false;
  bool _disposed = false;

  static const _maxRetries = 3;
  static const _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];
  static const _pollingInterval = Duration(seconds: 5);
  static const _maxPollFailures = 3;

  Stream<ConnectionStatus> get connectionStatusStream {
    return Stream.multi((controller) {
      controller.add(_status);
      final sub = _statusController.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = sub.cancel;
    });
  }

  ConnectionStatus _status = ConnectionStatus.connected;
  ConnectionStatus get status => _status;

  void _emit(ConnectionStatus status) {
    if (_disposed || _status == status) return;
    final previous = _status;
    _status = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
    if (previous == ConnectionStatus.connected &&
        status != ConnectionStatus.connected) {
      ErrorReporter.breadcrumb(
        'Realtime: $previous → $status',
        category: 'realtime',
        level: status == ConnectionStatus.disconnected
            ? SentryLevel.warning
            : SentryLevel.info,
      );
    }
  }

  void subscribe({
    required String roomId,
    required RoomStateRefresh onStateRefresh,
  }) {
    if (_disposed) return;
    unsubscribe();
    _roomId = roomId;
    _onStateRefresh = onStateRefresh;
    _retryCount = 0;
    _pollFailures = 0;
    _isSubscribed = false;
    _emit(ConnectionStatus.connected);
    _joinChannel();
  }

  void unsubscribe() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _stopPolling();
    _teardownChannel();
    _roomId = null;
    _onStateRefresh = null;
    _retryCount = 0;
    _pollFailures = 0;
    _isSubscribed = false;
    if (!_disposed) {
      _emit(ConnectionStatus.connected);
    }
  }

  void dispose() {
    _disposed = true;
    unsubscribe();
    _statusController.close();
  }

  Future<void> manualRefresh() async {
    if (_roomId == null || _onStateRefresh == null) return;
    await _refreshState();
    if (!_isSubscribed && _status != ConnectionStatus.connected) {
      _retryCount = 0;
      _joinChannel(silent: true);
    }
  }

  void _joinChannel({bool silent = false}) {
    final roomId = _roomId;
    if (roomId == null || _disposed) return;

    _teardownChannel();

    _channel = _client
        .channel('room:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: roomId,
          ),
          callback: (_) => _refreshState(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (_) => _refreshState(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stories',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (_) => _refreshState(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'votes',
          callback: (_) => _refreshState(),
        )
        .subscribe((status, error) {
          if (_disposed) return;
          switch (status) {
            case RealtimeSubscribeStatus.subscribed:
              _onSubscribed();
            case RealtimeSubscribeStatus.channelError:
            case RealtimeSubscribeStatus.closed:
            case RealtimeSubscribeStatus.timedOut:
              _onChannelLost(silent: silent, error: error);
          }
        });

    if (!silent) {
      _refreshState();
    }
  }

  void _onSubscribed() {
    _retryCount = 0;
    _pollFailures = 0;
    _isSubscribed = true;
    _stopPolling();
    _emit(ConnectionStatus.connected);
    _refreshState();
  }

  void _onChannelLost({required bool silent, Object? error}) {
    _isSubscribed = false;
    if (error != null) {
      debugPrint('Realtime channel error: $error');
    }
    if (_status == ConnectionStatus.polling) {
      return;
    }
    if (silent) {
      return;
    }
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _retryTimer?.cancel();
    if (_retryCount < _maxRetries) {
      _emit(ConnectionStatus.reconnecting);
      final delay = _retryDelays[_retryCount];
      _retryCount++;
      _retryTimer = Timer(delay, () => _joinChannel());
      return;
    }
    _startPolling();
  }

  void _startPolling() {
    if (_disposed || _roomId == null) return;
    _stopPolling();
    _emit(ConnectionStatus.polling);
    _refreshState();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _pollTick());
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _pollTick() async {
    if (_disposed || _roomId == null) return;
    await _refreshState();
    if (_isSubscribed) return;
    _joinChannel(silent: true);
  }

  Future<void> _refreshState() async {
    final refresh = _onStateRefresh;
    if (refresh == null) return;
    try {
      await refresh();
      _pollFailures = 0;
      if (_status == ConnectionStatus.disconnected) {
        _emit(ConnectionStatus.polling);
      }
    } catch (e, st) {
      debugPrint('Errore refresh room: $e\n$st');
      _pollFailures++;
      if (_pollFailures >= _maxPollFailures) {
        _emit(ConnectionStatus.disconnected);
      }
    }
  }

  void _teardownChannel() {
    final channel = _channel;
    _channel = null;
    _isSubscribed = false;
    if (channel != null) {
      _client.removeChannel(channel);
    }
  }
}
