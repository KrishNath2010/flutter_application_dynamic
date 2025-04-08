import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' as wi;
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';


/* All game details loaded globaly when the app starts
 * This is done to avoid loading the game details multiple times when navigating between pages.
 * The game details are loaded once and stored in a global variable for access throughout the app.
 * This approach improves performance and reduces redundant data loading.
*/
List<GameDetails> gameDetailsList = [];
Future<List<Game>>? games;
int gamePicked = 0;
int currentDirectoryIndex = 0;
int currentFileNumber = 0;
String currentDir = '';
String currentText = '';
int endFileNumber = 0;
int totalCurrentDirCount = 0;
int totalDirectories = 0;
int startFileNumber = 0;
bool hint1Exists = false;
bool hint2Exists = false;
String currentFileName = '';
String hint1FileName = '';
String hint1Directory = '';
String hint2FileName = '';
String hint2Directory = '';
String texts="";
int defaultQuestionCount = 10;
int maxNumber=0;
int easyStartFirstNumber = 0;
int easyEndFirstNumber = 0;
int easyStartSecondNumber = 0;
int easyEndSecondNumber = 0;
int hardStartFirstNumber = 0;
int hardEndFirstNumber = 0;
int hardStartSecondNumber = 0;
int hardEndSecondNumber = 0;

/* The main function is the entry point of the Flutter application. */
void main() {
  FlutterError.onError = (details) {
  FlutterError.presentError(details);
  if (kReleaseMode) exit(1);
};
  // main function
  runApp(MyApp(gameDetailsList: []));
}

/*
 * MyApp class is the main entry point of the application.
 * It initializes the app and sets up the theme and home page.
*/
class MyApp extends StatefulWidget {
  MyApp({required gameDetailsList});
  @override
  MyAppPageState createState() => MyAppPageState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, widget) {
        Widget error = const Text('...rendering error...');
        if (widget is Scaffold || widget is Navigator) {
          error = Scaffold(body: Center(child: error));
        }
        ErrorWidget.builder = (errorDetails) => error;
        if (widget != null) return widget;
        throw StateError('widget is null');
      },
    );
  }
}
  // Function to load the games list from games.json
 Future<List<Game>> loadGames() async {
  String jsonString = await rootBundle.loadString('assets/games.json');
  print('3333 $jsonString 44444');
  Map<String, dynamic> decoded = jsonDecode(jsonString);
  List<dynamic> gamesList = decoded['games'];
  print('3333 gamesList $gamesList 44444');

  return gamesList.map((gameJson) => Game.fromJson(gameJson)).toList();
}

 // Function to load game details from game.json
  Future<GameDetails> loadGameDetails(String gameDirectory) async {
    String jsonString = await rootBundle.loadString('assets/games/$gameDirectory/game.json');
    Map<String, dynamic> decoded = jsonDecode(jsonString);
  print('3333 decoded $decoded 44444');

    return GameDetails.fromJson(decoded);
  }
  // Function to load all game details (for all games in the list)
  Future<List<GameDetails>> loadAllGameDetails() async {
    List<Game> games = await loadGames();
    
    // Load the game details for each game in the list
    List<GameDetails> allGameDetails = [];
    for (var game in games) {
      GameDetails gameDetails = await loadGameDetails(game.directory);
      allGameDetails.add(gameDetails);
    }
    
    return allGameDetails;
  }
  void staticLoadGameDetails() {
    if (gameDetailsList.isEmpty) {
      // Use Future.delayed to call async functions after initState
      Future.delayed(Duration.zero, () async {

        gameDetailsList = await loadAllGameDetails();

        //setState(() 
        {
          //gameDetailsList = games;
          currentDirectoryIndex = 0;
          currentFileNumber = gameDetailsList[gamePicked].learn.normal[0].startNumber;
          currentDir = gameDetailsList[gamePicked].learn.normal[0].directory;
          defaultQuestionCount = gameDetailsList[gamePicked].play.numberOfQuestions['DefaultQuestionCount'];
          texts = currentText = gameDetailsList[gamePicked].learn.normal[0].name;
          endFileNumber = gameDetailsList[gamePicked].learn.normal[0].endNumber;
          totalCurrentDirCount = gameDetailsList[gamePicked].learn.normal[0].endNumber - gameDetailsList[0].learn.normal[0].startNumber + 1;
          totalDirectories = gameDetailsList[gamePicked].learn.normal.length;
          hint1Exists = gameDetailsList[gamePicked].learn.hint1.isNotEmpty;
          if (hint1Exists) {
            hint1Directory = gameDetailsList[gamePicked].learn.hint1[0].directory;
            hint1FileName = '$hint1Directory/H$currentFileNumber.jpg';
          }
          hint2Exists = gameDetailsList[gamePicked].learn.hint2.isNotEmpty;
          if (hint2Exists) {
            hint2Directory = gameDetailsList[gamePicked].learn.hint2[0].directory;
            hint2FileName = '$hint2Directory/H$currentFileNumber.m4a';
          }
          currentFileName = '$currentDir/$currentFileNumber.jpg';
          maxNumber=gameDetailsList[gamePicked].play.playModes['TotalOptions'];
          easyStartFirstNumber = gameDetailsList[gamePicked].play.playModes['Easy'][0]['StartNumber'];
          easyEndFirstNumber = gameDetailsList[gamePicked].play.playModes['Easy'][0]['EndNumber'];
          easyStartSecondNumber = gameDetailsList[gamePicked].play.playModes['Easy'][1]['StartNumber'];
          easyEndSecondNumber = gameDetailsList[gamePicked].play.playModes['Easy'][1]['EndNumber'];
          hardStartFirstNumber = gameDetailsList[gamePicked].play.playModes['Hard'][0]['StartNumber'];
          hardEndFirstNumber = gameDetailsList[gamePicked].play.playModes['Hard'][0]['EndNumber'];
          hardStartSecondNumber = gameDetailsList[gamePicked].play.playModes['Hard'][1]['StartNumber'];
          hardEndSecondNumber = gameDetailsList[gamePicked].play.playModes['Hard'][1]['EndNumber'];
        }
        //);

        // Print all game details for verification
        for (var gameDetails in gameDetailsList) {
          print('Game Name: ${gameDetails.name}');
          print('Description: ${gameDetails.description}');
          print('Play Modes: ${gameDetails.play.playModes}');
          print('Normal Items: ${gameDetails.learn.normal.map((item) => item.name).join(", ")}');
          print('Hint1 Items: ${gameDetails.learn.hint1.map((item) => item.name).join(", ")}');
          print('---');
        }
      });
    }
  }

