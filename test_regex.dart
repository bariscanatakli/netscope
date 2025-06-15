void main() {
  final regex = RegExp(r'\((.*?)\)');
  final match = regex.firstMatch('multiple (brackets) (192.168.1.1)');
  print('Result: ${match?.group(1)}');
}
