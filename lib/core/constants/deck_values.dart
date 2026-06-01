import '../l10n/l10n_extensions.dart';
import '../../data/models/models.dart';
import 'package:flutter/widgets.dart';

/// Valori del deck per la stima.
abstract final class DeckValues {
  static const defaultDeck = [
    '0',
    '½',
    '1',
    '2',
    '3',
    '5',
    '8',
    '13',
    '21',
    '?',
    '☕',
  ];

  static const numbersOnly = ['1', '2', '3', '5', '8', '13'];

  static const tshirt = ['XS', 'S', 'M', 'L', 'XL'];

  static const powersOf2 = ['0', '1', '2', '4', '8', '16', '32', '?', '☕'];

  static const safe = ['1', '2', '3', '5', '8', '13', '21', '?', '☕'];

  static List<String> forRoom(Room room) {
    if (room.deckValues.isEmpty) return List<String>.from(defaultDeck);
    return List<String>.from(room.deckValues);
  }

  static String label(BuildContext context, String value) {
    final l10n = context.l10n;
    return switch (value) {
      '0' => l10n.deckLabelZero,
      '½' => l10n.deckLabelHalf,
      '?' => l10n.deckLabelUnsure,
      '☕' => l10n.deckLabelCoffee,
      _ => l10n.deckLabelSpritz(value),
    };
  }

  static bool isValidForRoom(Room room, String value) =>
      forRoom(room).contains(value);
}
