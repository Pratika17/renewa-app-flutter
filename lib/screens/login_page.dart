import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:renewa/screens/contactus_page.dart';
import 'package:renewa/screens/register_page.dart';



class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Renewa-bg.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 30,
            right: 30,
            child: Column(
              children: [
                const SizedBox(height: 30,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactUsScreen()),
                    );
                  },
                  child: const Text('Contact Us'),
                ),
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 14, 45, 14)),
                          ),
                          const SizedBox(height: 20),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 19, 43, 30)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 15, 45, 14)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 21, 45, 27)),
                              ),
                            ),
                            style: TextStyle(color: Color.fromARGB(255, 18, 44, 26)),
                          ),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Color.fromARGB(255, 18, 42, 27)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 20, 47, 26)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(255, 20, 42, 22)),
                              ),
                            ),
                            obscureText: true,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: false,
                                    onChanged: (value) {},
                                    checkColor: Colors.white,
                                    fillColor: WidgetStateProperty.all(Colors.white),
                                  ),
                                  Text('Remember me', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text('Forgot Password?', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Login'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const RegistrationScreen(),
                              ));
                            },
                            child: Text("Don't have an account? Register", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}