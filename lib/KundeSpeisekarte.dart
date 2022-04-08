import 'package:flutter/material.dart';
import 'package:new_project/main.dart';
import 'Produkt.dart';
import 'Warenkob.dart';

Map<int, Produkt> produkteImWarenkorb = new Map<int, Produkt>();

final produktPizzaSalami = Produkt(
    id: 1,
    name: "Pizza Salami",
    beschreibung: "Extra Scharf",
    preis: 4.99,
    anzahl: 0);
final produktPizzaHawaii = Produkt(
    id: 2,
    name: "Pizza Hawaii",
    beschreibung: "Mit Schinken",
    preis: 5.99,
    anzahl: 0);
final produktPizzaNapoli = Produkt(
    id: 3,
    name: "Pizza Napoli",
    beschreibung: "Mit Peperoniwurst",
    preis: 6.99,
    anzahl: 0);

class KundeSpeisekarte extends StatefulWidget {
  static double summeWarenkorb = 0;
  final Future<List<Produkt>> produkte;

  KundeSpeisekarte({Key key, qrResultRaw, this.produkte}) : super(key: key);

  @override
  KundeSpeisekarteState createState() => KundeSpeisekarteState();
}

class KundeSpeisekarteState extends State<KundeSpeisekarte> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Speisekarte - Nr: ' + FirstScreen.qrResultRaw.rawContent),
      ),
      body: Center(child: buildProdukteList()),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'Warenkorb',
        onPressed: () {
          navigateToWarenkorb(context);
        },
        label: Text('Warenkorb: ' +
            KundeSpeisekarte.summeWarenkorb.toStringAsFixed(2) +
            '€'),
        icon: const Icon(Icons.shopping_bag),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: bottomNavBar(),
    );
    return scaffold;
  }

  Widget buildProdukteList() => ListView(
        children: [
          tile(
              produktPizzaSalami.id,
              produktPizzaSalami.name,
              produktPizzaSalami.beschreibung,
              produktPizzaSalami.preis,
              produktPizzaSalami.anzahl,
              produktPizzaSalami),
          tile(
              produktPizzaHawaii.id,
              produktPizzaHawaii.name,
              produktPizzaHawaii.beschreibung,
              produktPizzaHawaii.preis,
              produktPizzaHawaii.anzahl,
              produktPizzaHawaii),
          tile(
              produktPizzaNapoli.id,
              produktPizzaNapoli.name,
              produktPizzaNapoli.beschreibung,
              produktPizzaNapoli.preis,
              produktPizzaNapoli.anzahl,
              produktPizzaNapoli),
        ],
      );

  ListTile tile(int id, String titel, String beschreibung, double preis,
          int anzahl, Produkt produkt) =>
      ListTile(
        leading: Text(
            preis.toString() +
                "€ (" +
                produkt.getAnzahl().toString() +
                " Stk.)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        title: Text(titel),
        subtitle: Text(beschreibung),
        trailing: Wrap(
          spacing: 12, // space between two icons
          children: <Widget>[
            // Button: Anzahl um 1 reduzieren
            FloatingActionButton.extended(
              heroTag: 'AnzahlReduzieren',
              onPressed: () {
                setState(() {
                  if (produkt.anzahl <= 0) {
                    produkteImWarenkorb.remove(produkt.getId());
                  } else {
                    produkt.setAnzahl(produkt.getAnzahl() - 1);
                    KundeSpeisekarte.summeWarenkorb =
                        (KundeSpeisekarte.summeWarenkorb - produkt.getPreis())
                            .abs();
                  }
                });
              },
              label: const Text('-'),
              backgroundColor: Colors.orangeAccent,
            ),
            FloatingActionButton.extended(
              heroTag: 'Anzahl',
              onPressed: () {
                produkteImWarenkorb[id] = produkt;
                produkt.setAnzahl(produkt.getAnzahl() + 1);
                KundeSpeisekarte.summeWarenkorb =
                    KundeSpeisekarte.summeWarenkorb + preis;
                onHinzufuegenProduktZuWarenkorbTapped(
                    KundeSpeisekarte.summeWarenkorb);
              },
              label: const Text('+'),
              backgroundColor: Colors.orangeAccent,
            ),
          ],
        ),
      );

  Widget bottomNavBar() => BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Pizza',
            backgroundColor: Colors.orangeAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Nudeln',
            backgroundColor: Colors.orangeAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Getränke',
            backgroundColor: Colors.orangeAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Fingerfood',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.orangeAccent,
        onTap: onBottomBarTapped,
      );

  void onBottomBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void onHinzufuegenProduktZuWarenkorbTapped(double summe) {
    setState(() {
      KundeSpeisekarte.summeWarenkorb = summe;
    });
  }

  void navigateToWarenkorb(BuildContext context) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => Warenkorb(
          produkteImWarenkorb: produkteImWarenkorb,
          summeWarenkorb: KundeSpeisekarte.summeWarenkorb,
        ),
      ),
    )
        .then((_) {
      // setState aufrufen, um die korrekte Gesamtsumme auf der Speisekarte anzuzeigen, wenn im Warenkorb der Back Button getätigt wird
      setState(() {});
    });
  }
}
