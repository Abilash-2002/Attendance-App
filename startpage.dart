import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/classcreate.dart';
import 'loginpage.dart';
import 'attendance.dart';
class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final TextEditingController uniqueIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String message = '';

  Future<void> authenticateUser() async {
    String uniqueId = uniqueIdController.text;
    String password = passwordController.text;

    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection('notes').doc(uniqueId).get();

      if (documentSnapshot.exists) {
        String? storedPassword = documentSnapshot.data() != null && (documentSnapshot.data() as Map<String, dynamic>).containsKey('Password')
    ? (documentSnapshot.data() as Map<String, dynamic>)['Password']
    : null;
    String? storedRole = documentSnapshot.data() != null && (documentSnapshot.data() as Map<String, dynamic>).containsKey('Password')
    ? (documentSnapshot.data() as Map<String, dynamic>)['Role']
    : null;
  if (password == storedPassword) {
       if (storedRole=="Student"){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SubjectsDisplay(uniqueId)));
       }
       else if (storedRole=="Staff") {
         Navigator.push(context, MaterialPageRoute(builder: (context)=>FirestoreRadioButtons(uniqueId)));
       }
       else if (storedRole=="Admin"){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Staff()));
       }
          setState(() {
            message = 'Continue';
          });
        } else {
          setState(() {
            message = 'No';
          });
        }
      } else {
        setState(() {
          message = 'No';
        });
      }
    } catch (e) {
      print('Error retrieving document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(color:Colors.blue),
        centerTitle: true,
        title: Text('Firebase Authentication',style:TextStyle(fontSize: 25,fontWeight:FontWeight.bold),),
      ),
      body:Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[ 
              TextField(
                style: TextStyle(fontSize: 15,color: Colors.pink),
                controller: uniqueIdController,
                decoration: InputDecoration(
                  labelText: 'Unique ID',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                style: TextStyle(fontSize: 15,color: Colors.pink),
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  authenticateUser();
                },
                style:ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text('Authenticate',style: TextStyle(fontSize: 15,color:const Color.fromARGB(255, 188, 111, 202)),),
              ),
              SizedBox(height: 20),
            
            ],
          ),
        ),
      ),
      );
  }
}
