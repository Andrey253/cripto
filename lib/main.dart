import 'dart:async';

import 'package:dio/dio.dart';

import 'data/base.dart';
import 'data/binance_pair.dart';
import 'data/bittrex_pair.dart';
import 'data/gateio_pair.dart';
import 'package:flutter/material.dart';

//./gradlew signingReport
//./gradlew wrapper --gradle-version 8.1 запускать дважды
// flutter build apk --split-per-abi
//firebase emulators:start
// dart run flutter_native_splash:create

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {},
      debugShowCheckedModeBanner: false,
      home: Home(),
      title: 'Fast Beer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription? sub;
  // Map<String, Paire> mapPaires = {};
  List<List<Paire?>> listPaires = [];

  String? isLoading;
  List<String> listAddress = [];
  String binance = 'https://api.binance.com/api/v3/ticker/bookTicker';
  String gateio = 'https://api.gateio.ws/api/v4/spot/tickers';
  String bittrex = 'https://api.bittrex.com/v3/markets/tickers';
  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    listAddress = [binance, gateio, bittrex];
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: () {
          _init();
        }),
        body: isLoading != null
            ? Center(child: Text(isLoading!))
            : ListView(
                children: [
                Table(
                  children: [
                    TableRow(children: [
                      Text('Exchange'),
                      Text('Currency'),
                      Text('Binance'),
                      Text('Bittrex'),
                      Text('Gate'),
                    ])
                  ],
                )
              ]..addAll(listPaires.map((paires) => Table(
                    border: TableBorder(
                        horizontalInside: BorderSide(
                            width: 2.0, color: Colors.lightBlue.shade50)),
                    children: paires
                        .map((e) => e?.symbol != null &&
                                e!.ks.any((element) => element > 1)
                            ? TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text((e.runtimeType).toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text((e.symbol)),
                                  ),
                                  ...e.ks.map((p) {
                                    final color = p > 1;
                                    final s = p.toStringAsFixed(4);
                                    return Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        s,
                                        style: color
                                            ? TextStyle(color: Colors.red)
                                            : TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }).toList()
                                ],
                              )
                            : TableRow(children: [
                                SizedBox.shrink(),
                                SizedBox.shrink(),
                                SizedBox.shrink(),
                                SizedBox.shrink(),
                                SizedBox.shrink(),
                              ]))
                        .toList())))));
  }

  void _init() async {
    setState(() {
      isLoading = 'binance...';
    });
    // await Future.wait(futures);
    final binancexData = await Dio().get(binance);
    setState(() {
      isLoading = 'bittrex...';
    });
    final bittrexData = await Dio().get(bittrex);
    setState(() {
      isLoading = 'gateio...';
    });
    final gateioData = await Dio().get(gateio);

    Map<String, Paire> mapBinance = listBinancePare(binancexData);
    Map<String, Paire> mapBittrex = listBittrexPare(bittrexData);
    Map<String, Paire> mapGate = listGateIoPare(gateioData);
    mapBinance.removeWhere((key, value) => double.parse(value.ask) == 0.0);
    listPaires = mapBinance.entries.map((e) {
      mapBinance[e.key]?.ks = [
        spread(mapBinance[e.key], mapBinance[e.key]),
        spread(mapBinance[e.key], mapBittrex[e.key]),
        spread(mapBinance[e.key], mapGate[e.key]),
      ];
      mapBittrex[e.key]?.ks = [
        spread(mapBittrex[e.key], mapBinance[e.key]),
        spread(mapBittrex[e.key], mapBittrex[e.key]),
        spread(mapBittrex[e.key], mapGate[e.key]),
      ];
      mapGate[e.key]?.ks = [
        spread(mapGate[e.key], mapBinance[e.key]),
        spread(mapGate[e.key], mapBittrex[e.key]),
        spread(mapGate[e.key], mapGate[e.key]),
      ];
      return [e.value, mapBittrex[e.key], mapGate[e.key]];
    }).toList();
    setState(() {
      isLoading = null;
    });
  }

  Map<String, Paire> listBinancePare(Response data) {
    Map<String, Paire> m = {};
    (data.data as List).forEach((element) {
      final el = Binance.fromMap(element);
      m[el.symbol] = el;
    });
    return m;
  }

  Map<String, Paire> listGateIoPare(Response data) {
    Map<String, Paire> m = {};
    (data.data as List).forEach((element) {
      final el = GateIo.fromMap(element);
      m[el.symbol] = el;
    });
    return m;
  }

  Map<String, Paire> listBittrexPare(Response data) {
    Map<String, Paire> m = {};
    (data.data as List).forEach((element) {
      final el = Bittrex.fromMap(element);
      m[el.symbol] = el;
    });
    return m;
  }
}

double spread(Paire? e, Paire? p) {
  if (p == null || e == null) return 0;
  return double.parse(e.bid) == 0 ||
          double.parse(e.ask) == 0 ||
          double.parse(p.ask) == 0 ||
          double.parse(p.bid) == 0
      ? 0
      : (double.parse(p.bid) / double.parse(e.ask) * 100 - 100);
}
