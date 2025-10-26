import 'package:flutter/material.dart';
import 'package:socialmedia/app/constants/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double widthFactor;
  final VoidCallback onPressed;
  final List<Color>? gradientColors;
  final double borderRadius;
  final Color textColor;
  final FontWeight fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    required this.widthFactor,
    required this.onPressed,
    this.gradientColors,
    this.borderRadius = 15,
    this.textColor = CColors.black,
    this.fontWeight = FontWeight.w900,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.width / 8,
      width: size.width / widthFactor,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  gradientColors ??
                  [
                    const Color.fromARGB(255, 255, 99, 9),
                    const Color.fromARGB(255, 255, 9, 9).withOpacity(0.4),
                  ],
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: size.width * 0.036,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
