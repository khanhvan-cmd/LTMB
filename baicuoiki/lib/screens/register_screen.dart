import 'package:flutter/material.dart';
import 'package:baicuoiki/models/user.dart';
import 'package:baicuoiki/services/auth_service.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên đăng nhập')),
      );
      return;
    }
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập email hợp lệ')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      print('Attempting to register with email: $email');
      final user = await _authService.register(email, password, username);
      if (user != null) {
        print('Registration successful, navigating to TaskScreen with userId: ${user.id}');
        Navigator.pushReplacementNamed(
          context,
          '/tasks',
          arguments: user,
        );
      }
    } catch (e) {
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      print('Attempting to sign in with Google');
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        print('Google Sign-In successful, navigating to TaskScreen with userId: ${user.id}');
        Navigator.pushReplacementNamed(
          context,
          '/tasks',
          arguments: user,
        );
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: AnimationLimiter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 600),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person, color: Color(0xFF3A1C71)),
                                  hintText: 'Username',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email, color: Color(0xFF3A1C71)),
                                  hintText: 'Email',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock, color: Color(0xFF3A1C71)),
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              _isLoading
                                  ? CircularProgressIndicator(color: Color(0xFFD76D77))
                                  : Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFD76D77),
                                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _signInWithGoogle,
                                    icon: Image.asset(
                                      'assets/y-nghia-gg-trong-cac-thuat-ngu-hang-ngay-1.webp',
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.contain,
                                    ),
                                    label: Text(
                                      'Sign up with Google',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}