class MyAppPageState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    staticLoadGameDetails();
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Hindi Vowel and Consonants App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: StartPage(gameDetailsList: [],),
      )
    );
  }
}

class MyAppState extends ChangeNotifier {
  //int questionCount = 10;  // Default question count
  late int correctAnswers;  // Total correct answers, now dynamic
  var randoom = Random().nextInt(49) + 1;
  late var current = randoom.toString();
  late List<String> allQuestionsList;
  //late List<String> correct;  // Updated dynamically with question count
  bool done = false;
  late int numb;
  var button1Clicked = <String>[]; //guesses
  var button2Clicked = <String>[]; //conson
  bool hard=false;
  bool hint1 = false;
  bool hint2 = false;
  //static var allGamesData;
  MyAppState();


  // Set the number of questions and adjust related properties
  void setQuestionCount(int count) {
    defaultQuestionCount = count;
    correctAnswers = count;
    //correct = List.generate(count, (index) => (index + 1).toString());
    allQuestionsList = [];
    done = false;
    button1Clicked.clear();
    Restart(false);
  }

  void setHint1() {
    hint1= true;
    notifyListeners();
  }

 void setHint2() {
  hint2 = true;
  notifyListeners();
}
  void getNext() {
    /*int minStartFirstNumber = gameDetailsList[gamePicked].play.playModes['Easy'][0]['StartNumber'];
    int minEndFirstNumber = gameDetailsList[gamePicked].play.playModes['Easy'][0]['EndNumber'];
    int minStartSecondNumber = gameDetailsList[gamePicked].play.playModes['Easy'][1]['StartNumber'];
    int minEndSecondNumber = gameDetailsList[gamePicked].play.playModes['Easy'][1]['EndNumber'];*/
    if (allQuestionsList.length==defaultQuestionCount){
      done=true;
    }
    if (!done) {
      if (allQuestionsList.indexOf(current) < allQuestionsList.length - 1) {
        current = allQuestionsList[allQuestionsList.indexOf(current) + 1];
      } else {
        int counter = 0;
        if(hard){
          do {
          randoom = Random().nextInt(maxNumber) + 1;
          current = randoom.toString();
          counter++;
        } while (allQuestionsList.contains(current) && counter <= defaultQuestionCount * 64);
        }
        else{
          do {
          randoom = Random().nextInt(maxNumber) + 1;
          current = randoom.toString();
          counter++;
        } while ((allQuestionsList.contains(current)|| (hardStartFirstNumber<=randoom && randoom<=hardEndFirstNumber)||(hardStartSecondNumber<=randoom && randoom<=hardEndSecondNumber)) && counter <= defaultQuestionCount * 64);
        }
        if (counter <= defaultQuestionCount * maxNumber) {
          allQuestionsList.add(current);
          print(allQuestionsList);
        } else {
          current = "end";
          done = true;
        }
      }
      numb = allQuestionsList.indexOf(current) + 1;
      hint1= false;
      hint2= false;
      notifyListeners();
    }
  hint2 = false;
  }

