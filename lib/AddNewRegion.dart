// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:svs/Global.dart';

class AddNewRegion extends StatefulWidget {
  const AddNewRegion({Key? key}) : super(key: key);

  @override
  State<AddNewRegion> createState() => AddNewRegionState();
}

class AddNewRegionState extends State<AddNewRegion> {
  CollectionReference regions =
      FirebaseFirestore.instance.collection('Regions');
  // GlobalKey<AutoCompleteTextFieldState<String>> schoolKey = GlobalKey();
  TextEditingController regionName = TextEditingController();
  TextEditingController regionNumber = TextEditingController();
  TextEditingController numberOfParties = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: globalDecoration,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: Text(
                'Register New Region',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: TextFormField(
                    style: getTextInputStyle(),
                    maxLength: 20,
                    enabled: true,
                    controller: regionName,
                    keyboardType: TextInputType.text,
                    decoration: getInputDecoration(
                        'Enter Region Name',
                        Icon(
                          Icons.area_chart_rounded,
                          color: textColor,
                        )))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextFormField(
                    style: getTextInputStyle(),
                    maxLength: 20,
                    enabled: true,
                    controller: regionNumber,
                    keyboardType: TextInputType.text,
                    decoration: getInputDecoration(
                        'Enter Region Number',
                        Icon(
                          Icons.app_registration_rounded,
                          color: textColor,
                        )))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextFormField(
                    style: getTextInputStyle(),
                    maxLength: 20,
                    enabled: true,
                    controller: numberOfParties,
                    keyboardType: TextInputType.number,
                    decoration: getInputDecoration(
                        'Enter Number of Parties',
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
                      if (regionName.text.length > 3 &&
                          regionNumber.text.length > 3 &&
                          numberOfParties.text.isNotEmpty) {
                        showCupertinoModalBottomSheet(
                          topRadius: const Radius.circular(25),
                          backgroundColor: Colors.red,
                          duration: const Duration(milliseconds: 500),
                          elevation: 1,
                          enableDrag: false,
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                                builder: (BuildContext context, imageState) {
                              List<TextEditingController> inputParties =
                                  List.generate(int.parse(numberOfParties.text),
                                      (index) => TextEditingController());
                              return Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 1.1,
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
                                            Icons.arrow_back_ios_new_rounded,
                                            color: Colors.white,
                                          )),
                                      backgroundColor: Colors.black,
                                      title: Text(
                                        'Add Parties For Region',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    body: Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            mainColor,
                                            secondaryColor,
                                          ],
                                        )),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                                child: ListView.builder(
                                                    itemCount: int.parse(
                                                        numberOfParties.text),
                                                    itemBuilder:
                                                        ((context, index) {
                                                      return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 10, 20, 0),
                                                          child: TextFormField(
                                                              style:
                                                                  getTextInputStyle(),
                                                              maxLength: 20,
                                                              enabled: true,
                                                              controller:
                                                                  inputParties[
                                                                      index],
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              decoration:
                                                                  getInputDecoration(
                                                                      'Enter Party no ' +
                                                                          (index + 1)
                                                                              .toString() +
                                                                          ' Name',
                                                                      Icon(
                                                                        Icons
                                                                            .person_pin_circle_rounded,
                                                                        color:
                                                                            textColor,
                                                                      ))));
                                                    }))),
                                            Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 0, 20, 50),
                                                child: TextButton(
                                                    style: TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 12, 0, 12),
                                                        primary: Colors.black,
                                                        backgroundColor:
                                                            tertiaryColor,
                                                        onSurface: Colors.black,
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        20)))),
                                                    onPressed: () {
                                                      int sum = 0;
                                                      List<String>
                                                          inputPartyString = [];
                                                      for (var item
                                                          in inputParties) {
                                                        inputPartyString
                                                            .add(item.text);
                                                        if (item.text.length >
                                                            1) {
                                                          sum++;
                                                        }
                                                        if (sum >=
                                                            inputParties
                                                                .length) {
                                                          EasyLoading.show(
                                                            maskType:
                                                                EasyLoadingMaskType
                                                                    .clear,
                                                            status:
                                                                'Saving Region',
                                                          );
                                                          regions.add({
                                                            'regionName':
                                                                regionName.text,
                                                            'regionNumber':
                                                                regionNumber
                                                                    .text,
                                                            'numberOfParties':
                                                                numberOfParties
                                                                    .text,
                                                            'nameOfParties':
                                                                inputPartyString,
                                                            'timeCreated':
                                                                Timestamp.now(),
                                                          }).then((value) {
                                                            EasyLoading
                                                                .dismiss();
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    'Region Registered',
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
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        }
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          100, 10, 100, 10),
                                                      child: Text(
                                                        'Register',
                                                        style: TextStyle(
                                                            color: textColor,
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
                            msg: 'Incorrect Data Entry',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.black,
                            fontSize: 16.0);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(100, 10, 100, 10),
                      child: Text(
                        'Proceed',
                        style: TextStyle(color: textColor, fontSize: 20),
                      ),
                    )),
              ),
            )
          ],
        )),
      ),
    );
  }
}
