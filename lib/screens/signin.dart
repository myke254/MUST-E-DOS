import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:office_of_the_dean/services/auth_service.dart';
import 'package:office_of_the_dean/services/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/constants.dart';

IconData iconData = Icons.brightness_7;
late String themeMode;
late ThemeNotifier themeNotifier;
void onThemeChanged(String value) async {
  var prefs = await SharedPreferences.getInstance();
  if (value == Constants.SYSTEM_DEFAULT) {
    themeNotifier.setThemeMode(ThemeMode.system);
  } else if (value == Constants.DARK) {
    themeNotifier.setThemeMode(ThemeMode.dark);
  } else {
    themeNotifier.setThemeMode(ThemeMode.light);
  }
  prefs.setString(Constants.APP_THEME, value);
}

getTheme() async {
  var prefs = await SharedPreferences.getInstance();
  themeMode = prefs.getString(Constants.APP_THEME)!;
  onThemeChanged(themeMode == 'Dark' ? 'light' : 'Dark');
  themeMode == 'Dark'
      ? iconData = Icons.brightness_3_sharp
      : iconData = Icons.brightness_7;
}

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  late final AnimationController _controller;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  bool signIn = true;
  late LottieComposition _composition;
  logIn() {
    if (_formKey.currentState!.validate()) {
      signIn
          ? AuthService().signInWithEmailAndPassword(
              emailController.text, passController.text)
          : AuthService().signUpWithEmailAndPassword(
              emailController.text, passController.text);
    } else {
      Fluttertoast.showToast(msg: 'something went wrong');
    }
  }

  bool passObscureText = true;
  bool confirmPassObscureText = true;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white.withOpacity(0)
            : Colors.black.withOpacity(0),
        title: Text(
          'M.u.s.t E-D.O.S',
          style: GoogleFonts.medievalSharp(
              color: Theme.of(context).brightness != Brightness.dark
                  ? Colors.black
                  : Colors.white),
        ),
      ),
      body: Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.withOpacity(.2)
            : Colors.black.withOpacity(.3),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, right: 10),
              child: Align(
                alignment: Alignment.topRight,
                // child: Lottie.asset(
                //   'assets/52869-day-and-night-switch-button.json',
                //   controller: _controller,
                //   height: 50,
                //   width: 50,
                //   onLoaded: (composition) {
                //     setState(() {
                //       _composition = composition;
                //     });
                //     // Configure the AnimationController with the duration of the
                //     // Lottie file and start the animation.

                //     _controller
                //       ..duration = composition.duration
                //       ..forward();
                //   },
                // ),
              ),
            ),
            // Image.asset(
            //   'assets/gif.gif',
            //   height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            //   fit: BoxFit.fitHeight,
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 100, right: 10),
              child: Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                      onTap: () {
                        // print(_composition.durationFrames);
                        // _controller
                        //   ..duration = _composition.duration
                        //   ..forward(from: 1);
                        getTheme();
                      },
                      child: Icon(iconData))),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Image.asset(
                  'assets/must1.png',
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 90.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            signIn ? 'SignIn' : 'SignUp',
                            style: GoogleFonts.varela(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'email field should not be empty';
                              }
                              return null;
                            },
                            controller: emailController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                // fillColor: Colors.teal.withOpacity(.1),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.mail,
                                  size: 20,
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15))),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10.0,
                              right: 10.0,
                              bottom: signIn ? 0 : 10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: passObscureText,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'passwords should not be empty';
                              }
                              return null;
                            },
                            controller: passController,
                            textInputAction: signIn
                                ? TextInputAction.send
                                : TextInputAction.next,
                            onFieldSubmitted: signIn
                                ? (val) {
                                    logIn();
                                  }
                                : (val) {},
                            decoration: InputDecoration(
                                //  fillColor: Colors.teal.withOpacity(.1),
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (passObscureText) {
                                          passObscureText = false;
                                        } else {
                                          passObscureText = true;
                                        }
                                      });
                                    },
                                    icon: Icon(passObscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off)),
                                labelText: 'password',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15))),
                          ),
                        ),
                        signIn
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {},
                                    child: Text(
                                      'forgot password?',
                                      style: GoogleFonts.varelaRound(
                                          color: Colors.blue),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        !signIn
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.visiblePassword,
                                  validator: (value) {
                                    if (value != passController.text) {
                                      return 'passwords do not match';
                                    }
                                    return null;
                                  },
                                  controller: confirmPassController,
                                  obscureText: confirmPassObscureText,
                                  textInputAction: TextInputAction.send,
                                  onFieldSubmitted: (val) {
                                    logIn();
                                  },
                                  decoration: InputDecoration(
                                      //fillColor: Colors.teal.withOpacity(.1),
                                      filled: true,
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (confirmPassObscureText) {
                                                confirmPassObscureText = false;
                                              } else {
                                                confirmPassObscureText = true;
                                              }
                                            });
                                          },
                                          icon: Icon(confirmPassObscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off)),
                                      labelText: 'confirm password',
                                      labelStyle: TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15))),
                                ),
                              )
                            : SizedBox(),
                        Divider(
                          indent: 50,
                          endIndent: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.red
                                    : Colors.blue,
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: logIn,
                              child: SizedBox(
                                height: 50,
                                width: 250,
                                child: Center(
                                  child: Text(
                                    signIn ? 'SignIn' : 'SignUp',
                                    style: GoogleFonts.monda(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: InkWell(
                            onTap: () {
                              emailController.clear();
                              passController.clear();
                              confirmPassController.clear();
                              setState(() {
                                if (signIn) {
                                  signIn = false;
                                } else {
                                  signIn = true;
                                }
                              });
                            },
                            child: Text(
                              signIn
                                  ? 'No account? Register'
                                  : 'Already have an account? SignIn',
                              style: GoogleFonts.varelaRound(
                                  color: signIn ? Colors.blue : Colors.green),
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
