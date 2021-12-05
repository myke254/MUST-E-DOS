import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:office_of_the_dean/screens/signin.dart';
import 'package:office_of_the_dean/services/auth_service.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        height: size.height,
        width: size.width,
        //color: Colors.blueGrey,
        child: SettingsList(
          sections: [
            SettingsSection(
              //title: 'Section',
              tiles: [
                SettingsTile(
                  title: 'Language',
                  subtitle: 'English',
                  leading: Icon(Icons.language),
                  onPressed: (BuildContext context) {},
                ),
                SettingsTile(
                    leading: Icon(iconData),
                    title: 'Theme',
                    subtitle: themeNotifier.getThemeMode() == ThemeMode.dark
                        ? 'dark theme'
                        : 'light theme',
                    onPressed: (val) {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(40)),
                              content: Material(
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RadioListTile(
                                      title: const Text('light theme'),
                                      value: ThemeMode.light,
                                      groupValue: themeNotifier.getThemeMode(),
                                      onChanged: (value) {
                                        print(value);
                                        getTheme();
                                        Navigator.of(context).pop();
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                    RadioListTile(
                                      title: const Text('Dark theme'),
                                      value: ThemeMode.dark,
                                      groupValue: themeNotifier.getThemeMode(),
                                      onChanged: (value) {
                                        print(value);
                                        getTheme();
                                        Navigator.of(context).pop();
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    }),
                SettingsTile(
                  subtitleTextStyle: GoogleFonts.varela(fontSize: 10),
                  title: 'LogOut',
                  subtitle: 'signed in as ${_user!.email}',
                  leading: Icon(Icons.logout),
                  onPressed: (BuildContext context) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(40)),
                            title: Text(
                              'You are signed in as ${_user!.email}',
                              style: GoogleFonts.aBeeZee(fontSize: 14),
                            ),
                            content: Text(
                              'SignOut?',
                              style: GoogleFonts.aBeeZee(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'stay',
                                    style: GoogleFonts.aBeeZee(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  )),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  AuthService().signOut();
                                },
                                child: Text(
                                  'SignOut',
                                  style: GoogleFonts.aBeeZee(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              )
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
