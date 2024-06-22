import 'package:flutter/material.dart';

class AdContainer extends StatelessWidget {

  final String text;
  final String description;
  final Gradient? gradient;
  final double height;

  const AdContainer({
    super.key,
    required this.text,
    required this.description,
    this.gradient,
    this.height = 300
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            spreadRadius: 10,
            blurRadius: 20,
          )
        ]
      ),
      width: MediaQuery.of(context).size.width,
      height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(text, 
              style: const TextStyle(fontSize: 30,fontWeight: FontWeight.bold)
            ),
    
            const SizedBox(height: 10),
    
            Text(description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15)
            ),
    
            const SizedBox(height: 10),
    
            ElevatedButton(
              onPressed: (){},
              child: const Text('Some action button', style: TextStyle(color: Colors.black))
            ),
            TextButton(onPressed: (){}, child: const Text('Another action', style: TextStyle(fontWeight: FontWeight.bold)))
          ],
        )
    );
  }
}