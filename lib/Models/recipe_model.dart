import 'dart:convert';

import 'package:uuid/uuid.dart';

class Recipe {
  String id;
  String name;
  List<String> ingredients;
  List<double> amounts;
  List<double> costs;
  int pieces;
  List<String> steps;
  List<String> stepImages;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.amounts,
    required this.costs,
    required this.pieces,
    required this.steps,
    required this.stepImages,
  }) {
    var uuid = Uuid();
    id = uuid.v4();
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      ingredients: jsonDecode(json['ingredients']),
      amounts: (jsonDecode(json['amounts']) as List<dynamic>)
          .map<double>((e) => e.toDouble())
          .toList(),
      costs: (jsonDecode(json['costs']) as List<dynamic>)
          .map<double>((e) => e.toDouble())
          .toList(),
      pieces: json['pieces'],
      steps: jsonDecode(json['steps']),
      stepImages: jsonDecode(json['step_images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ingredients': jsonEncode(ingredients),
      'amounts': jsonEncode(amounts),
      'costs': jsonEncode(costs),
      'pieces': pieces,
      'steps': jsonEncode(steps),
      'step_images': jsonEncode(stepImages),
    };
  }

  double get costPerPiece {
    double totalCost = 0;
    for (int i = 0; i < ingredients.length; i++) {
      totalCost += amounts[i] * costs[i];
    }
    return totalCost / pieces;
  }
}
