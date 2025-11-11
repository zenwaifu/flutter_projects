import 'package:flutter/material.dart';

class BMRCalcScreen extends StatefulWidget {
  const BMRCalcScreen({super.key});

  @override
  State<BMRCalcScreen> createState() => _BMRCalcScreenState();
}

class _BMRCalcScreenState extends State<BMRCalcScreen> {
  TextEditingController ageController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  
  String gender = 'Male';
  double bmrResult = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMR Calculator',style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 150, 120, 232),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple),
              borderRadius: BorderRadius.circular(8.0),
              color: const Color.fromARGB(255, 185, 166, 235)// Adjust the opacity as needed,
          ),
          width: 300,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(width: 80, child: Text('Gender')),
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
                  SizedBox(width: 80, child: Text('Age')),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter age',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Age 16-80'),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: 80, child: Text('Height (cm)')),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter height',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('cm'),
                ],
              ), 
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: 80, child: Text('Weight (kg)')),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter weight',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('kg'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: calculateBMR,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Background color
                    ),
                    child: Text('Calculate BMR'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Background color
                    ),
                    child: Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Your BMR: ${bmrResult.toStringAsFixed(2)} kcal/day',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
            ),
      )
    );
  }

  void calculateBMR() {
    int age = int.parse(ageController.text);
    double height = double.parse(heightController.text);
    double weight = double.parse(weightController.text);
    

    if (gender == 'Male') {
      bmrResult = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmrResult = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
    setState(() {});
  }
}