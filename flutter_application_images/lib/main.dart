import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

//import 'package:audioplayers/audio_cache.dart';
//import 'package:audioplayers/audioplayers.dart';


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
        title: 'Hindi Vowel and Constanants App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: StartPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  int questionCount = 10;  // Default question count
  late int corans;  // Total correct answers, now dynamic
  var randoom = Random().nextInt(49) + 1;
  late var current = randoom.toString();
  late List<String> allWords;
  //late List<String> correct;  // Updated dynamically with question count
  bool done = false;
  late int numb;
  var guesses = <String>[];
  var conson = <String>[];
  bool hard=false;
  bool hint1 = false;
  bool hint2 = false;
  static var allGamesData;
  //List<String> allGames;
  //List <List<String>> allGamesData;
  MyAppState();
  //readJson();

  // Set the number of questions and adjust related properties
  void setQuestionCount(int count) {
    questionCount = count;
    corans = count;
    //correct = List.generate(count, (index) => (index + 1).toString());
    allWords = [];
    done = false;
    guesses.clear();
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
  if (allWords.length==questionCount){
    done=true;
  }
  if (!done) {
    if (allWords.indexOf(current) < allWords.length - 1) {
      current = allWords[allWords.indexOf(current) + 1];
    } else {
      int counter = 0;
      if(hard){
        do {
        randoom = Random().nextInt(49) + 1;
        current = randoom.toString();
        counter++;
      } while (allWords.contains(current) && counter <= questionCount * 64);
      }
      else {
        do {
        randoom = Random().nextInt(49) + 1;
        current = randoom.toString();
        counter++;
      } while ((allWords.contains(current)|| (11<=randoom && randoom<=13)||(45<=randoom && randoom<=49)) && counter <= questionCount * 64);
      }
      if (counter <= questionCount * 49) {
        allWords.add(current);
        print(allWords);
      } else {
        current = "end";
        done = true;
      }
    }
    numb = allWords.indexOf(current) + 1;
    hint1= false;
    hint2= false;
    notifyListeners();
  }
}

  void getPrev() {
    if (!done && allWords.indexOf(current) > 0) {
      current = allWords[allWords.indexOf(current) - 1];
      numb = allWords.indexOf(current) + 1;
      notifyListeners();
    }
  }
  void toggleGuess(){
    if (guesses.contains(current)) {
      guesses.remove(current);
    } else{
      guesses.add(current);
    }
  }
  void con() {
    if (guesses.contains(current)) {
      guesses.remove(current);
    } 
    if (!conson.contains(current)) {
      conson.add(current);
    }
    notifyListeners();
  }
  void Vowel() {
    if (!guesses.contains(current)) {
      guesses.add(current);
    }
    if (conson.contains(current)) {
      conson.remove(current);
    } 
    notifyListeners();
  }
  void Restart(end) {
    allWords.clear();
    randoom = Random().nextInt(questionCount) + 1;
    current = randoom.toString();
    allWords.add(current);
    done = false;
    numb = 1;
    guesses.clear();
    conson.clear();
    hint1=false;
    hint2=false;
    if (end==false){
      notifyListeners();
    }
  }

  static Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/games.json');
    final data = await json.decode(response);
    allGamesData = data; 
    print(allGamesData);
  }
}


