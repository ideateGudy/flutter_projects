import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: const SafeArea(
        child: Column(
          children: [
            //logo
            Icon(
              Icons.lock,
              size: 100,
            ),
        
            //welcome back, you've been missed!
        
            //username textfield
        
            //password textfield
        
            //forgot password?
        
            //sign in button
        
            //or continue with
        
            //google + apple sign in buttons
        
            //not a member? register now
          ],
        ),
      ),
    );
  }
}