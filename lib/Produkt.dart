import 'dart:convert';

import 'package:flutter/services.dart';

class Produkt {
  int id;
  String name;
  String beschreibung;
  double preis;
  int anzahl;
  double summeGesamt;

  Produkt(
      {this.id,
      this.name,
      this.beschreibung,
      this.preis,
      this.anzahl,
      this.summeGesamt});

  factory Produkt.fromJson(Map<String, dynamic> json) {
    return Produkt(
      id: json['id'] as int,
      name: json['name'] as String,
      beschreibung: json['beschreibung'] as String,
      preis: json['preis'] as double,
      anzahl: json['anzahl'] as int,
      summeGesamt: json['summeGesamt'] as double,
    );
  }

  // Funktion, die einen response body in eine List<Produkt> konvertiert
  List<Produkt> parseProdukte(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Produkt>((json) => Produkt.fromJson(json)).toList();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/sample.json');
    final data = await json.decode(response);

    return parseProdukte(data);
  }

  int getId() {
    return this.id;
  }

  void setId(int id) {
    this.id = id;
  }

  String getName() {
    return this.name;
  }

  void setName(String name) {
    this.name = name;
  }

  String getBeschreibung() {
    return this.beschreibung;
  }

  void setBeschreibung(String beschreibung) {
    this.beschreibung = beschreibung;
  }

  double getPreis() {
    return this.preis;
  }

  void setPreis(double preis) {
    this.preis = preis;
  }

  int getAnzahl() {
    return this.anzahl;
  }

  void setAnzahl(int anzahl) {
    this.anzahl = anzahl;
  }

  double getSummeGesamt() {
    summeGesamt = anzahl * preis;
    return summeGesamt;
  }

  void setSummeGesamt(double summeGesamt) {
    this.summeGesamt = summeGesamt;
  }

  asMap() {}
}
