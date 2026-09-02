import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'core/database/app_database.dart';

const g = Color(0xFF2E7D32);
const dg = Color(0xFF1B5E20);
const pg = Color(0xFFE8F5E9);
const bg = Color(0xFFF5F8F4);

enum Module { dashboard, sites, customers, orders, employees, time, calendar }

class PincusApp extends StatefulWidget {
  const PincusApp({super.key});
  @override State<PincusApp> createState() => _PincusAppState();
}

class _PincusAppState extends State<PincusApp> {
  final db = AppDatabase();
  Module current = Module.dashboard;
  @override void dispose() { db.close(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 800;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: g,
        foregroundColor: Colors.white,
        title: Row(children: [
          const Icon(Icons.park_outlined), const SizedBox(width: 10),
          Text(moduleName(current), style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
      ),
      body: Row(children: [
        if (!mobile) SideBar(selected: current, onTap: (m) => setState(() => current = m)),
        Expanded(child: current == Module.dashboard
            ? Dashboard(db: db, open: (m) => setState(() => current = m))
            : current == Module.calendar ? CalendarPage(db: db) : CrudPage(db: db, module: current)),
      ]),
      bottomNavigationBar: mobile ? NavigationBar(
        selectedIndex: current == Module.sites ? 1 : current == Module.customers ? 2 : current == Module.time ? 3 : 0,
        onDestinationSelected: (i) => setState(() => current = i == 1 ? Module.sites : i == 2 ? Module.customers : i == 3 ? Module.time : Module.dashboard),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Start'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), label: 'Baustellen'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Kunden'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), label: 'Zeit'),
        ],
      ) : null,
    );
  }
}

String moduleName(Module m) => switch (m) {
  Module.dashboard => 'Dashboard', Module.sites => 'Baustellen', Module.customers => 'Kunden',
  Module.orders => 'Aufträge', Module.employees => 'Mitarbeiter', Module.time => 'Zeiterfassung', Module.calendar => 'Kalender',
};
IconData moduleIcon(Module m) => switch (m) {
  Module.dashboard => Icons.dashboard_outlined, Module.sites => Icons.location_on_outlined, Module.customers => Icons.people_outline,
  Module.orders => Icons.assignment_outlined, Module.employees => Icons.groups_outlined, Module.time => Icons.schedule_outlined, Module.calendar => Icons.calendar_month_outlined,
};

class SideBar extends StatelessWidget {
  final Module selected; final ValueChanged<Module> onTap;
  const SideBar({super.key, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) => Container(
    width: 116, color: Colors.white,
    child: Column(children: [
      Padding(padding: const EdgeInsets.all(9), child: Image.asset('assets/images/logo.png', height: 54, errorBuilder: (_, __, ___) => const Icon(Icons.park, color: g, size: 42))),
      Expanded(child: ListView(children: Module.values.map((m) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: InkWell(borderRadius: BorderRadius.circular(14), onTap: () => onTap(m), child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: selected == m ? pg : Colors.transparent, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Icon(moduleIcon(m), size: 27, color: selected == m ? g : Colors.black54),
            const SizedBox(height: 3),
            Text(moduleName(m), textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: selected == m ? FontWeight.w700 : FontWeight.w500, color: selected == m ? dg : Colors.black87)),
          ]),
        )),
      )).toList())),
    ]),
  );
}

class Dashboard extends StatelessWidget {
  final AppDatabase db; final ValueChanged<Module> open;
  const Dashboard({super.key, required this.db, required this.open});
  Future<List<int>> counts() async => [
    await db.select(db.sites).get().then((x) => x.length),
    await db.select(db.customers).get().then((x) => x.length),
    await db.select(db.orders).get().then((x) => x.length),
    await db.select(db.employees).get().then((x) => x.length),
  ];
  @override Widget build(BuildContext context) => FutureBuilder<List<int>>(
    future: counts(), builder: (_, s) {
      if (!s.hasData) return const Center(child: CircularProgressIndicator(color: g));
      final c = s.data!;
      return ListView(padding: const EdgeInsets.fromLTRB(30, 40, 30, 50), children: [
        const Text('Pincus Baum und Landschaftspflege', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700, color: dg)),
        const SizedBox(height: 4),
        const Text('Baustellenmanagement & Unternehmensverwaltung', style: TextStyle(fontSize: 17, color: Colors.black54)),
        const SizedBox(height: 28),
        Wrap(spacing: 14, runSpacing: 14, children: [
          Stat('Baustellen', c[0], Icons.location_on, () => open(Module.sites)),
          Stat('Kunden', c[1], Icons.people, () => open(Module.customers)),
          Stat('Aufträge', c[2], Icons.assignment, () => open(Module.orders)),
          Stat('Mitarbeiter', c[3], Icons.groups, () => open(Module.employees)),
        ]),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          const Icon(Icons.account_tree_outlined, color: g, size: 30), const SizedBox(width: 14),
          const Expanded(child: Text('Kunde → Baustelle → Auftrag → Mitarbeiter → Arbeitszeit', style: TextStyle(fontWeight: FontWeight.w600))),
          FilledButton(onPressed: () => open(Module.orders), child: const Text('Auftrag anlegen')),
        ]))),
      ]);
    },
  );
}

