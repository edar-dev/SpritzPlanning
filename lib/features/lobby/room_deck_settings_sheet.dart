import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/deck_values.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/error_snackbar.dart';

class RoomDeckSettingsSheet extends ConsumerStatefulWidget {
  const RoomDeckSettingsSheet({super.key, required this.participantId});

  final String participantId;

  static Future<void> show(BuildContext context, String participantId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => RoomDeckSettingsSheet(participantId: participantId),
    );
  }

  @override
  ConsumerState<RoomDeckSettingsSheet> createState() =>
      _RoomDeckSettingsSheetState();
}

class _RoomDeckSettingsSheetState extends ConsumerState<RoomDeckSettingsSheet> {
  List<String>? _deck;
  bool? _allowCoffee;

  void _initFromRoom(Room? room) {
    if (_deck != null) return;
    _deck = List<String>.from(
      room != null ? DeckValues.forRoom(room) : DeckValues.defaultDeck,
    );
    _allowCoffee = room?.allowCoffeeBreak ?? true;
  }

  void _applyPreset(List<String> preset) {
    setState(() {
      _deck = List<String>.from(preset);
      if (_allowCoffee == false) {
        _deck!.removeWhere((v) => v == '☕');
      }
    });
  }

  Future<void> _save() async {
    try {
      await ref.read(roomRepositoryProvider).setRoomDeck(
            participantId: widget.participantId,
            deckValues: _deck!,
            allowCoffeeBreak: _allowCoffee!,
          );
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      if (mounted) {
        await showUserError(context, e, stackTrace: st);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final room = ref.watch(roomStateProvider).valueOrNull?.room;
    _initFromRoom(room);
    final deck = _deck!;
    final allowCoffee = _allowCoffee!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.deckSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: Text(l10n.deckPresetFibonacci),
                  onPressed: () => _applyPreset(DeckValues.defaultDeck),
                ),
                ActionChip(
                  label: Text(l10n.deckPresetNumbers),
                  onPressed: () => _applyPreset(DeckValues.numbersOnly),
                ),
                ActionChip(
                  label: Text(l10n.deckPresetTshirt),
                  onPressed: () => _applyPreset(DeckValues.tshirt),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(l10n.deckAllowCoffee),
              value: allowCoffee,
              onChanged: (v) {
                setState(() {
                  _allowCoffee = v;
                  if (!v) {
                    _deck!.removeWhere((e) => e == '☕');
                  } else if (!_deck!.contains('☕')) {
                    _deck!.add('☕');
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: deck
                  .map(
                    (v) => Chip(
                      label: Text(DeckValues.label(context, v)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.salvaOrdine),
            ),
          ],
        ),
      ),
    );
  }
}
