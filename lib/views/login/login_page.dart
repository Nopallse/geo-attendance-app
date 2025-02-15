import 'package:absensi_app/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_app/utils/device_utils.dart';
import 'package:logger/logger.dart';

import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final logger = Logger();

  void _printDeviceId() async {
    String deviceId = await DeviceUtils.getDeviceId();
    logger.d("Device ID: $deviceId");
  }

  @override
  void initState() {
    super.initState();
    _printDeviceId();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    AuthService authService = AuthService();
    String deviceId = await DeviceUtils.getDeviceId(); // Dapatkan device ID
    logger.d("Device ID login page: $deviceId");
    Map<String, dynamic> result = await authService.login(
      _emailController.text,
      _passwordController.text,
      deviceId,
    );

    setState(() {
      _isLoading = false;
    });

    if (result["success"]) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Login gagal")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
