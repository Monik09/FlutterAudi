import 'package:chhabrain_task_songslistener/screens/home.dart';
import 'package:chhabrain_task_songslistener/utils/authentication.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/loginScreen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailInput = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String phnNumber;
  TextEditingController _passwordInput = TextEditingController();
  TextEditingController _confirmPasswordInput = TextEditingController();
  Authentication authentication = Authentication();
  String password, cPassword;
  bool isLogin = true;

  @override
  void dispose() {
    _emailInput.dispose();
    _confirmPasswordInput.dispose();
    _passwordInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.085,
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SizedBox(
                  width: 320,
                  height: 240,
                  child: Image.asset(
                    "assets/happyMusic.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                "Chhabrain Music",
                style: TextStyle(
                    color: Color(0xff264653),
                    fontSize: 50,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        controller: _emailInput,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          suffixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        validator: (val) {
                          print(val);
                          return (!val.contains("@")) ? "Invalid Email" : null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextFormField(
                        controller: _passwordInput,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          suffixIcon: Icon(Icons.visibility_off),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                        onEditingComplete: () {
                          setState(() {
                            password = _passwordInput.value.text.toString();
                          });
                        },
                        validator: (val) {
                          print(val);
                          return (val.length <= 7)
                              ? "Password must be greater than 6"
                              : null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (!isLogin)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          controller: _confirmPasswordInput,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            suffixIcon: Icon(Icons.visibility_off),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (val) {
                            print("oC----" + val);
                            setState(() {
                              cPassword = val;
                            });
                          },
                          onEditingComplete: () {
                            setState(() {
                              cPassword =
                                  _confirmPasswordInput.value.text.toString();
                            });
                          },
                          validator: (val) {
                            print(val);
                            print("Cp____________________________>$cPassword");
                            print("p____________________________>$password");
                            return (cPassword != password)
                                ? "Passwords dont match"
                                : null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                child: Text(isLogin ? 'Login' : "Sign up"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[800],
                ),
                onPressed: () async {
                  print(_emailInput.value);
                  print(_passwordInput.value);
                  if (_formKey.currentState.validate()) {
                    print(_emailInput.value);
                    print(_passwordInput.value);

                    String result = isLogin
                        ? await authentication.signIn(
                            _emailInput.value.text.toString().trim(),
                            _passwordInput.value.text.toString(),
                          )
                        : await authentication.register(
                            _emailInput.value.text.toString().trim(),
                            _passwordInput.value.text.toString(),
                          );
                    print(result);

                    if (result == "true") {
                      // Navigator.of(context).pushNamed(HomeScreen.routeName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("User Signed In Successfully"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pushNamed(Home.routeName);
                      // dispose();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result),
                        ),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 25.0),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text.rich(
                  TextSpan(
                      text: isLogin
                          ? 'Don\'t have an account '
                          : "Have an account? ",
                      children: [
                        TextSpan(
                          text: isLogin ? 'Signup' : "LogIn",
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ]),
                ),
              ),
              SizedBox(height: 55.0),
            ],
          ),
        ),
      ),
    );
  }
}
