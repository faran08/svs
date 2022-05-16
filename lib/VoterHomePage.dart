// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:group_button/group_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'Global.dart';

class VoterHomePage extends StatefulWidget {
  const VoterHomePage({Key? key}) : super(key: key);

  @override
  State<VoterHomePage> createState() => _VoterHomePageState();
}

class _VoterHomePageState extends State<VoterHomePage> {
  String voterName = '';
  String voterFather = '';
  String voterDOB = '';
  String regionNumber = '';
  String downloadURL = '';
  bool visibe = false;
  String votingKeyString = '';
  String documentID = '';
  bool voterRegistered = false;
  final GlobalKey genKeyOne = GlobalKey();
  final GlobalKey genKeyTwo = GlobalKey();
  final picker = ImagePicker();
  Widget finalCryptoImage = Container();

  TextEditingController searchVoter = TextEditingController();
  TextEditingController votingKey = TextEditingController();
  CollectionReference voters = FirebaseFirestore.instance.collection('Voters');
  CollectionReference votes = FirebaseFirestore.instance.collection('Votes');
  CollectionReference regions =
      FirebaseFirestore.instance.collection('Regions');
  CollectionReference globals =
      FirebaseFirestore.instance.collection('Globals');
  bool votingStatus = false;

  Future<void> takePictureOne() async {
    RenderRepaintBoundary boundary =
        genKeyOne.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    File imgFile = File('$directory/photoOne.png');
    setState(() {
      imgFile.writeAsBytes(pngBytes).then((value) {
        Permission.photos.request().then(
          (value) {
            if (value.isGranted) {
              getApplicationDocumentsDirectory().then((value) {
                GallerySaver.saveImage('$directory/photoOne.png',
                        albumName: DateTime.now().toString())
                    .then((value) {
                  Fluttertoast.showToast(
                      msg: "Image Saved!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey,
                      textColor: Colors.black,
                      fontSize: 16.0);
                });
              });
            } else {
              openAppSettings();
            }
          },
        );
      });
    });
  }

  Future<ui.Image> loadUiImage(String url) async {
    final response = await http.get(Uri.parse(url));
    response.bodyBytes;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(response.bodyBytes, completer.complete);
    return completer.future;
  }

