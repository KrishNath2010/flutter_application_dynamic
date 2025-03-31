//import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart' hide String;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var randoom = Random().nextInt(11) + 1;
  late var current = randoom.toString();
  late var allWords = <String>[current];
  var correct = ["1","2","3","4","5","6","7","8","9","10","11"];
  var corans = 11;
  var done=false;
  late var numb=allWords.indexOf(current) + 1;
  void getNext() {
    if (done!=true){
      if (allWords.isEmpty){
        allWords.add(current);  
      }
      if (allWords.indexOf(current)<(allWords.length-1)){
        current=allWords[((allWords.indexOf(current)+1))];
      }
      else{
        var counter=0;
        do{
          randoom = Random().nextInt(11) + 1;
          current = randoom.toString();
          counter=counter + 1;
        } while ((allWords.contains(current)==true) && (counter<=80));
        if (counter!=81){
          allWords.add(current);
        }
        else{
          current="end";
          done=true;
        }
      }
      numb=allWords.indexOf(current) + 1;
      notifyListeners();
    }
  }
  void getPrev(){
    if (done!=true){
      if (allWords.indexOf(current) != 0){
        current=allWords[(allWords.indexOf(current))-1];
        numb=allWords.indexOf(current) + 1;
        notifyListeners();
      }
    }
  }
  var guesses = <String>[];
  void toggleGuess() {
    if (guesses.contains(current)) {
      guesses.remove(current);
    } else {
      guesses.add(current);
    }
    notifyListeners();
  }
  void Restart(){
    randoom = Random().nextInt(11) + 1;
    current = randoom.toString();
    allWords = <String>[current];
    correct = ["1","2","3","4","5","6","7","8","9","10","11"];
    done=false;
    numb=allWords.indexOf(current) + 1;
    guesses=[];
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = EndPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var appState = context.watch<MyAppState>();
    return LayoutBuilder(
      builder: (context, constraints) {
        var appState = context.watch<MyAppState>();
        Text tempQuestion;
        if (!appState.done) {
          tempQuestion = Text('Question Number: ${appState.numb}');
        } 
        else {
          tempQuestion = Text('');
        }
        return Scaffold(
          appBar: AppBar(
            title: SizedBox(
              child: tempQuestion,
            ),
          ),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.question_answer),
                      label: Text('Answers'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,  // ← Here.
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.guesses.contains(pair)) {
      icon = Icons.thumb_up;
    } else {
      icon = Icons.thumb_up_outlined;
    }
    if (appState.done==false){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          BigCard(),
          SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      appState.getPrev();
                    },
                    child: Text('Prev'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleGuess();
                    },
                    icon: Icon(icon),
                    label: Text('Vowel'),
                  ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      );
    }  
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          BigCard(),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
            appState.Restart();
            },
            child: Text('Restart'),
          ),
          ] 
        )
    );    
  }
}

class BigCard extends StatelessWidget {
  
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    late var current = appState.current;
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Image.asset('assets/images/$current.jpg');
  }
}
class EndPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.done==false){
      return Center(
        child: Text('please finish the game to check your answers'),
      );
    }
    if (appState.guesses.isEmpty) {
      return Center(
        child: Text('No guesses yet. Please guess atleast 1 letter'),
      );
    }
    var missing=<String>[];
    for (var pair in appState.correct){
        if (false==appState.guesses.contains(pair)){
          missing.add(pair);
        }
    }
    var percent=((appState.corans-missing.length)/appState.corans)*100;
    return ListView(
      children: [
        Text('You have '
              '${appState.guesses.length} guesses: and you are missing ''${missing.length}'' correct answers, the ones that you are missing are shown below, this means that you have gotten ''$percent''% of the answers right. Good Job!!'  ),
        for (var pair in missing)
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Image.asset('assets/images/$pair.jpg'),
          ),
      ],
    );
  }
}