class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //MyAppState.readJson();
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to your Hindi Vowel and Constonants App'),
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
                        MaterialPageRoute(builder: (context) => SetQuestionCountPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: Size(256, 96),
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
                        MaterialPageRoute(builder: (context) => LearnPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: Size(256, 96),
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


class LearnPage extends StatefulWidget {
  @override
  _LearnPageState createState() => _LearnPageState();
}

class GameList {
  List<String> games;

  GameList({required this.games});

  // Factory constructor to create an instance from a JSON map
  factory GameList.fromJson(Map<String, dynamic> json) {
    return GameList(
      games: List<String>.from(json['games']),
    );
  }
}

class _LearnPageState extends State<LearnPage> {

  Future<GameList> loadGames() async {
      var response = await rootBundle.loadString('assets/games.json');
      Map<String, dynamic> decoded = await json.decode(response);
      return GameList.fromJson(decoded);
  }

  @override
  void initState() {
    Future<GameList> gameList =  loadGames();
    print(gameList);
    super.initState();
  }

  List<String> flashcards = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
    'assets/images/6.jpg',
    'assets/images/7.jpg',
    'assets/images/8.jpg',
    'assets/images/9.jpg',
    'assets/images/10.jpg',
    'assets/images/11.jpg',
    'assets/images/12.jpg',
    'assets/images/13.jpg',
    'assets/images/14.jpg',
    'assets/images/15.jpg',
    'assets/images/16.jpg',
    'assets/images/17.jpg',
    'assets/images/18.jpg',
    'assets/images/19.jpg',
    'assets/images/20.jpg',
    'assets/images/21.jpg',
    'assets/images/22.jpg',
    'assets/images/23.jpg',
    'assets/images/24.jpg',
    'assets/images/25.jpg',
    'assets/images/26.jpg',
    'assets/images/27.jpg',
    'assets/images/28.jpg',
    'assets/images/29.jpg',
    'assets/images/30.jpg',
    'assets/images/31.jpg',
    'assets/images/32.jpg',
    'assets/images/33.jpg',
    'assets/images/34.jpg',
    'assets/images/35.jpg',
    'assets/images/36.jpg',
    'assets/images/37.jpg',
    'assets/images/38.jpg',
    'assets/images/39.jpg',
    'assets/images/40.jpg',
    'assets/images/41.jpg',
    'assets/images/42.jpg',
    'assets/images/43.jpg',
    'assets/images/44.jpg',
    'assets/images/45.jpg',
    'assets/images/46.jpg',
    'assets/images/47.jpg',
    'assets/images/48.jpg',
    'assets/images/49.jpg',
  ];
  List<String> flashcardsHint1 = [
    'assets/images/H1.jpg',
    'assets/images/H2.jpg',
    'assets/images/H3.jpg',
    'assets/images/H4.jpg',
    'assets/images/H5.jpg',
    'assets/images/H6.jpg',
    'assets/images/H7.jpg',
    'assets/images/H8.jpg',
    'assets/images/H9.jpg',
    'assets/images/H10.jpg',
    'assets/images/H11.jpg',
    'assets/images/H12.jpg',
    'assets/images/H13.jpg',
    'assets/images/H14.jpg',
    'assets/images/H15.jpg',
    'assets/images/H16.jpg',
    'assets/images/H17.jpg',
    'assets/images/H18.jpg',
    'assets/images/H19.jpg',
    'assets/images/H20.jpg',
    'assets/images/H21.jpg',
    'assets/images/H22.jpg',
    'assets/images/H23.jpg',
    'assets/images/H24.jpg',
    'assets/images/H25.jpg',
    'assets/images/H26.jpg',
    'assets/images/H27.jpg',
    'assets/images/H28.jpg',
    'assets/images/H29.jpg',
    'assets/images/H30.jpg',
    'assets/images/H31.jpg',
    'assets/images/H32.jpg',
    'assets/images/H33.jpg',
    'assets/images/H34.jpg',
    'assets/images/H35.jpg',
    'assets/images/H36.jpg',
    'assets/images/H37.jpg',
    'assets/images/H38.jpg',
    'assets/images/H39.jpg',
    'assets/images/H40.jpg',
    'assets/images/H41.jpg',
    'assets/images/H42.jpg',
    'assets/images/H43.jpg',
    'assets/images/H44.jpg',
    'assets/images/H45.jpg',
    'assets/images/H46.jpg',
    'assets/images/H47.jpg',
    'assets/images/H48.jpg',
    'assets/images/H49.jpg',
  ];
    List<String> flashcardsHint2 = [
    'K=Kamal',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
    'assets/images/6.jpg',
    'assets/images/7.jpg',
    'assets/images/8.jpg',
    'assets/images/9.jpg',
    'assets/images/10.jpg',
    'assets/images/11.jpg',
    'assets/images/12.jpg',
    'assets/images/13.jpg',
    'assets/images/14.jpg',
    'assets/images/15.jpg',
    'assets/images/16.jpg',
    'assets/images/17.jpg',
    'assets/images/18.jpg',
    'assets/images/19.jpg',
    'assets/images/20.jpg',
    'assets/images/21.jpg',
    'assets/images/22.jpg',
    'assets/images/23.jpg',
    'assets/images/24.jpg',
    'assets/images/25.jpg',
    'assets/images/26.jpg',
    'assets/images/27.jpg',
    'assets/images/28.jpg',
    'assets/images/29.jpg',
    'assets/images/30.jpg',
    'assets/images/31.jpg',
    'assets/images/32.jpg',
    'assets/images/33.jpg',
    'assets/images/34.jpg',
    'assets/images/35.jpg',
    'assets/images/36.jpg',
    'assets/images/37.jpg',
    'assets/images/38.jpg',
    'assets/images/39.jpg',
    'assets/images/40.jpg',
    'assets/images/41.jpg',
    'assets/images/42.jpg',
    'assets/images/43.jpg',
    'assets/images/44.jpg',
    'assets/images/45.jpg',
    'assets/images/46.jpg',
    'assets/images/47.jpg',
    'assets/images/48.jpg',
    'assets/images/49.jpg',
  ];
    List<String> flashcardsWhy1 = [
    'Not a vowel which would sound like a,e,i,o,u',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
    'assets/images/5.jpg',
    'assets/images/6.jpg',
    'assets/images/7.jpg',
    'assets/images/8.jpg',
    'assets/images/9.jpg',
    'assets/images/10.jpg',
    'assets/images/11.jpg',
    'assets/images/12.jpg',
    'assets/images/13.jpg',
    'assets/images/14.jpg',
    'assets/images/15.jpg',
    'assets/images/16.jpg',
    'assets/images/17.jpg',
    'assets/images/18.jpg',
    'assets/images/19.jpg',
    'assets/images/20.jpg',
    'assets/images/21.jpg',
    'assets/images/22.jpg',
    'assets/images/23.jpg',
    'assets/images/24.jpg',
    'assets/images/25.jpg',
    'assets/images/26.jpg',
    'assets/images/27.jpg',
    'assets/images/28.jpg',
    'assets/images/29.jpg',
    'assets/images/30.jpg',
    'assets/images/31.jpg',
    'assets/images/32.jpg',
    'assets/images/33.jpg',
    'assets/images/34.jpg',
    'assets/images/35.jpg',
    'assets/images/36.jpg',
    'assets/images/37.jpg',
    'assets/images/38.jpg',
    'assets/images/39.jpg',
    'assets/images/40.jpg',
    'assets/images/41.jpg',
    'assets/images/42.jpg',
    'assets/images/43.jpg',
    'assets/images/44.jpg',
    'assets/images/45.jpg',
    'assets/images/46.jpg',
    'assets/images/47.jpg',
    'assets/images/48.jpg',
    'assets/images/49.jpg',
  ];
  int currentIndex = 0;
  String texts="Vowel";
  void nextCard() {
    setState(() {
      if (currentIndex < flashcards.length - 1) {
        currentIndex++; 
        if (currentIndex>12){
          texts="Consonant";
        }
      }
    });
  }

  void prevCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        if (currentIndex<=12){
          texts="Vowel";
        }
      }
    });
  }

  void hint1Card() {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  flashcards[currentIndex],
                  height: 300, 
                  width: 300,
                  fit: BoxFit.cover,
                ),
               Padding (padding: const EdgeInsets.only(right:20.0),),
                const SizedBox(width: 50),
                Image.asset(
                  flashcardsHint1[currentIndex],
                  height: 200, 
                  width: 350,
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
                  child: Text('Previous'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: nextCard,
                  child: Text('Next'),
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
  @override
  _SetQuestionCountPageState createState() => _SetQuestionCountPageState();
}

class _SetQuestionCountPageState extends State<SetQuestionCountPage> {
  final TextEditingController _controller = TextEditingController();
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
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
                        'How many questions do you want?',
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
                          labelText: 'Enter #questions from 6 to 19, default #question-count=10',
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
                        if (number != null && number > 5) {
                          if (number<20){
                            appState.setQuestionCount(number);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(questionCount: number),
                              ),
                            );
                          }
                          else{
                            setState(() {
                              errorMessage = 'Too many questions, please enter a valid number less than 20';
                            });
                          }
                        } else {
                          setState(() {
                            errorMessage = 'Please enter a valid number greater than 5';
                          });
                        }
                      } else {
                        appState.setQuestionCount(10);
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

  MyHomePage({Key? key, required this.questionCount}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    if (selectedIndex == 0) {
      page = GeneratorPage();
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
                        MaterialPageRoute(builder: (context) => StartPage()),
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


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    /*IconData icon;
    if (appState.guesses.contains(pair)) {
      icon = Icons.thumb_up;
    } else {
      icon = Icons.thumb_up_outlined;
    }*/
    if (!appState.allWords.contains(pair)) {
      appState.allWords.add(pair);
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
                    appState.Vowel();
                    appState.getNext();
                  },
                  child: Text('Vowel'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                  onPressed: () {
                    appState.con();
                    appState.getNext();
                  },
                  child: Text('Consonant'),
                ),
                  SizedBox(width: 10),
                  ElevatedButton(
                  onPressed: () {
                    appState.setHint1();
                  },
                  child: Text('Hint 1'),
                ),
                //                  SizedBox(width: 10),
                //  ElevatedButton(
                //  onPressed: () {
                //    appState.setHint2();
                //  },
                //  child: Text('Hint 2'),
                //),
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
    return Image.asset('assets/images/$current.jpg');
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
    late var current = appState.current;
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    if (appState.hint1==true){
      return Image.asset('assets/images/H$current.jpg');//$current
    }
    else{
      return Image.asset('assets/images/blueright.jpg');
    }
  }
}

class Hint2Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary);
    if (appState.hint2==true) {
          return Text(
      'text on card',
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      );
    }
    else{
      return Text('');
    }
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
    for (var pair in appState.allWords){
        print(pair);
        if(pair!="end"){
          if (false==appState.guesses.contains(pair) && (int.parse(pair)<=11)){
            missing.add(pair);
          }
          else if (false==appState.conson.contains(pair) && (int.parse(pair)>11)){
            cmissing.add(pair);
          }
        }
    }

    var percent=(((appState.allWords.length-missing.length-cmissing.length)/appState.allWords.length)*100).ceil();
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
          'You got ${appState.allWords.length-missing.length-cmissing.length} questions right out of ${appState.allWords.length} questions.\n'
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
              // Merge the two lists
              if (index < missing.length) {
                item = missing[index]; 
                category = "Vowel"; 
                categorys = "Consonant";
              } else {
                item = cmissing[index - missing.length]; 
                category = "Consonant"; 
                categorys = "Vowel"; 
              }

              return Column(
                children: [
                  Expanded(
                    child: Image.asset('assets/images/$item.jpg'), 
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