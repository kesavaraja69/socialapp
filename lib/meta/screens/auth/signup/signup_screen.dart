import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/app/constants/constants.dart';
import 'package:socialmedia/app/routes/app_route.dart';
import 'package:socialmedia/core/notifiers/auth_provider.dart';
import 'package:socialmedia/meta/screens/auth/login/login_screen.dart';
import 'package:socialmedia/meta/widgets/custom_button.dart';
import 'package:socialmedia/meta/widgets/custom_snackbar.dart';
import 'package:socialmedia/meta/widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameC;
  late TextEditingController emailC;
  late TextEditingController passC;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController();
    emailC = TextEditingController();
    passC = TextEditingController();
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final res = await auth.signUp(
      name: nameC.text.trim(),
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
                'Sign up',
                style: TextStyle(
                  fontSize: 24,
                  color: CColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 17),
              CustomTextField(
                icon: Icons.person,
                hintText: "Enter your name",
                controller: nameC,

                validator: (v) => v == null || v.isEmpty ? ' Enter name' : null,
              ),
              const SizedBox(height: 12),
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
                      text: "Create account",
                      widthFactor: 1.5,
                      gradientColors: [CColors.black, CColors.black],
                      textColor: CColors.white,
                      onPressed: loading ? () {} : _signup,
                    ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text(
                  "Already have an account? Login here",
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
