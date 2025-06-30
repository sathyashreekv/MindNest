import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'model/journl_entry.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:fl_chart/fl_chart.dart';


void main(){
  runApp(MoodJournalApp());
}

class MoodJournalApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title:'MindNest',
      theme:ThemeData(primarySwatch: Colors.amber),
      home:MoodHomePage(),
      debugShowCheckedModeBanner: false,
      );
  }
}
class MoodHomePage extends StatefulWidget{
  @override
  _MoodHomePageState createState() =>_MoodHomePageState();
}
class _MoodHomePageState extends State<MoodHomePage>{
  final  List<String>moods=[
'😀 Happy',
'😢 Sad',
'😡 Angry',
'😱 Shocked',
'🤔 Thinking',
'😍 Affection',
'😴 Tired',
'🤯 Overwhelmed',
'😎 Cool' ,
'😭 Crying '
  ];
  final List<Color> moodColors = [
  Colors.pink,   // 😊 Happy
  const Color.fromARGB(255, 77, 148, 196), // 😔 Sad
  Colors.redAccent.shade100,// 😠 Angry
  Colors.green.shade100,    // 😌 Calm
  const Color.fromARGB(255, 212, 155, 63),  // 😕 Confused
  const Color.fromARGB(255, 201, 77, 223),
  const Color.fromARGB(255, 149, 158, 48),
  Colors.teal,
  Colors.deepOrange,
  Colors.lightBlueAccent
    // 😩 Tired
];
  StreamController<int> spinnerContoller=StreamController<int>();
  String selectedMood="";
  TextEditingController _journalController = TextEditingController();
  List<JournalEntry> journalEntries=[];
  int lastSelectedIndex=0;
  TextEditingController _chatController = TextEditingController();
  String _chatResponse = '';

  @override
  void initState(){
    super.initState();
    loadEntries();
    checkInIfInactive();
  }

  @override
  void dispose(){
    spinnerContoller.close();
    super.dispose();
  }
  Future<void> saveEntry() async{
    if(_journalController.text.trim().isEmpty || _journalController.text.isEmpty){
      
      return;
    }
   final entry=JournalEntry(
    mood:selectedMood,
    content:_journalController.text.trim(),
    timestamp:DateTime.now(),
   );

   final prefs=await SharedPreferences.getInstance();
   List<String> stored= prefs.getStringList('journal')??[];
   stored.add(jsonEncode(entry.toJson()));
   await prefs.setStringList('journal', stored);

   _journalController.clear();
   selectedMood='';
   await loadEntries();
   await prefs.setString('lastEntryTime', DateTime.now().toIso8601String());

  }
  Future<void> loadEntries() async{
    final prefs= await SharedPreferences.getInstance();
    List<String> stored=prefs.getStringList('journal')??[];
    final loaded=stored
    .map((e)=>JournalEntry.fromJson(jsonDecode(e)))
    .toList();
    loaded.sort((a,b)=> b.timestamp.compareTo(a.timestamp));
    setState(() {
      journalEntries=loaded;
    });
    

   
  }
  Future<void> checkInIfInactive() async {
  final prefs = await SharedPreferences.getInstance();
  final lastStr = prefs.getString('lastEntryTime');
  if (lastStr == null) return;

  final lastTime = DateTime.tryParse(lastStr);
  if (lastTime == null) return;

  final now = DateTime.now();
  final difference = now.difference(lastTime);

  if (difference.inMinutes >=4) {
    // Delay to ensure context is ready
    Future.delayed(Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("🕒 It's been a while"),
          content: Text("We haven't heard from you in a bit. Want to share how you're feeling today?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Maybe Later")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Optional: Trigger wheel or journal entry
              },
              child: Text("Yes, Check In"),
            )
          ],
        ),
      );
    });
  }
}

  
  String _getPromptForMood(String mood) {
  if (mood.contains("Happy")) return "What made you feel happy today?";
  if (mood.contains("Sad")) return "What's weighing on your heart?";
  if (mood.contains("Angry")) return "What triggered your anger?";
  if (mood.contains("Calm")) return "What helped you feel at peace?";
  if (mood.contains("Confused")) return "What's unclear or uncertain?";
  if (mood.contains("Tired")) return "What drained your energy today?";
  return "How are you feeling?";
  
}
String _getChatResponse(String input) {
  input = input.toLowerCase();
  if (input.contains("sad")) return "It’s okay to feel sad. Want to try some calming music?";
  if (input.contains("help")) return "I'm here for you. Try the SOS button anytime.";
  if (input.contains("happy")) return "That's awesome! What made you feel happy today?";
  if (input.contains("alone")) return "You're not alone. Reach out or try SOS support.";
  return "Thanks for sharing. Keep going, you're doing great.";
}


bool shouldShowSOS() {
  final recent = journalEntries.take(5).toList();
  final sosMoods = ['😢', '😴', '😭', '😡'];
  final moodCount = recent.where((e) =>
      sosMoods.any((m) => e.mood.contains(m))).length;
  return moodCount >= 2; // Show if 2 or more "SOS" moods are detected
}


