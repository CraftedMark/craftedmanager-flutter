import 'package:flutter/material.dart';

class ChocoBarCalc extends StatefulWidget {
  @override
  _ChocoBarCalcState createState() => _ChocoBarCalcState();
}

class _ChocoBarCalcState extends State<ChocoBarCalc> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController totalActiveController = TextEditingController();
  final TextEditingController totalBarsController = TextEditingController();
  final TextEditingController chocolateCostController = TextEditingController();
  final TextEditingController activeCostController = TextEditingController();

  double resultChocolateNeeded = 0.0;
  double resultBarsProduced = 0.0;
  double resultCostPerBar = 0.0;
  double totalActive = 0.0;
  double activeCostPerPound = 0.0;

  double convertToGrams(double weight, String unit) {
    switch (unit) {
      case 'lbs':
        return weight * 453.592;
      default:
        return weight;
    }
  }

  double convertGramsToPounds(double weightInGrams) {
    return weightInGrams * 0.00220462;
  }

  double convertCostPerGramToCostPerPound(double costPerGram) {
    return costPerGram * 453.592;
  }

  void calculateEverything() {
    try {
      double weight = weightController.text.isNotEmpty
          ? double.parse(weightController.text)
          : 0.0;
      double dosage = dosageController.text.isNotEmpty
          ? double.parse(dosageController.text)
          : 0.0;
      double chocolateCost = chocolateCostController.text.isNotEmpty
          ? double.parse(chocolateCostController.text)
          : 0.0;
      double activeCost = activeCostController.text.isNotEmpty
          ? double.parse(activeCostController.text)
          : 0.0;
      int totalBars = totalBarsController.text.isNotEmpty
          ? int.parse(totalBarsController.text)
          : 0;

      if (weight > 0 && totalBars > 0) {
        resultChocolateNeeded = weight * totalBars;
      }

      if (dosage > 0) {
        if (totalBars > 0) {
          totalActive = dosage * totalBars;
          totalActiveController.text = totalActive.toString();
          resultBarsProduced = totalBars.toDouble();
        } else if (totalActiveController.text.isNotEmpty) {
          totalActive = double.parse(totalActiveController.text);
          resultBarsProduced = totalActive / dosage;
          totalBarsController.text = resultBarsProduced.round().toString();
          if (weight > 0) {
            resultChocolateNeeded = weight * resultBarsProduced;
          }
        }
      }

      if (weight > 0 && dosage > 0 && chocolateCost > 0 && activeCost > 0) {
        resultCostPerBar = (weight * chocolateCost) + (dosage * activeCost);
        activeCostPerPound = convertCostPerGramToCostPerPound(activeCost);
      } else if (weight > 0 && dosage > 0 && chocolateCost > 0) {
        activeCost = dosage * chocolateCost;
        activeCostController.text = activeCost.toString();
        resultCostPerBar = (weight * chocolateCost) + (activeCost * totalBars);
        activeCostPerPound = convertCostPerGramToCostPerPound(activeCost);
      }

      setState(() {});
    } catch (FormatException) {
      print('Please enter valid numbers.');
      // You can replace the print statement with a dialog or a snackbar to show the error to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chocolate Bar Calculator"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight of Each Bar (in grams)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosage Per Bar (in grams)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: totalActiveController,
                decoration: InputDecoration(
                  labelText: 'Total Active Ingredient Available (in grams)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: totalBarsController,
                decoration: InputDecoration(
                  labelText: 'Total Number of Bars to Produce',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: chocolateCostController,
                decoration: InputDecoration(
                  labelText: 'Cost of Chocolate per gram',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: activeCostController,
                decoration: InputDecoration(
                  labelText: 'Cost of Active Ingredient per gram',
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                child: Text('Calculate Everything'),
                onPressed: () {
                  calculateEverything();
                },
              ),
              Text(
                  'Total Chocolate Needed: $resultChocolateNeeded grams (${convertGramsToPounds(resultChocolateNeeded)} lbs)'),
              Text(
                  'Total Active Ingredient Needed: $totalActive grams (${convertGramsToPounds(totalActive)} lbs)'),
              Text('Total Bars that can be Produced: $resultBarsProduced'),
              Text('Cost Per Bar: \$ $resultCostPerBar'),
              Text('Cost of Active Ingredient per lb: \$ $activeCostPerPound'),
            ],
          ),
        ),
      ),
    );
  }
}
