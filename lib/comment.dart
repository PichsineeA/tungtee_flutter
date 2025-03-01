import 'package:flutter/material.dart';
import 'package:tangteevs/utils/showSnackbar.dart';
import 'package:tangteevs/widgets/custom_textfield.dart';
import 'HomePage.dart';
import 'utils/color.dart';
import 'services/auth_service.dart';
import 'package:getwidget/getwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math';

class Comment extends StatefulWidget {
  DocumentSnapshot postid;
  Comment({required this.postid});

  @override
  _MyCommentState createState() => _MyCommentState();
}

class _MyCommentState extends State<Comment> {
  var postData = {};
  var userData = {};
  var commentLen = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var postSnap = await FirebaseFirestore.instance
          .collection('post')
          .doc(widget.postid['postid'])
          .get();

      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.postid['uid'])
          .get();

      // get post Length
      var commentSnap = await FirebaseFirestore.instance
          .collection('comments')
          .where('postid', isEqualTo: widget.postid['postid'])
          .get();

      commentLen = commentSnap.docs.length;
      postData = postSnap.data()!;
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  final CollectionReference _comment =
      FirebaseFirestore.instance.collection('comments');
  final commentSet = FirebaseFirestore.instance.collection('comments').doc();

  bool _isLoading = false;
  bool submit = false;
  final _formKey = GlobalKey<FormState>();
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: unselected),
                onPressed: () => {
                  nextScreenReplaceOut(context, MyHomePage()),
                },
              ),
              elevation: 1,
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: unselected,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            body: Column(
              children: [
                SingleChildScrollView(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: green,
                                  backgroundImage: NetworkImage(
                                    userData['profile'].toString(),
                                  ),
                                  radius: 25,
                                ),
                                SizedBox(
                                  width: 290,
                                  child: Text('\t\t' + userData['Displayname'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'MyCustomFont',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                Container(
                                  width: 20,
                                  child: IconButton(
                                    onPressed: (() {
                                      //add action
                                    }),
                                    icon: const Icon(
                                      Icons.favorite_border,
                                      color: unselected,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Card(
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 151, 150, 150),
                                  width: 0.5,
                                ),
                              ),
                              //margin: const EdgeInsets.only(top: 15),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 400,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.00),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 290,
                                              child: Text(
                                                  postData['activityName'],
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'MyCustomFont',
                                                    color: unselected,
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ),
                                            SizedBox(
                                              width: 18.4,
                                              child: IconButton(
                                                  onPressed: () {},
                                                  icon:
                                                      const Icon(Icons.person)),
                                            ),
                                            Text.rich(
                                                TextSpan(children: <InlineSpan>[
                                              TextSpan(
                                                  text: '\t\t' +
                                                      '0 / ' +
                                                      postData['peopleLimit'],
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'MyCustomFont',
                                                    color: unselected,
                                                  )),
                                            ])),
                                          ],
                                        ),
                                        Text.rich(
                                            TextSpan(children: <InlineSpan>[
                                          const TextSpan(
                                            text: '',
                                          ),
                                          const WidgetSpan(
                                            child: Icon(
                                              Icons.calendar_today,
                                            ),
                                          ),
                                          TextSpan(
                                              text: '\t\t' +
                                                  postData['date'] +
                                                  '(' +
                                                  postData['time'] +
                                                  ')',
                                              style: const TextStyle(
                                                fontFamily: 'MyCustomFont',
                                                color: unselected,
                                              )),
                                        ])),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text.rich(
                                            TextSpan(children: <InlineSpan>[
                                          const TextSpan(
                                            text: '',
                                          ),
                                          const WidgetSpan(
                                            child: Icon(
                                              Icons.maps_home_work,
                                            ),
                                          ),
                                          TextSpan(
                                              text: '\t\t' + postData['place'],
                                              style: const TextStyle(
                                                fontFamily: 'MyCustomFont',
                                                color: unselected,
                                              )),
                                        ])),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text.rich(
                                            TextSpan(children: <InlineSpan>[
                                          const TextSpan(
                                            text: '',
                                          ),
                                          const WidgetSpan(
                                            child: Icon(
                                              Icons.place,
                                            ),
                                          ),
                                          TextSpan(
                                              text:
                                                  '\t\t' + postData['location'],
                                              style: const TextStyle(
                                                fontFamily: 'MyCustomFont',
                                                color: unselected,
                                              )),
                                        ])),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                            width: 250,
                                            child: Text(
                                                '\nDetail\n\t\t\t\t\t' +
                                                    postData['detail'],
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'MyCustomFont',
                                                    color: unselected))),
                                        Row(
                                          children: [
                                            const SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Padding(
                                                padding: EdgeInsets.all(1),
                                                child: SizedBox(
                                                  width: 265,
                                                  height: 25,
                                                  child: Text('add tag+',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'MyCustomFont',
                                                        color: unselected,
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Comment',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'MyCustomFont',
                                      color: unselected,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ],
                          ),
                          Container(
                              // child: FutureBuilder(
                              //   future: FirebaseFirestore.instance
                              //       .collection('comments')
                              //       .where('postid',
                              //           isEqualTo: widget.postid['postid'])
                              //       .get(),
                              //   builder: (context, snapshot) {
                              //     if (snapshot.connectionState ==
                              //         ConnectionState.waiting) {
                              //       return Container(
                              //         child: Center(
                              //           child: Column(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.center,
                              //             children: const <Widget>[
                              //               SizedBox(
                              //                 height: 30.0,
                              //                 width: 30.0,
                              //                 child: CircularProgressIndicator(),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       );
                              //     }
                              //     return ListView.builder(
                              //         itemCount:
                              //             (snapshot.data! as dynamic).docs.length,
                              //         itemBuilder: (context, index) {
                              //           DocumentSnapshot snap =
                              //               (snapshot.data! as dynamic).docs[index];

                              //           var Mytext = new Map();
                              //           Mytext['proImg'] = (snap.data()!
                              //               as dynamic)['activityName'];

                              //           return Center(
                              //             child: Padding(
                              //               padding:
                              //                   const EdgeInsets.only(left: 10),
                              //               child: Row(
                              //                 children: [
                              //                   const Padding(
                              //                     padding:
                              //                         EdgeInsets.only(bottom: 45),
                              //                     child: CircleAvatar(
                              //                       backgroundColor: green,
                              //                       // backgroundImage: NetworkImage(
                              //                       //   userData['profile'].toString(),
                              //                       // ),
                              //                       radius: 20,
                              //                     ),
                              //                   ),
                              //                   SizedBox(
                              //                     width: 300,
                              //                     child: Card(
                              //                       clipBehavior: Clip.hardEdge,
                              //                       shape: RoundedRectangleBorder(
                              //                         borderRadius:
                              //                             BorderRadius.circular(
                              //                                 15.0),
                              //                         side: const BorderSide(
                              //                           color: Color.fromARGB(
                              //                               255, 151, 150, 150),
                              //                           width: 2,
                              //                         ),
                              //                       ),
                              //                       margin: const EdgeInsets.only(
                              //                           left: 10),
                              //                       child: Padding(
                              //                         padding:
                              //                             EdgeInsets.all(15.00),
                              //                         child: Column(
                              //                           crossAxisAlignment:
                              //                               CrossAxisAlignment
                              //                                   .start,
                              //                           children: [
                              //                             Row(
                              //                               children: const [
                              //                                 SizedBox(
                              //                                   width: 215,
                              //                                   child: Text(
                              //                                       '\t\tname',
                              //                                       style:
                              //                                           TextStyle(
                              //                                         fontSize: 16,
                              //                                         fontFamily:
                              //                                             'MyCustomFont',
                              //                                         color: Colors
                              //                                             .black,
                              //                                         fontWeight:
                              //                                             FontWeight
                              //                                                 .bold,
                              //                                       )),
                              //                                 ),
                              //                                 Padding(
                              //                                   padding:
                              //                                       EdgeInsets.only(
                              //                                           left: 2),
                              //                                   child: Text('time',
                              //                                       style:
                              //                                           TextStyle(
                              //                                         fontSize: 16,
                              //                                         fontFamily:
                              //                                             'MyCustomFont',
                              //                                         color:
                              //                                             unselected,
                              //                                       )),
                              //                                 )
                              //                               ],
                              //                             ),
                              //                             const Padding(
                              //                               padding:
                              //                                   EdgeInsets.all(8.0),
                              //                               child: Text(
                              //                                 'Detail',
                              //                                 style: TextStyle(
                              //                                   fontSize: 16,
                              //                                   fontFamily:
                              //                                       'MyCustomFont',
                              //                                   color: unselected,
                              //                                 ),
                              //                               ),
                              //                             )
                              //                           ],
                              //                         ),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           );
                              //         });
                              //   },
                              // ),
                              )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Form(
                    key: _formKey,
                    //width: 350, //MediaQuery.of(context).size.width,
                    //height: 45.0,
                    //color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.attach_file_outlined,
                            color: purple,
                            size: 30,
                          ),
                        ),
                        SizedBox(
                          width: 315, //MediaQuery.of(context).size.width,
                          height: 45.0,
                          child: TextFormField(
                            controller: commentController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a valid activity name';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(width: 1, color: unselected),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(width: 2, color: unselected),
                              ),
                              hintText: 'Send a message',
                              hintStyle: TextStyle(
                                color: unselected,
                                fontFamily: 'MyCustomFont',
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate() == true) {
                              setState(() {
                                _isLoading = true;
                              });
                              await commentSet.set({
                                'cid': commentSet.id,
                                'comment': commentController.text,
                                'postid': postData['postid'],
                                'uid': userData['uid'],
                                'profile': userData['profile'],
                                'Displayname': userData['Displayname'],
                                'timeStamp': FieldValue.serverTimestamp(),
                              }).whenComplete(() {
                                _formKey.currentState?.reset();
                                commentController.clear();
                              });
                              //await _post.set(post);
                            }
                          },
                          icon: Icon(
                            Icons.send_outlined,
                            size: 30,
                            color: purple,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ));
  }
}