class Stat extends StatelessWidget {
  final String label; final int value; final IconData icon; final VoidCallback tap;
  const Stat(this.label, this.value, this.icon, this.tap, {super.key});
  @override Widget build(BuildContext context) => SizedBox(width: 300, child: Card(child: InkWell(
    onTap: tap, borderRadius: BorderRadius.circular(14), child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: pg, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: g)),
      const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), Text('$value', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: dg)), const Text('Im System', style: TextStyle(color: Colors.black54)),
      ])), const Icon(Icons.chevron_right, color: Colors.black26),
    ])),
  )));
}

enum Kind { sites, customers, orders, employees, time }
Kind kindFor(Module m) => switch (m) { Module.sites => Kind.sites, Module.customers => Kind.customers, Module.orders => Kind.orders, Module.employees => Kind.employees, Module.time => Kind.time, _ => Kind.sites };

class CrudPage extends StatefulWidget { final AppDatabase db; final Module module; const CrudPage({super.key, required this.db, required this.module}); @override State<CrudPage> createState() => _CrudPageState(); }
class _CrudPageState extends State<CrudPage> {
  late Future<List<dynamic>> data; String search = '';
  @override void initState(){super.initState(); reload();}
  void reload(){data=query();}
  Future<List<dynamic>> query()=>switch(kindFor(widget.module)){
    Kind.sites=>widget.db.select(widget.db.sites).get(), Kind.customers=>widget.db.select(widget.db.customers).get(), Kind.orders=>widget.db.select(widget.db.orders).get(), Kind.employees=>widget.db.select(widget.db.employees).get(), Kind.time=>widget.db.select(widget.db.timeEntries).get()};
  String primary(dynamic x)=>switch(kindFor(widget.module)){Kind.sites=>x.title,Kind.customers=>x.name,Kind.orders=>x.title,Kind.employees=>x.name,Kind.time=>x.employeeName};
  String secondary(dynamic x)=>switch(kindFor(widget.module)){Kind.sites=>x.address,Kind.customers=>'${x.contact} • ${x.phone}',Kind.orders=>'${x.status} • ${x.date} • ${x.price.toStringAsFixed(2)} €',Kind.employees=>'${x.role} • ${x.targetHours} h/Woche',Kind.time=>'${fmt(x.date)} • ${fmtTime(x.startTime)}${x.endTime==null?'':' – ${fmtTime(x.endTime)}'}'};
  @override Widget build(BuildContext context)=>FutureBuilder<List<dynamic>>(future:data,builder:(_,s){if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator(color:g));if(s.hasError)return Center(child:Text('Fehler: ${s.error}'));final items=(s.data??[]).where((x)=>('${primary(x)} ${secondary(x)}').toLowerCase().contains(search.toLowerCase())).toList();return ListView(padding:const EdgeInsets.fromLTRB(30,26,30,40),children:[Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:pg,borderRadius:BorderRadius.circular(14)),child:Icon(moduleIcon(widget.module),color:g)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(moduleName(widget.module),style:const TextStyle(fontSize:29,fontWeight:FontWeight.w700,color:dg)),const Text('Einträge verwalten und verknüpfen',style:TextStyle(color:Colors.black54))])),FilledButton.icon(onPressed:()=>edit(),icon:const Icon(Icons.add),label:const Text('Neu'))]),const SizedBox(height:18),TextField(onChanged:(v)=>setState(()=>search=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'${moduleName(widget.module)} durchsuchen …',filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none))),const SizedBox(height:12),Text('${items.length} Einträge',style:const TextStyle(fontWeight:FontWeight.w700,color:dg)),const SizedBox(height:8),...items.map((x)=>Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:CircleAvatar(backgroundColor:pg,child:Icon(moduleIcon(widget.module),color:g)),title:Text(primary(x),style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(secondary(x)),trailing:Wrap(children:[IconButton(onPressed:()=>edit(x),icon:const Icon(Icons.edit_outlined)),IconButton(onPressed:()=>remove(x),icon:const Icon(Icons.delete_outline))]))))]);});
  Future<void> edit([dynamic item])async{final v=await showDialog<Map<String,String>>(context:context,builder:(_)=>EntryDialog(db:widget.db,kind:kindFor(widget.module),item:item));if(v==null)return;try{if(item==null)await insert(v);else await update(item,v);setState(reload);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Fehler: $e')));}}
  Future<void> remove(dynamic x)async{final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:const Text('Eintrag löschen?'),content:Text(primary(x)),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Abbrechen')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Löschen'))]));if(ok!=true)return;final k=kindFor(widget.module);switch(k){case Kind.sites:await(widget.db.delete(widget.db.sites)..where((t)=>t.id.equals(x.id))).go();case Kind.customers:await(widget.db.delete(widget.db.customers)..where((t)=>t.id.equals(x.id))).go();case Kind.orders:await(widget.db.delete(widget.db.orders)..where((t)=>t.id.equals(x.id))).go();case Kind.employees:await(widget.db.delete(widget.db.employees)..where((t)=>t.id.equals(x.id))).go();case Kind.time:await(widget.db.delete(widget.db.timeEntries)..where((t)=>t.id.equals(x.id))).go();}setState(reload);}
  Future<void> insert(Map<String,String>v)async{switch(kindFor(widget.module)){case Kind.sites:await widget.db.into(widget.db.sites).insert(SitesCompanion.insert(title:v['title']!,address:v['address']!,customerId:Value(_str(v['customerId']))));case Kind.customers:await widget.db.into(widget.db.customers).insert(CustomersCompanion.insert(id:_id(),name:v['name']!,contact:Value(v['contact']??''),phone:Value(v['phone']??''),address:Value(v['address']??'')));case Kind.orders:await widget.db.into(widget.db.orders).insert(OrdersCompanion.insert(id:_id(),title:v['title']!,customerId:Value(_str(v['customerId'])),siteId:Value(_int(v['siteId'])),status:Value(v['status']??'Neu'),date:v['date']!,price:Value(_num(v['price']))));case Kind.employees:await widget.db.into(widget.db.employees).insert(EmployeesCompanion.insert(id:_id(),name:v['name']!,role:v['role']!,targetHours:Value(_num(v['targetHours']))));case Kind.time:await widget.db.into(widget.db.timeEntries).insert(TimeEntriesCompanion.insert(siteId:int.parse(v['siteId']!),employeeName:v['employeeName']!,date:_date(v['date']!),startTime:_dt(v['date']!,v['startTime']!),endTime:Value((v['endTime']??'').isEmpty?null:_dt(v['date']!,v['endTime']!)),breakMinutes:Value(_num(v['breakMinutes'])),notes:Value(_str(v['notes']))));}}
  Future<void> update(dynamic x,Map<String,String>v)async{switch(kindFor(widget.module)){case Kind.sites:await(widget.db.update(widget.db.sites)..where((t)=>t.id.equals(x.id))).write(SitesCompanion(title:Value(v['title']!),address:Value(v['address']!),customerId:Value(_str(v['customerId']))));case Kind.customers:await(widget.db.update(widget.db.customers)..where((t)=>t.id.equals(x.id))).write(CustomersCompanion(name:Value(v['name']!),contact:Value(v['contact']??''),phone:Value(v['phone']??''),address:Value(v['address']??'')));case Kind.orders:await(widget.db.update(widget.db.orders)..where((t)=>t.id.equals(x.id))).write(OrdersCompanion(title:Value(v['title']!),customerId:Value(_str(v['customerId'])),siteId:Value(_int(v['siteId'])),status:Value(v['status']??'Neu'),date:Value(v['date']!),price:Value(_num(v['price']))));case Kind.employees:await(widget.db.update(widget.db.employees)..where((t)=>t.id.equals(x.id))).write(EmployeesCompanion(name:Value(v['name']!),role:Value(v['role']!),targetHours:Value(_num(v['targetHours']))));case Kind.time:await(widget.db.update(widget.db.timeEntries)..where((t)=>t.id.equals(x.id))).write(TimeEntriesCompanion(siteId:Value(int.parse(v['siteId']!)),employeeName:Value(v['employeeName']!),date:Value(_date(v['date']!)),startTime:Value(_dt(v['date']!,v['startTime']!)),endTime:Value((v['endTime']??'').isEmpty?null:_dt(v['date']!,v['endTime']!)),breakMinutes:Value(_num(v['breakMinutes'])),notes:Value(_str(v['notes']))));}}
}

