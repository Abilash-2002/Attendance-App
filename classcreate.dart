import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'attdisplay.dart';

class FirestoreRadioButtons extends StatefulWidget {
  final String uniqueId;
  FirestoreRadioButtons(this.uniqueId);

  @override
  _FirestoreRadioButtonsState createState() => _FirestoreRadioButtonsState();
}

class _FirestoreRadioButtonsState extends State<FirestoreRadioButtons> {
  String classroomLabel = '';
  Map<String,String> subjects={};
  String subject = '';
  String year = '';
  Position? _currentPosition;
  late bool serviceperm = false;
  late LocationPermission permission;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> list1 = [];
  List<String> list2 = [];
  String? selectedOption1;
  String? selectedOption2;

  @override
  void initState() {
    super.initState();
    fetchListsFromFirestore();
  }
  
  void Attendance(String sub) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MapTablePage(sub)));
  }

  Future<void> _checkLocationService() async {
    serviceperm = await Geolocator.isLocationServiceEnabled();
    if (!serviceperm) {
      await Geolocator.openLocationSettings();
    }
  }

Future<void> addSubject() async {
  try {
    await firestore.collection('CreateClass').doc(subject).set({
      'Subject': subject,
      'Year': year,
    });

    QuerySnapshot querySnapshot = await firestore
        .collection('notes')
        .where('Role', isEqualTo: 'Student')
        .where('Year', isEqualTo: year)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      // Access the data using square bracket notation
      Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>?;

      // Check if the 'Subjects' field exists
      if (docData != null && docData.containsKey('Subjects')) {
        Map<String, dynamic>? subjects = docData['Subjects'] as Map<String, dynamic>?;

        // Create a new map if it doesn't exist
        if (subjects == null) {
          subjects = {};
        }

        subjects[subject] = "0";

        await doc.reference.update({'Subjects': subjects});
        await doc.reference.update({'${subject}':{}});
      }
    }

    DocumentSnapshot docSnapshot =
        await firestore.collection('notes').doc(widget.uniqueId).get();
        print(widget.uniqueId);
        print(subject);
List<dynamic> sub = docSnapshot["Subject"] as List<dynamic>? ?? [];
Set<dynamic> subSet = sub.toSet(); // Convert list to set
subSet.add(subject);
await docSnapshot.reference.update({'Subject': subSet.toList()});
    Navigator.of(context).pop();
  } catch (e) {
    print("Error adding subject: $e");
  }
}

  Future<void> _getCurrentLocation() async {
    await _checkLocationService();

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      await Permission.location.request();
      return;
    }

    try {
      for(int j=0;j<3;j++){
        await Future.delayed(Duration(seconds: 2));
      for(int i=0;i<10;i++){
      Position newPosition = await Geolocator.getCurrentPosition();
         print(newPosition.latitude);
      print(newPosition.longitude);
      setState(() {
        _currentPosition = newPosition;
      });
      }
      }
      int lat = (_currentPosition!.latitude * 10000000).toInt();
      int long = (_currentPosition!.longitude * 10000000).toInt();

      await firestore.collection('Classroom').doc(classroomLabel).set({
        'Location': [lat, long],
        'Name': classroomLabel,
      });

      Navigator.of(context).pop();

      print('Location added to Classroom collection for $classroomLabel');
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> fetchListsFromFirestore() async {
    DocumentSnapshot docSnapshot =
        await firestore.collection('notes').doc(widget.uniqueId).get();

    List<dynamic> subjects1 = docSnapshot['Subject'];
    QuerySnapshot querySnapshot =
        await firestore.collection('Classroom').get();
    Set<String> uniqueValues1 = Set<String>();

    querySnapshot.docs.forEach((doc) {
      uniqueValues1.add(doc['Name'] as String);
    });

    List<String> validSubjects1 =
        subjects1.whereType<String>().toList();
    List<String> validSubjects2 =
        uniqueValues1.whereType<String>().toList();

    setState(() {
      list1 = validSubjects1;
      list2 = validSubjects2;
    });
  }

Future<void> updateSubjectForStudents() async {
  try {
    // Get all documents where role is "Student"
    QuerySnapshot querySnapshot =
        await firestore.collection('notes').where('Role', isEqualTo: 'Student').get();

    // Update the Subjects field for each document
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> subjects = doc['Subjects'];
      print(subjects);
      if (subjects != null) {
        subjects.forEach((key, value) {
          // Set the value to "1"
          subjects[key] = '0';
        });
        // Update the document with the selected options
        selectedOption1 != null ? subjects[selectedOption1!] = "1" : null;

        // Update the document
        await doc.reference.update({'Class':selectedOption2});
        await doc.reference.update({'Subjects': subjects});
        print(subjects);

        // Wait for 30 seconds

      }
    }
    await Future.delayed(Duration(seconds: 30));
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> subjects = doc['Subjects'];
        // Update the document again to set the value to "0"
        subjects.forEach((key, value) {
          subjects[key] = '0';
        });
        await doc.reference.update({'Subjects': subjects});
    print('Subjects updated for students successfully.');
  }
  } catch (e) {
    print('Error updating subjects for students: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(color:Colors.blue,),
        centerTitle: true,
        title: Text('Create Classroom',style:TextStyle(fontSize: 25,fontWeight:FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Subject:',style:TextStyle(fontSize: 20,fontWeight:FontWeight.bold),)),
                Column(
                  children: List<Widget>.generate(
                    list1.length,
                    (int index) {
                      return RadioListTile<String>(
                        title: Text(list1[index],style:TextStyle(fontSize: 15,fontWeight:FontWeight.bold,color: Colors.red),),
                        value: list1[index],
                        groupValue: selectedOption1,
                        onChanged: (String? value) {
                          setState(() {
                            selectedOption1 = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Classroom:',style:TextStyle(fontSize: 20,fontWeight:FontWeight.bold),)),
                Column(
                  children: List<Widget>.generate(
                    list2.length,
                    (int index) {
                      return RadioListTile<String>(
                        title: Text(list2[index],style:TextStyle(fontSize: 15,fontWeight:FontWeight.bold,color: Colors.green),),
                        value: list2[index],
                        groupValue: selectedOption2,
                        onChanged: (String? value) {
                          setState(() {
                            selectedOption2 = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
           Column(//classroom
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add Classroom'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                onChanged: (value) {
                                  classroomLabel = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter classroom label',
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _getCurrentLocation(); 
                                  Navigator.of(context).pop();
                                },
                                child: Text('Get Location'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  style:ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  child: Text('Add Classroom',style: TextStyle(fontSize: 15,color:Colors.white)),
                ),
                SizedBox(height: 20),
                ElevatedButton(//subject
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add Subject'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                onChanged: (value) {
                                  subject = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Subject',
                                ),
                              ),
                              TextField(
                                onChanged: (value) {
                                  year = value;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Year',
                                ),
                              ),
                  ElevatedButton(
                    onPressed: () {
                      addSubject();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add Subject'),
                  ),
                ],
              ),
            );
          },
        );
      },
      style:ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: Text('Add Subject',style: TextStyle(fontSize: 15,color:Colors.white)),
    ),
    SizedBox(height: 20),
    ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String classroomLabel = '';
            return AlertDialog(
              title: Text('Generate Attendance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  TextField(
                    onChanged: (value) {
                      subject = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Subject',
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Attendance(subject);
                    },
                    child: Text('Get Attendance'),
                  ),
                ],
              ),
            );
          },
        );
      },
      style:ElevatedButton.styleFrom(backgroundColor: Colors.purple),

      child: Text('Attendance',style: TextStyle(fontSize: 15,color:Colors.white)),
    ),
  ],
),
 SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (selectedOption1 != null && selectedOption2 != null) {
                  await updateSubjectForStudents();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please select options from both lists.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style:ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: Text('Submit',style: TextStyle(fontSize: 15,color:Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}