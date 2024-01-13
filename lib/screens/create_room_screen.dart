import 'package:flutter/material.dart';
import 'package:scribbl/screens/paint_screen.dart';
import 'package:scribbl/widgets/custom_text_field.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roomNameController = TextEditingController();
  String maxRoundsValue = "Select Max Rounds";
  String roomSizeValue = "Select Room Size";

  void createRoom() {
    if (nameController.text.isNotEmpty &&
        roomNameController.text.isNotEmpty &&
        maxRoundsValue != "" &&
        roomSizeValue != "") {
      Map<String, String> data = {
        "nickname": nameController.text,
        "name": roomNameController.text,
        "occupancy": roomSizeValue,
        "maxRounds": maxRoundsValue
      };
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PaintScreen(data: data, screenFrom: 'createRoom')));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          "Create Room ",
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
        DropdownButton<String>(
          alignment: AlignmentDirectional.center,
          focusColor: const Color(0xffF5F6FA),
          items: <String>["2", "5", "10", "15"]
              .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black),
                  )))
              .toList(),
          hint: Text(
            maxRoundsValue,
            style: const TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          onChanged: (String? value) {
            setState(() {
              maxRoundsValue = value.toString();
            });
          },
        ),
        const SizedBox(
          height: 20,
        ),
        DropdownButton<String>(
          alignment: AlignmentDirectional.center,
          focusColor: const Color(0xffF5F6FA),
          items: <String>["2", "3", "4", "5", "6", "7", "8"]
              .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black),
                  )))
              .toList(),
          hint: Text(
            roomSizeValue,
            style: const TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          onChanged: (String? value) {
            setState(() {
              roomSizeValue = value.toString();
            });
          },
        ),
        const SizedBox(
          height: 50,
        ),
        SizedBox(
          width: 150,
          height: 45,
          child: ElevatedButton(
              onPressed: createRoom,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  backgroundColor: const Color.fromARGB(255, 147, 216, 57)),
              child: const Text(
                "Create",
                style: TextStyle(color: Colors.white, fontSize: 18),
              )),
        )
      ]),
    );
  }
}
