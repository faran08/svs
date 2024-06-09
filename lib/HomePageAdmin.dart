// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:svs/AdminLogin.dart';

import 'Global.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  CollectionReference globals =
      FirebaseFirestore.instance.collection('Globals');
  bool votingStatus = false;
  @override
  void initState() {
    EasyLoading.show(
      maskType: EasyLoadingMaskType.clear,
      status: 'Loading Voting Status',
    );
    globals.doc('VotingStatus').get().then((value) {
      setState(() {
        votingStatus = (value.data() as Map)['votingEnabled'];
        EasyLoading.dismiss();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.asset('assets/backgr.jpg').image,
                colorFilter: ColorFilter.mode(
                    Colors.blueAccent.shade100, BlendMode.darken),
                fit: BoxFit.fill)
            //     gradient: LinearGradient(
            //   begin: Alignment.topRight,
            //   end: Alignment.bottomLeft,
            //   colors: [
            //     mainColor,
            //     secondaryColor,
            //   ],
            // )),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 70, 0, 0),
                  child: Text(
                    'Home Page',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
                  child: IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => AdminLogin())));
                      },
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: 30,
                      )),
                )
              ],
            ),
            Center(
              child: ClipOval(
                child: SizedBox.fromSize(
                  size: Size.fromRadius(100), // Image radius
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        primary: Colors.black,
                        backgroundColor: secondaryColor,
                        onSurface: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20)))),
                    onPressed: () {
                      if (votingStatus) {
                        globals
                            .doc('VotingStatus')
                            .update({'votingEnabled': false}).then((value) {
                          setState(() {
                            votingStatus = false;
                          });
                        });
                      } else {
                        globals
                            .doc('VotingStatus')
                            .update({'votingEnabled': true}).then((value) {
                          setState(() {
                            votingStatus = true;
                          });
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(100, 10, 100, 10),
                      child: Text(
                        votingStatus ? 'Disable Voting' : 'Enable Voting',
                        style: TextStyle(color: textColor, fontSize: 20),
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
