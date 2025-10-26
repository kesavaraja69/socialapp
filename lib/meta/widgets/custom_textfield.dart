import 'package:flutter/material.dart';
import 'package:socialmedia/app/constants/constants.dart';

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool isPassword;
  final bool isEmail;
  final FormFieldValidator<String>? validator;
  final TextEditingController controller;
  final ValueNotifier<bool> _obscureNotifier = ValueNotifier<bool>(true);

  CustomTextField({
    super.key,
    required this.icon,
    required this.hintText,
    required this.validator,
    this.isPassword = false,
    this.isEmail = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size.width,
        alignment: Alignment.center,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 48, 48, 48),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ValueListenableBuilder<bool>(
            valueListenable: _obscureNotifier,
            builder: (context, obscure, _) {
              return TextFormField(
                style: TextStyle(
                  color: Colors.white.withOpacity(.8),
                  fontSize: 17,
                ),
                controller: controller,
                obscureText: isPassword ? obscure : false,
                validator: validator,
                keyboardType: isEmail
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: Colors.white.withOpacity(.7)),
                  suffixIcon: isPassword
                      ? IconButton(
                          onPressed: () {
                            _obscureNotifier.value = !_obscureNotifier.value;
                          },
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white.withOpacity(.5),
                          ),
                        )
                      : const SizedBox(),
                  border: InputBorder.none,

                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(
                      255,
                      192,
                      192,
                      193,
                    ).withOpacity(.7),
                  ),
                  errorStyle: const TextStyle(
                    height: 0.6,
                    fontSize: 12,
                    color: CColors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
