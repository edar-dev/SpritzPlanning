/// Valori del deck Fibonacci per la stima.
abstract final class DeckValues {
  static const values = [
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

  static String label(String value) {
    return switch (value) {
      '0' => 'Acqua',
      '½' => 'Mezzo',
      '?' => 'Non ho sete',
      '☕' => 'Pausa caffè',
      _ => 'Spritz $value',
    };
  }

  static bool isValid(String value) => values.contains(value);
}