  void getPrev() {
    if (!done && allQuestionsList.indexOf(current) > 0) {
      current = allQuestionsList[allQuestionsList.indexOf(current) - 1];
      numb = allQuestionsList.indexOf(current) + 1;
      hint1=hint2=false;
      notifyListeners();
    }
  }
  void toggleGuess(){
    if (button1Clicked.contains(current)) {
      button1Clicked.remove(current);
    } else{
      button1Clicked.add(current);
    }
  }
  void Button2Click() {
    if (button1Clicked.contains(current)) {
      button1Clicked.remove(current);
    } 
    if (!button2Clicked.contains(current)) {
      button2Clicked.add(current);
    }
    notifyListeners();
  }
  void Button1Click() {
    if (!button1Clicked.contains(current)) {
      button1Clicked.add(current);
    }
    if (button2Clicked.contains(current)) {
      button2Clicked.remove(current);
    } 
    notifyListeners();
  }
  void Restart(end) {
    allQuestionsList.clear();
    randoom = Random().nextInt(defaultQuestionCount) + 1;
    current = randoom.toString();
    allQuestionsList.add(current);
    done = false;
    numb = 1;
    button1Clicked.clear();
    button2Clicked.clear();
    hint1=false;
    hint2=false;
    if (end==false){
      notifyListeners();
    }

  }

  static Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/games.json');
    print('4444 readJson $response 555555');
    final data = await json.decode(response);
    //allGamesData = data; 
    print(data);
  }
}



class StartPage extends StatefulWidget {
  StartPage({required gameDetailsList});
  @override
  StartPageState createState() => StartPageState();  
}

class StartPageState extends State<StartPage> {
  StartPageState();

  @override
  void initState() {
   super.initState();
   staticLoadGameDetails();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    wi.Size size = wi.Size(256.0,96.0);
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Page'),
      ),
      body: Container(
        color: theme.colorScheme.primaryContainer, // Matching GeneratorPage background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Color.fromRGBO(0, 0, 0, 1),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Please select an option below',
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetQuestionCountPage(gameDetailsList:[])),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: size,
                    ),
                    child: Text('Play Game',style: theme.textTheme.headlineLarge!.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),),
                  ),
                  SizedBox(width: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LearnPage(gameDetailsList:[])),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: size,
                    ),
                    child: Text('Learn',style: theme.textTheme.headlineLarge!.copyWith(
                          color: theme.colorScheme.onPrimary,
                    ),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameDetails {
  String name;
  String description;
  PlaySettings play;
  LearnSettings learn;

  GameDetails({
    required this.name,
    required this.description,
    required this.play,
    required this.learn,
  });

  factory GameDetails.fromJson(Map<String, dynamic> json) {
    return GameDetails(
      name: json['Name'],
      description: json['Description'],
      play: PlaySettings.fromJson(json['Play']),
      learn: LearnSettings.fromJson(json['Learn']),
    );
  }
}

class PlaySettings {
  Map<String, dynamic> numberOfQuestions;
  String hardMode;
  //String button;
  Map<String, dynamic> playModes;

  PlaySettings({
    required this.numberOfQuestions,
    required this.hardMode,
    //required this.button,
    required this.playModes,
  });

  factory PlaySettings.fromJson(Map<String, dynamic> json) {
    return PlaySettings(
      numberOfQuestions: json['Number of questions'],
      hardMode: json['HardMode'],
      //button: json['Button'],
      playModes: json['PlayModes'],
    );
  }
}

class LearnSettings {
  String gameType;
  Map<String, dynamic> button;
  List<LearnItem> normal;
  List<LearnItem> hint1;
  List<LearnItem> hint2;


  LearnSettings({
    required this.gameType,
    required this.button,
    required this.normal,
    required this.hint1,
    required this.hint2,
  });

  factory LearnSettings.fromJson(Map<String, dynamic> json) {
    var normalList = json['Normal'] as List;
    var hint1List = json['Hint1'] as List;
    var hint2List = json['Hint2'] as List;

    return LearnSettings(
      gameType: json['GameType'],
      button: json['Button'],
      normal: normalList.map((item) => LearnItem.fromJson(item)).toList(),
      hint1: hint1List.map((item) => LearnItem.fromJson(item)).toList(),
      hint2: hint2List.map((item) => LearnItem.fromJson(item)).toList(),
    );
  }
}

class LearnItem {
  String name;
  String directory;
  int startNumber;
  int endNumber;
  int? height;
  int? width;

  LearnItem({required this.name, required this.directory, required this.startNumber, 
    required this.endNumber, this.height, this.width});

  factory LearnItem.fromJson(Map<String, dynamic> json) {
    return LearnItem(
      name: json['Name'],
      directory: json['Directory'],
      startNumber: json['StartNumber'],
      endNumber: json['EndNumber'],
      height: json['height'],
      width: json['width'],
    );
  }
}

// Model class for a game in games.json
class Game {
  String name;
  String directory;

  Game({required this.name, required this.directory});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['Name'],
      directory: json['Directory'],
    );
  }
}

class LearnPage extends StatefulWidget {
  LearnPage({required gameDetailsList});
  @override
  LearnPageState createState() => LearnPageState();
}

class LearnPageState extends State<LearnPage> {
  LearnPageState();
  final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.STOP); // Create an instance of AudioPlayer

  @override
  void initState() {
   super.initState();
   staticLoadGameDetails();
   _playAudio(hint2FileName);
       _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      // Listen to player state changes
      if (state == PlayerState.COMPLETED) {
        print("Audio playback completed.");
      } else  {
        print("not sure what happened maybe Error during audio playback. $state.");
      }
    });
        // Listen to any audio player error
    _audioPlayer.onPlayerError.listen((message) {
      print("Error during audio playback: $message");
    });
  }

  @override
