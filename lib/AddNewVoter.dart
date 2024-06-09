// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'Global.dart';

class AddNewVoter extends StatefulWidget {
  const AddNewVoter({Key? key}) : super(key: key);

  @override
  State<AddNewVoter> createState() => _AddNewVoterState();
}

class _AddNewVoterState extends State<AddNewVoter> {
  GlobalKey<AutoCompleteTextFieldState<String>> schoolKey = GlobalKey();
  CollectionReference regions =
      FirebaseFirestore.instance.collection('Regions');
  CollectionReference voters = FirebaseFirestore.instance.collection('Voters');
  TextEditingController regionNumberController = TextEditingController();
  TextEditingController voterName = TextEditingController();
  TextEditingController fatherName = TextEditingController();
  TextEditingController addressDetail = TextEditingController();
  TextEditingController voterIdentity = TextEditingController();
  TextEditingController dateOfBirth = TextEditingController();
  List<QueryDocumentSnapshot<Object?>> regionsData = [];
  List<String> autoCompleteData = [];
  DateTime selectedDateTime = DateTime.now();
  String selectedDateTimeText =
      DateFormat('EEE, dd MMM, yyyy').format(DateTime.now());
  @override
  void initState() {
    EasyLoading.show(
      maskType: EasyLoadingMaskType.clear,
      status: 'Loading Data Please Wait!',
    );
    regions.get().then((value) {
      setState(() {
        for (var item in value.docs) {
          regionsData.add(item);
          autoCompleteData.add((item.data()! as Map)['regionNumber'] as String);
        }
        EasyLoading.dismiss();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: globalDecoration,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
            child: ListView(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: Text(
                'Register New Voter',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child:
                    // ignore: missing_required_param
                    AutoCompleteTextField<String>(
                  clearOnSubmit: false,
                  decoration: getInputDecoration(
                      'Enter Region Number', const Icon(Icons.location_city)),
                  itemSorter: (a, b) {
                    return 0;
                  },
                  itemFilter: (suggestion, input) =>
                      suggestion.toLowerCase().startsWith(input.toLowerCase()),
                  itemBuilder: (context, suggestion) => Padding(
                      child: ListTile(
                        leading: Container(
                            child: Center(
                              child: Text(suggestion[0],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              // The child of a round Card should be in round shape
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [
                                Colors.blue[900]!,
                                Colors.purple[800]!
                              ]),
                            )),
                        title: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      padding: const EdgeInsets.all(5.0)),
                  style: TextStyle(fontSize: 18, color: textColor),
                  key: schoolKey,
                  suggestions: autoCompleteData,
                  controller: regionNumberController,
                  itemSubmitted: (item) {
                    setState(() {
                      regionNumberController.text = item;
                    });
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextFormField(
                    style: getTextInputStyle(),
                    maxLength: 20,
                    enabled: true,
                    controller: voterIdentity,
                    keyboardType: TextInputType.text,
                    decoration: getInputDecoration(
                        'Enter Voter Identity',
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
                    controller: voterName,
                    keyboardType: TextInputType.text,
                    decoration: getInputDecoration(
                        'Enter Voter Name',
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
                    controller: fatherName,
                    keyboardType: TextInputType.text,
                    decoration: getInputDecoration(
                        'Enter Voter Father Name',
                        Icon(
                          Icons.person_add,
                          color: textColor,
                        )))),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextFormField(
                    style: getTextInputStyle(),
                    maxLength: 50,
                    enabled: true,
                    controller: addressDetail,
                    keyboardType: TextInputType.text,
                    decoration: getInputDecoration(
                        'Enter Voter Address',
                        Icon(
                          Icons.home,
                          color: textColor,
                        )))),
            TextButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.utc(1950), onChanged: (date) {
                    print('change $date');
                  }, onConfirm: (date) {
                    setState(() {
                      selectedDateTime = date;
                      selectedDateTimeText = DateFormat('EEE, dd MMM, yyyy')
                          .format(selectedDateTime);
                      print(selectedDateTime
                          .difference(DateTime.now())
                          .inDays
                          .abs());
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Date of Birth',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              selectedDateTimeText,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
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
                      if (voterName.text.length > 3 &&
                          fatherName.text.length > 3 &&
                          regionNumberController.text.length > 3 &&
                          addressDetail.text.length > 3 &&
                          selectedDateTime
                                  .difference(DateTime.now())
                                  .inDays
                                  .abs() >
                              6480) {
                        EasyLoading.show(
                          maskType: EasyLoadingMaskType.clear,
                          status: 'Loading',
                        );
                        voters.add({
                          'voterIdentity': voterIdentity.text,
                          'voterName': voterName.text,
                          'fatherName': fatherName.text,
                          'regionNumber': regionNumberController.text,
                          'addressDetail': addressDetail.text,
                          'DOB': Timestamp.fromDate(selectedDateTime),
                          'registered': false,
                          'cryptoKey': '',
                          'downloadURL': ''
                        }).then((value) {
                          EasyLoading.dismiss();
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                              msg: 'Voter Added!',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.black,
                              fontSize: 16.0);
                        });
                      } else {
                        EasyLoading.dismiss();
                        Fluttertoast.showToast(
                            msg: 'Incorrect Data',
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
                        'Add Voter',
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
