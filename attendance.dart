import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // Import DateFormat
import 'dart:async';
import 'package:tflite_flutter/tflite_flutter.dart';

class SubjectsDisplay extends StatefulWidget {
  final String uniqueId;
  SubjectsDisplay(this.uniqueId);
  @override
  _SubjectsDisplayState createState() => _SubjectsDisplayState();
}

class _SubjectsDisplayState extends State<SubjectsDisplay> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  int lat=0;
  int long=0;
  int times=0;
  bool _isBiometricAvailable = false;
  String _authenticationResult = '';
  bool _authenticated = false;
  late Timer _timer;
  var predvalue1=0;
  var predvalue2=0;
  Position? _currentPosition;
  late bool serviceperm = false;
  late LocationPermission permission;
  String? Attend='';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> subjectsWithOneValue = [];
  List<String> classroomLocations = [];
  List<int> location = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    bool isAvailable = await _localAuthentication.canCheckBiometrics;
    setState(() {
      _isBiometricAvailable = isAvailable;
    });

    if (isAvailable) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Please authenticate to proceed',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
    if (isAuthenticated) {
      setState(() {
        _authenticated = true;
        fetchSubjectsAndLocationsFromFirestore();
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          _getCurrentLocation();
        });
      });
    } else {
      setState(() {
        _authenticationResult = 'Authentication failed';
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkLocationService() async {
    serviceperm = await Geolocator.isLocationServiceEnabled();
    if (!serviceperm) {
      await Geolocator.openLocationSettings();
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
      Position newPosition = await Geolocator.getCurrentPosition();
      for(int i=0;i<50;i++){
      setState(() {
        _currentPosition = newPosition;
      });
      }
      lat = (_currentPosition!.latitude * 10000000).toInt() - location[0].toInt();
      long = (_currentPosition!.longitude * 10000000).toInt() - location[1].toInt();
      print("${lat},${long}");
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> fetchSubjectsAndLocationsFromFirestore() async {
    try {
      QuerySnapshot subjectsSnapshot = await firestore
          .collection('notes')
          .where('Role', isEqualTo: 'Student')
          .where('UID', isEqualTo:int.parse(widget.uniqueId))
          .get();

      subjectsSnapshot.docs.forEach((doc) {
        Map<String, dynamic> subjects = doc['Subjects'];
        print(subjects);
        if (subjects != null) {
          subjects.forEach((subject, value) {
            if (value == '1') {
              setState(() {
                subjectsWithOneValue.add(subject);
              });
            }
          });
        }
      });
       DocumentSnapshot docSnapshot =
        await firestore.collection('notes').doc(widget.uniqueId).get();
         String loc = docSnapshot["Class"] as String? ?? "";
      QuerySnapshot classroomsSnapshot =
          await firestore.collection('Classroom').where("Name", isEqualTo: loc).get();

      classroomsSnapshot.docs.forEach((doc) {
        List<dynamic> docLocation = doc['Location'];
        if (docLocation.isNotEmpty) {
          setState(() {
            location = docLocation.cast<int>();
          });
          print(location);
        }
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> handleButtonPressed(int index) async {
  for(int i=0;i<8;i++){
  for(int j=0;j<100;j++){  
  Position newPosition = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = newPosition;
        print(((_currentPosition!.latitude * 10000000).toInt() - location[0]).abs());
        print(((_currentPosition!.longitude * 10000000).toInt() - location[1]).abs());
      });
  }    
  while(i>3){  
   final interpreter=await Interpreter.fromAsset('converted_model.tflite');
    var input1=[[lat]];
    var output1=List.filled(1,0).reshape([1,1]);
    interpreter.run(input1,output1);
    print(output1[0][0]);
    setState(() {
       predvalue1=output1[0][0].round();
    });
    final interpreter1=await Interpreter.fromAsset('converted_model.tflite');
    var input2=[[long]];
    var output2=List.filled(1,0).reshape([1,1]);
    interpreter.run(input2,output2);
    print(output2[0][0]);
    setState(() {
       predvalue2=output2[0][0].round();
    });
 times=0;
    if (predvalue1==1 && predvalue2==1) {
      times++;
  await Future.delayed(Duration(seconds: 15));// Increment the counter
  if (times == 3) {
    print(times);
    Attend = "Present"; // Update attendance to "Present" if counter equals 3
    print(Attend);
  }
  } else {
  Attend = "Absent";
  print(Attend);
  }
  print(subjectsWithOneValue[index]);
    setState(() {});
  }
  }
    // Add the Attend value and the date to the database
    await addToDatabase(subjectsWithOneValue[index], Attend ?? 'NO');
  }

  Future<void> addToDatabase(String subject, String attend) async {
    try {
      // Get the current date
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // Add the data to the Firestore database
      // Find the document by ID and update its data
await firestore.collection('notes').doc(widget.uniqueId).update({
  '${formattedDate}': Attend,
});


      print('Attendance added to database');
    } catch (e) {
      print('Error adding attendance to database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ATTENDANCE'),
      ),
      body: Center(
        child: _authenticated
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              itemCount: subjectsWithOneValue.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed:(){
                        handleButtonPressed(index);
                      },
                      style: ButtonStyle(
                        backgroundColor: Attend == ''
                            ? MaterialStateProperty.all(Colors.blue)
                            : Attend == "Absent"
                            ? MaterialStateProperty.all(Colors.red)
                            : MaterialStateProperty.all(Colors.green),
                      ),
                      child: Text(subjectsWithOneValue[index]),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              Attend ?? 'NO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isBiometricAvailable
                  ? 'Biometric authentication available'
                  : 'Biometric authentication not available',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isBiometricAvailable ? _authenticate : null,
              child: Text('Authenticate'),
            ),
            SizedBox(height: 20),
            Text(_authenticationResult),
          ],
        ),
      ),
    );
  }
}