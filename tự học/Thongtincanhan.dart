void main() {
  // Khai báo biến
  String name = "Nguyễn Văn A";
  int age = 20;
  double height = 1.75;

  // In thông tin ra màn hình
  print("Xin chào, tôi là $name!");
  print("Tôi $age tuổi và cao $height mét.");

  // Tính BMI (chỉ số khối cơ thể)
  double weight = 70.5;
  double bmi = weight / (height * height);
  print("Chỉ số BMI của tôi là: ${bmi.toStringAsFixed(2)}");
}