void dispose() {
  _audioPlayer.dispose(); // Clean up the player
  print("PLAYER disposed");
  super.dispose();
}
void _playAudio(String test) async {
  try {

  //String hint2FileName = 'assets/2H1.m4a';
    int result = await _audioPlayer.setUrl(hint2FileName, isLocal: true); // or setSourceUrl() for URLs
    print('AFTER attepting to load :$hint2FileName');

    // Now play the audio
    if (result == 1) {

    print('hintfile loaded successfully :$hint2FileName');
    await _audioPlayer.play(hint2FileName, isLocal: true);
    print("Audio is playing");
  } else {
    print("Error loading audio file: $result, $hint2FileName");
  }
  } catch (e) {
    print("Error during audio playback: $e");
  }
}

  void nextCard() {
    setState(() {
      if (currentFileNumber < endFileNumber) {
        currentFileNumber++; 
      }
      else {
          //switch to the next directory
          if (currentDirectoryIndex < totalDirectories - 1) {
            currentDirectoryIndex++;
          }
          // now that you have switched, update all variables except when you are in the last directory, last image and next button is pressed
          if ((currentDirectoryIndex < totalDirectories -1) || 
            (((currentDirectoryIndex == totalDirectories - 1) && (currentDirectoryIndex != 0) &&
            (gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex-1].endNumber == currentFileNumber)))) {
            startFileNumber = currentFileNumber = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].startNumber;
            currentDir = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].directory;
            texts = currentText = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].name;
            endFileNumber = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].endNumber;
            totalCurrentDirCount = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].endNumber - gameDetailsList[0].learn.normal[currentDirectoryIndex].startNumber + 1;
            hint1Exists = gameDetailsList[gamePicked].learn.hint1.isNotEmpty;
            hint2Exists = gameDetailsList[gamePicked].learn.hint2.isNotEmpty;
          }
      }
      currentFileName = '$currentDir/$currentFileNumber.jpg';
      if (hint1Exists) {
        hint1Directory = gameDetailsList[gamePicked].learn.hint1[currentDirectoryIndex].directory;
        hint1FileName = '$hint1Directory/H$currentFileNumber.jpg';
      }
      if (hint2Exists) {
        hint2Directory = gameDetailsList[gamePicked].learn.hint2[currentDirectoryIndex].directory;
        hint2FileName = '$hint2Directory/H$currentFileNumber.m4a';
        _playAudio(hint2FileName);
      }      
    });
  }

  void prevCard() {
    setState(() {
      if ((currentFileNumber > startFileNumber) && (currentFileNumber > 1))   {
        currentFileNumber--; 
      }
      else {
          //switch to the previous directory
          if (currentDirectoryIndex > 0) {
            currentDirectoryIndex--;
          }
          if ((currentDirectoryIndex >= 0)) { //  ||
            //(((currentDirectoryIndex == 0) &&
            //(gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].startNumber != currentFileNumber)))) {
            startFileNumber = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].startNumber;
            currentDir = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].directory;
            texts = currentText = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].name;
            if (gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].startNumber == currentFileNumber) {
              currentFileNumber = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].startNumber;
              endFileNumber = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].endNumber;
            }
            else {
              currentFileNumber = endFileNumber = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].endNumber;
            }
            hint1Exists = gameDetailsList[gamePicked].learn.hint1.isNotEmpty;
            hint2Exists = gameDetailsList[gamePicked].learn.hint2.isNotEmpty;
            totalCurrentDirCount = gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].endNumber - gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].startNumber + 1;
          }
      }
      currentFileName = '$currentDir/$currentFileNumber.jpg';
      if (hint1Exists) {
        hint1Directory = gameDetailsList[gamePicked].learn.hint1[currentDirectoryIndex].directory;
        hint1FileName = '$hint1Directory/H$currentFileNumber.jpg';
      }      
      if (hint2Exists) {
        hint2Directory = gameDetailsList[gamePicked].learn.hint2[currentDirectoryIndex].directory;
        hint2FileName = '$hint2Directory/H$currentFileNumber.m4a';
        _playAudio(hint2FileName);
      }
    });
  }

  /*void hint1Card() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        if (currentIndex<=12){
          texts="Hint1";
        }
      }
    });
  }

  void hint2Card() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        if (currentIndex<=12){
          texts="Hint2";
        }
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //staticLoadGameDetails();  
    //_playAudio();
    return Scaffold(
      appBar: AppBar(title: Text('Learn')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Color.fromRGBO(0, 0, 0, 1),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  texts,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                const SizedBox(height: 10),
                Image.asset(
                  //flashcards[currentIndex],
                  currentFileName,
                  height: 300,//(gameDetailsList.isNotEmpty)? gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].height!.toDouble(): 300,
                  width: 300,//(gameDetailsList.isNotEmpty) ? gameDetailsList[gamePicked].learn.normal[currentDirectoryIndex].width!.toDouble(): 300, 
                  fit: BoxFit.cover,
                ),
               Padding (padding: const EdgeInsets.only(right:20.0),),
                const SizedBox(height: 10, width: 100),
                Image.asset(
                  //flashcardsHint1[currentIndex],
                  hint1FileName,
                  //height: 250,//(gameDetailsList.isNotEmpty)? gameDetailsList[gamePicked].learn.hint1[currentDirectoryIndex].height!.toDouble(): 200,
                  //width: 500,//(gameDetailsList.isNotEmpty)? gameDetailsList[gamePicked].learn.hint1[currentDirectoryIndex].width!.toDouble(): 350, 
                  fit: BoxFit.cover,
                ),
                //Padding (padding: const EdgeInsets.only(right:20.0),),
                //const SizedBox(height: 10, width:20),
                //Text(
                //  flashcardsHint2[currentIndex],
                //  style: TextStyle(
                //    height: 30, 
                //    fontSize: 20,
                //    color: Colors.deepPurple,
                //    decorationThickness:2.85,
                //  ),
                //),
                /*Padding (padding: const EdgeInsets.only(right:30.0),),
                const SizedBox(height: 10, width:10),
                Text(
                  flashcardsWhy1[currentIndex],
                  style: TextStyle(
                    height: 30, 
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                    decorationThickness:2.85,
                  ),
                ),*/
              ],
            ), //Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: prevCard, 
                  child: Text((gameDetailsList.isNotEmpty)? gameDetailsList[gamePicked].learn.button['Back']['Name']: 'Previous'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: nextCard,
                  child: Text(gameDetailsList.isNotEmpty? gameDetailsList[gamePicked].learn.button['Next']['Name']:'Next'),
                ),
              ],
            ),
          ], //children
        ),
      ),
    );
  }
}




