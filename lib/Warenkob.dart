import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:new_project/KundeSpeisekarte.dart';
import 'package:intl/intl.dart';
import 'package:new_project/main.dart';
import 'Produkt.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class Warenkorb extends StatefulWidget {
  final Map<int, Produkt> produkteImWarenkorb;
  final double summeWarenkorb;

  Warenkorb({Key key, this.produkteImWarenkorb, this.summeWarenkorb})
      : super(key: key);

  @override
  WarenkorbState createState() => WarenkorbState();
}

class WarenkorbState extends State<Warenkorb> {
  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text("Warenkorb - " + FirstScreen.qrResultRaw.rawContent),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Row(
        children: [
          Expanded(
            child: buildProdukteList(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'Drucken',
        onPressed: () {
          BuildContext ctx;
          testPrint("192.168.0.9", ctx);
        },
        label: Text('Bestellung abschicken! (' +
            KundeSpeisekarte.summeWarenkorb.toStringAsFixed(2) +
            '€)'),
        icon: const Icon(Icons.print),
        backgroundColor: Colors.green,
      ),
    );

    return scaffold;
  }

  ListTile tile(int id, Produkt produkt) => ListTile(
        leading: Text(
            (produkt.getSummeGesamt()).toStringAsFixed(2) +
                "€ (" +
                produkt.getAnzahl().toString() +
                " Stk.)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        title: Text(produkt.getName()),
        trailing: Wrap(
          spacing: 12,
          children: <Widget>[
            // Button: Anzahl um 1 reduzieren
            FloatingActionButton.extended(
              heroTag: 'AnzahlReduzieren',
              onPressed: () {
                setState(() {
                  produkt.setAnzahl(produkt.getAnzahl() - 1);
                  if (produkt.anzahl <= 0) {
                    produkteImWarenkorb.remove(produkt.getId());
                  }
                  KundeSpeisekarte.summeWarenkorb =
                      (KundeSpeisekarte.summeWarenkorb - produkt.getPreis())
                          .abs();
                });
              },
              label: const Text('-'),
              backgroundColor: Colors.orangeAccent,
            ),
            // Button: Anzahl um 1 erhöhen
            FloatingActionButton.extended(
              heroTag: 'AnzahlErhoehen',
              onPressed: () {
                setState(() {
                  produkt.setAnzahl(produkt.getAnzahl() + 1);
                  KundeSpeisekarte.summeWarenkorb =
                      KundeSpeisekarte.summeWarenkorb + produkt.getPreis();
                });
              },
              label: const Text('+'),
              backgroundColor: Colors.orangeAccent,
            ),
          ], // space between two icons
        ),
      );

  Widget buildProdukteList() => ListView(
        children: [
          for (MapEntry e in produkteImWarenkorb.entries) tile(e.key, e.value),
        ],
      );

  void testPrint(String printerIp, BuildContext ctx) async {
    // Einstellung der Papiergroße
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect("192.168.0.9", port: 9100);

    if (res == PosPrintResult.success) {
      // DEMO RECEIPT
      await printDemoReceipt(printer);

      printer.disconnect();
    }
  }

  Future<void> printDemoReceipt(NetworkPrinter printer) async {
    printer.text('ORDERi',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    printer.text('Kurfuerstenstrasse 104',
        styles: PosStyles(align: PosAlign.center));
    printer.text('56068 Koblenz', styles: PosStyles(align: PosAlign.center));
    printer.text('Tel: 0151 6512 6666',
        styles: PosStyles(align: PosAlign.center));
    printer.text('Web: www.orderi.eu',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    printer.hr();

    printer.row([
      PosColumn(text: "Anzahl", width: 2),
      PosColumn(text: 'Produkt', width: 6),
      PosColumn(
          text: 'Preis', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Summe', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    for (MapEntry e in produkteImWarenkorb.entries) {
      Produkt produkt = e.value;
      printer.row([
        // Anzahl
        PosColumn(text: produkt.anzahl.toString(), width: 2),
        // Produkt
        PosColumn(text: produkt.name, width: 6),
        // Preis
        PosColumn(
            text: produkt.preis.toStringAsFixed(2),
            width: 2,
            styles: PosStyles(align: PosAlign.right)),
        // Summe
        PosColumn(
            text: produkt.getSummeGesamt().toStringAsFixed(2),
            width: 2,
            styles: PosStyles(align: PosAlign.right))
      ]);
    }
    printer.hr();

    // Gesamt
    printer.row([
      PosColumn(
          text: 'Gesamt',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: KundeSpeisekarte.summeWarenkorb.toStringAsFixed(2),
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    printer.hr(ch: '=', linesAfter: 1);
    printer.feed(2);
    printer.text('Danke!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('dd.MM.yyyy H:mm');
    final String timestamp = formatter.format(now);
    printer.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    printer.feed(1);
    printer.cut();
  }
}
