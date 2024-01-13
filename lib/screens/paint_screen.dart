import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scribbl/models/my_custom_paint.dart';
import 'package:scribbl/models/touch_points.dart';
import 'package:scribbl/screens/final_leaderboard.dart';
import 'package:scribbl/screens/home_screen.dart';
import 'package:scribbl/screens/waiting_lobby_screen.dart';
import 'package:scribbl/sidebar/player_scoreboard_drawer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  const PaintScreen({super.key, required this.data, required this.screenFrom});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  int guessedUsercnt = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final scrollController = ScrollController();
  List<Map> messages = [];
  final controller = TextEditingController();
  List<Map> scoreboard = [];

  bool isTextReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowfinalLeaderBoard = false;

  @override
  void initState() {
    connect();
    super.initState();
  }

  void startTimer() {
    const onesec = Duration(seconds: 1);
    _timer = Timer.periodic(onesec, (timer) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _socket.disconnect();
    _socket.dispose();
    _timer.cancel();
    super.dispose();
  }

  List<Widget> textBlankWidget = [];

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text(
        '_',
        style: TextStyle(fontSize: 30),
      ));
    }
  }

  void selectColor() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Choose Color"),
              content: SingleChildScrollView(
                child: BlockPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      String colorString = color.toString();
                      String valueString =
                          colorString.split('(0x')[1].split(')')[0];

                      Map map = {
                        'color': valueString,
                        'roomName': dataOfRoom['name']
                      };
                      _socket.emit('color-change', map);
                    }),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"))
              ],
            ));
  }

  void connect() {
    _socket = IO.io('http://10.0.2.2:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();
    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }
    _socket.onConnect((data) {
      print("connected");
      _socket.on('updateRoom', (roomData) {
        print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });

        if (roomData['isJoin'] != true) {
          startTimer();
        }
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'].toString()
            });
          });
        }
      });

      _socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor
                  ..strokeWidth = strokeWidth,
                points: Offset((point['details']['dx'].toDouble()),
                    (point['details']['dy'].toDouble()))));
          });
        }
      });
      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        print(value);
        Color otherColor = Color(value);
        setState(() {
          selectedColor = otherColor;
        });
      });
      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });
      _socket.on('clear-screen', (data) {
        setState(() {
          points.clear();
        });
      });

      _socket.on('msg', (msgdata) {
        setState(() {
          messages.add(msgdata);
          guessedUsercnt = msgdata['guessedUsercnt'];
        });
        if (guessedUsercnt == dataOfRoom['players'].length - 1) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }
        scrollController.animateTo(
            scrollController.position.maxScrollExtent + 40,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });

      _socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
                setState(() {
                  dataOfRoom = data;
                  renderTextBlank(data['word']);
                  isTextReadOnly = false;
                  guessedUsercnt = 0;
                  points.clear();
                  _start = 60;
                });
                Navigator.of(context).pop();
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                title: Center(child: Text("Word was $oldWord")),
              );
            });
      });
      _socket.on('closeInput', (data) {
        _socket.emit('updateScore', widget.data['name']);
        setState(() {
          isTextReadOnly = true;
        });
      });

      _socket.on(
          'notCorrectGame',
          (data) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
              (route) => false));

      _socket.on('updateScore', (roomData) {
        scoreboard.clear();
        for (int i = 0; i < roomData['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomData['players'][i]['nickname'],
              'points': roomData['players'][i]['points'],
            });
          });
        }
      });
      _socket.on('show-leaderboard', (roomPlayers) {
        scoreboard.clear();
        for (int i = 0; i < roomPlayers.length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomPlayers[i]['nickname'],
              'points': roomPlayers[i]['points'],
            });
          });
          if (maxPoints < int.parse(scoreboard[i]['points'].toString())) {
            winner = scoreboard[i]['username'];
            maxPoints = int.parse(scoreboard[i]['points'].toString());
          }
        }
        setState(() {
          _timer.cancel();
          isShowfinalLeaderBoard = true;
        });
      });
      _socket.on('user-disconnected', (data) {
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],
              'points': data['players'][i]['points'],
            });
          });
        }
      });
    });
    _socket.onDisconnect((_) => print('Connection Disconnection'));
    _socket.onConnectError((err) => print(err));
    _socket.onError((err) => print(err));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      drawer: PlayerScore(scoreboard),
      backgroundColor: Colors.grey.shade100,
      body:
          // ignore: unnecessary_null_comparison
          dataOfRoom != null
              ? dataOfRoom['isJoin'] != true
                  ? !isShowfinalLeaderBoard
                      ? Stack(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: size.width,
                                    height: size.height * 0.55,
                                    child: GestureDetector(
                                        onPanUpdate: (details) {
                                          print(details.localPosition.dx);
                                          _socket.emit('paint', {
                                            'details': {
                                              'dx': details.localPosition.dx,
                                              'dy': details.localPosition.dy
                                            },
                                            'roomName': widget.data['name']
                                          });
                                        },
                                        onPanStart: (details) {
                                          _socket.emit('paint', {
                                            'details': {
                                              'dx': details.localPosition.dx,
                                              'dy': details.localPosition.dy
                                            },
                                            'roomName': widget.data['name']
                                          });
                                        },
                                        onPanEnd: (details) {
                                          _socket.emit('paint', {
                                            'details': null,
                                            'roomName': widget.data['name']
                                          });
                                        },
                                        child: SizedBox.expand(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: RepaintBoundary(
                                              child: CustomPaint(
                                                size: Size.infinite,
                                                painter: MyCustomPainter(
                                                    pointsList: points),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: selectColor,
                                          icon: Icon(
                                            Icons.color_lens,
                                            color: selectedColor,
                                          )),
                                      Expanded(
                                          child: Slider(
                                        min: 1.0,
                                        max: 10,
                                        label: "StrokeWidth $strokeWidth",
                                        activeColor: selectedColor,
                                        value: strokeWidth,
                                        onChanged: (value) {
                                          Map map = {
                                            'value': value,
                                            'roomName': dataOfRoom['name']
                                          };
                                          _socket.emit('stroke-width', map);
                                        },
                                      )),
                                      IconButton(
                                          onPressed: () {
                                            _socket.emit('clear-screen',
                                                dataOfRoom['name']);
                                          },
                                          icon: Icon(
                                            Icons.layers_clear,
                                            color: selectedColor,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  dataOfRoom.containsKey('turn') &&
                                          (dataOfRoom['turn']['nickname'] !=
                                              widget.data['nickname'])
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: textBlankWidget)
                                      : Center(
                                          child: Text(
                                          dataOfRoom['word'] != null
                                              ? dataOfRoom['word'].toString()
                                              : "",
                                          style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w400),
                                        )),
                                  SizedBox(
                                      height: size.height * 0.3,
                                      child: ListView.builder(
                                          itemCount: messages.length,
                                          shrinkWrap: true,
                                          controller: scrollController,
                                          itemBuilder: (context, index) {
                                            var msg = messages[index].values;
                                            return ListTile(
                                              title: Text(msg.elementAt(0),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              subtitle: Text(
                                                msg.elementAt(1),
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 16),
                                              ),
                                            );
                                          }))
                                ],
                              ),
                            ),
                            dataOfRoom.containsKey('turn') &&
                                    (dataOfRoom['turn']['nickname'] !=
                                        widget.data['nickname'])
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: TextField(
                                          readOnly: isTextReadOnly,
                                          controller: controller,
                                          textInputAction: TextInputAction.done,
                                          autocorrect: false,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color:
                                                          Colors.transparent)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color:
                                                          Colors.transparent)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                              fillColor:
                                                  const Color(0xffF5F5FA),
                                              filled: true,
                                              hintText: "Your Guess",
                                              hintStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400)),
                                          onSubmitted: (value) {
                                            if (value.trim().isNotEmpty) {
                                              Map map = {
                                                'username':
                                                    widget.data['nickname'],
                                                'msg': value.trim(),
                                                'word': dataOfRoom['word'],
                                                'roomName': dataOfRoom['name'],
                                                'guessedUsercnt':
                                                    guessedUsercnt,
                                                'totalTime': 60,
                                                'timeTaken': 60 - _start,
                                              };
                                              _socket.emit('msg', map);
                                              controller.clear();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            SafeArea(
                                child: IconButton(
                              onPressed: () =>
                                  scaffoldKey.currentState!.openDrawer(),
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.black,
                              ),
                            ))
                          ],
                        )
                      : FinalLeaderboard(scoreboard, winner)
                  : WaitingLobbyScreen(
                      lobbyName: dataOfRoom['name'],
                      numberofPlayers: dataOfRoom['players'].length,
                      occupancy: dataOfRoom['occupancy'],
                      players: dataOfRoom['players'],
                    )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
      floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: FloatingActionButton(
            onPressed: () {},
            elevation: 7,
            backgroundColor: Colors.white,
            child: Text(
              '$_start',
              style: const TextStyle(color: Colors.black, fontSize: 22),
            ),
          )),
    );
  }
}