  void getImage(StateSetter myState) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final getPath = await getApplicationDocumentsDirectory();
    String path = getPath.path;
    if (pickedFile != null) {
      try {
        EasyLoading.show(
          maskType: EasyLoadingMaskType.clear,
          status: 'Merging Images',
        );
        loadUiImage(downloadURL).then((value) {
          ui.Image _two = value;
          Image _one = Image.memory(File(pickedFile.path).readAsBytesSync());
          myState(() {
            finalCryptoImage = ShaderMask(
              blendMode: BlendMode.multiply,
              shaderCallback: (bounds) => ImageShader(
                _two,
                TileMode.clamp,
                TileMode.clamp,
                Matrix4.identity().storage,
              ),
              child: _one,
            );
          });
          EasyLoading.dismiss();
        });
      } catch (e) {
        EasyLoading.dismiss();
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> takePictureTwo() async {
    EasyLoading.show(
      maskType: EasyLoadingMaskType.clear,
      status: 'Uploading Image',
    );
    RenderRepaintBoundary boundary =
        genKeyTwo.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    File imgFile = File('$directory/photoTwo.png');
    setState(() {
      imgFile.writeAsBytes(pngBytes).then((value) {
        uploadFile(value);
      });
    });
  }

  Future uploadFile(File uploadImageFile) async {
    String refString = '/cryptoImages/' + getRandomString(10);
    Reference storageReference =
        FirebaseStorage.instance.ref().child(refString);
    try {
      storageReference.putFile(uploadImageFile).then((p0) {
        p0.ref.getDownloadURL().then((value) {
          voters.doc(documentID).update({'downloadURL': value});
          EasyLoading.dismiss();
          Navigator.of(context).pop();
        });
      });
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  String getRandomString(int length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

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
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            mainColor,
            secondaryColor,
          ],
        )),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: 50,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: Text(
                    'Secure Voting Application',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: votingStatus
                  ? Text(
                      'Voting Has Started',
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    )
                  : Text(
                      'Voting Has Not Started',
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 20,
                          fontWeight: FontWeight.w900),
                    ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: TextFormField(
                    style: getTextInputStyle(),
                    maxLength: 20,
                    enabled: true,
                    controller: searchVoter,
                    keyboardType: TextInputType.text,
                    decoration: getInputDecoration(
                        'Enter your registration number',
                        Icon(
                          Icons.numbers,
                          color: textColor,
                        )))),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        primary: Colors.black,
                        backgroundColor: tertiaryColor,
                        onSurface: Colors.black,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20)))),
                    onPressed: () {
                      voters
                          .where('voterIdentity', isEqualTo: searchVoter.text)
                          .limit(1)
                          .get()
                          .then((value) {
                        setState(() {
                          votingKeyString =
                              (value.docs.first.data() as Map)['cryptoKey'];
                          documentID = value.docs.first.id;
                          downloadURL =
                              (value.docs.first.data() as Map)['downloadURL'];
                          voterRegistered =
                              (value.docs.first.data() as Map)['registered'];
                          voterName =
                              (value.docs.first.data() as Map)['voterName'];
                          voterFather =
                              (value.docs.first.data() as Map)['fatherName'];
                          voterDOB = DateFormat('EEE, dd MMM, yyyy')
                              .format(DateTime.fromMillisecondsSinceEpoch(
                                  (value.docs.first.data() as Map)['DOB']
                                      .millisecondsSinceEpoch))
                              .toString();
                          regionNumber =
                              (value.docs.first.data() as Map)['regionNumber'];
                          visibe = true;
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(100, 10, 100, 10),
                      child: Text(
                        'Search',
                        style: TextStyle(color: textColor, fontSize: 20),
                      ),
                    )),
              ),
            ),
            visibe
                ? GestureDetector(
                    onTap: () {
                      if (voterRegistered) {
                        EasyLoading.show(
                            maskType: EasyLoadingMaskType.clear,
                            status: 'Loading Election Data');
                        String selectedParty = '';
                        List<String> nameOfParties = [];
                        regions
                            .where('regionNumber', isEqualTo: regionNumber)
                            .limit(1)
                            .get()
                            .then((value) {
                          for (var item in (value.docs.first.data()
                              as Map)['nameOfParties']) {
                            nameOfParties.add(item);
                          }
                          EasyLoading.dismiss();
                          if (votingStatus) {
                            TextEditingController votingKey =
                                TextEditingController();
                            showCupertinoModalBottomSheet(
                              topRadius: const Radius.circular(25),
                              backgroundColor: Colors.red,
                              duration: const Duration(milliseconds: 500),
                              elevation: 1,
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context, imageState) {
                                  return Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: Scaffold(
                                        resizeToAvoidBottomInset: false,
                                        appBar: AppBar(
                                          toolbarHeight: 70.0,
                                          elevation: 10,
                                          leadingWidth: 50,
                                          leading: IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                finalCryptoImage = Container();
                                                votingKey.text = '';
                                              },
                                              icon: Icon(
                                                Icons
                                                    .arrow_back_ios_new_rounded,
                                                color: Colors.white,
                                              )),
                                          backgroundColor: Colors.black,
                                          title: Text(
                                            'Submit Your Vote',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ),
                                        body: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                color: Colors.red),
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        20, 20, 20, 10),
                                                    child: TextButton(
                                                        style: TextButton.styleFrom(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    0, 12, 0, 12),
                                                            primary:
                                                                Colors.black,
                                                            backgroundColor:
                                                                Colors.yellow,
                                                            onSurface:
                                                                Colors.black,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20)))),
                                                        onPressed: () {
                                                          getImage(imageState);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  100,
                                                                  10,
                                                                  100,
                                                                  10),
                                                          child: Text(
                                                            'Get Image',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20),
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                                finalCryptoImage,
                                                Text(
                                                  'Image should be selected to generate key!',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        20, 50, 20, 0),
                                                    child: TextFormField(
                                                        style:
                                                            getTextInputStyle(),
                                                        maxLength: 20,
                                                        enabled: true,
                                                        controller: votingKey,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        decoration:
                                                            getInputDecoration(
                                                                'Enter Key',
                                                                Icon(
                                                                  Icons.numbers,
                                                                  color:
                                                                      textColor,
                                                                )))),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 0, 10),
                                                  child: Text(
                                                    'Select Party To Vote',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                GroupButton(
                                                  // controller: controller,
                                                  options: GroupButtonOptions(
                                                      buttonWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.2,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)),
                                                      crossGroupAlignment:
                                                          CrossGroupAlignment
                                                              .start,
                                                      groupRunAlignment:
                                                          GroupRunAlignment
                                                              .start,
                                                      mainGroupAlignment:
                                                          MainGroupAlignment
                                                              .start,
                                                      direction: Axis.vertical,
                                                      textAlign: TextAlign.left,
                                                      alignment:
                                                          Alignment.center),
                                                  buttons: nameOfParties,
                                                  isRadio: true,
                                                  onSelected:
                                                      (value, int, bool) {
                                                    setState(() {
                                                      selectedParty =
                                                          value!.toString();
                                                      print(selectedParty);
                                                    });
                                                  },
                                                ),
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        20, 20, 20, 0),
                                                    child: TextButton(
                                                        style: TextButton.styleFrom(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    0, 12, 0, 12),
                                                            primary:
                                                                Colors.black,
                                                            backgroundColor:
                                                                Colors.yellow,
                                                            onSurface:
                                                                Colors.black,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20)))),
                                                        onPressed: () {
                                                          if (votingKey.text ==
                                                              votingKeyString) {
                                                            print(
                                                                'voting key match');
                                                            votes
                                                                .where(
                                                                    'voteCastedBy',
                                                                    isEqualTo:
                                                                        searchVoter
                                                                            .text)
                                                                .get()
                                                                .then((value) {
                                                              if (value.docs
                                                                  .isEmpty) {
                                                                votes.add({
                                                                  'regionNumber':
                                                                      regionNumber,
                                                                  'voteCastedTo':
                                                                      selectedParty,
                                                                  'voteCastedBy':
                                                                      searchVoter
                                                                          .text
                                                                }).then(
                                                                    (value) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                });
                                                              } else {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        'Vote Already Casted',
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .BOTTOM,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey,
                                                                    textColor:
                                                                        Colors
                                                                            .black,
                                                                    fontSize:
                                                                        16.0);
                                                              }
                                                            });
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    'Keys donot match. If key not generated, generated key !',
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                textColor:
                                                                    Colors
                                                                        .black,
                                                                fontSize: 16.0);
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  100,
                                                                  10,
                                                                  100,
                                                                  10),
                                                          child: Text(
                                                            'Cast Vote',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 20),
                                                          ),
                                                        )),
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Voting Has Not Started Yet',
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
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Center(
                        child: PhysicalModel(
                          elevation: 8,
                          shadowColor: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                          color: backGrColorText,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            width: MediaQuery.of(context).size.width / 1,
                            decoration: BoxDecoration(
                                color: backGrColorText,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Align(
                              alignment: Alignment.center,
                              child: ListTile(
                                title: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                    voterName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: textColor),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Son of: ' +
                                            voterFather +
                                            '\n' +
                                            'Born on: ' +
                                            voterDOB +
                                            '\n' +
                                            'Voting Region: ' +
                                            regionNumber +
                                            '\n' +
                                            'Registered to Vote: ' +
                                            voterRegistered.toString(),
                                        style: TextStyle(
                                            fontSize: 15, color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
            visibe
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                              primary: Colors.black,
                              backgroundColor: Colors.yellow,
                              onSurface: Colors.black,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)))),
                          onPressed: () {
                            if (!voterRegistered) {
                              EasyLoading.show(
                                maskType: EasyLoadingMaskType.clear,
                                status: 'Generating Visual Crypto',
                              );
                              String key = getRandomString(6);

                              voters
                                  .doc(documentID)
                                  .update({'registered': true}).then((value) {
                                Fluttertoast.showToast(
                                    msg: 'Voter Registered',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.black,
                                    fontSize: 16.0);
                                EasyLoading.dismiss();
                                showCupertinoModalBottomSheet(
                                  topRadius: const Radius.circular(25),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(milliseconds: 500),
                                  elevation: 1,
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context, imageState) {
                                      return Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 10),
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              1.1,
                                          child: Scaffold(
                                            appBar: AppBar(
                                              toolbarHeight: 70.0,
                                              elevation: 10,
                                              leadingWidth: 50,
                                              leading: IconButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  icon: Icon(
                                                    Icons
                                                        .arrow_back_ios_new_rounded,
                                                    color: Colors.white,
                                                  )),
                                              backgroundColor: Colors.black,
                                              title: Text(
                                                'Secure Visual Crypto',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ),
                                            body: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                    color: Colors.red),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 10, 0, 0),
                                                      child: RepaintBoundary(
                                                        key: genKeyOne,
                                                        child: Container(
                                                          width: 200,
                                                          height: 100,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          20))),
                                                          child: Center(
                                                            child: Text(
                                                              key[0] +
                                                                  '     ' +
                                                                  key[2] +
                                                                  '     ' +
                                                                  key[4] +
                                                                  '     ',
                                                              style: TextStyle(
                                                                  fontSize: 25,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                20, 20, 20, 0),
                                                        child: TextButton(
                                                            style: TextButton.styleFrom(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        12,
                                                                        0,
                                                                        12),
                                                                primary:
                                                                    Colors
                                                                        .black,
                                                                backgroundColor:
                                                                    Colors
                                                                        .yellow,
                                                                onSurface:
                                                                    Colors
                                                                        .black,
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20)))),
                                                            onPressed: () {
                                                              EasyLoading.show(
                                                                maskType:
                                                                    EasyLoadingMaskType
                                                                        .clear,
                                                                status:
                                                                    'Processing',
                                                              );
                                                              voters
                                                                  .doc(
                                                                      documentID)
                                                                  .update({
                                                                'cryptoKey': key
                                                              }).then(
                                                                (value) {
                                                                  if (defaultTargetPlatform ==
                                                                          TargetPlatform
                                                                              .iOS ||
                                                                      defaultTargetPlatform ==
                                                                          TargetPlatform
                                                                              .android) {
                                                                    takePictureOne();
                                                                    takePictureTwo();
                                                                  } else if (defaultTargetPlatform == TargetPlatform.linux ||
                                                                      defaultTargetPlatform ==
                                                                          TargetPlatform
                                                                              .macOS ||
                                                                      defaultTargetPlatform ==
                                                                          TargetPlatform
                                                                              .windows) {
                                                                    // Some desktop specific code there
                                                                  } else {
                                                                    // Some web specific code there
                                                                  }
                                                                },
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      100,
                                                                      10,
                                                                      100,
                                                                      10),
                                                              child: Text(
                                                                'Save Key',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                            )),
                                                      ),
                                                    ),
                                                    // Visibility(
                                                    //     visible: false,
                                                    //     child: )
                                                    Stack(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 20, 0, 0),
                                                          child:
                                                              RepaintBoundary(
                                                            key: genKeyTwo,
                                                            child: Container(
                                                              width: 200,
                                                              height: 100,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius: const BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          20))),
                                                              child: Center(
                                                                child: Text(
                                                                  '     ' +
                                                                      key[1] +
                                                                      '     ' +
                                                                      key[3] +
                                                                      '     ' +
                                                                      key[5],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          25,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 20, 0, 0),
                                                          child: Container(
                                                            width: 200,
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            20))),
                                                            child: Container(),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                );
                              });
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Already Registered',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey,
                                  textColor: Colors.black,
                                  fontSize: 16.0);
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(100, 10, 100, 10),
                            child: Text(
                              'Register as Voter',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          )),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
