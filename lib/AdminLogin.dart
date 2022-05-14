// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:svs/Global.dart';
import 'package:svs/HomePage.dart';
import 'package:svs/testFile.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({Key? key}) : super(key: key);

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController userName = TextEditingController();
  TextEditingController passWord = TextEditingController();
  CollectionReference admins = FirebaseFirestore.instance.collection('Admins');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Secure Voting System',
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: TextFormField(
                  style: getTextInputStyle(),
                  maxLength: 20,
                  enabled: true,
                  controller: userName,
                  keyboardType: TextInputType.text,
                  decoration: getInputDecoration(
                      'Enter username',
                      Icon(
                        Icons.person,
                        color: textColor,
                      )))),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: TextFormField(
                  style: getTextInputStyle(),
                  maxLength: 20,
                  enabled: true,
                  controller: passWord,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: getInputDecoration(
                      'Enter password',
                      Icon(
                        Icons.person,
                        color: textColor,
                      )))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                    primary: Colors.black,
                    backgroundColor: tertiaryColor,
                    onSurface: Colors.black,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)))),
                onPressed: () {
                  EasyLoading.show(
                    maskType: EasyLoadingMaskType.clear,
                    status: 'Loggin in...',
                  );
                  if (userName.text.length > 3 && passWord.text.length > 3) {
                    admins
                        .where('userName', isEqualTo: userName.text)
                        .where('passWord', isEqualTo: passWord.text)
                        .limit(1)
                        .get()
                        .then((value) {
                      if (value.docs.length == 1) {
                        EasyLoading.dismiss();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      } else {
                        EasyLoading.dismiss();
                        Fluttertoast.showToast(
                            msg: "Admin Username/ Password not correct",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.black,
                            fontSize: 16.0);
                      }
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(100, 10, 100, 10),
                  child: Text(
                    'Proceed',
                    style: TextStyle(color: textColor, fontSize: 20),
                  ),
                )),
          )
        ],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          mainColor,
          secondaryColor,
        ],
      )),
    ));
  }
}
