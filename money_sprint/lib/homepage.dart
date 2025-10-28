import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //default blue shade color
  final Color primaryPurple = Color.fromRGBO(224, 64, 251, 1);

  int? weeksNeeded;
  

  String? _selectedReason;
  String? _selectedPriority;

  TextEditingController targetAmountController = TextEditingController();
  TextEditingController savingPerWeekController = TextEditingController();
  TextEditingController startingBalanceController = TextEditingController();
  
  double resultWeeks = 0;
  double remainingAmount = 0;

  FocusNode targetFocusNode = FocusNode();
  //FocusNode savingFocusNode = FocusNode();  

  //dropdown reason saving for saving
  static final List<String> _reasonSaving = [
    'Personal',
    'Education',
    'Household',
    'Vacation',
    'Other',
  ];

  //dropdown saving priority
  static final List<String> _savingPriority = [
    'Low',
    'Medium',
    'High',
  ];

  //dispose controllers and focus nodes - clear memory
  @override
  void dispose() {
    targetAmountController.dispose();
    savingPerWeekController.dispose();
    startingBalanceController.dispose();
    targetFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Money Sprint', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryPurple,
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
                  color: primaryPurple.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Track Your Savings!",
                      style: TextStyle(
                        fontSize: 22,
                        color: primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.money, size: 30, color: primaryPurple)
                  ],
                ),
                SizedBox(height: 10),
                //Input - Target Amount
                Row(
                  children: [
                    Expanded( 
                      child: Text('Why do you want to save?', 
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: primaryPurple)
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 150, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: primaryPurple,
                            width: 2.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                              value: _selectedReason,
                              hint: Text('Select'),
                              items: _reasonSaving.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedReason = newValue;
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
                //Input - Target Amount
                Row(
                  children: [
                    Expanded(
                      child: Text('Target Amount (RM)',
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: primaryPurple)
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: targetAmountController,
                          focusNode: targetFocusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: primaryPurple,
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
                            labelText: 'Enter your goal (RM)', labelStyle: TextStyle(fontSize: 12),
                            hintText: 'e.g. 5000.00',
                          )
                        )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Input - Savings Per Week
                Row(
                  children: [
                    Expanded( 
                      child: Text('Savings Per Week (RM)', 
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: primaryPurple,)
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: savingPerWeekController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: primaryPurple,
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
                            labelText: 'Amount Saved Weekly (RM)', labelStyle: TextStyle(fontSize: 12),
                            hintText: 'e.g. 400.00',
                          )
                        )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Input - Starting Balance
                Row(
                  children: [
                    Expanded(
                      child: Text('Starting Balance (RM)', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: primaryPurple)
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: 150,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: startingBalanceController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: primaryPurple,
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
                            labelText: 'Current Savings (RM)', labelStyle: TextStyle(fontSize: 12),
                            hintText: 'e.g. 1200.00'
                          )
                        )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                //Input - Saving Priority
                Row(
                  children: [
                    Expanded(
                      child: Text('Saving Priority', 
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: primaryPurple)
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: primaryPurple,
                            width: 2.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                              value: _selectedPriority,
                              hint: Text('Select'),
                              items: _savingPriority.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPriority = newValue;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Calculate Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 40),
                        backgroundColor: primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: calculateWeeksNeeded,
                      child: Text('Calculate',style: TextStyle(color: Colors.white),),
                    ),
                    // Reset Button
                    ElevatedButton(
                      onPressed: () {
                        targetAmountController.clear();
                        savingPerWeekController.clear();
                        startingBalanceController.clear();
                        _selectedReason = null;
                        _selectedPriority = null;
                        

                        resultWeeks = 0.0;
                        remainingAmount = 0.0;
                        
                        FocusScope.of(context).requestFocus(targetFocusNode);
                        targetFocusNode.requestFocus();

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
                      Icon(Icons.calendar_month_outlined, size: 20, color: primaryPurple),
                      Text('Weeks to reach goal : ',
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: primaryPurple),
                      ),
                      SizedBox(width: 5),
                      Text(resultWeeks.toStringAsFixed(2),
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: primaryPurple),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.money, size: 20, color: primaryPurple),
                      Text('Remaining Amount: ',
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: primaryPurple),
                      ),
                      SizedBox(width: 5),
                      Text(remainingAmount.toStringAsFixed(2),
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: primaryPurple),
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

  void calculateWeeksNeeded() {
    String targetText = targetAmountController.text.trim();
    String savingText = savingPerWeekController.text.trim();
    String balanceText = startingBalanceController.text.trim();
    
    //validate empty or null fields
    if (
      targetText.isEmpty || 
      savingText.isEmpty || 
      balanceText.isEmpty ||
      _selectedReason == null||
      _selectedPriority == null
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the fields.'),
        backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Try parsing to double safely
    double? targetAmount = double.tryParse(targetText);
    double? savingPerWeek = double.tryParse(savingText);
    double? startingBalance = double.tryParse(balanceText);

    //Check for invalid numeric input
    if (
      targetAmount == null || 
      savingPerWeek == null || 
      startingBalance == null
      ) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid numeric values.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    return;
    } 

    if (
      targetAmount <= 0 || 
      savingPerWeek <= 0
      ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Amounts must be greater than zero.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    
    //Calculate remaining amount
    double remaining = targetAmount - startingBalance;

    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already met your savings goal.'),
        backgroundColor: Colors.greenAccent,
        ),
      );
      setState(() {
        resultWeeks = 0.0;
        remaining = 0.0;
      });
      return;
    }

    //Calculate weeks needed
    double weeksNeeded = remaining / savingPerWeek;
    setState(() {
      resultWeeks = weeksNeeded;
      remainingAmount = remaining;
    });

    //Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Goal: $_selectedReason\n'
          'Priority: $_selectedPriority\n'
          'You can reach your goal in ${weeksNeeded.toStringAsFixed(2)} weeks \n'
          'with currently remaining balance of ${remaining.toStringAsFixed(2)}',
        ),
        backgroundColor: Colors.greenAccent,
        duration: Duration(seconds: 3),
      ),
    );
  }
}