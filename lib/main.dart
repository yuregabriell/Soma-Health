import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bg=Color(0xff101214), panel=Color(0xff1c2022), muted=Color(0xffa2a8a6);
const white=Color(0xfff6f7f3), lime=Color(0xffd4f18c);
void main(){WidgetsFlutterBinding.ensureInitialized();runApp(const Soma());}
String date(){final x=DateTime.now();return x.year.toString()+'-'+x.month.toString()+'-'+x.day.toString();}
double value(dynamic x,[double otherwise=0])=>x is num?x.toDouble():otherwise;
Widget pad(Widget child,{double h=20})=>Padding(padding:EdgeInsets.symmetric(horizontal:h),child:child);
Widget tile(Widget child)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0xff33383a))),child:child);
Widget heading(String eye,String name)=>Padding(padding:const EdgeInsets.fromLTRB(20,20,20,22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(eye,style:const TextStyle(color:lime,fontSize:11,letterSpacing:2.2,fontWeight:FontWeight.bold)),const Text('SŌMA',style:TextStyle(color:white,fontSize:16,letterSpacing:3,fontWeight:FontWeight.w900))]),
 const SizedBox(height:17),Text(name,style:const TextStyle(color:white,fontSize:30,fontWeight:FontWeight.w800,letterSpacing:-.7))]));
