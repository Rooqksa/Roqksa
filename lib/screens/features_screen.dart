import 'package:flutter/material.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});
  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> {
  static const bg = Color(0xFF15111F);
  static const surface = Color(0xFF211C31);
  static const gold = Color(0xFFE9BD68);
  final posts = <Map<String, dynamic>>[
    {'name':'صديق Roqksa','vip':8,'text':'مساء الخير يا أجمل مجتمع ❤️','likes':12},
    {'name':'عضو مميز','vip':4,'text':'نلتقي الليلة في الغرف الصوتية 🌙','likes':7},
  ];
  final visitors = [
    {'name':'أحمد','vip':12,'time':'الآن'},
    {'name':'سارة','vip':7,'time':'منذ 15 دقيقة'},
    {'name':'محمد','vip':3,'time':'منذ ساعة'},
    {'name':'نورة','vip':17,'time':'أمس'},
  ];
  final products = [
    {'name':'وردة','price':10,'icon':Icons.local_florist_rounded,'color':Color(0xFFE879A5)},
    {'name':'قلب ذهبي','price':50,'icon':Icons.favorite_rounded,'color':gold},
    {'name':'تاج ملكي','price':150,'icon':Icons.workspace_premium_rounded,'color':Color(0xFF9B72FF)},
    {'name':'سيارة فاخرة','price':500,'icon':Icons.directions_car_rounded,'color':Color(0xFF59B7C7)},
  ];
  Color vipColor(int n) {
    const colors = [Color(0xFF9E9E9E),Color(0xFF8D9AA6),Color(0xFF69A7C8),Color(0xFF4E91D8),Color(0xFF4776D0),Color(0xFF6957D8),Color(0xFF9256D8),Color(0xFFB04FC4),Color(0xFFD34F9A),Color(0xFFE65376),Color(0xFFE66A4C),Color(0xFFE99A3D),Color(0xFFD6B43D),Color(0xFF9AB94A),Color(0xFF55B78A),Color(0xFF39BDBD),Color(0xFFE9BD68)];
    final level = n.clamp(1,17).toInt();
    return colors[level-1];
  }
  Widget vip(int n) => Container(padding: const EdgeInsets.symmetric(horizontal:8,vertical:4),decoration:BoxDecoration(color:vipColor(n).withValues(alpha:.15),border:Border.all(color:vipColor(n)),borderRadius:BorderRadius.circular(20)),child:Text('VIP $n',style:TextStyle(color:vipColor(n),fontWeight:FontWeight.bold,fontSize:11)));
  Widget panel(Widget child) => Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:surface,borderRadius:BorderRadius.circular(16)),child:child);
  Widget heading(String s,IconData i)=>Row(children:[Icon(i,color:gold),const SizedBox(width:8),Text(s,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold))]);
  @override
  Widget build(BuildContext context) => Directionality(textDirection:TextDirection.rtl,child:Container(color:bg,child:SafeArea(top:false,child:ListView(padding:const EdgeInsets.all(16),children:[
    const Text('مجتمع Roqksa',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900)),
    const SizedBox(height:18),heading('من زارني',Icons.visibility),const SizedBox(height:10),
    panel(Column(children:visitors.map((v)=>ListTile(contentPadding:EdgeInsets.zero,leading:CircleAvatar(child:const Icon(Icons.person)),title:Row(children:[Text(v['name'] as String),const SizedBox(width:8),vip(v['vip'] as int)]),subtitle:Text(v['time'] as String,style:const TextStyle(color:Colors.white54)))).toList())),
    const SizedBox(height:20),heading('مستويات VIP',Icons.workspace_premium),const SizedBox(height:10),
    panel(Wrap(spacing:7,runSpacing:8,children:List.generate(17,(i)=>vip(i+1)))),
    const SizedBox(height:20),Row(children:[Expanded(child:heading('المنشورات',Icons.dynamic_feed)),TextButton(onPressed:addPost,child:const Text('منشور جديد',style:TextStyle(color:gold)))]),
    ...posts.map((p)=>Padding(padding:const EdgeInsets.only(bottom:10),child:panel(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const CircleAvatar(child:Icon(Icons.person)),const SizedBox(width:8),Expanded(child:Text(p['name'] as String)),vip(p['vip'] as int)]),
      const SizedBox(height:12),Text(p['text'] as String),
      Row(children:[IconButton(onPressed:()=>setState(()=>p['likes']=(p['likes'] as int)+1),icon:const Icon(Icons.favorite_border,color:Color(0xFFE879A5))),Text('${p['likes']} إعجاب')])
    ])))),
    const SizedBox(height:12),heading('متجر Roqksa',Icons.shopping_bag),const SizedBox(height:10),
    GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:products.length,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:1.15,crossAxisSpacing:10,mainAxisSpacing:10),itemBuilder:(ctx,i){final p=products[i];return panel(Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(p['icon'] as IconData,color:p['color'] as Color,size:32),const SizedBox(height:8),Text(p['name'] as String),Text('${p['price']} عملة',style:const TextStyle(color:gold)),TextButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('شراء تجريبي: ${p['name']}'))),child:const Text('شراء تجريبي'))]));}),
    const SizedBox(height:12),const Text('ملاحظة: هذه بيانات تجريبية. الزيارات والمنشورات والمشتريات الفعلية تحتاج خادماً وقاعدة بيانات ونظام دفع.',style:TextStyle(color:Colors.white38,fontSize:11))
  ])))));
  Future<void> addPost() async {
    final c=TextEditingController();
    final value=await showDialog<String>(context:context,builder:(ctx)=>Directionality(textDirection:TextDirection.rtl,child:AlertDialog(title:const Text('منشور جديد'),content:TextField(controller:c,maxLines:4,maxLength:300,decoration:const InputDecoration(hintText:'اكتب ما تريد مشاركته')),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(ctx,c.text.trim()),child:const Text('نشر'))])));
    c.dispose();
    if(value!=null&&value.isNotEmpty&&mounted)setState(()=>posts.insert(0,{'name':'أنا','vip':1,'text':value,'likes':0}));
  }
}
