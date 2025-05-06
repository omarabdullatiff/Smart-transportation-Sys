// import 'package:flutter/material.dart';
//
// class CustomTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final bool isPassword;
//   final TextInputType keyboardType;
//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.label,
//     required this.hint,
//     this.isPassword = false,
//     this.keyboardType = TextInputType.text,
//   });
//
//   @override
//   _CustomTextFieldState createState() => _CustomTextFieldState();
// }
//
// class _CustomTextFieldState extends State<CustomTextField> {
//   late bool _obscureText;
//
//   @override
//   void initState() {
//     super.initState();
//     _obscureText = widget.isPassword;
//   }
//
//   void setVisibility(bool visible) {
//     if (widget.isPassword) {
//       setState(() {
//         _obscureText = !visible;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.7),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: widget.controller,
//         obscureText: _obscureText,
//         keyboardType: widget.keyboardType,
//         decoration: InputDecoration(
//           labelText: widget.label,
//           hintText: widget.hint,
//           labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
//           hintStyle: TextStyle(color: Colors.grey.shade400),
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFF91A800), width: 2),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//           prefixIcon: widget.isPassword
//               ? IconButton(
//             icon: Icon(
//               _obscureText ? Icons.visibility_off : Icons.visibility,
//               color: Colors.grey,
//             ),
//             onPressed: () => setState(() => _obscureText = !_obscureText),
//           )
//               : null,
//         ),
//         style: const TextStyle(fontSize: 16, color: Colors.black),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType ??
            (widget.isPassword ? TextInputType.text : TextInputType.text),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF91A800), width: 2),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
