import 'package:flutter/material.dart';
import 'package:scribbl/screens/paint_screen.dart';
import 'package:scribbl/widgets/custom_text_field.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomNameController = TextEditingController();

  void joinRoom() {
    if (nameController.text.isNotEmpty && roomNameController.text.isNotEmpty) {
      Map<String, String> data = {
        "nickname": nameController.text,
        "name": roomNameController.text,
      };
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PaintScreen(data: data, screenFrom: "joinRoom")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter Valid detials")));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          "Join Room ",
          style: TextStyle(fontSize: 30, color: Colors.black),
        ),
        SizedBox(
          height: size.height * 0.05,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomTextField(
            hintText: "Enter Your Name",
            controller: nameController,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomTextField(
            hintText: "Enter Room Name",
            controller: roomNameController,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        const SizedBox(
          height: 50,
        ),
        SizedBox(
          width: 150,
          height: 45,
          child: ElevatedButton(
              onPressed: joinRoom,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  backgroundColor: const Color.fromARGB(255, 147, 216, 57)),
              child: const Text(
                "Join",
                style: TextStyle(color: Colors.white, fontSize: 18),
              )),
        )
      ]),
    );
  }
}
