import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool? _autoReveal;
  bool? _hideVoters;
  final _pinController = TextEditingController();

  void _initFromRoom(Room? room) {
    if (_deck != null) return;
    _deck = List<String>.from(
      room != null ? DeckValues.forRoom(room) : DeckValues.defaultDeck,
    );
    _allowCoffee = room?.allowCoffeeBreak ?? true;
    _autoReveal = room?.autoRevealWhenAllVoted ?? false;
    _hideVoters = room?.hideVotersUntilReveal ?? false;
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _applyPreset(List<String> preset) {
    setState(() {
      _deck = List<String>.from(preset);
      if (_allowCoffee == false) {
        _deck!.removeWhere((e) => e == '☕');
      }
    });
  }

  Future<void> _save() async {
    final repo = ref.read(roomRepositoryProvider);
    try {
      await repo.setRoomDeck(
        participantId: widget.participantId,
        deckValues: _deck!,
        allowCoffeeBreak: _allowCoffee!,
      );
      await repo.setRoomSettings(
        participantId: widget.participantId,
        autoRevealWhenAllVoted: _autoReveal!,
        hideVotersUntilReveal: _hideVoters!,
      );
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      if (mounted) {
        await showUserError(context, e, stackTrace: st);
      }
    }
  }

  Future<void> _savePin({required bool remove}) async {
    try {
      await ref.read(roomRepositoryProvider).setRoomPin(
            participantId: widget.participantId,
            pin: remove ? null : _pinController.text.trim(),
          );
      if (!remove) _pinController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              remove ? context.l10n.removeRoomPin : context.l10n.setRoomPin,
            ),
          ),
        );
      }
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
                ActionChip(
                  label: Text(l10n.deckPresetPowers2),
                  onPressed: () => _applyPreset(DeckValues.powersOf2),
                ),
                ActionChip(
                  label: Text(l10n.deckPresetSafe),
                  onPressed: () => _applyPreset(DeckValues.safe),
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
            SwitchListTile(
              title: Text(l10n.autoRevealTitle),
              subtitle: Text(l10n.autoRevealSubtitle),
              value: _autoReveal!,
              onChanged: (v) => setState(() => _autoReveal = v),
            ),
            SwitchListTile(
              title: Text(l10n.hideVotersUntilRevealTitle),
              subtitle: Text(l10n.hideVotersUntilRevealSubtitle),
              value: _hideVoters!,
              onChanged: (v) => setState(() => _hideVoters = v),
            ),
            const Divider(),
            Text(l10n.setRoomPin, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: l10n.roomPinLabel,
                hintText: l10n.roomPinHint,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _savePin(remove: false),
                    child: Text(l10n.setRoomPin),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () => _savePin(remove: true),
                    child: Text(l10n.removeRoomPin),
                  ),
                ),
              ],
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
