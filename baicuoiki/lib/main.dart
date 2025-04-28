import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:baicuoiki/firebase_options.dart';
import 'package:baicuoiki/screens/login_screen.dart';
import 'package:baicuoiki/screens/register_screen.dart';
import 'package:baicuoiki/screens/task_screen.dart';
import 'package:baicuoiki/screens/task_detail_screen.dart';
import 'package:baicuoiki/models/task.dart'; // Thêm import cho Task

// Hàm main khởi động ứng dụng
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter sẵn sàng
  try {
    await Firebase.initializeApp(); // Khởi tạo Firebase
    print('Firebase khởi tạo thành công');
  } catch (e) {
    print('Lỗi khi khởi tạo Firebase: $e');
  }
  runApp(const MyApp()); // Chạy ứng dụng
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager', // Tiêu đề ứng dụng
      theme: ThemeData(
        primarySwatch: Colors.blue, // Màu chủ đạo
        visualDensity: VisualDensity.adaptivePlatformDensity, // Tối ưu hiển thị
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          displayLarge: TextStyle(fontFamily: 'Poppins'),
          displayMedium: TextStyle(fontFamily: 'Poppins'),
          displaySmall: TextStyle(fontFamily: 'Poppins'),
          headlineLarge: TextStyle(fontFamily: 'Poppins'),
          headlineMedium: TextStyle(fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontFamily: 'Poppins'),
          titleMedium: TextStyle(fontFamily: 'Poppins'),
          titleSmall: TextStyle(fontFamily: 'Poppins'),
          labelLarge: TextStyle(fontFamily: 'Poppins'),
          labelMedium: TextStyle(fontFamily: 'Poppins'),
          labelSmall: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      initialRoute: '/login', // Màn hình khởi đầu
      routes: {
        '/login': (context) => LoginScreen(), // Định tuyến màn hình đăng nhập
        '/register': (context) => RegisterScreen(), // Định tuyến màn hình đăng ký
        '/tasks': (context) => TaskScreen(), // Định tuyến màn hình danh sách công việc
        '/task_detail': (context) => TaskDetailScreen(
          task: ModalRoute.of(context)!.settings.arguments as Task, // Ép kiểu Task
        ),
      },
    );
  }
}