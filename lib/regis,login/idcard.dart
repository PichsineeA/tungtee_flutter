import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangteevs/Homepage.dart';
import 'package:tangteevs/profile/Profile.dart';
import 'package:tangteevs/regis,login/Registernext.dart';
import 'package:tangteevs/services/auth_service.dart';
import 'package:tangteevs/services/database_service.dart';
import '../helper/helper_function.dart';
import '../team/privacy.dart';
import '../team/team.dart';
import '../utils/color.dart';
import '../utils/showSnackbar.dart';
import '../widgets/custom_textfield.dart';

class IdcardPage extends StatefulWidget {
  final String uid;
  const IdcardPage({Key? key, required this.uid}) : super(key: key);

  @override
  _IdcardPageState createState() => _IdcardPageState();
}

class _IdcardPageState extends State<IdcardPage> {
  DatabaseService databaseService = DatabaseService();
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  bool isChecked = false;
  bool isadmin = false;
  String bio = "";
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  String _ImageidcardController = '';
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  File? media;

  var userData = {};
  var postLen = 0;
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
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      userData = userSnap.data()!;
      _ImageidcardController = userData['idcard'].toString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarHeight: 120,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "VERIFICATION",
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.bold,
            color: purple,
            shadows: [
              Shadow(
                blurRadius: 5,
                color: Colors.grey,
                offset: Offset(3, 3),
              ),
            ],
          ),
        ),
        // ignore: prefer_const_constructors
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(-20),
          child: const Text("ยืนยันตัวตนของคุณ",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: unselected)),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("สแกนบัตรประชาชนของคุณ",
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'MyCustomFont',
                            color: unselected)),
                    SizedBox(
                        height: 120,
                        child: media != null
                            ? Image.file(media!)
                            : Image.asset('assets/images/id-card.png')),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          minimumSize: const Size(268, 36),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () async {
                        ImagePicker imagePicker = ImagePicker();
                        XFile? file = await imagePicker.pickImage(
                            source: ImageSource.gallery);
                        print('${file?.path}');

                        if (file == null) return;
                        String uniqueFileName =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        Reference referenceRoot =
                            FirebaseStorage.instance.ref();
                        Reference referenceDirImages =
                            referenceRoot.child('idcard');
                        Reference referenceImageToUpload =
                            referenceDirImages.child("${user?.uid}");
                        try {
                          //Store the file
                          await referenceImageToUpload.putFile(File(file.path));
                          //Success: get the download URL
                          _ImageidcardController =
                              await referenceImageToUpload.getDownloadURL();
                        } catch (error) {
                          //Some error occurred
                        }
                        setState(() {
                          media = File(file.path);
                        });
                        print(_ImageidcardController);
                      },
                      child: const Text("Take a photo of idcard"),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                        "ข้อแนะนำ:\nหลีกเลี่ยงแสงสะท้อน และความมืดเกินไป \nรูปไม่เบลอ เห็นตัวอักษรชัดเจน ",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'MyCustomFont',
                            color: unselected)),
                    const SizedBox(
                      height: 120,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;

                              isadmin = false;
                            });
                          },
                        ),
                        Text.rich(TextSpan(
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'MyCustomFont'),
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                    "ฉันขอรับรองว่ามีอายุมากกว่า 15 ปี และยอมรับ",
                                style: const TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                                recognizer: TapGestureRecognizer()),
                            TextSpan(
                                text: "เงื่อนไขการใช้งาน\n",
                                style: const TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, TermsPage());
                                  }),
                            TextSpan(
                                text: "และ",
                                style: const TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                                recognizer: TapGestureRecognizer()),
                            TextSpan(
                                text: "นโยบายความเป็นส่วนตัว",
                                style: const TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, PrivacyPage());
                                  }),
                          ],
                        )),
                      ],
                    ),
                    SizedBox(
                      width: 307,
                      height: 49,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: isChecked ? purple : unselected,
                            minimumSize: const Size(268, 49),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Text(
                              'Next',
                              style: TextStyle(
                                  fontSize: 22, fontFamily: 'MyCustomFont'),
                            ), // <-- Text
                            const SizedBox(
                              width: 3,
                            ),
                            const Icon(
                              // <-- Icon
                              Icons.navigate_next_sharp,
                              size: 26.0,
                            ),
                          ],
                        ),
                        onPressed: () {
                          if (isChecked == true) {
                            Updata();
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Updata() async {
    final String Imageidcard = _ImageidcardController.toString();

    if (_formKey.currentState!.validate()) {
      await _users.doc(widget.uid).update({
        "idcard": Imageidcard,
      });
      _ImageidcardController = '';
      nextScreen(
          context, RegisnextPage(uid: FirebaseAuth.instance.currentUser!.uid));
    }
  }
}
