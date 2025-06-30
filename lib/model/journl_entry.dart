class JournalEntry{
  final String mood;
  final String content;
  final DateTime timestamp;

  JournalEntry({
    required this.mood,
    required this.content,
    required this.timestamp,
  });


Map<String ,dynamic> toJson()=>{
  'mood':mood,
  'content':content,
  'timestamp':timestamp.toIso8601String(),
};
factory JournalEntry.fromJson(Map<String, dynamic> json){
 return JournalEntry(mood: json['mood'], 
 content: json['content'], timestamp: DateTime.parse(json['timestamp']));
 
}
}