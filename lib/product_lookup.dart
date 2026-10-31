import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'food_library.dart';

const deep=Color(0xff101214), surface=Color(0xff212629), lime=Color(0xffd4f18c), muted=Color(0xffaaaead);

class ProductNutrition {
 final String code,name,brand;
 final FoodPortion portion;
 final bool hasAllMacros;
 ProductNutrition(this.code,this.name,this.brand,this.portion,this.hasAllMacros);
 static double? nutrient(Map<String,dynamic> d,String key){
  final v=d[key];
  if(v is num&&v>=0&&v.isFinite)return v.toDouble();
  if(v is String){final n=double.tryParse(v);if(n!=null&&n.isFinite&&n>=0)return n;}
  return null;
 }
 static ProductNutrition? parse(Map<String,dynamic> obj){
  final name=(obj['product_name_pt']??obj['product_name']??'').toString().trim();
  final raw=obj['nutriments']; if(name.isEmpty||raw is! Map)return null;
  final n=Map<String,dynamic>.from(raw);
  final kj=nutrient(n,'energy_100g');
  final kcal=nutrient(n,'energy-kcal_100g')??(kj==null?null:kj/4.184);
  if(kcal==null||kcal>1500)return null;
  final protein=nutrient(n,'proteins_100g'),carbs=nutrient(n,'carbohydrates_100g'),
   fat=nutrient(n,'fat_100g'),sugar=nutrient(n,'sugars_100g');
  final complete=protein!=null&&carbs!=null&&fat!=null&&sugar!=null;
  return ProductNutrition((obj['code']??'').toString(),name,(obj['brands']??'').toString(),
   FoodPortion(name,'Open Food Facts',100,kcal,protein??0,carbs??0,fat??0,sugar??0),complete);
 }
}
class ProductApi {
 final http.Client client;
 ProductApi(this.client);
 static const host='world.openfoodfacts.org';
 static const fields='code,product_name,product_name_pt,brands,nutriments';
 static const headers={'User-Agent':'SOMAHealth/0.3 (https://github.com/yuregabriell/Soma-Health)','Accept':'application/json'};
 Future<dynamic> get(Uri u)async{
  final r=await client.get(u,headers:headers).timeout(const Duration(seconds:18));
  if(r.statusCode==429)throw const FormatException('Limite de pedidos atingido. Tenta mais tarde.');
  if(r.statusCode!=200)throw const FormatException('O catálogo está indisponível.');
  return jsonDecode(utf8.decode(r.bodyBytes));
 }
 Future<List<ProductNutrition>> search(String term)async{
  if(term.trim().length<2)return [];
  final result=await get(Uri.https(host,'/cgi/search.pl',{'search_terms':term,'search_simple':'1','action':'process',
   'json':'1','page_size':'18','fields':fields}));
  if(result is! Map||result['products'] is! List)return [];
  final list=<ProductNutrition>[],seen=<String>{};
  for(final item in result['products'] as List){
   if(item is! Map)continue;
   final p=ProductNutrition.parse(Map<String,dynamic>.from(item));
   if(p!=null&&seen.add(p.code.isNotEmpty?p.code:p.name))list.add(p);
  }
  return list;
 }
 Future<ProductNutrition?> lookup(String code)async{
  if(!RegExp(r'^[0-9]{8,14}$').hasMatch(code))throw const FormatException('Código inválido (8 a 14 dígitos).');
  final data=await get(Uri.https(host,'/api/v2/product/'+code+'.json',{'fields':fields}));
  if(data is! Map||data['status']==0||data['product'] is! Map)return null;
  return ProductNutrition.parse(Map<String,dynamic>.from(data['product'] as Map));
 }
}
class ProductSearchScreen extends StatefulWidget{
 const ProductSearchScreen({super.key});
 @override State<ProductSearchScreen> createState()=>_ProductSearchState();
}
class _ProductSearchState extends State<ProductSearchScreen>{
 final search=TextEditingController(),grams=TextEditingController(text:'100'),httpClient=http.Client();
 late final api=ProductApi(httpClient);
 List<ProductNutrition> results=[];
 ProductNutrition? selected;
 bool loading=false;String? error;int seq=0;
 @override void dispose(){seq++;search.dispose();grams.dispose();httpClient.close();super.dispose();}
 Future<void> find([String? code])async{
  final token=++seq;
  setState((){loading=true;error=null;selected=null;results=[];});
  try{
   if(code!=null){
    final product=await api.lookup(code);
    if(!mounted||token!=seq)return;
    setState((){results=product==null?[]:[product];selected=product;
     if(product==null)error='Produto não encontrado. Utiliza o registo manual.';});
   }else{
    final found=await api.search(search.text);
    if(!mounted||token!=seq)return;
    setState((){results=found;if(found.isEmpty)error='Nenhum produto encontrado.';});
   }
  }catch(e){
   if(mounted&&token==seq)setState(()=>error=e is FormatException?e.message:'Sem ligação. Experimenta a biblioteca offline.');
  }finally{if(mounted&&token==seq)setState(()=>loading=false);}
 }
 Future<void> scan()async{
  final code=await Navigator.of(context).push<String>(MaterialPageRoute(builder:(_)=>const BarcodePage()));
  if(mounted&&code!=null)await find(code);
 }
 Future<void> manualBarcode()async{
  final c=TextEditingController();
  final code=await showDialog<String>(context:context,builder:(x)=>AlertDialog(title:const Text('Código de barras'),
   content:TextField(controller:c,keyboardType:TextInputType.number,decoration:const InputDecoration(hintText:'EAN / UPC')),
   actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('Cancelar')),
    FilledButton(onPressed:()=>Navigator.pop(x,c.text.trim()),child:const Text('Pesquisar'))]));
  c.dispose();
  if(mounted&&code!=null&&code.isNotEmpty)await find(code);
 }
 @override Widget build(BuildContext context){
  final g=double.tryParse(grams.text.replaceAll(',','.'))??0;
  final serving=selected?.portion.forGrams(g.clamp(0,2000));
  return Scaffold(backgroundColor:deep,appBar:AppBar(title:const Text('Produtos e marcas'),backgroundColor:deep),
   body:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(16,10,16,8),child:Row(children:[
     Expanded(child:TextField(controller:search,onSubmitted:(_)=>find(),
      decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'Pesquisar produto',
       filled:true,fillColor:surface,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none)))),
     IconButton.filled(onPressed:()=>find(),icon:const Icon(Icons.arrow_forward)),
    ])),
    Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Row(children:[
     Expanded(child:OutlinedButton.icon(onPressed:scan,icon:const Icon(Icons.qr_code_scanner),label:const Text('Ler código'))),
     const SizedBox(width:8),
     Expanded(child:OutlinedButton.icon(onPressed:manualBarcode,icon:const Icon(Icons.numbers),label:const Text('Digitar código')))
    ])),
    if(loading)const LinearProgressIndicator(minHeight:2),
    if(error!=null)Padding(padding:const EdgeInsets.all(17),child:Text(error!,style:const TextStyle(color:muted))),
    Expanded(child:ListView.builder(itemCount:results.length,itemBuilder:(x,i){
     final p=results[i];return ListTile(title:Text(p.name,maxLines:2,overflow:TextOverflow.ellipsis),
      subtitle:Text((p.brand.isEmpty?'Produto':p.brand)+' · '+p.portion.kcal.round().toString()+' kcal/100g'),
      trailing:p==selected?const Icon(Icons.check_circle,color:lime):const Icon(Icons.chevron_right),
      onTap:()=>setState(()=>selected=p));
    })),
    if(serving!=null)Container(color:surface,padding:const EdgeInsets.fromLTRB(18,15,18,22),
     child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(selected!.name,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:18)),
      const SizedBox(height:10),
      TextField(controller:grams,onChanged:(_)=>setState((){}),keyboardType:const TextInputType.numberWithOptions(decimal:true),
       decoration:const InputDecoration(labelText:'Porção consumida',suffixText:'g')),
      const SizedBox(height:10),
      Text(serving.kcal.round().toString()+' kcal · '+serving.protein.toStringAsFixed(1)+' g proteína',
       style:const TextStyle(color:lime,fontWeight:FontWeight.bold)),
      Text('Hidratos '+serving.carbs.toStringAsFixed(1)+' g · Gorduras '+serving.fats.toStringAsFixed(1)+' g · Açúcares '+serving.sugar.toStringAsFixed(1)+' g',
       style:const TextStyle(fontSize:12,color:muted)),
      if(!selected!.hasAllMacros)const Padding(padding:EdgeInsets.only(top:9),
       child:Text('Dados nutricionais incompletos; alguns campos ausentes aparecem como 0.',style:TextStyle(fontSize:11,color:Colors.orangeAccent))),
      const SizedBox(height:8),
      const Text('Dados: Open Food Facts (ODbL). Confirma sempre os valores na embalagem.',style:TextStyle(fontSize:11,color:muted)),
      const SizedBox(height:14),
      SizedBox(width:double.infinity,child:FilledButton(onPressed:g<=0||g>2000?null:()=>Navigator.pop(context,serving),
       child:const Text('Adicionar refeição'))),
     ]))
   ])));
 }
}
class BarcodePage extends StatefulWidget{
 const BarcodePage({super.key});
 @override State<BarcodePage> createState()=>_BarcodeState();
}
class _BarcodeState extends State<BarcodePage>{
 bool detected=false;
 @override Widget build(BuildContext context)=>Scaffold(backgroundColor:deep,
  appBar:AppBar(title:const Text('Digitalizar código'),backgroundColor:deep),
  body:Stack(children:[
   MobileScanner(onDetect:(capture){
    if(detected)return;
    for(final barcode in capture.barcodes){
     final code=barcode.rawValue;
     if(code!=null&&RegExp(r'^[0-9]{8,14}$').hasMatch(code)){
      detected=true;Navigator.pop(context,code);break;
     }
    }
   }),
   Center(child:IgnorePointer(child:Container(width:255,height:165,
    decoration:BoxDecoration(border:Border.all(color:lime,width:3),borderRadius:BorderRadius.circular(16))))),
   const Positioned(bottom:35,left:20,right:20,child:Text('Enquadra o código de barras do produto.',
    textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),
  ]));
 }
}
