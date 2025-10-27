import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/app/constants/constants.dart';
import 'package:socialmedia/app/routes/app_route.dart';
import 'package:socialmedia/core/notifiers/auth_provider.dart';
import 'package:socialmedia/meta/widgets/custom_button.dart';
import 'package:socialmedia/meta/widgets/custom_snackbar.dart';
import 'package:socialmedia/meta/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailC;
  late TextEditingController passC;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    emailC = TextEditingController();
    passC = TextEditingController();
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final res = await auth.login(
      email: emailC.text.trim(),
      password: passC.text.trim(),
    );
    setState(() => loading = false);
    if (res == "success") {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.homeRoute, (route) => false);
      }
    } else {
      if (mounted) {
        SnackbarUtil.show(context, res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  color: CColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 17),
              CustomTextField(
                icon: Icons.email,
                hintText: "Enter your email",
                isEmail: true,
                controller: emailC,
                validator: (v) => v == null || !v.contains('@')
                    ? '  Enter valid email'
                    : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                icon: Icons.lock,
                hintText: "Enter your password",
                isPassword: true,
                controller: passC,

                validator: (v) =>
                    v == null || v.length < 6 ? '  Min 6 chars' : null,
              ),
              const SizedBox(height: 20),
              loading
                  ? SizedBox(
                      height: 25,
                      width: 25,
                      child: const CircularProgressIndicator(
                        color: CColors.black,
                      ),
                    )
                  : CustomButton(
                      text: "Login",
                      widthFactor: 1.5,
                      gradientColors: [Colors.black, Colors.black],
                      textColor: CColors.white,
                      onPressed: loading ? () {} : _login,
                      // child: loading
                      //     ? const CircularProgressIndicator(color: Colors.white)
                      //     : const Text('Login'),
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.signupRoute,
                  (route) => false,
                ),
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(
                    fontSize: 16,
                    color: CColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