Widget title(String t,String hint)=>Padding(padding:const EdgeInsets.fromLTRB(20,28,20,14),child:Row(children:[Expanded(child:Text(t,style:const TextStyle(color:white,fontSize:21,fontWeight:FontWeight.bold))),Text(hint,style:const TextStyle(color:muted,fontSize:11))]));
Widget picture(String url)=>Image.network(url,fit:BoxFit.cover,errorBuilder:(c,e,s)=>Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xff46543f),Color(0xff181c23)],begin:Alignment.topLeft,end:Alignment.bottomRight)),child:const Center(child:Icon(Icons.spa,color:lime,size:58))));
Widget feature(String label, String text, String sub, String img, VoidCallback tap, {double height = 280}) {
  return pad(
    GestureDetector(
      onTap: tap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              picture(img),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xee050707)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: lime, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(text, style: const TextStyle(color: white, fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    Text(sub, style: const TextStyle(color: Color(0xffe5e5df), fontSize: 13)),
                    const SizedBox(height: 12),
                    const Row(children: [
                      Text('EXPLORAR', style: TextStyle(color: lime, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: lime, size: 16),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget metric(String label,String val,IconData icon)=>tile(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:lime),const SizedBox(height:15),Text(val,style:const TextStyle(color:white,fontSize:23,fontWeight:FontWeight.bold)),const SizedBox(height:5),Text(label,style:const TextStyle(color:muted,fontSize:10,letterSpacing:1))]));
Widget action(String label,String note,String button,IconData icon,VoidCallback press)=>tile(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 Icon(icon,color:lime,size:28),const SizedBox(height:13),Text(label,style:const TextStyle(fontSize:18,color:white,fontWeight:FontWeight.bold)),const SizedBox(height:8),
 Text(note,style:const TextStyle(color:muted,height:1.4)),const SizedBox(height:8),
 TextButton.icon(onPressed:press,label:Text(button.toUpperCase()),icon:const Icon(Icons.arrow_forward),iconAlignment:IconAlignment.end)]));
class Soma extends StatefulWidget{const Soma({super.key});@override State<Soma> createState()=>_SomaState();}
class _SomaState extends State<Soma>{
 int tab=0,water=0,sessions=0,goal=2000;double sleep=7.5,weight=75,height=175;String mood='Bem';bool loaded=false;
 List<Map<String,dynamic>> meals=[],glucose=[],weights=[];
 @override void initState(){super.initState();load();}
 Future<void> load()async{
  try{final p=await SharedPreferences.getInstance();final m=jsonDecode(p.getString('soma_v1')??'{}') as Map<String,dynamic>;
  if(!mounted)return;setState((){
    water=m['day']==date()?(m['water'] as num? ??0).toInt():0;goal=(m['goal'] as num? ??2000).toInt();
    sleep=value(m['sleep'],7.5);weight=value(m['weight'],75);height=value(m['height'],175);
    sessions=(m['sessions'] as num? ??0).toInt();mood=m['mood'] as String? ??'Bem';
    meals=(m['meals'] as List? ??[]).map((e)=>Map<String,dynamic>.from(e as Map)).toList();
    glucose=(m['glucose'] as List? ??[]).map((e)=>Map<String,dynamic>.from(e as Map)).toList();
    weights=(m['weights'] as List? ??[]).map((e)=>Map<String,dynamic>.from(e as Map)).toList();
  });}catch(_){}
  if(mounted)setState(()=>loaded=true);
 }
 void update(VoidCallback fn){setState(fn);persist();}
 Future<void> persist()async{final p=await SharedPreferences.getInstance();await p.setString('soma_v1',jsonEncode({
 'water':water,'day':date(),'goal':goal,'sleep':sleep,'weight':weight,'height':height,
 'sessions':sessions,'mood':mood,'meals':meals,'glucose':glucose,'weights':weights}));}
 Future<void> askNumber(String label,String hint,void Function(double) save)async{
  final c=TextEditingController();
  final n=await showDialog<double>(context:context,builder:(d)=>AlertDialog(backgroundColor:panel,title:Text(label),content:TextField(controller:c,autofocus:true,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(hintText:hint)),actions:[
   TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancelar')),
   FilledButton(onPressed:()=>Navigator.pop(d,double.tryParse(c.text.replaceAll(',','.'))),child:const Text('Guardar'))]));
  c.dispose();if(n!=null&&n.isFinite&&n>0&&mounted)save(n);
 }
 Future<void> addMeal()async{
  final name=TextEditingController(),cal=TextEditingController(),prot=TextEditingController(),carb=TextEditingController(),fat=TextEditingController(),sugar=TextEditingController();
  XFile? image;
  final entry=await showModalBottomSheet<Map<String,dynamic>>(context:context,isScrollControlled:true,backgroundColor:panel,showDragHandle:true,builder:(d)=>StatefulBuilder(builder:(ctx,setSheet)=>Padding(padding:EdgeInsets.fromLTRB(22,8,22,MediaQuery.viewInsetsOf(ctx).bottom+24),child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const Text('Registar refeição',style:TextStyle(color:white,fontSize:26,fontWeight:FontWeight.bold)),
   const SizedBox(height:8),const Text('A análise por IA ainda não está ligada. Confirma os nutrientes manualmente.',style:TextStyle(color:muted)),
   const SizedBox(height:14),
   OutlinedButton.icon(onPressed:()async{final p=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:75);if(p!=null)setSheet(()=>image=p);},icon:const Icon(Icons.photo_library_outlined),label:Text(image==null?'Selecionar fotografia':'Fotografia selecionada')),
   const SizedBox(height:12),input(name,'Alimento ou refeição'),input(cal,'Calorias (kcal)',num:true),
   Row(children:[Expanded(child:input(prot,'Proteína (g)',num:true)),const SizedBox(width:10),Expanded(child:input(carb,'Hidratos (g)',num:true))]),
   Row(children:[Expanded(child:input(fat,'Gorduras (g)',num:true)),const SizedBox(width:10),Expanded(child:input(sugar,'Açúcares (g)',num:true))]),
   const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:(){
    if(name.text.trim().isEmpty)return;
    double n(TextEditingController c)=>max(0,double.tryParse(c.text.replaceAll(',','.'))??0);
    Navigator.pop(ctx,{'name':name.text.trim(),'cal':n(cal),'prot':n(prot),'carb':n(carb),'fat':n(fat),'sugar':n(sugar),'day':date()});}
    ,child:const Text('Adicionar ao diário'))),
  ])))));
  for(final c in [name,cal,prot,carb,fat,sugar]){c.dispose();}
  if(entry!=null)update(()=>meals.insert(0,entry));
 }
 Widget input(TextEditingController c,String label,{bool num=false})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c,keyboardType:num?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,decoration:InputDecoration(labelText:label,filled:true,fillColor:const Color(0xff2b3032),border:OutlineInputBorder(borderRadius:BorderRadius.circular(11),borderSide:BorderSide.none))));
 void aiInfo()=>showModalBottomSheet<void>(context:context,backgroundColor:panel,showDragHandle:true,builder:(c)=>Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
 const Icon(Icons.auto_awesome,color:lime,size:35),const SizedBox(height:14),
 const Text('Scanner nutricional',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:white)),const SizedBox(height:10),
 const Text('A integração com ChatGPT e a identificação automática dos alimentos ainda não estão disponíveis na v0.1. Esta versão oferece registo manual, sem inventar resultados de IA.',style:TextStyle(color:muted,height:1.5)),
 const SizedBox(height:20),SizedBox(width:double.infinity,child:FilledButton(onPressed:(){Navigator.pop(c);addMeal();},child:const Text('Registar manualmente'))),const SizedBox(height:12)])));
 @override Widget build(BuildContext context)=>MaterialApp(title:'SŌMA',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,brightness:Brightness.dark,scaffoldBackgroundColor:bg,colorScheme:ColorScheme.fromSeed(seedColor:lime,brightness:Brightness.dark),filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:lime,foregroundColor:bg,minimumSize:const Size(10,48)))),home:Scaffold(
 body:SafeArea(child:!loaded?const Center(child:CircularProgressIndicator()):IndexedStack(index:tab,children:[todayPage(),nutritionPage(),TrainingPage(done:()=>update(()=>sessions++)),healthPage(),progressPage()])),
 bottomNavigationBar:SafeArea(top:false,child:Container(height:70,decoration:const BoxDecoration(color:Color(0xff191c1f),border:Border(top:BorderSide(color:Color(0xff363a3a)))),child:Row(children:[
 nav(0,Icons.home_outlined,'Hoje'),nav(1,Icons.restaurant_outlined,'Nutrição'),nav(2,Icons.fitness_center,'Treinar'),nav(3,Icons.favorite_border,'Saúde'),nav(4,Icons.auto_graph,'Evolução')])))));
 Widget nav(int n,IconData icon,String label)=>Expanded(child:InkWell(onTap:()=>setState(()=>tab=n),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
 Icon(icon,color:tab==n?lime:muted,size:24),const SizedBox(height:5),Text(label,style:TextStyle(color:tab==n?white:muted,fontSize:10,fontWeight:tab==n?FontWeight.bold:FontWeight.normal))])));
 Widget todayPage()=>ListView(children:[
 heading('A TUA ROTINA','Cuida de ti, todos os dias.'),
 feature('HOJE É DIA DE MOVIMENTO','Constrói a tua melhor versão','Plano guiado de força e condicionamento','https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=900',()=>setState(()=>tab=2)),
 title('A tua rotina','Registos de hoje'),
 pad(Row(children:[Expanded(child:metric('ÁGUA',water.toString()+' ml',Icons.water_drop_outlined)),const SizedBox(width:10),Expanded(child:metric('SONO',sleep.toStringAsFixed(1)+' h',Icons.nightlight_outlined))])),
 title('Para ti','Descobre e explora'),
 feature('NUTRIÇÃO','Escolhas equilibradas','Regista uma refeição e os teus nutrientes','https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=900',()=>setState(()=>tab=1),height:215),
 const SizedBox(height:14),
 feature('DESCANSO','Recupera com intenção','Sono, respiração e bem-estar','https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=900',()=>setState(()=>tab=3),height:215),
 title('ASSISTENTE','Nutrição visual'),
 pad(action('Analisar uma refeição','Fotografia e chat serão integrados numa atualização.','Abrir',Icons.auto_awesome,aiInfo)),
 const SizedBox(height:32)]);
 Widget nutritionPage(){
 final t=meals.where((m)=>m['day']==date()).toList();
 double sum(String key)=>t.fold(0.0,(n,m)=>n+value(m[key]));
 return ListView(children:[
 heading('NUTRIÇÃO','Começa por te conhecer.'),
 feature('DIÁRIO DE REFEIÇÕES','Alimenta o teu potencial','Acompanhar calorias e nutrientes','https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=900',addMeal),
 title('Hoje','Registos manuais'),
 pad(Wrap(spacing:10,runSpacing:10,children:[metric('ENERGIA',sum('cal').round().toString()+' kcal',Icons.local_fire_department_outlined),metric('PROTEÍNA',sum('prot').toStringAsFixed(1)+' g',Icons.egg_outlined)])),
 title('Refeições',t.length.toString()+' registadas'),
 if(t.isEmpty)pad(action('Ainda não registaste refeições','Adiciona os ingredientes e as quantidades manualmente.','Adicionar',Icons.restaurant,addMeal)),
 ...t.map((m)=>Padding(padding:const EdgeInsets.fromLTRB(20,0,20,9),child:tile(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(m['name'].toString(),style:const TextStyle(color:white,fontSize:17,fontWeight:FontWeight.bold)),const SizedBox(height:5),Text(value(m['cal']).round().toString()+' kcal • '+value(m['prot']).toStringAsFixed(1)+' g proteína',style:const TextStyle(color:muted))])))),
 const SizedBox(height:12),pad(action('Scanner com fotografia','A versão atual não interpreta automaticamente os alimentos.','Abrir',Icons.camera_alt_outlined,aiInfo)),const SizedBox(height:32)]);
 }
 Widget healthPage()=>ListView(children:[
 heading('BEM-ESTAR','Equilíbrio é progresso.'),
 feature('CUIDADO PESSOAL','Tempo para recuperar','Sono, hidratação e equilíbrio emocional','https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=900',()=>{}),
 title('Hidratação','Meta ajustável'),
 pad(tile(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 Text(water.toString()+' / '+goal.toString()+' ml',style:const TextStyle(color:white,fontSize:28,fontWeight:FontWeight.bold)),
 const SizedBox(height:14),LinearProgressIndicator(value:(water/max(1,goal)).clamp(0.0,1.0),minHeight:7,color:lime,backgroundColor:const Color(0xff3b4142)),
 const SizedBox(height:16),
 Row(children: [150, 250, 500].map((x) {
   return Expanded(child: Padding(
     padding: const EdgeInsets.only(right: 5),
     child: OutlinedButton(
       onPressed: () => update(() => water += x),
       child: Text('+' + x.toString(), style: const TextStyle(fontSize: 12)),
     ),
   ));
 }).toList()),
 TextButton(onPressed:()=>askNumber('Meta diária de água','Mililitros',(x)=>update(()=>goal=x.round())),child:const Text('Alterar meta'))
 ]))),
 title('Sono','Última noite'),
 pad(tile(Column(children:[Text(sleep.toStringAsFixed(1)+' horas',style:const TextStyle(color:white,fontSize:22)),Slider(value:sleep.clamp(3,12),min:3,max:12,divisions:18,onChanged:(x)=>update(()=>sleep=x))]))),
 title('Como te sentes?','Registo de humor'),
 pad(Wrap(spacing:7,runSpacing:6,children:['Muito bem','Bem','Cansado','Ansioso','Triste'].map((m)=>ChoiceChip(label:Text(m),selected:mood==m,onSelected:(_)=>update(()=>mood=m))).toList())),
 const SizedBox(height:16),
 pad(action('Respiração guiada','Uma pausa de um minuto para relaxar.','Começar',Icons.spa_outlined,()=>Navigator.of(context).push(MaterialPageRoute(builder:(c)=>const BreathPage())))),
 title('Glicemia','Medição por dispositivo externo'),
 pad(action('Registar glicemia',glucose.isEmpty?'Ainda sem registos':'Último: '+value(glucose.first['v']).toStringAsFixed(1)+' mg/dL','Registar',Icons.bloodtype_outlined,
 ()=>askNumber('Glicemia medida','mg/dL',(n)=>update(()=>glucose.insert(0,{'v':n,'day':date()}))))),
 const SizedBox(height:32)]);
 Widget progressPage(){final bmi=weight/pow(height/100,2);return ListView(children:[
 heading('EVOLUÇÃO','O teu próprio percurso.'),
 feature('O TEU CAMINHO','Força, saúde e consistência','O progresso é mais do que um número','https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=900',()=>{}),
 title('Composição corporal','Indicadores'),
 pad(Row(children:[Expanded(child:metric('PESO',weight.toStringAsFixed(1)+' kg',Icons.monitor_weight_outlined)),const SizedBox(width:10),Expanded(child:metric('IMC',bmi.toStringAsFixed(1),Icons.insights_outlined))])),
 const SizedBox(height:9),
 pad(const Text('O IMC não mede gordura nem massa muscular. Não é um diagnóstico.',style:TextStyle(color:muted,fontSize:12))),
 const SizedBox(height:20),
 pad(action('Atualizar peso','Guarda o peso atual e acompanha tendências.','Registar',Icons.add_chart,()=>askNumber('Peso atual','kg',(n)=>update((){weight=n;weights.insert(0,{'v':n,'day':date()});})))),
 const SizedBox(height:12),
 pad(action('Editar altura',height.toStringAsFixed(0)+' cm','Editar',Icons.height,()=>askNumber('Altura','cm',(n)=>update(()=>height=n)))),
 title('Treinos concluídos','Consistência'),pad(metric('SESSÕES',sessions.toString(),Icons.fitness_center)),
 title('Histórico de peso',weights.length.toString()+' registos'),
 ...weights.take(10).map((m)=>Padding(padding:const EdgeInsets.fromLTRB(20,0,20,8),child:tile(Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(value(m['v']).toStringAsFixed(1)+' kg',style:const TextStyle(color:white,fontWeight:FontWeight.bold)),Text(m['day'].toString(),style:const TextStyle(color:muted))])))),
 const SizedBox(height:30)]);}
}
class TrainingPage extends StatefulWidget{final VoidCallback done;const TrainingPage({super.key,required this.done});@override State<TrainingPage> createState()=>_TrainingState();}
class _TrainingState extends State<TrainingPage>{
 bool home=true,playing=false,rest=false;int index=0,secs=30;Timer? ticker;
 final house=['Flexões inclinadas','Remada com mochila','Elevação lateral','Agachamentos','Prancha'];
 final gym=['Puxada alta','Remada baixa','Elevação lateral com halteres','Leg press','Prancha'];
 List<String> get exercises=>home?house:gym;
 @override void dispose(){ticker?.cancel();super.dispose();}
 void reset(){ticker?.cancel();setState((){playing=false;rest=false;secs=30;index=0;});}
 void toggle(){if(playing){ticker?.cancel();setState(()=>playing=false);return;}
 setState(()=>playing=true);ticker=Timer.periodic(const Duration(seconds:1),(_){
 if(!mounted)return;if(secs>1){setState(()=>secs--);return;}
 HapticFeedback.selectionClick();
 if(!rest&&index==exercises.length-1){finish();return;}
 setState((){if(rest){rest=false;index++;secs=30;}else{rest=true;secs=15;}});
 });}
 void finish(){reset();widget.done();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Treino concluído e registado!')));}
 @override Widget build(BuildContext context)=>ListView(children:[
 heading('MOVIMENTO','Treina com intenção.'),
 pad(SegmentedButton<bool>(showSelectedIcon:false,segments:const [ButtonSegment(value:true,label:Text('Em casa'),icon:Icon(Icons.home_outlined)),ButtonSegment(value:false,label:Text('Ginásio'),icon:Icon(Icons.fitness_center))],selected:{home},onSelectionChanged:(s){reset();setState(()=>home=s.first);})),
 const SizedBox(height:16),
 feature('TREINO GUIADO',home?'A tua sala, o teu ritmo':'Treinar com aparelhos','Circuito demonstrativo com 30s de exercício','https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=900',()=>{},height:205),
 const SizedBox(height:22),
 pad(tile(Column(children:[
 Text(rest?'DESCANSO':'EXERCÍCIO '+(index+1).toString()+' / '+exercises.length.toString(),style:const TextStyle(color:lime,letterSpacing:1.6,fontSize:11,fontWeight:FontWeight.bold)),
 const SizedBox(height:15),Text(rest?'Recupera a respiração':exercises[index],textAlign:TextAlign.center,style:const TextStyle(color:white,fontSize:22,fontWeight:FontWeight.bold)),
 const SizedBox(height:12),Text('00:'+secs.toString().padLeft(2,'0'),style:const TextStyle(color:white,fontSize:60,fontWeight:FontWeight.w300)),
 const SizedBox(height:12),LinearProgressIndicator(value:rest?(15-secs)/15:(30-secs)/30,minHeight:6,color:lime,backgroundColor:const Color(0xff3b4242)),
 const SizedBox(height:22),Row(children:[
 OutlinedButton(onPressed:reset,child:const Icon(Icons.replay)),
 const SizedBox(width:10),
 Expanded(child:FilledButton.icon(onPressed:toggle,icon:Icon(playing?Icons.pause:Icons.play_arrow),label:Text(playing?'Pausar':'Começar'))),
 const SizedBox(width:10),
 OutlinedButton(onPressed:(){ticker?.cancel();setState((){playing=false;rest=false;secs=30;index=min(exercises.length-1,index+1);});},child:const Icon(Icons.skip_next))
 ]),
 const SizedBox(height:10),TextButton(onPressed:finish,child:const Text('Terminar e registar'))]))),
 title('O teu circuito','30s por exercício'),
 ...exercises.asMap().entries.map((e)=>Padding(padding:const EdgeInsets.fromLTRB(20,0,20,8),child:tile(Row(children:[CircleAvatar(backgroundColor:const Color(0xff37403c),child:Text((e.key+1).toString(),style:const TextStyle(color:lime))),const SizedBox(width:14),Expanded(child:Text(e.value,style:const TextStyle(color:white))),const Text('30s',style:TextStyle(color:muted))])))),
 pad(const Padding(padding:EdgeInsets.symmetric(vertical:22),child:Text('Plano demonstrativo: adapta os movimentos à tua condição e interrompe em caso de dor.',style:TextStyle(color:muted,height:1.5))))]);
}
class BreathPage extends StatefulWidget{const BreathPage({super.key});@override State<BreathPage> createState()=>_BreathState();}
class _BreathState extends State<BreathPage>{int t=0;Timer? timer;
 @override void initState(){super.initState();timer=Timer.periodic(const Duration(seconds:1),(_){if(!mounted)return;setState(()=>t++);if(t>=60){timer?.cancel();Navigator.of(context).pop();}});}
 @override void dispose(){timer?.cancel();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(backgroundColor:bg,appBar:AppBar(backgroundColor:bg),body:Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
 AnimatedContainer(duration:const Duration(milliseconds:900),height:t%10<4?210:150,width:t%10<4?210:150,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:lime,width:2),color:lime.withValues(alpha:.17)),child:const Icon(Icons.spa,color:lime,size:70)),
 const SizedBox(height:42),Text(t%10<4?'Inspira suavemente':'Expira lentamente',style:const TextStyle(color:white,fontSize:23,fontWeight:FontWeight.bold)),
 const SizedBox(height:12),Text((60-t).toString()+' segundos',style:const TextStyle(color:muted)),
 const SizedBox(height:30),TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Terminar'))])));
}
