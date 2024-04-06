import 'package:flutter/material.dart';
import 'package:test/firestore.dart';

class Staff extends StatefulWidget {
  const Staff({Key? key}) : super(key: key);

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  int? uid;
  String? pass;
  String? role;
  String? Year;
  String? classr;
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController uniqController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  String? selectedRole;
  bool showAdditionalTextBox = false;

  void getID(int id) {
    setState(() {
      uid = id;
    });
  }

  void getyear(String year) {
    setState(() {
      Year = year;
    });
  }

  void getClass(String Class) {
    setState(() {
      classr = Class;
    });
  }

  void getPassword(String password) {
    setState(() {
      pass = password;
    });
  }

  void setSelectedRole(String? role) {
    setState(() {
      selectedRole = role;
      if (role == 'Student') {
        // Show the additional text box if the selected role is 'Student'
        showAdditionalTextBox = true;
      } else {
        // Hide the additional text box for other roles
        showAdditionalTextBox = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(color:Colors.blue),
        centerTitle: true,
          title: Text("Add User",style:TextStyle(fontSize: 25,fontWeight:FontWeight.bold),),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: uniqController,
                    decoration: InputDecoration(
                      labelText: "UNIQUE ID",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    onChanged: (String UID) {
                      getID(int.parse(UID));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: passController,
                    decoration: InputDecoration(
                      labelText: "PASSWORD",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    onChanged: (String password) {
                      getPassword(password);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ROLE",style:TextStyle(fontSize: 20,fontWeight:FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Student',
                            groupValue: selectedRole,
                            onChanged: (String? value) {
                              setSelectedRole(value);
                            },
                          ),
                          Text("Student",style:TextStyle(fontSize: 15,fontWeight:FontWeight.bold),),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Staff',
                            groupValue: selectedRole,
                            onChanged: (String? value) {
                              setSelectedRole(value);
                            },
                          ),
                          Text("Staff",style:TextStyle(fontSize: 15,fontWeight:FontWeight.bold),),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Admin',
                            groupValue: selectedRole,
                            onChanged: (String? value) {
                              setSelectedRole(value);
                            },
                          ),
                          Text("Admin",style:TextStyle(fontSize: 15,fontWeight:FontWeight.bold),),
                        ],
                      ),
                      if (showAdditionalTextBox && selectedRole == 'Student')
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: TextFormField(
                            controller: yearController,
                            decoration: InputDecoration(
                              labelText: 'Year',
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2.0),
                              ),
                            ),
                             onChanged: (String year) {
                                getyear(year);
                               },
                            // Add your logic here to handle additional text field value
                          ),
                        ),
                        
                      ],
                  ),
                ),
                ElevatedButton(
                  child: Text(
                    "Submit",style: TextStyle(fontSize: 15,color:const Color.fromARGB(255, 188, 111, 202)),
                  ),
                  onPressed: () {
                    if ((selectedRole != null) & (selectedRole != "Student" )) {
                      firestoreService.addNote(
                        int.parse(uniqController.text),
                        passController.text,
                        selectedRole!,
                      );
                      Navigator.of(context).pop();
                    }
                    else if ((selectedRole != null) & (selectedRole == "Student" )) {
                      firestoreService.addNotes(
                        int.parse(uniqController.text),
                        passController.text,
                        selectedRole!,
                        yearController.text,
                      );
                      Navigator.of(context).pop();
                    } 
                    else  {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Please select a role.'),
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
                  style:ElevatedButton.styleFrom(backgroundColor: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
