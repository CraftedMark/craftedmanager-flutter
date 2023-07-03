import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/ingredients_model.dart';

class Recipe {
  final String id;
  String name;
  List<Ingredient> ingredients;
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
  })  : assert(ingredients.length == amounts.length),
        assert(ingredients.length == costs.length);

  Recipe.empty()
      : id = Uuid().v4(),
        name = '',
        ingredients = [],
        amounts = [],
        costs = [],
        pieces = 0,
        steps = [],
        stepImages = [];

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
