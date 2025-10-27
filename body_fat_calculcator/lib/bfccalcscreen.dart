import 'package:flutter/material.dart';

class BFCCalcScreen extends StatefulWidget {
  const BFCCalcScreen({super.key});

  @override
  State<BFCCalcScreen> createState() => _BFCCalcScreenState();
}

class _BFCCalcScreenState extends State<BFCCalcScreen> {
  String gender = 'Male';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Body Fat Calculator', style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 139, 101, 204) ,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(16.0),
          width: 350,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple, width: 2),
            borderRadius: BorderRadius.circular(10),
            color: Color.fromARGB(255, 166, 143, 206),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],  
          ),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row (
                children: [
                  SizedBox(
                    width: 100, 
                    child: Text('Gender'),
                  ),
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
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: 100, child: Text('Age')),
                  SizedBox(
                    width: 200,
                    child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your age',
                    ),
                  ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: 100, child: Text('Height (cm)')),
                  SizedBox(
                    width: 200,
                    child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your height in cm',
                        ),
                      ),
                    ),
                  ] ,
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width:100, child: Text('Weight (kg)')),
                    SizedBox(
                      width: 200,
                      child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your weight in kg',
                          ),
                        ),
                      ),
                  ] ,
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width:100, child: Text('Neck')),
                    SizedBox(
                      width: 200,
                      child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Neck circumference in cm',
                          ),
                        ),
                      ),
                    ] ,
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width:100, child: Text('Waist')),
                    SizedBox(
                      width: 200,
                      child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter waist circumference in cm',
                          ),
                        ),
                      ),
                    ] ,
                ),
                SizedBox(height: 5),
                Row (
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        overlayColor: Color.fromARGB(255, 139, 101, 204),
                        foregroundColor: Color.fromARGB(255, 139, 101, 204),
                        textStyle: TextStyle(color: Color.fromARGB(255, 223, 219, 228), fontSize: 16,),
                      ),
                      child: Text('Calculate BFC'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        overlayColor: Color.fromARGB(255, 139, 101, 204),
                        foregroundColor: Color.fromARGB(255, 139, 101, 204),
                        textStyle: TextStyle(color: Color.fromARGB(255, 223, 219, 228), fontSize: 16,),
                      ),
                      child: Text('Reset'),
                    ),
                  ],
                  ),
                  SizedBox(height: 5),
          ],
      ),
      )
    )
    );
  }
}