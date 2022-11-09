import 'package:dicoding_restaurant/login/login_qubit.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var userController = TextEditingController();
  var passController = TextEditingController();

  bool isShown = false;

  var loginCubit = LoginCubit();

  @override
  void dispose() {
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Login page")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userController,
                autocorrect: false,
                decoration: const InputDecoration(
                    labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passController,
                obscureText: !isShown,
                autocorrect: false,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        // iconSize: 20,
                        onPressed: () {
                          setState(() {
                            isShown = !isShown;
                          });
                        },
                        icon: isShown
                            ? const Icon(Icons.remove_red_eye)
                            : const Icon(Icons.remove_red_eye_outlined)),
                    labelText: 'Password',
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    loginCubit.login(userController.text, passController.text);
                  },
                  child: const Text('Login'))
            ],
          ),
        ));
  }
}
