import 'package:flutter/material.dart';

class MaterialCalculator extends StatefulWidget {
  @override
  _MaterialCalculatorState createState() => _MaterialCalculatorState();
}

class _MaterialCalculatorState extends State<MaterialCalculator> {
  final TextEditingController _activeIngredientController =
      TextEditingController();
  final TextEditingController _mgPerPieceController = TextEditingController();
  final TextEditingController _numPiecesController = TextEditingController();
  final TextEditingController _multiplierController = TextEditingController();
  double _totalMaterialNeeded = 0;

  void _calculateMaterial() {
    double activeIngredientPercent =
        double.parse(_activeIngredientController.text);
    double mgPerPiece = double.parse(_mgPerPieceController.text);
    int numPieces = int.parse(_numPiecesController.text);
    double multiplier = double.parse(_multiplierController.text);

    double totalActiveIngredientNeeded =
        (mgPerPiece * numPieces * multiplier) / 1000;
    _totalMaterialNeeded =
        totalActiveIngredientNeeded / (activeIngredientPercent / 100);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _activeIngredientController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Active Ingredient Percent',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _mgPerPieceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Mg per Piece',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _numPiecesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Pieces',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _multiplierController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Multiplier',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateMaterial,
                child: Text('Calculate Material'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Total Material Needed: ${_totalMaterialNeeded.toStringAsFixed(2)} grams',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