class SetQuestionCountPage extends StatefulWidget {
    SetQuestionCountPage({required gameDetailsList});

  @override
  SetQuestionCountPageState createState() => SetQuestionCountPageState();  
}

class SetQuestionCountPageState extends State<SetQuestionCountPage> {
  final TextEditingController _controller = TextEditingController();
  String errorMessage = '';
  SetQuestionCountPageState();

  @override
  void initState() {
   super.initState();
   staticLoadGameDetails();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    wi.Size size = wi.Size(256.0,96.0);
    var appState = context.watch<MyAppState>();
    staticLoadGameDetails();
    return Scaffold(
      appBar: AppBar(title: Text('Set Number of Questions')),
      body: Container(
        color: theme.colorScheme.primaryContainer,
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 128),
                  Card(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        //'How many questions do you want?',
                        gameDetailsList[gamePicked].play.numberOfQuestions['QuestionText'],
                        style: theme.textTheme.headlineMedium!.copyWith(
                          color: theme.colorScheme.onSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 256),
                  Card(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Select to make game harder",
                        style: theme.textTheme.headlineMedium!.copyWith(
                          color: theme.colorScheme.onSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 140),
                  Flexible(
                    child:SizedBox(
                      width:420,
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          //labelText: 'Enter #questions from 6 to 19, default #question-count=10',
                          labelText: gameDetailsList[gamePicked].play.numberOfQuestions['QuestionHint'],
                          errorText: errorMessage.isEmpty ? null : errorMessage,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 448),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      /* Text("",
                        style: theme.textTheme.headlineMedium!.copyWith(
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),), */
                      Switch(
                        value: appState.hard,
                        onChanged: (bool value) {
                          setState(() {
                            appState.hard = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              /* const SizedBox(height: 40),
              const SizedBox(width: 384),
              ElevatedButton(
                onPressed: () {
                  final input = _controller.text;
                  if (input.isNotEmpty) {
                    final number = int.tryParse(input);
                    if (number != null && number > 5) {
                      // Save the number of questions to app state or pass to next screen
                      // You can modify the state or pass the number to the game screen
                      appState.setQuestionCount(number);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(questionCount: number),
                        ),
                      );
                    } else {
                      setState(() {
                        errorMessage = 'Please enter a valid number greater than 5';
                      });
                    }
                  } 
                  else{appState.setQuestionCount(10);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(questionCount: 10),
                        ),
                      );
                  }
                },
                style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: Size(256, 96),
                ),
                child: Text('Start Game',style: theme.textTheme.headlineLarge!.copyWith(
                          color: theme.colorScheme.onPrimary,
                  ),
                ),
              ), */
              Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 128),
                  ElevatedButton(
                    onPressed: () {
                      final input = _controller.text;
                      if (input.isNotEmpty) {
                        final number = int.tryParse(input);
                        int maxNumber = gameDetailsList[gamePicked].play.numberOfQuestions['ValidationRangeMax']+1;
                        int minNumber = gameDetailsList[gamePicked].play.numberOfQuestions['ValidationRangeMin']-1;
                        if (number != null && number > minNumber) {
                          if (number<maxNumber){
                            appState.setQuestionCount(number);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(questionCount: number, gameDetailsList:[]),
                              ),
                            );
                          }
                          else{
                            setState(() {
                              errorMessage = 'Too many questions, please enter a valid number less than $maxNumber';
                            });
                          }
                        } else {
                          setState(() {
                            errorMessage = 'Please enter a valid number greater than $minNumber';
                          });
                        }
                      } else {
                        int defaultNumber = gameDetailsList[gamePicked].play.numberOfQuestions['DefaultQuestionCount'];
                        appState.setQuestionCount(defaultNumber);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(questionCount: defaultNumber, gameDetailsList:[]),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: size,
                    ),
                    child: Text(
                      'Start Game',
                      style: theme.textTheme.headlineLarge!.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
class MyHomePage extends StatefulWidget {
  final int questionCount;
  MyHomePage({Key? key, required this.questionCount, required gameDetailsList}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    if (selectedIndex == 0) {
      page = GeneratorPage(gameDetailsList: [],);
    } else if (selectedIndex == 1) {
      page = EndPage();
    } else {
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
                    if (value == 0) {
                      // Navigate back to StartPage instead of switching index
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => StartPage(gameDetailsList:[])),
                      );
                    } else {
                      setState(() {
                        selectedIndex = value;
                      });
                    }
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



class GeneratorPage extends StatefulWidget {
    GeneratorPage({required gameDetailsList});

  @override
  GeneratorPageState createState() => GeneratorPageState();  
}

class GeneratorPageState extends State<GeneratorPage> {
  GeneratorPageState();

  @override
  void initState() {
   super.initState();
   staticLoadGameDetails();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var button1String = gameDetailsList[gamePicked].play.playModes['Button']['1']['Name'];
    var button2String = gameDetailsList[gamePicked].play.playModes['Button']['2']['Name'];
    var button3String = "";
    if (gameDetailsList[gamePicked].play.playModes['Button']['3'] != null) {
      button3String = gameDetailsList[gamePicked].play.playModes['Button']['3']['Name'];
    }
    var hint1String = gameDetailsList[gamePicked].play.playModes['Button']['Hint1']['Name'];

    var hint2String = '';
    if (gameDetailsList[gamePicked].play.playModes['Button']['Hint2'] != null) {
      hint2String = gameDetailsList[gamePicked].play.playModes['Button']['Hint2']['Name'];
    }

    if (!appState.allQuestionsList.contains(pair)) {
      appState.allQuestionsList.add(pair);
    }

    if (appState.done==false){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.all(8.0)),
            Row(
              children:[
                Padding(padding: const EdgeInsets.all(8.0)),
                SizedBox(width: 10),
                if (appState.hint1==true) 
                  Hint1Card()
                else
                  BlueCard(),
                Padding(padding: const EdgeInsets.all(8.0)),
                SizedBox(width: 10),
                BigCard(),
                Padding(padding: const EdgeInsets.all(8.0)),
                SizedBox(width: 10),
                Hint2Card()
              ],
            ),
            SizedBox(height: 100),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      appState.getPrev();
                    },
                    child: Text('Go Back'),
                  ),
                  /*ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleGuess();
                    },
                    icon: Icon(icon),
                    label: Text('Vowel'),
                  ),*/
                  SizedBox(width: 10),
                  ElevatedButton(
                  onPressed: () {
                    appState.Button1Click();
                    appState.getNext();
                  },
                  child: Text(button1String.toString()),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                  onPressed: () {
                    appState.Button2Click();
                    appState.getNext();
                  },
                  child: Text(button2String.toString()),
                ),
                  SizedBox(width: 10),
                  ElevatedButton(
                  onPressed: () {
                    appState.setHint1();
                  },
                  child: Text(hint1String.toString()),
                ),
                  SizedBox(width: 10),
                  ElevatedButton(
                  onPressed: () {
                    appState.setHint2();
                  },
                  child: Text(hint2String.toString()),
                ), 
                /*SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),*/
              ],
            ),
          ],
        ),
      );
    }  
    if (appState.done) {
      Future.microtask(() {
        var homePageState = context.findAncestorStateOfType<_MyHomePageState>();
        homePageState?.setState(() {
          homePageState.selectedIndex = 1;  // Switch to EndPage
        });
      });
      Future.delayed(Duration(seconds: 3), () {
        appState.Restart(true);
      });
    }
    /* return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          BigCard(),
          //SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
            appState.Restart();
            },
            child: Text('Restart'),
          ),
          ] 
        )
    );    */
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          BigCard(),  
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
    int currentNumber = int.parse(current);
    var directory = "";
    if (currentNumber >= easyStartFirstNumber && currentNumber <= easyEndFirstNumber) {
      directory = gameDetailsList[gamePicked].play.playModes['Easy'][0]['Directory'];
      return Image.asset('$directory/$current.jpg');
    } else if (currentNumber >= easyStartSecondNumber && currentNumber <= easyEndSecondNumber) {
      directory = gameDetailsList[gamePicked].play.playModes['Easy'][1]['Directory'];
      return Image.asset('$directory/$current.jpg');
    } else if (currentNumber >= hardStartFirstNumber && currentNumber <= hardEndFirstNumber) {
      directory = gameDetailsList[gamePicked].play.playModes['Hard'][0]['Directory'];
      return Image.asset('$directory/$current.jpg');
    } else if (currentNumber >= hardStartSecondNumber && currentNumber <= hardEndSecondNumber) {
      directory = gameDetailsList[gamePicked].play.playModes['Hard'][1]['Directory'];
      return Image.asset('$directory/$current.jpg');
    }
    else {
      return Image.asset('assets/images/blueright.jpg');
    }
  }
}

class BlueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    late var current = appState.current;
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Image.asset('assets/images/blueright.jpg');
  }
}

class Hint1Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    late var currentstr = appState.current;
    late int current = int.parse(appState.current);
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    var hint1Directory = "";
    //get all easy value
    int minStartFirstNumber = gameDetailsList[gamePicked].play.playModes['Easy'][0]['StartNumber'];
    int minEndFirstNumber = gameDetailsList[gamePicked].play.playModes['Easy'][0]['EndNumber'];
    int minStartSecondNumber = gameDetailsList[gamePicked].play.playModes['Easy'][1]['StartNumber'];
    int minEndSecondNumber = gameDetailsList[gamePicked].play.playModes['Easy'][1]['EndNumber'];
    if (appState.hard == true) {
    //get the hint 1 directory based on the number
      int maxStartFirstNumber = gameDetailsList[gamePicked].play.playModes['Hard'][0]['StartNumber'];
      int maxEndFirstNumber = gameDetailsList[gamePicked].play.playModes['Hard'][0]['EndNumber'];
      int maxStartSecondNumber = gameDetailsList[gamePicked].play.playModes['Hard'][1]['StartNumber'];
      int maxEndSecondNumber = gameDetailsList[gamePicked].play.playModes['Hard'][1]['EndNumber'];   
      if (current >= minStartFirstNumber && current <= minEndFirstNumber) {
        hint1Directory = gameDetailsList[gamePicked].play.playModes['Easy'][0]['Hint1Directory'];
      } else if (current >= minStartSecondNumber && current <= minEndSecondNumber) {
        hint1Directory = gameDetailsList[gamePicked].play.playModes['Easy'][1]['Hint1Directory'];
      } else if (current >= maxStartFirstNumber && current <= maxEndFirstNumber) {
        hint1Directory = gameDetailsList[gamePicked].play.playModes['Hard'][0]['Hint1Directory'];
      } else if (current >= maxStartSecondNumber && current <= maxEndSecondNumber) {
        hint1Directory = gameDetailsList[gamePicked].play.playModes['Hard'][1]['Hint1Directory'];
      } 
    }
    else {
      if (current <= minEndFirstNumber) {
        hint1Directory = gameDetailsList[gamePicked].play.playModes['Easy'][0]['Hint1Directory'];
      } else if (current > minEndFirstNumber) {
        hint1Directory = gameDetailsList[gamePicked].play.playModes['Easy'][1]['Hint1Directory'];
      }
    }

