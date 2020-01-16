import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  title: "Poke App",
  home: HomePage(),

  debugShowCheckedModeBanner: false,
));


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top - action bar
      appBar: AppBar(
        title: Text("Poke App"),
        backgroundColor: Colors.cyan,
      ),

      // body - content
      body: Center(
        child: Text("Hello from Pokemon App"),
      ),

      // Drawer
      drawer: Drawer(),

      // Action button
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        backgroundColor: Colors.cyan,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
