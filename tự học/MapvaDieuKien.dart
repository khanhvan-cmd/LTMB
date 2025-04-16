void main() {
  // Tạo Map lưu điểm học sinh
  Map<String, double> studentScores = {
    'An': 8.5,
    'Bình': 6.0,
    'Cường': 9.2,
    'Dung': 4.5,
  };

  // In điểm của từng học sinh
  print('Điểm của học sinh:');
  studentScores.forEach((name, score) {
    print('$name: $score');
  });

  // Kiểm tra và xếp loại học sinh
  print('\nXếp loại học sinh:');
  for (var entry in studentScores.entries) {
    String rank;
    if (entry.value >= 8.0) {
      rank = 'Giỏi';
    } else if (entry.value >= 6.5) {
      rank = 'Khá';
    } else if (entry.value >= 5.0) {
      rank = 'Trung bình';
    } else {
      rank = 'Yếu';
    }
    print('${entry.key}: $rank');
  }

  // Cập nhật điểm cho một học sinh
  studentScores['Dung'] = 6.8;
  print('\nSau khi cập nhật điểm của Dung: ${studentScores['Dung']}');
}
