import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapTablePage extends StatefulWidget {
  final String subject;
  MapTablePage(this.subject);

  @override
  _MapTablePageState createState() => _MapTablePageState();
}

class _MapTablePageState extends State<MapTablePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> mapDataList = [];
  Set<int> UID={};
  @override
  void initState() {
    super.initState();
    fetchMapDataFromFirestore();
  }

  Future<void> fetchMapDataFromFirestore() async {
    print(widget.subject);
    try {
      QuerySnapshot subjectsSnapshot = await firestore
          .collection('notes')
          .where('Role', isEqualTo: 'Student')
          .where('Year', isEqualTo:'3')
          .get();

      subjectsSnapshot.docs.forEach((doc) {
        Map<String, dynamic> subjects = doc[widget.subject];
        UID.add(doc["UID"]);
        print(UID);
          setState(() {
          mapDataList.add(subjects);
        });
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(color:Colors.blue),
        centerTitle: true,
        title: Text('Attendance Sheet',style:TextStyle(fontSize: 25,fontWeight:FontWeight.bold),),
      ),
      body: mapDataList.isNotEmpty
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _buildDataColumns(),
                rows: _buildDataRows(),
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('No Data'),
                        content: Text('No data available for display.'),
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
                },
                child: Text('No Data Available'),
              ),
            ),
    );
  }

List<DataColumn> _buildDataColumns() {
  List<DataColumn> columns = [
    DataColumn(
      label: Text('Date',style:TextStyle(fontSize: 15,fontWeight:FontWeight.bold),),
    ),
  ];
  int i=0;
  if (UID != null) {
    for (var mapData in mapDataList) {
      columns.add(
        DataColumn(
          label: Text(UID.elementAt(i).toString(),style:TextStyle(fontSize: 15,fontWeight:FontWeight.bold),),
        ),
      );
    i++;  
    }
  }

  return columns;
}
List<DataRow> _buildDataRows() {
  List<DataRow> rows = [];
  Set<String> allKeys = {};

  // Collect all keys from mapDataList
  for (var mapData in mapDataList) {
    allKeys.addAll(mapData.keys);
  }

  // Sort keys
  List<String> sortedKeys = allKeys.toList()..sort();

  // Iterate over sorted keys
  for (var key in sortedKeys) {
    List<DataCell> cells = [
      DataCell(Text(key,style:TextStyle(fontSize: 15,fontWeight:FontWeight.bold),)),
    ];

    // Iterate over mapDataList to get values for each key
    for (var mapData in mapDataList) {
      // Check if the key exists in the mapData, if not, set the value as "Absent"
      var value = mapData.containsKey(key) ? mapData[key].toString() : "Absent";
      cells.add(DataCell(Text(value)));
    }

    rows.add(DataRow(cells: cells));
  }

  return rows;
}

}
