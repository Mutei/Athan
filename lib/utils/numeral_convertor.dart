// lib/utils/numeral_converter.dart

String convertToArabicNumerals(String input) {
  const Map<String, String> numerals = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  StringBuffer buffer = StringBuffer();
  for (var char in input.split('')) {
    buffer.write(numerals[char] ?? char);
  }
  return buffer.toString();
}
