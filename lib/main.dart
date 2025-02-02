import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

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
              if (index == 5) {
                // 랜덤 뽑기: 1~5번 메뉴 중 랜덤 선택 후, 랜덤 문제 모드 활성화
                int randomMenuIndex = Random().nextInt(5) + 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProblemDisplayPage(
                      menuIndex: randomMenuIndex,
                      isRandom: true,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProblemDisplayPage(
                      menuIndex: index + 1,
                      isRandom: false,
                    ),
                  ),
                );
              }
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
  List<Directory> problemDirs = [];
  int currentIndex = 0;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    loadProblems();
  }

  void loadProblems() {
    // 문제 디렉토리 경로: 프로젝트 폴더/images/<menuIndex>
    String path = "images/${widget.menuIndex}";
    Directory dir = Directory(path);
    if (dir.existsSync()) {
      List<Directory> dirs =
          dir.listSync().whereType<Directory>().toList();
      dirs.sort((a, b) => a.path.compareTo(b.path));
      setState(() {
        problemDirs = dirs;
        if (widget.isRandom) {
          currentIndex = Random().nextInt(problemDirs.length);
        } else {
          currentIndex = 0;
        }
      });
    }
  }

  void nextProblem() {
    if (widget.isRandom) {
      setState(() {
        currentIndex = Random().nextInt(problemDirs.length);
        showAnswer = false;
      });
    } else {
      if (currentIndex < problemDirs.length - 1) {
        setState(() {
          currentIndex++;
          showAnswer = false;
        });
      }
    }
  }

  void prevProblem() {
    if (!widget.isRandom && currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (problemDirs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("메뉴 ${widget.menuIndex}")),
        body: Center(child: Text("문제가 없습니다.")),
      );
    }

    // 각 문제 폴더 내에는 "문제.png"와 "정답.png" 파일이 있어야 함.
    String problemPath = "${problemDirs[currentIndex].path}/문제.png";
    String answerPath = "${problemDirs[currentIndex].path}/정답.png";

    // 화면 크기에 맞춰 이미지 높이를 조정합니다.
    double screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = MediaQuery.of(context).size.height * 0.5; // 50% 높이

    return Scaffold(
      appBar: AppBar(
        title: Text("메뉴 ${widget.menuIndex} - 문제 ${currentIndex + 1}"),
      ),
      bottomNavigationBar: 
            Container(
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
            // 문제 이미지를 크게 표시
            Container(
              width: screenWidth,
              height: imageHeight,
              color: Colors.white,
              child: Image.file(
                File(problemPath),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 10),
            // 정답 이미지: 기본은 숨김 상태
            showAnswer
                ? Container(
                    width: screenWidth,
                    height: 50,
                    color: Colors.black12,
                    child: Image.file(
                      File(answerPath),
                      fit: BoxFit.contain,
                    ),
                  )
                : Container(
                    width: screenWidth,
                    height: 50,
                    color: Colors.grey[300],
                    child: Center(
                        child: Text("정답을 보려면 '정답 보기' 버튼을 누르세요.",
                            style: TextStyle(fontSize: 18))),
                  ),
            
          ],
        ),
      ),
    );
  }
}