class EntryDialog extends StatefulWidget{final AppDatabase db;final Kind kind;final dynamic item;const EntryDialog({super.key,required this.db,required this.kind,this.item});@override State<EntryDialog> createState()=>_EntryDialogState();}
class _EntryDialogState extends State<EntryDialog>{final Map<String,TextEditingController> c={};List<dynamic> customers=[],sites=[],employees=[];String? customerId,siteId,employeeName;bool loading=true;
 @override void initState(){super.initState();load();}
 Future<void> load()async{customers=await widget.db.select(widget.db.customers).get();sites=await widget.db.select(widget.db.sites).get();employees=await widget.db.select(widget.db.employees).get();final x=widget.item;if(x!=null){customerId=(widget.kind==Kind.sites||widget.kind==Kind.orders)?x.customerId:null;siteId=[Kind.orders,Kind.time].contains(widget.kind)?x.siteId?.toString():null;employeeName=widget.kind==Kind.time?x.employeeName:null;}if(mounted)setState(()=>loading=false);}
 TextEditingController f(String k,[String?v])=>c.putIfAbsent(k,()=>TextEditingController(text:v??''));
 void seed(){final x=widget.item;if(x==null||c.isNotEmpty)return;switch(widget.kind){case Kind.sites:f('title',x.title);f('address',x.address);case Kind.customers:f('name',x.name);f('contact',x.contact);f('phone',x.phone);f('address',x.address);case Kind.orders:f('title',x.title);f('status',x.status);f('date',x.date);f('price',x.price.toString());case Kind.employees:f('name',x.name);f('role',x.role);f('targetHours',x.targetHours.toString());case Kind.time:f('date',fmt(x.date));f('startTime',fmtTime(x.startTime));f('endTime',fmtTime(x.endTime));f('breakMinutes',x.breakMinutes.toString());f('notes',x.notes??'');}}
 @override Widget build(BuildContext context){if(loading)return const AlertDialog(content:SizedBox(height:70,child:Center(child:CircularProgressIndicator(color:g))));seed();return AlertDialog(title:Text('${widget.item==null?'Neu':'Bearbeiten'} – ${kindName(widget.kind)}'),content:SizedBox(width:560,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:fields()))),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Abbrechen')),FilledButton(onPressed:()=>Navigator.pop(context,{for(final e in c.entries)e.key:e.value.text,'customerId':customerId??'','siteId':siteId??'','employeeName':employeeName??''}),child:const Text('Speichern'))]});}
 List<Widget> fields()=>switch(widget.kind){Kind.sites:[t('title','Baustellenname'),t('address','Adresse'),customer()],Kind.customers:[t('name','Name / Firma'),t('contact','Ansprechpartner'),t('phone','Telefon'),t('address','Adresse')],Kind.orders:[t('title','Auftragsbezeichnung'),customer(),site(true),drop('status',['Neu','Angebot','Beauftragt','In Arbeit','Abgeschlossen']),t('date','Termin'),t('price','Preis (€)')],Kind.employees:[t('name','Name'),t('role','Rolle / Tätigkeit'),t('targetHours','Wochenstunden')],Kind.time:[site(false),employee(),t('date','Datum (TT.MM.JJJJ)'),t('startTime','Beginn (HH:MM)'),t('endTime','Ende (HH:MM)'),t('breakMinutes','Pause (Minuten)'),t('notes','Notizen',3)]};
 Widget t(String k,String l,[int lines=1])=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:f(k),maxLines:lines,decoration:InputDecoration(labelText:l,filled:true,fillColor:bg,border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide.none))));
 Widget drop(String k,List<String>v){final cur=c[k]?.text;return Padding(padding:const EdgeInsets.only(bottom:10),child:DropdownButtonFormField<String>(initialValue:v.contains(cur)?cur:v.first,decoration:InputDecoration(labelText:k,filled:true,fillColor:bg,border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide.none)),items:v.map<DropdownMenuItem<String>>((x)=>DropdownMenuItem<String>(value:x,child:Text(x))).toList(),onChanged:(x){if(x!=null)f(k).text=x;}));}
 Widget customer()=>Padding(padding:const EdgeInsets.only(bottom:10),child:DropdownButtonFormField<String?>(initialValue:customers.any((x)=>x.id==customerId)?customerId:null,decoration:InputDecoration(labelText:'Kunde',filled:true,fillColor:bg,border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide.none)),items:[const DropdownMenuItem<String?>(value:null,child:Text('Kein Kunde')),...customers.map<DropdownMenuItem<String?>>((x)=>DropdownMenuItem<String?>(value:x.id,child:Text(x.name)))],onChanged:(x)=>customerId=x));
 Widget site(bool optional)=>Padding(padding:const EdgeInsets.only(bottom:10),child:DropdownButtonFormField<String?>(initialValue:sites.any((x)=>x.id.toString()==siteId)?siteId:null,decoration:InputDecoration(labelText:optional?'Baustelle (optional)':'Baustelle',filled:true,fillColor:bg,border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide.none)),items:[if(optional)const DropdownMenuItem<String?>(value:null,child:Text('Keine Baustelle')),...sites.map<DropdownMenuItem<String?>>((x)=>DropdownMenuItem<String?>(value:x.id.toString(),child:Text(x.title)))],onChanged:(x)=>siteId=x));
 Widget employee()=>Padding(padding:const EdgeInsets.only(bottom:10),child:DropdownButtonFormField<String>(initialValue:employees.any((x)=>x.name==employeeName)?employeeName:null,decoration:InputDecoration(labelText:'Mitarbeiter',filled:true,fillColor:bg,border:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide.none)),items:employees.map<DropdownMenuItem<String>>((x)=>DropdownMenuItem<String>(value:x.name,child:Text(x.name))).toList(),onChanged:(x)=>employeeName=x));
 @override void dispose(){for(final x in c.values)x.dispose();super.dispose();}
}
String kindName(Kind k)=>switch(k){Kind.sites=>'Baustellen',Kind.customers=>'Kunden',Kind.orders=>'Aufträge',Kind.employees=>'Mitarbeiter',Kind.time=>'Zeiterfassung'};

