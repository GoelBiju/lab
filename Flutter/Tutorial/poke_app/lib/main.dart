import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
  title: "Poke App",
  home: HomePage(),

  debugShowCheckedModeBanner: false,
));


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var url = "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json";

  @override
  void initState() {
    super.initState();

    fetchData();
    print('2nd work');
  }

  fetchData() async {
    var res = await http.get(url);
    print(res.body);
  }

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
