import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:student_monitoring_app/components/camera_view.dart';
import 'package:student_monitoring_app/models/face_features.dart';
import 'package:student_monitoring_app/models/student.dart';
import 'package:student_monitoring_app/resources/extract_features.dart';
import 'package:student_monitoring_app/views/study_session_screens/authenticated_user_screen.dart';

class AuthenticateScreen extends StatefulWidget {
  const AuthenticateScreen({super.key});

  @override
  State<AuthenticateScreen> createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        title: const Text(
          "User Authenticate",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CameraView(
              onImage: (image) {
                _setImage(image);
              },
              onInputImage: (inputImage) async {
                setState(() => isMatching = true);
                _faceFeatures =
                    await extractFaceFeatures(inputImage, _faceDetector);
                setState(() => isMatching = false);
              },
            ),
            if (_canAuthenticate)
              isMatching
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : InkWell(
                      onTap: () {
                        setState(() => isMatching = true);
                        _fetchUsersAndMatchFace();
                      },
                      child: Container(
                        width: 240,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                              colors: [
                                // Color.fromRGBO(222, 249, 196, 1),
                                Color.fromRGBO(91, 202, 191, 1),
                                Color.fromRGBO(91, 202, 191, 1),
                                // Color.fromRGBO(222, 249, 196, 1)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                        ),
                        child: const Text(
                          "Start Authentication",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            // ElevatedButton(
            //     child: const Text("Authenticate"),
            //     onPressed: () {
            //       setState(() => isMatching = true);
            //       _fetchUsersAndMatchFace();
            //     },
            //   ),
            const SizedBox(height: 38),
          ],
        ),
      ),
    );
  }

  /// Member functions

  Future _setImage(Uint8List imageToAuthenticate) async {
    image2.bitmap = base64Encode(imageToAuthenticate);
    image2.imageType = regula.ImageType.PRINTED;

    setState(() {
      _canAuthenticate = true;
    });
  }

  double compareFaces(FaceFeatures face1, FaceFeatures face2) {
    double distEar1 = euclideanDistance(face1.rightEar!, face1.leftEar!);
    double distEar2 = euclideanDistance(face2.rightEar!, face2.leftEar!);

    double ratioEar = distEar1 / distEar2;

    double distEye1 = euclideanDistance(face1.rightEye!, face1.leftEye!);
    double distEye2 = euclideanDistance(face2.rightEye!, face2.leftEye!);

    double ratioEye = distEye1 / distEye2;

    double distCheek1 = euclideanDistance(face1.rightCheek!, face1.leftCheek!);
    double distCheek2 = euclideanDistance(face2.rightCheek!, face2.leftCheek!);

    double ratioCheek = distCheek1 / distCheek2;

    double distMouth1 = euclideanDistance(face1.rightMouth!, face1.leftMouth!);
    double distMouth2 = euclideanDistance(face2.rightMouth!, face2.leftMouth!);

    double ratioMouth = distMouth1 / distMouth2;

    double distNoseToMouth1 =
        euclideanDistance(face1.noseBase!, face1.bottomMouth!);
    double distNoseToMouth2 =
        euclideanDistance(face2.noseBase!, face2.bottomMouth!);

    double ratioNoseToMouth = distNoseToMouth1 / distNoseToMouth2;

    double ratio =
        (ratioEye + ratioEar + ratioCheek + ratioMouth + ratioNoseToMouth) / 5;
    log(ratio.toString(), name: "Ratio");

    return ratio;
  }

  // A function to calculate the Euclidean distance between two points
  double euclideanDistance(Points p1, Points p2) {
    final sqr =
        math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
    return sqr;
  }

