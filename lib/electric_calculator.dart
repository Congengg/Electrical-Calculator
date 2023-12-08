import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void  main(){
  runApp(Electricalculator());
}
class Expense{
  final String previousMonth;
  final String currentMonth;

  Expense (this.previousMonth,this.currentMonth);
}

class Electricalculator extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: ExpenseList(),
    );
  }
}

class ExpenseList extends StatefulWidget{
  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final List<Expense> expenses = [];
  final TextEditingController previousController = TextEditingController();
  final TextEditingController currentController = TextEditingController();
  final TextEditingController electricalController = TextEditingController();
  String ratevalue = '';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      previousController.text = prefs.getString('_prevMonth') ?? '';
      currentController.text = prefs.getString('_currMonth') ?? '';
      ratevalue = prefs.getString('_selectedRate') ?? '';
      electricalController.text = prefs.getString('_totalAmount') ?? '';
    });
  }

  void _addExpense() async{
    String previousMonth = previousController.text.trim();
    String currentMonth = currentController.text.trim();
    double rate = 0.0;

    if (previousMonth.isNotEmpty && currentMonth.isNotEmpty && ratevalue.isNotEmpty) {
      if (ratevalue == "Residential") {
        rate = 0.095;
      } else if (ratevalue == "Industrial") {
        rate = 0.125;
      }

      double consumption = double.parse(currentMonth) - double.parse(previousMonth);
      double charge = consumption * rate;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('_prevMonth', previousMonth);
      prefs.setString('_currMonth', currentMonth);
      prefs.setString('_selectedRate', ratevalue);
      prefs.setString('_totalAmount', charge.toStringAsFixed(2));

      setState(() {
        expenses.add(Expense(previousMonth, currentMonth));
        electricalController.text = charge.toStringAsFixed(2); // Display the charge
        previousController.clear();
        currentController.clear();

      });
    }
  }

  void _updateDisplay() {
    setState(() {
      electricalController.text = '';
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electrical Usage Calculator'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: previousController,
              onChanged: (_) => _updateDisplay(),
              decoration: InputDecoration(
                labelText: 'Previous Month Reading(kWh)',
              ),

            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: currentController,
              onChanged: (_) => _updateDisplay(),
              decoration: InputDecoration(
                labelText: 'Current Month Reading(kWh)',
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Radio<String>(value: "Residential", groupValue:ratevalue, onChanged: (value) => setState(() => ratevalue = value!)),
                        Text('Residential'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(value: "Industrial", groupValue:ratevalue , onChanged: (value) => setState(() => ratevalue = value!)),
                        Text('Industrial'),
                      ],
                    ),
                  ],

                ),
              ],

            ),

          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Calculate Charge and Save'),
          ),
          // Container(
          //   child: _buildListView(),
          // ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: electricalController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'RM',
              ),
            ),
          ),
        ],
      ),
    );
  }
}