    if (appState.hint1==true){
      // reset it to false so go back works
      //appState.hint1 = false;
      return Image.asset('$hint1Directory/H$currentstr.jpg');//$current
    }
    else{
      return Image.asset('assets/images/blueright.jpg');
    }
  }
}

class Hint2Card extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.STOP); // Create an instance of AudioPlayer
  @override
void dispose() {
  _audioPlayer.dispose(); // Clean up the player
  print("PLAYER disposed");
  //super.dispose();
}
void _playAudio(String audioString) async {
  try {

  //String hint2FileName = 'assets/2H1.m4a';
    int result = await _audioPlayer.setUrl(audioString, isLocal: true); // or setSourceUrl() for URLs
    print('AFTER attepting to load :$audioString');

    // Now play the audio
    if (result == 1) {

    print('hintfile loaded successfully :$audioString');
    await _audioPlayer.play(audioString, isLocal: true);
    print("Audio is playing");
  } else {
    print("Error loading audio file: $result, $audioString");
  }
  } catch (e) {
    print("Error during audio playback: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary);
    var currentstr = appState.current;
    int current = int.parse(appState.current);
    var hint2Directory = "";
    //get all easy value
    int minStartFirstNumber = gameDetailsList[gamePicked].play.playModes['Easy'][0]['StartNumber'];
    int minEndFirstNumber = gameDetailsList[gamePicked].play.playModes['Easy'][0]['EndNumber'];
    int minStartSecondNumber = gameDetailsList[gamePicked].play.playModes['Easy'][1]['StartNumber'];
    int minEndSecondNumber = gameDetailsList[gamePicked].play.playModes['Easy'][1]['EndNumber'];
    if (appState.hard == true) {
    //get the hint 2 directory based on the number
      int maxStartFirstNumber = gameDetailsList[gamePicked].play.playModes['Hard'][0]['StartNumber'];
      int maxEndFirstNumber = gameDetailsList[gamePicked].play.playModes['Hard'][0]['EndNumber'];
      int maxStartSecondNumber = gameDetailsList[gamePicked].play.playModes['Hard'][1]['StartNumber'];
      int maxEndSecondNumber = gameDetailsList[gamePicked].play.playModes['Hard'][1]['EndNumber'];   
      if (current >= minStartFirstNumber && current <= minEndFirstNumber) {
        hint2Directory = gameDetailsList[gamePicked].play.playModes['Easy'][0]['Hint2Directory'];
      } else if (current >= minStartSecondNumber && current <= minEndSecondNumber) {
        hint2Directory = gameDetailsList[gamePicked].play.playModes['Easy'][1]['Hint2Directory'];
      } else if (current >= maxStartFirstNumber && current <= maxEndFirstNumber) {
        hint2Directory = gameDetailsList[gamePicked].play.playModes['Hard'][0]['Hint2Directory'];
      } else if (current >= maxStartSecondNumber && current <= maxEndSecondNumber) {
        hint2Directory = gameDetailsList[gamePicked].play.playModes['Hard'][1]['Hint2Directory'];
      } 
    }
    else {
      if (current <= minEndFirstNumber) {
        hint2Directory = gameDetailsList[gamePicked].play.playModes['Easy'][0]['Hint2Directory'];
      } else if (current > minEndFirstNumber) {
        hint2Directory = gameDetailsList[gamePicked].play.playModes['Easy'][1]['Hint2Directory'];
      }
    }
    if (appState.hint2==true) {
          /*return Text(
      'text on card',
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      );*/
      _playAudio('$hint2Directory/H$current.m4a');
    }
    //else{
      //reset to false so go back works
      //appState.hint2 = false;
      return Text('');
    //}
  }
}

class EndPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.done==false){
      return Center(
        child: Text('Please finish the game to check your answers',style: TextStyle(fontSize: 32), 
          textAlign: TextAlign.center,),
      );
    }
    //appState.Restart();
    var missing=<String>[];
    var cmissing=<String>[];
    for (var pair in appState.allQuestionsList){
        print(pair);
        if(pair!="end"){
          if (false==appState.button1Clicked.contains(pair) && (int.parse(pair)<= gameDetailsList[gamePicked].play.playModes['Hard'][0]['EndNumber'])){
            missing.add(pair);
          }
          else if (false==appState.button2Clicked.contains(pair) && (int.parse(pair)> gameDetailsList[gamePicked].play.playModes['Hard'][0]['EndNumber'])){
            cmissing.add(pair);
          }
        }
    }

    var percent=(((appState.allQuestionsList.length-missing.length-cmissing.length)/appState.allQuestionsList.length)*100).ceil();
    //appState.Restart();
    /*return ListView(
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
    */
    return Padding(
    padding: EdgeInsets.all(16.0), // Adds padding around the entire page
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You got ${appState.allQuestionsList.length-missing.length-cmissing.length} questions right out of ${appState.allQuestionsList.length} questions.\n'
          'You got $percent% of the answers right. Good Job!!',
          style: TextStyle(fontSize: 16), // Adjust font size if needed
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20), // Small gap between text and images
        /* Text(
          'Here are the answers you said that were consonents but actually are vowels:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ), */
        /* Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: missing.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: Image.asset('assets/images/${missing[index]}.jpg'),
                  ),
                  Text(
                    "Correct Answer: Vowel \n" "Your Answer: Consonent",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
        /* const SizedBox(height: 20),
        Text(
          'Here are the answers you said that were vowels but actually are consonents:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ), */
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: cmissing.length,
            itemBuilder: (context, index) {
              //return Image.asset('assets/images/${cmissing[index]}.jpg');
              return Column(
                children: [
                  Expanded(
                    child: Image.asset('assets/images/${cmissing[index]}.jpg'),
                  ),
                  Text(
                    "Correct Answer: Consonent \n" "Your Answer: Vowel",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),*/
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: missing.length + cmissing.length, // Total incorrect answers
            itemBuilder: (context, index) {
              String item;
              String category;
              String categorys;
              var button1String = gameDetailsList[gamePicked].play.playModes['Button']['1']['Name'];
              var button2String = gameDetailsList[gamePicked].play.playModes['Button']['2']['Name'];

              // Merge the two lists
              if (index < missing.length) {
                item = missing[index]; 
                category = button1String;//"Vowel"; 
                categorys = button2String;//"Consonant";
              } else {
                item = cmissing[index - missing.length]; 
                category = button2String;//"Consonant"; 
                categorys = button1String;//"Vowel"; 
              }
              int currentNumber = int.parse(item);
              var directory = "";
              if (currentNumber >= easyStartFirstNumber && currentNumber <= easyEndFirstNumber) {
                directory = gameDetailsList[gamePicked].play.playModes['Easy'][0]['Directory'];
              } else if (currentNumber >= easyStartSecondNumber && currentNumber <= easyEndSecondNumber) {
                directory = gameDetailsList[gamePicked].play.playModes['Easy'][1]['Directory'];
              } else if (currentNumber >= hardStartFirstNumber && currentNumber <= hardEndFirstNumber) {
                directory = gameDetailsList[gamePicked].play.playModes['Hard'][0]['Directory'];
              } else if (currentNumber >= hardStartSecondNumber && currentNumber <= hardEndSecondNumber) {
                directory = gameDetailsList[gamePicked].play.playModes['Hard'][1]['Directory'];
              }
              return Column(
                children: [
                  Expanded(
                    child: Image.asset('$directory/$item.jpg'), 
                  ),
                  Text(
                    "Correct Answer: $category \n""Your Answer: $categorys",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height:20),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
  }
}