  _fetchUsersAndMatchFace() {
    FirebaseFirestore.instance.collection("students").get().catchError((e) {
      log("Getting User Error: $e");
      setState(() => isMatching = false);
      showToast("Something went wrong. Please try again.");
    }).then((snap) {
      if (snap.docs.isNotEmpty) {
        users.clear();
        log(snap.docs.length.toString(), name: "Total Registered Users");
        for (var doc in snap.docs) {
          Student user = Student.fromJson(doc.data());
          //print("User: ${user.name}, FaceFeatures: ${user.faceFeatures ?? 0}");
          //  if (user.faceFeatures == null || user.faceFeatures!.) continue;
          if (user.faceFeatures == null || user.faceFeatures!.isEmpty) continue;
          double similarity = compareFaces(_faceFeatures!, user.faceFeatures!);
          if (similarity >= 0.8 && similarity <= 1.5) {
            users.add([user, similarity]);
          }
        }
        log(users.length.toString(), name: "Filtered Users");
        setState(() {
          //Sorts the users based on the similarity.
          //More similar face is put first.
          users.sort((a, b) => (((a.last as double) - 1).abs())
              .compareTo(((b.last as double) - 1).abs()));
        });

        _matchFaces();
      } else {
        _showFailureDialog(
          title: "No Users Registered",
          description:
              "Make sure users are registered first before Authenticating.",
        );
      }
    });
  }

  _matchFaces() async {
    bool faceMatched = false;
    for (List user in users) {
      image1.bitmap = (user.first as Student).image;
      image1.imageType = regula.ImageType.PRINTED;

      //Face comparing logic.
      var request = regula.MatchFacesRequest();
      request.images = [image1, image2];
      dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));

      var response = regula.MatchFacesResponse.fromJson(json.decode(value));
      dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75);

      var split =
          regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));
      setState(() {
        _similarity = split!.matchedFaces.isNotEmpty
            ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
            : "error";
        log("similarity: $_similarity");

        if (_similarity != "error" && double.parse(_similarity) > 90.00) {
          faceMatched = true;
          loggingUser = user.first;
        } else {
          faceMatched = false;
        }
      });
      if (faceMatched) {
        setState(() {
          trialNumber = 1;
          isMatching = false;
        });

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AuthenticatedUserScreen(user: loggingUser!),
            ),
          );
        }
        break;
      }
    }
    if (!faceMatched) {
      if (trialNumber == 4) {
        setState(() => trialNumber = 1);
        _showFailureDialog(
          title: "Redeem Failed",
          description: "Face doesn't match. Please try again.",
        );
      } else if (trialNumber == 3) {
        //After 2 trials if the face doesn't match automatically, the registered name prompt
        //will be shown. After entering the name the face registered with the entered name will
        //be fetched and will try to match it with the to be authenticated face.
        //If the faces match, Viola!. Else it means the user is not registered yet.
        setState(() {
          isMatching = false;
          trialNumber++;
        });
        if (!context.mounted) return;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Enter Name"),
                content: TextFormField(
                  controller: _nameController,
                  cursorColor: Colors.redAccent,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 2,
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 2,
                        color: Colors.redAccent,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (_nameController.text.trim().isEmpty) {
                        showToast("Enter a name to proceed");
                      } else {
                        Navigator.of(context).pop();
                        setState(() => isMatching = true);
                        _fetchUserByName(_nameController.text.trim());
                      }
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  )
                ],
              );
            });
      } else {
        setState(() => trialNumber++);
        _showFailureDialog(
          title: "Redeem Failed",
          description: "Face doesn't match. Please try again.",
        );
      }
    }
  }

  _fetchUserByName(String orgID) {
    FirebaseFirestore.instance
        .collection("students")
        .where("organizationId", isEqualTo: orgID)
        .get()
        .catchError((e) {
      log("Getting User Error: $e");
      setState(() => isMatching = false);
      showToast("Something went wrong. Please try again.");
    }).then((snap) {
      if (snap.docs.isNotEmpty) {
        users.clear();

        for (var doc in snap.docs) {
          setState(() {
            users.add([Student.fromJson(doc.data()), 1]);
          });
        }
        _matchFaces();
      } else {
        setState(() => trialNumber = 1);
        _showFailureDialog(
          title: "User Not Found",
          description:
              "User is not registered yet. Register first to authenticate.",
        );
      }
    });
  }

  _showFailureDialog({
    required String title,
    required String description,
  }) {
    setState(() => isMatching = false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void showToast(msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }

  /// Data Members
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  FaceFeatures? _faceFeatures;
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();

  final TextEditingController _nameController = TextEditingController();

  bool _canAuthenticate = false;
  String _similarity = "";
  List<dynamic> users = [];
  bool userExists = false;
  Student? loggingUser;
  bool isMatching = false;
  int trialNumber = 1;

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}
