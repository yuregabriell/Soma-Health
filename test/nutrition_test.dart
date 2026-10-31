import 'package:flutter_test/flutter_test.dart';
import 'package:soma_health/food_library.dart';
import 'package:soma_health/product_lookup.dart';

void main() {
 test('offline portion scales macronutrients', () {
  final apple=foods.firstWhere((f)=>f.name=='Maçã com casca');
  final portion=apple.forGrams(150);
  expect(portion.grams,150);
  expect(portion.kcal,closeTo(78,0.001));
  expect(portion.sugar,closeTo(15.6,0.001));
 });
 test('Open Food Facts product decoded with complete macros', () {
  final p=ProductNutrition.parse({
   'code':'5600000000000','product_name':'Iogurte',
   'brands':'Example','nutriments':{
    'energy-kcal_100g':60,
    'proteins_100g':4,
    'carbohydrates_100g':5,
    'fat_100g':2,
    'sugars_100g':4.5,
   }
  });
  expect(p, isNotNull);
  expect(p!.hasAllMacros,true);
  expect(p.portion.forGrams(200).kcal,120);
  expect(p.portion.forGrams(200).protein,8);
 });
 test('missing calories are not silently fabricated', () {
  final p=ProductNutrition.parse({'product_name':'Unknown','nutriments':{'proteins_100g':5}});
  expect(p,isNull);
 });
 test('missing macronutrients trigger incomplete flag', () {
  final p=ProductNutrition.parse({'product_name':'Partial','nutriments':{'energy_100g':418.4}});
  expect(p,isNotNull);
  expect(p!.hasAllMacros,false);
  expect(p.portion.kcal,closeTo(100,0.01));
 });
}
