import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var typing = false;
  var location = "";
  final TextEditingController _textEditingController = TextEditingController();

  void updateLocation(String value) {
    setState(() {
      location = value;
      _textEditingController.clear(); // Clear the text field
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Container(
            alignment: Alignment.centerLeft,
            child: TextField(
              controller:
                  _textEditingController, // Add the TextEditingController
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Search location...'),
              onSubmitted: (String value) {
                updateLocation(value);
              },
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                updateLocation("Geolocation");
              },
            ),
          ],
          leading: const Icon(Icons.search),
        ),
        bottomNavigationBar: const BottomBar(),
        body: Views(location: location),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      tabs: <Widget>[
        Tab(
          icon: Icon(Icons.sunny),
          text: "Currently",
        ),
        Tab(
          icon: Icon(Icons.today),
          text: "Today",
        ),
        Tab(
          icon: Icon(Icons.calendar_month),
          text: "Weekly",
        ),
      ],
    );
  }
}

class Views extends StatelessWidget {
  final String location;

  const Views({super.key, required this.location});

  Widget displayView(String label) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label),
        Text(location,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: <Widget>[
        displayView("Currently"),
        displayView("Today"),
        displayView("Weekly"),
      ],
    );
  }
}
