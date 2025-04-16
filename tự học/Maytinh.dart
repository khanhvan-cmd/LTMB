import 'dart:io';

void main() {
  print('Chào mừng đến với Máy tính đơn giản!');

  // Nhập số từ người dùng
  print('Nhập số thứ nhất:');
  double num1 = double.parse(stdin.readLineSync()!);

  print('Nhập số thứ hai:');
  double num2 = double.parse(stdin.readLineSync()!);

  print('Chọn phép tính (+, -, *, /):');
  String operator = stdin.readLineSync()!;

  // Gọi hàm tính toán
  double result = calculate(num1, num2, operator);

  // In kết quả
  print('Kết quả: $num1 $operator $num2 = ${result.toStringAsFixed(2)}');
}

// Hàm thực hiện phép tính
double calculate(double a, double b, String op) {
  switch (op) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '*':
      return a * b;
    case '/':
      if (b != 0) {
        return a / b;
      } else {
        print('Lỗi: Không thể chia cho 0!');
        return 0;
      }
    default:
      print('Phép tính không hợp lệ!');
      return 0;
  }
}