void showSOSPopup() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("🚨 SOS Support"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("You're not alone. Would you like to..."),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              launchUrl(Uri.parse("https://www.youtube.com/watch?v=2OEL4P1Rz04"));
            },
            icon: Icon(Icons.music_note),
            label: Text("Listen to Calming Music"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Future: connect to real contact
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Pretending to contact your friend 💬")),
              );
            },
            icon: Icon(Icons.contact_page),
            label: Text("Talk to a Friend"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))
      ],
    ),
  );
}




@override
Widget build(BuildContext context){
  return Scaffold(
    appBar:AppBar(title:Text('MindNest',style: TextStyle(fontFamily: 'poppins',),)),
    backgroundColor: Colors.white,
  
    body:Padding(
      padding:EdgeInsets.all(16),
      child:SingleChildScrollView(
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        
        children: [
        SizedBox(
          height:300,
          child: FortuneWheel(
            selected:spinnerContoller.stream,
            // items:moods.map((mood)=> FortuneItem(child: Text(mood))).toList(),
            items:List.generate(moods.length, (index)=>FortuneItem(child:Text(moods[index]),
            style:FortuneItemStyle(color:moodColors[index],
            borderColor:Colors.white,
            borderWidth: 2,
            textStyle: const TextStyle(fontSize: 16,color:Colors.white,fontWeight: FontWeight.bold,)))),
            onAnimationEnd: (){
              setState(() {
                selectedMood=moods[lastSelectedIndex];
                
              });
            },
          ),
        ),
        
        ElevatedButton(
          onPressed:(){
               WidgetsBinding.instance.addPostFrameCallback((_) {
            final index=Random().nextInt(moods.length);
            lastSelectedIndex=index;
            spinnerContoller.add(index);
          });
          },
          child: Text("Spin the Mood Wheel"),
        ),
        if (selectedMood.isNotEmpty)...[
          SizedBox(height:8),
          Text('selected Mood:$selectedMood'),
          SizedBox(height:8),
          Text(_getPromptForMood(selectedMood),
          style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
          SizedBox(height:8),
          TextField(
            controller:_journalController,
            maxLines: 4,
            decoration:InputDecoration(
              hintText:'Write your thoughts....',
              border:OutlineInputBorder(),
            )
            ,),
            SizedBox(height:12),
            ElevatedButton(onPressed:saveEntry,
            child:Text('📝 Save Entry'),)

        ],
        SizedBox(height:16),
//         if(shouldShowSOS())
//         ElevatedButton.icon(onPressed: showSOSPopup, icon:Icon(Icons.warning),
//         label:Text("🚨 SOS Support"),
//         style:ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
//         ),
//         SizedBox(height:16),
//         if (_isUserNeedingHelp()) ...[
//   SizedBox(height: 16),
//   Card(
//     color: Colors.red.shade100,
//     child: ListTile(
//       leading: Icon(Icons.warning_amber_rounded, color: Colors.red),
//       title: Text("It looks like you're going through a tough time."),
//       subtitle: Text("Try some calming music or talk to someone you trust."),
//       trailing: IconButton(
//         icon: Icon(Icons.music_note),
//         onPressed: () {
//           launchUrl(Uri.parse("https://www.youtube.com/watch?v=2OEL4P1Rz04")); // soothing music
//         },
//       ),
//     ),
//   ),
if (shouldShowSOS()) ...[
  ElevatedButton.icon(
    onPressed: showSOSPopup,
    icon: Icon(Icons.warning),
    label: Text("🚨 SOS Support"),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
  ),
  SizedBox(height: 16),
  Card(
    color: Colors.red.shade100,
    child: ListTile(
      leading: Icon(Icons.warning_amber_rounded, color: Colors.red),
      title: Text("It looks like you're going through a tough time."),
      subtitle: Text("Tap SOS for support or try calming music."),
      trailing: IconButton(
        icon: Icon(Icons.music_note),
        onPressed: () {
          launchUrl(Uri.parse("https://www.youtube.com/watch?v=2OEL4P1Rz04"));
        },
      ),
    ),
  ),
  SizedBox(height: 16),
],
        SizedBox(height:16),
        if(journalEntries.isNotEmpty)...[
          Text("Recent Entries",style:TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
        
          ListView.builder(
          itemCount:journalEntries.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder:(context, index){
            final entry=journalEntries[index];
            return Card(
              child:ListTile(
                title:Text(entry.mood),
                subtitle:Text(entry.content),
                trailing: Text(DateFormat('MM d,HH:mm').format(entry.timestamp)),
              ),
            );
          },
        ),
        
      buildChatBot(),
      


        ],
        
        ]
       

      ),
    ),
  ));
}

Widget buildChatBot() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    SizedBox(height: 16),
    Text("💬 Talk to MindNest", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    SizedBox(height: 8),
    TextField(
      controller: _chatController,
      decoration: InputDecoration(
        labelText: "Ask something...",
        border: OutlineInputBorder(),
      ),
      onSubmitted: (text) {
        setState(() {
          _chatResponse = _getChatResponse(text);
          _chatController.clear();
        });
      },
    ),
    SizedBox(height: 10),
    if (_chatResponse.isNotEmpty)
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text("MindNest: $_chatResponse"),
      ),
  ],
);




}


