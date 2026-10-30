import 'package:flutter/material.dart';

class FoodPortion {
  final String name,category;
  final double grams,kcal,protein,carbs,fats,sugar;
  const FoodPortion(this.name,this.category,this.grams,this.kcal,this.protein,this.carbs,this.fats,this.sugar);
  FoodPortion forGrams(double grams) => FoodPortion(name,category,grams,kcal*grams/100,
    protein*grams/100,carbs*grams/100,fats*grams/100,sugar*grams/100);
}
/// Informative, approximate reference values per 100 grams. Not medical-grade.
const foods=<FoodPortion>[
  FoodPortion('Frango cozinhado','Proteínas',100,165,31,0,3.6,0),
  FoodPortion('Ovo cozido','Proteínas',100,155,13,1.1,11,1.1),
  FoodPortion('Atum em água','Proteínas',100,116,26,0,1,0),
  FoodPortion('Salmão cozinhado','Proteínas',100,206,22,0,12,0),
  FoodPortion('Tofu firme','Proteínas',100,144,17,3,8.7,.6),
  FoodPortion('Feijão preto cozido','Leguminosas',100,132,8.9,23.7,.5,.3),
  FoodPortion('Lentilhas cozidas','Leguminosas',100,116,9,20,.4,1.8),
  FoodPortion('Arroz branco cozido','Cereais',100,130,2.7,28.2,.3,.1),
  FoodPortion('Arroz integral cozido','Cereais',100,123,2.7,25.6,1,.2),
  FoodPortion('Aveia','Cereais',100,389,16.9,66.3,6.9,1),
  FoodPortion('Pão integral','Cereais',100,247,13,41,4.2,5.6),
  FoodPortion('Batata cozida','Tubérculos',100,87,1.9,20,.1,.9),
  FoodPortion('Batata doce cozida','Tubérculos',100,76,1.4,17.7,.1,5.7),
  FoodPortion('Brócolos cozidos','Vegetais',100,35,2.4,7.2,.4,1.4),
  FoodPortion('Cenoura crua','Vegetais',100,41,.9,9.6,.2,4.8),
  FoodPortion('Tomate','Vegetais',100,18,.9,3.9,.2,2.6),
  FoodPortion('Maçã com casca','Frutas',100,52,.3,13.8,.2,10.4),
  FoodPortion('Banana','Frutas',100,89,1.1,22.8,.3,12.2),
  FoodPortion('Laranja','Frutas',100,47,.9,11.8,.1,9.4),
  FoodPortion('Iogurte natural','Laticínios',100,61,3.5,4.7,3.3,4.7),
  FoodPortion('Leite meio gordo','Laticínios',100,47,3.4,4.8,1.6,4.8),
  FoodPortion('Azeite','Gorduras',100,884,0,0,100,0),
  FoodPortion('Amêndoas','Gorduras',100,579,21,22,50,4.4),
  FoodPortion('Abacate','Gorduras',100,160,2,8.5,14.7,.7),
];

class FoodPicker extends StatefulWidget {
  const FoodPicker({super.key});
  @override State<FoodPicker> createState()=>_FoodPickerState();
}
class _FoodPickerState extends State<FoodPicker> {
  String query='';
  FoodPortion? selected;
  final grams=TextEditingController(text:'100');
  @override void dispose(){grams.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    const lime=Color(0xffD4F18C);
    final matches=foods.where((f)=>(f.name+' '+f.category).toLowerCase().contains(query.toLowerCase())).toList();
    final g=double.tryParse(grams.text.replaceAll(',','.'))??0;
    final portion=selected?.forGrams(g.clamp(0,2000));
    return Scaffold(backgroundColor:const Color(0xff111315),
      appBar:AppBar(title:const Text('Biblioteca alimentar'),backgroundColor:const Color(0xff111315)),
      body:SafeArea(child:Column(children:[
        Padding(padding:const EdgeInsets.all(16),
          child:TextField(onChanged:(s)=>setState(()=>query=s),
            decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'Pesquisar alimento',
            filled:true,fillColor:const Color(0xff22272a),border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none)))),
        Expanded(child:ListView.builder(itemCount:matches.length,itemBuilder:(ctx,i){
          final f=matches[i];
          return ListTile(
            title:Text(f.name),
            subtitle:Text(f.category+' • '+f.kcal.toStringAsFixed(0)+' kcal / 100 g'),
            trailing:selected==f?const Icon(Icons.check_circle,color:lime):const Icon(Icons.chevron_right),
            onTap:()=>setState(()=>selected=f));
        })),
        if(portion!=null)Container(
          decoration:const BoxDecoration(color:Color(0xff22272a),borderRadius:BorderRadius.vertical(top:Radius.circular(22))),
          padding:const EdgeInsets.fromLTRB(20,16,20,16),
          child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(selected!.name,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const SizedBox(height:12),
            TextField(controller:grams,onChanged:(_)=>setState((){}),keyboardType:const TextInputType.numberWithOptions(decimal:true),
              decoration:const InputDecoration(labelText:'Peso da porção em gramas')),
            const SizedBox(height:10),
            Text('Estimativa: '+portion.kcal.round().toString()+' kcal • '+portion.protein.toStringAsFixed(1)+' g proteína',
              style:const TextStyle(color:lime)),
            const SizedBox(height:6),
            Text('Hidratos '+portion.carbs.toStringAsFixed(1)+' g • Gorduras '+portion.fats.toStringAsFixed(1)+' g • Açúcares '+portion.sugar.toStringAsFixed(1)+' g',
              style:const TextStyle(fontSize:12,color:Colors.white70)),
            const SizedBox(height:8),
            const Text('Estimativas por 100 g: confirma marcas, porções e preparação.',
              style:TextStyle(color:Colors.white60,fontSize:11)),
            const SizedBox(height:12),
            SizedBox(width:double.infinity,child:FilledButton(onPressed:g<=0||g>2000?null:()=>Navigator.pop(context,portion),
              child:const Text('Adicionar ao diário'))),
          ]),
        )
      ])));
  }
}
