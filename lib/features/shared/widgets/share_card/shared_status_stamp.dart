import 'package:flutter/material.dart';

class SharedStatusStamp extends StatelessWidget {
 const SharedStatusStamp({
 super.key,
 required this.text,
 required this.color,
 this.showCheck = false,
 });

 final String text;
 final Color color;
 final bool showCheck;

 @override
 Widget build(BuildContext context) {
 return Row(
 mainAxisSize: MainAxisSize.min,
 children: [
 if (showCheck)
 Padding(
 padding: const EdgeInsets.only(right: 3),
 child: Icon(Icons.done_rounded, size: 11, color: color.withOpacity(0.65)),
 ),
 Text(
 text,
 style: TextStyle(
 fontSize: 10,
 fontWeight: FontWeight.w600,
 fontStyle: FontStyle.italic,
 letterSpacing: 0.2,
 color: color.withOpacity(0.9),
 ),
 ),
 ],
 );
 }
}