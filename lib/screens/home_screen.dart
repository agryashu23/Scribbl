import 'package:flutter/material.dart';
import 'package:scribbl/screens/create_room_screen.dart';
import 'package:scribbl/screens/join_room_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.1,
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset('assets/play.png')),
            SizedBox(
              height: size.height * 0.05,
            ),
            const Text(
              "Create / Join a room to play!",
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
            SizedBox(
              height: size.height * 0.07,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: size.width * 0.4,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 147, 216, 57)),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateRoomScreen())),
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Create",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )),
                ),
                SizedBox(
                  width: size.width * 0.4,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const JoinRoomScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 147, 216, 57)),
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Join",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )),
                ),
              ],
            )
          ]),

      //
    );
  }
}
