// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'Global.dart';

class Regions extends StatefulWidget {
  const Regions({Key? key}) : super(key: key);

  @override
  State<Regions> createState() => _RegionsState();
}

class _RegionsState extends State<Regions> {
  CollectionReference voters = FirebaseFirestore.instance.collection('Voters');
  CollectionReference votes = FirebaseFirestore.instance.collection('Votes');
  CollectionReference regions =
      FirebaseFirestore.instance.collection('Regions');
  List<QueryDocumentSnapshot<Object?>> inputData = [];
  @override
  void initState() {
    regions.get().then((value) {
      if (mounted) {
        setState(() {
          for (var item in value.docs) {
            inputData.add(item);
          }
        });
      }
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
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
              child: Text(
                'Regions',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900),
              ),
            ),
            inputData.isNotEmpty
                ? Flexible(
                    child: ListView.builder(
                        itemCount: inputData.length,
                        itemBuilder: ((context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                            child: PhysicalModel(
                              elevation: 8,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              color: backGrColorText,
                              child: GestureDetector(
                                onLongPress: (() {
                                  int totalVotes = 0;
                                  List<Map> votingResult = [];
                                  votes
                                      .where('regionNumber',
                                          isEqualTo: (inputData[index].data()
                                              as Map)['regionNumber'])
                                      .get()
                                      .then((value) {
                                    totalVotes = value.docs.length;
                                    for (var item in (inputData[index].data()
                                        as Map)['nameOfParties']) {
                                      votingResult.add(
                                          {'PartyName': item, 'totalVotes': 0});
                                    }
                                    for (var item in value.docs) {
                                      for (var votingParty in votingResult) {
                                        if (votingParty['PartyName'] ==
                                            (item.data()
                                                as Map)['voteCastedTo']) {
                                          votingParty['totalVotes'] =
                                              votingParty['totalVotes'] + 1;
                                        }
                                      }
                                    }
                                    showCupertinoModalBottomSheet(
                                      topRadius: const Radius.circular(25),
                                      backgroundColor: Colors.red,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      elevation: 1,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(builder:
                                            (BuildContext context, imageState) {
                                          return Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 0, 10),
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
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_back_ios_new_rounded,
                                                        color: Colors.white,
                                                      )),
                                                  backgroundColor: Colors.black,
                                                  title: Text(
                                                    'Voting Result',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ),
                                                ),
                                                body: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                      begin: Alignment.topRight,
                                                      end: Alignment.bottomLeft,
                                                      colors: [
                                                        mainColor,
                                                        secondaryColor,
                                                      ],
                                                    )),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Total Votes Casted: ' +
                                                              totalVotes
                                                                  .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 20),
                                                        ),
                                                        Flexible(
                                                            child: ListView
                                                                .builder(
                                                                    itemCount:
                                                                        votingResult
                                                                            .length,
                                                                    itemBuilder:
                                                                        ((context,
                                                                            index) {
                                                                      return ListTile(
                                                                        title:
                                                                            Text(
                                                                          votingResult[index]
                                                                              [
                                                                              'PartyName'],
                                                                          style: TextStyle(
                                                                              fontSize: 25,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                        subtitle:
                                                                            Text(
                                                                          'Votes Casted:  ' +
                                                                              votingResult[index]['totalVotes'].toString(),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 18),
                                                                        ),
                                                                      );
                                                                    })))
                                                      ],
                                                    )),
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                    );
                                  });
                                }),
                                onTap: (() {
                                  EasyLoading.show(
                                    maskType: EasyLoadingMaskType.clear,
                                    status: 'Loading Voters',
                                  );
                                  voters
                                      .where('regionNumber',
                                          isEqualTo: (inputData[index].data()
                                              as Map)['regionNumber'])
                                      .get()
                                      .then((value) {
                                    if (value.docs.isNotEmpty) {
                                      EasyLoading.dismiss();
                                      showCupertinoModalBottomSheet(
                                        topRadius: const Radius.circular(25),
                                        backgroundColor: Colors.red,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        elevation: 1,
                                        enableDrag: false,
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(builder:
                                              (BuildContext context,
                                                  imageState) {
                                            return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 10),
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
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        icon: Icon(
                                                          Icons
                                                              .arrow_back_ios_new_rounded,
                                                          color: Colors.white,
                                                        )),
                                                    backgroundColor:
                                                        Colors.black,
                                                    title: Text(
                                                      'List of Voters',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  body: Container(
                                                      decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                        begin:
                                                            Alignment.topRight,
                                                        end: Alignment
                                                            .bottomLeft,
                                                        colors: [
                                                          mainColor,
                                                          secondaryColor,
                                                        ],
                                                      )),
                                                      child: ListView.builder(
                                                          itemCount:
                                                              value.docs.length,
                                                          itemBuilder:
                                                              ((context,
                                                                  index) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      15,
                                                                      10,
                                                                      15,
                                                                      10),
                                                              child:
                                                                  PhysicalModel(
                                                                elevation: 8,
                                                                shadowColor:
                                                                    Colors
                                                                        .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                color:
                                                                    backGrColorText,
                                                                child:
                                                                    Container(
                                                                  margin: const EdgeInsets
                                                                          .fromLTRB(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0),
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      1,
                                                                  decoration: BoxDecoration(
                                                                      color:
                                                                          backGrColorText,
                                                                      borderRadius: const BorderRadius
                                                                              .all(
                                                                          Radius.circular(
                                                                              20))),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child:
                                                                        ListTile(
                                                                      title:
                                                                          Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            Text(
                                                                          value.docs[index]
                                                                              [
                                                                              'voterName'],
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 20,
                                                                              color: textColor),
                                                                        ),
                                                                      ),
                                                                      subtitle:
                                                                          Padding(
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            10),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              value.docs[index]['voterIdentity'],
                                                                              style: TextStyle(fontSize: 15, color: textColor),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }))),
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    } else {
                                      EasyLoading.dismiss();
                                      Fluttertoast.showToast(
                                          msg: 'No Voter Registered Yet',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey,
                                          textColor: Colors.black,
                                          fontSize: 16.0);
                                    }
                                  });
                                }),
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  width: MediaQuery.of(context).size.width / 1,
                                  decoration: BoxDecoration(
                                      color: backGrColorText,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: ListTile(
                                      title: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          inputData[index]['regionName'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: textColor),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              inputData[index]['regionNumber'],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: textColor),
                                            ),
                                            Text(
                                              'Name of Parties',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.yellow,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Flexible(
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        ClampingScrollPhysics(),
                                                    itemCount: int.parse(
                                                        inputData[index][
                                                            'numberOfParties']),
                                                    itemBuilder:
                                                        ((context, partyNum) {
                                                      return Text(
                                                        inputData[index][
                                                                'nameOfParties']
                                                            [partyNum],
                                                        style: TextStyle(
                                                            color: textColor),
                                                      );
                                                    })))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        })))
                : Container()
          ],
        )),
      ),
    );
  }
}
