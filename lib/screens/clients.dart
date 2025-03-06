import 'package:flutter/material.dart';

class Clients extends StatelessWidget{
  const Clients({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Clients")
      ),
      body: Center(child: Text("Clients Screen")),
    );
  }


}