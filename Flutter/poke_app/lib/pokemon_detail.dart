import 'package:flutter/material.dart';
import 'package:poke_app/pokemon.dart';

class PokeDetail extends StatelessWidget {
  final Pokemon pokemon;

  PokeDetail({this.pokemon});

  List<Widget> pokemonInfo() {
    var infoBuilder = [
      // Add in blank box to give some space.
      SizedBox(
        height: 100.0,
      ),
      Text(
        pokemon.name,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text("Height: ${pokemon.height}"),
      Text("Weight: ${pokemon.weight}"),
      Text(
        "Types",
        style: TextStyle(
          fontWeight: FontWeight.bold
        )
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pokemon.type.map((t) => 
          FilterChip(
            backgroundColor: Colors.amber,
            // Reverse from the type values object to get 
            // type strings.
            label: Text(typeValues.reverse[t]), 
            onSelected: (b){},
          )
        ).toList(),
      ),
      Text(
        "Weakness",
        style: TextStyle(
          fontWeight: FontWeight.bold
        )
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pokemon.weaknesses.map((t) => 
          FilterChip(
            backgroundColor: Colors.red,
            // Reverse from the type values object to get 
            // type strings.
            label: Text(
              typeValues.reverse[t],
              style: TextStyle(color: Colors.white)
            ), 
            onSelected: (b){},
          )
        ).toList(),
      ),
    ];

    if (pokemon.prevEvolution != null) {
      infoBuilder.addAll([
        Text("Previous Evolution",
          style: TextStyle(
            fontWeight: FontWeight.bold
          )
        ),
                
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: pokemon.prevEvolution.map((n) => 
            FilterChip(
              backgroundColor: Colors.green,
              // Reverse from the type values object to get 
              // type strings.
              label: Text(
                n.name,
                style: TextStyle(color: Colors.white)
              ), 
              onSelected: (b){},
            )
          ).toList(),
        ),
      ]);
    }


    if (pokemon.nextEvolution != null) {
      infoBuilder.addAll([
        Text("Next Evolution",
          style: TextStyle(
            fontWeight: FontWeight.bold
          )
        ),
                
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: pokemon.nextEvolution.map((n) => 
            FilterChip(
              backgroundColor: Colors.green,
              // Reverse from the type values object to get 
              // type strings.
              label: Text(
                n.name,
                style: TextStyle(color: Colors.white)
              ), 
              onSelected: (b){},
            )
          ).toList(),
        )]
      );
    }

    return infoBuilder;
  }

  Stack bodyWidget(BuildContext context) { 
    var builder = Stack(
      children: <Widget>[
        Positioned(
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width - 20,
          left: 10.0,
          top: MediaQuery.of(context).size.height * 0.1,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: pokemonInfo(),
            ),
          ),
        ),

        // Place the Pokemon image on top of the information.
        Align(
          alignment: Alignment.topCenter,
          child: Hero(tag: pokemon.img, child: Container(
            height: 200.0,
            width: 200.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(pokemon.img)
              ),
            ),
          )),  
        )
      ],
    );

    return builder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.cyan,
        title: Text(pokemon.name),
      ),

      body: bodyWidget(context),
    );
  }
}