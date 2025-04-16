void main() {
  // Tạo danh sách công việc
  List<String> todoList = [
    "Học Dart",
    "Làm bài tập",
    "Đi siêu thị",
    "Gọi điện cho bạn",
  ];

  // In danh sách công việc
  print("Danh sách công việc hôm nay:");
  for (int i = 0; i < todoList.length; i++) {
    print("${i + 1}. ${todoList[i]}");
  }

  // Thêm công việc mới
  todoList.add("Tập thể dục");
  print("\nSau khi thêm công việc mới:");
  todoList.forEach((task) => print("- $task"));

  // Xóa công việc đầu tiên
  todoList.removeAt(0);
  print("\nSau khi xóa công việc đầu tiên:");
  todoList.forEach((task) => print("- $task"));
}
