import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(CBTApp());
}

class CBTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CBT App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<String> menuOptions = [
    "인공지능 데이터 확보",
    "인공지능 데이터 전처리",
    "인공지능 데이터 특징 추출",
    "인공지능 모델 학습",
    "인공지능서비스 인터페이스 개발",
    "랜덤 뽑기",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CBT 메뉴")),
      body: ListView.builder(
        itemCount: menuOptions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("${index + 1}. ${menuOptions[index]}"),
            onTap: () {
              int menuIndex;
              bool isRandom;
              if (index == 5) {
                // 1~5번 메뉴 중 랜덤 선택
                menuIndex = Random().nextInt(5) + 1;
                isRandom = true;
              } else {
                menuIndex = index + 1;
                isRandom = false;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProblemDisplayPage(
                    menuIndex: menuIndex,
                    isRandom: isRandom,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProblemDisplayPage extends StatefulWidget {
  final int menuIndex;
  final bool isRandom; // 랜덤 모드 여부
  ProblemDisplayPage({required this.menuIndex, required this.isRandom});

  @override
  _ProblemDisplayPageState createState() => _ProblemDisplayPageState();
}

class _ProblemDisplayPageState extends State<ProblemDisplayPage> {
  // 각 문제를 '문제'와 '정답' 이미지의 경로로 구성된 Map의 리스트로 저장합니다.
  List<Map<String, String>> problems = [];
  int currentIndex = 0;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    loadProblems();
  }

  /// AssetManifest.json을 읽어, 해당 메뉴의 문제(문제.png)와 정답(정답.png) 경로를 추출합니다.
  Future<void> loadProblems() async {
    final manifestContent =
        await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // 예: images/1/ 폴더 내의 "문제.png" 파일을 모두 찾습니다.
    List<String> problemPaths = manifestMap.keys
        .where((String key) =>
            key.startsWith('images/${widget.menuIndex}/') &&
            key.endsWith('문제.png'))
        .toList();
    problemPaths.sort();

    List<Map<String, String>> loadedProblems = [];
    for (var pPath in problemPaths) {
      // 동일 폴더 내의 "정답.png" 경로를 생성합니다.
      String answerPath = pPath.replaceAll('문제.png', '정답.png');
      if (manifestMap.containsKey(answerPath)) {
        loadedProblems.add({
          'problem': pPath,
          'answer': answerPath,
        });
      }
    }

    setState(() {
      problems = loadedProblems;
      if (problems.isNotEmpty) {
        currentIndex = widget.isRandom
            ? Random().nextInt(problems.length)
            : 0;
      }
    });
  }

  void nextProblem() {
    if (problems.isEmpty) return;
    setState(() {
      if (widget.isRandom) {
        currentIndex = Random().nextInt(problems.length);
      } else {
        if (currentIndex < problems.length - 1) {
          currentIndex++;
        }
      }
      showAnswer = false;
    });
  }

  void prevProblem() {
    if (problems.isEmpty) return;
    if (!widget.isRandom && currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (problems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("메뉴 ${widget.menuIndex}")),
        body: Center(child: Text("문제가 없습니다.")),
      );
    }

    String problemAsset = problems[currentIndex]['problem']!;
    String answerAsset = problems[currentIndex]['answer']!;

    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: Text("메뉴 ${widget.menuIndex} - 문제 ${currentIndex + 1}"),
      ),
      bottomNavigationBar: Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: prevProblem,
              child: Text("이전 문제"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showAnswer = !showAnswer;
                });
              },
              child: Text("정답 보기"),
            ),
            ElevatedButton(
              onPressed: nextProblem,
              child: Text("다음 문제"),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 문제 이미지 표시
            Container(
              width: screenWidth,
              height: imageHeight,
              color: Colors.white,
              child: Image.asset(
                problemAsset,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10),
            // 정답 이미지 (버튼을 누르면 표시)
            showAnswer
                ? Container(
                    width: screenWidth,
                    height: 50,
                    color: Colors.black12,
                    child: Image.asset(
                      answerAsset,
                      fit: BoxFit.contain,
                    ),
                  )
                : Container(
                    width: screenWidth,
                    height: 50,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        "정답을 보려면 '정답 보기' 버튼을 누르세요.",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
