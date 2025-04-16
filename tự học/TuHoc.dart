// Bài 1: Sử dụng Null Safety và Pattern Matching để xử lý dữ liệu người dùng
void main() {
  // Null Safety: Biến không thể null nhờ từ khóa required
  User user = User(name: 'Bob', age: 30);

  // Pattern Matching: Phân tích dữ liệu với switch expression (Dart 3+)
  String description = switch (user) {
    User(name: 'Bob', age: var a) => 'Bob is $a years old',
    User(name: var n, age: var a) when a >= 18 => '$n is an adult',
    User(name: var n, age: var a) => '$n is a minor',
  };

  // Chuyển tuổi thành chuỗi với định dạng
  String ageAsString = user.age.toString();

  // In kết quả
  print('User: ${user.name}');
  print('Description: $description');
  print('Age as string: $ageAsString');
}

// Class với null safety
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});
}

// Bài 2: Xử lý JSON với Record Types và async/await
void main() async {
  // Record Type: Lưu trữ dữ liệu JSON (Dart 3+)
  (String name, double price) product = await fetchProduct();

  // Chuyển giá thành chuỗi với 2 chữ số thập phân
  String priceAsString = product.price.toStringAsFixed(2);

  // Kiểm tra giá với pattern matching
  String status = switch (product) {
    (name: var n, price: var p) when p > 100 => '$n is expensive',
    (name: var n, price: var p) => '$n is affordable',
  };

  // In kết quả
  print('Product: ${product.name}');
  print('Price: $priceAsString');
  print('Status: $status');
}

// Mô phỏng lấy dữ liệu JSON bất đồng bộ
Future<(String, double)> fetchProduct() async {
  // Giả lập độ trễ mạng
  await Future.delayed(Duration(seconds: 1));
  return ('Laptop', 999.99);
}

// Bài 3: Làm việc với Extension Methods và xử lý lỗi
void main() {
  // String: Chuỗi đầu vào
  String input = '  dart programming  ';

  // Extension Method: Tự định nghĩa phương thức cho String
  String formatted = input.toTitleCase();

  // Xử lý lỗi khi chuyển chuỗi thành số
  String numberString = '123.45';
  double? parsedNumber;
  try {
    parsedNumber = double.parse(numberString);
  } catch (e) {
    parsedNumber = null;
  }

  // Chuyển số thành chuỗi với định dạng
  String numberAsString = parsedNumber?.toStringAsFixed(2) ?? 'Invalid number';

  // In kết quả
  print('Input: $input');
  print('Formatted: $formatted');
  print('Parsed number: $numberAsString');
}

// Extension Method để định dạng chuỗi thành Title Case
extension StringExtension on String {
  String toTitleCase() {
    return trim()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
