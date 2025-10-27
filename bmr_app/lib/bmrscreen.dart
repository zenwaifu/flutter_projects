import 'package:flutter/material.dart';

class BMRCalcScreen extends StatefulWidget {
  const BMRCalcScreen({super.key});

  @override
  State<BMRCalcScreen> createState() => _BMRCalcScreenState();
}

class _BMRCalcScreenState extends State<BMRCalcScreen> {
  
  String gender = 'Male';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMR Calculator',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[400],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.purpleAccent[100],
        ),
        width: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(width: 100, child: Text('Gender')),
                DropdownButton<String>(
                  value: gender,
                  items: <String>['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    gender = newValue!;
                    setState(() {});
                  },
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 100, child: Text('Age')),
                SizedBox(
                  width: 150,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter age',
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 100, child: Text('Height (cm)')),
                SizedBox(
                  width: 150,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter height',
                    ),
                  ),
                )
              ],
            ), 
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Calculate BMR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Background color
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Background color
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    )
    );
  }
}