class CalendarPage extends StatefulWidget{final AppDatabase db;const CalendarPage({super.key,required this.db});@override State<CalendarPage> createState()=>_CalendarPageState();}
class _CalendarPageState extends State<CalendarPage>{DateTime month=DateTime(DateTime.now().year,DateTime.now().month);@override Widget build(BuildContext context){final first=DateTime(month.year,month.month,1);final days=DateTime(month.year,month.month+1,0).day;final offset=(first.weekday+6)%7;final cells=((offset+days+6)~/7)*7;const names=['Mo','Di','Mi','Do','Fr','Sa','So'];return Padding(padding:const EdgeInsets.all(28),child:Column(children:[Row(children:[const Icon(Icons.calendar_month,color:g,size:31),const SizedBox(width:10),const Expanded(child:Text('Kalender',style:TextStyle(fontSize:29,fontWeight:FontWeight.w700,color:dg))),IconButton(onPressed:()=>setState(()=>month=DateTime(month.year,month.month-1)),icon:const Icon(Icons.chevron_left)),Text('${month.month.toString().padLeft(2,'0')}/${month.year}',style:const TextStyle(fontWeight:FontWeight.w700)),IconButton(onPressed:()=>setState(()=>month=DateTime(month.year,month.month+1)),icon:const Icon(Icons.chevron_right))]),const SizedBox(height:16),Expanded(child:Card(child:GridView.builder(padding:const EdgeInsets.all(12),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:7,crossAxisSpacing:8,mainAxisSpacing:8,childAspectRatio:1.35),itemCount:cells+7,itemBuilder:(_,i){if(i<7)return Center(child:Text(names[i],style:const TextStyle(fontWeight:FontWeight.w700,color:g)));final n=i-7-offset;if(n<0||n>=days)return const SizedBox();final d=DateTime(month.year,month.month,n+1);final now=DateTime.now();final today=d.year==now.year&&d.month==now.month&&d.day==now.day;return Container(padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:today?pg:Colors.white,border:Border.all(color:today?g:Colors.black12),borderRadius:BorderRadius.circular(10)),child:Text('${d.day}',style:TextStyle(fontWeight:FontWeight.w700,color:today?dg:null)));}))) ]));}}

String _id()=>DateTime.now().microsecondsSinceEpoch.toString();
String? _str(String? v)=>v==null||v.trim().isEmpty?null:v.trim();
int? _int(String? v)=>v==null||v.trim().isEmpty?null:int.tryParse(v);
double _num(String? v)=>double.tryParse((v??'').replaceAll(',','.'))??0;
DateTime _date(String v){final p=v.trim().split(RegExp(r'[.\-/]'));if(p.length==3){if(p[0].length==4)return DateTime(int.parse(p[0]),int.parse(p[1]),int.parse(p[2]));return DateTime(int.parse(p[2]),int.parse(p[1]),int.parse(p[0]));}return DateTime.now();}
DateTime _dt(String d,String t){final x=_date(d);final p=t.split(':');return DateTime(x.year,x.month,x.day,int.tryParse(p[0])??0,p.length>1?int.tryParse(p[1])??0:0);}
String fmt(DateTime? d)=>d==null?'':'${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}';
String fmtTime(DateTime? d)=>d==null?'':'${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
