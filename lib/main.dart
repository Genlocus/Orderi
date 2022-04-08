import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:new_project/KundeSpeisekarte.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      initialRoute: 'homeScreen',
      routes: {
        // When navigating to the "main" route, build the HomeScreen widget.
        'HomeScreen': (context) => Startseite(),
        // When navigating to the "KundeSPeisekarte" route, build the SecondScreen widget.
        'NewScreen': (context) =>
            KundeSpeisekarte(qrResultRaw: FirstScreen.qrResultRaw),
      },
      title: 'orderI',
      home: Startseite(),
    ));

class Startseite extends StatefulWidget {
  @override
  FirstScreen createState() => FirstScreen();
}

class FirstScreen extends State<Startseite> {
  static ScanResult qrResultRaw;
  String title = "orderI";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: Text(''),
          centerTitle: true,
        ),
        body: new Container(
          color: Colors.orangeAccent,
          height: 750.0,
          alignment: Alignment.center,
          child: new Column(
            children: [
              new Container(
                height: 45.0,
              ),
              new Container(
                child: new Text(
                  "Willkommen zu orderI",
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Colors.black),
                ),
              ),
              new Container(
                child: new Text(
                  '\n\n\n\n\nBitte scannen Sie den QR-Code, welcher sich auf dem von Ihnen genutzten Tisch befindet. \n\nDazu klicken Sie auf den Button „QR-Code scannen".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 15.0,
                      color: Colors.black),
                ),
              ),
              new Container(height: 250.0),
              new Container(
                child: FloatingActionButton.extended(
                    icon: Icon(Icons.camera_alt),
                    label: Text("QR-Code scannen"),
                    backgroundColor: Colors.black,
                    onPressed: _scanQR),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.orangeAccent[100]);
  }

  Future _scanQR() async {
    try {
      ScanResult qrResult = await BarcodeScanner.scan();
      qrResultRaw = qrResult;
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => KundeSpeisekarte(
                    qrResultRaw: qrResultRaw,
                  )),
        );
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          title = "Zugriff auf die Kameria wurde abgelehnt";
        });
      } else {
        setState(() {
          title = "Unbekannter Fehler $ex";
        });
      }
    } on FormatException {
      setState(() {
        title =
            "Sie haben den Zurück-Button gedrückt ohne den QR-Code zu scannen";
      });
    } catch (ex) {
      setState(() {
        title = "Unbekannter Fehler $ex";
      });
    }
  }
}
