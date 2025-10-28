import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //default blue shade color
  late final Color primaryBlue = Color.fromRGBO(76, 163, 216, 1);

  String? _selectedActivity;
  String? _selectedTemperature;
  String? _selectedGender;

  TextEditingController weightController = TextEditingController();
  TextEditingController activityDurationController = TextEditingController();
  
  double result = 0.0;

  FocusNode weightFocusNode = FocusNode();
  

  //dropdown activity level
  static final List<String> _activityLevel = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active'
  ];

  //dropdown temperature
  static final List<String> _temperature =[
    'Hot',
    'Warm',
    'Cold'
  ];

  //dropdown gender
  static final List<String> _gender =[
    'Male',
    'Female'
  ];

  //dispose controllers and focus nodes - clear memory
  @override
  void dispose() {
    weightController.dispose();
    activityDurationController.dispose();
    weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sip Smart Calculator', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: primaryBlue.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Stay Hydrated",
                      style: TextStyle(
                        fontSize: 22,
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.water_drop, size: 40, color: primaryBlue)
                  ],
                ),
                SizedBox(height: 15),
                //Input - gender
                Row(
                  children: [
                    SizedBox(
                      width: 100, 
                      child: Text('Gender',
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: primaryBlue)
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: primaryBlue,
                            width: 2.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                              value: _selectedGender,
                              hint: Text('Select'),
                              items: _gender.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                  });
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Input - weight
                Row(
                  children: [
                    SizedBox(
                      width: 100, 
                      child: Text('Weight (kg)', 
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: primaryBlue,)
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: weightController,
                          focusNode: weightFocusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Colors.blueGrey,
                                width: 2.0,
                              ),
                            ),
                            labelText: 'Weight (kg)', labelStyle: TextStyle(fontSize: 12),
                            hintText: 'e.g. 70.6',
                          )
                        )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                //Input - activity duration
                Row(
                  children: [
                    SizedBox(
                      width: 100, 
                      child: Text('Activity Duration (min)', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: primaryBlue)
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: activityDurationController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Colors.blueGrey,
                                width: 2.0,
                              ),
                            ),
                            labelText: 'Activity Duration(min)', labelStyle: TextStyle(fontSize: 12),
                            hintText: 'e.g. 90'
                          )
                        )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                //Input - activity level
                Row(
                  children: [
                    SizedBox(
                      width: 100, 
                      child: Text('Activity Level', 
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: primaryBlue)
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: primaryBlue,
                            width: 2.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                              value: _selectedActivity,
                              hint: Text('Select'),
                              items: _activityLevel.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedActivity = newValue;
                                  });
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Input Temperature
                Row(
                  children: [
                    SizedBox(
                      width: 100, 
                      child: Text('Temperature', 
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: primaryBlue)
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 150, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: primaryBlue,
                            width: 2.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                              value: _selectedTemperature,
                              hint: Text('Select'),
                              items: _temperature.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTemperature = newValue;
                                  });
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Calculate Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 40),
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: calculateWaterIntake,
                      child: Text('Calculate Water Intake',style: TextStyle(color: Colors.white),),
                    ),
                    // Reset Button
                    ElevatedButton(
                      onPressed: () {
                        weightController.clear();
                        activityDurationController.clear();
                        _selectedGender = null;
                        _selectedActivity = null;
                        _selectedTemperature = null;
                        
                        FocusScope.of(context).requestFocus(weightFocusNode);
                        weightFocusNode.requestFocus();

                        result = 0.00;

                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 40),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text('Reset',style: TextStyle(color: Colors.white),),
                    )
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.water_drop_outlined, size: 20, color: primaryBlue),
                      Text('Water Intake: ${result.toStringAsFixed(1)} L',
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: primaryBlue),
                      ),
                    ],
                  ),
                )
              ],
            ),
        )
      ),
    )
    );
  }

  void calculateWaterIntake() {
    if (weightController.text.isEmpty || double.parse(weightController.text) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid input. Enter a positive number for weight'),
              backgroundColor: Colors.red,
            ),
          );
          return;
    }

    if (activityDurationController.text.isEmpty || double.parse(activityDurationController.text) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid input. Enter a positive number for activity duration'),
              backgroundColor: Colors.red,
            ),
          );
          return;
    }

    if (weightController.text.isEmpty ||
        activityDurationController.text.isEmpty ||
        _selectedGender == null ||
        _selectedActivity == null ||
        _selectedTemperature == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill in all the fields.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
    }

    // Convert to double
    double weight = double.parse(weightController.text);
    double activityDuration = double.parse(activityDurationController.text);

    //Base: 35ml per kg
    double waterMl = weight * 35.0;

    //Add 12ml/min of activity duration
    waterMl += activityDuration * 12.0;

    //Adjust by gender
    if (_selectedGender == 'Male') {
      waterMl *= 1.1;
    } else if (_selectedGender == 'Female') {
      waterMl *= 0.9;
    }

    //Adjust by activity level
    switch (_selectedActivity) {
       case 'Lightly Active' :
        waterMl *= 1.2;
        break;
       case 'Moderately Active' :
        waterMl *= 1.4;
        break;
       case 'Very Active' :
        waterMl *= 1.6;
        break;
       case 'Extra Active' :
        waterMl *= 1.8;
        break;
       default:
        break;
    }

    //Adjust by temperature
    switch (_selectedTemperature) {
       case 'Cold' :
        waterMl *= 1.0;
        break;
       case 'Warm' :
        waterMl *= 1.2;
        break;
       case 'Hot' :
        waterMl *= 1.4;
        break;
       default:
        break;
    }

    //Convert to liters
    double waterLiters = waterMl / 1000;

    //Round to 1 decimal
    setState(() {
      result = double.parse(waterLiters.toStringAsFixed(1));
    });
  }
}