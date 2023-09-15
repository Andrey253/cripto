// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'base.dart';

class Binance extends Paire {
  String symbol;
  String bid;
  String ask;
  List<double> ks;
  Binance({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.ks,
  });

  factory Binance.fromMap(Map<String, dynamic> map) {
    return Binance(
      symbol: map['symbol'] as String,
      bid: map['bidPrice'] as String,
      ask: map['askPrice'] as String,
      ks: [],
    );
  }

  factory Binance.fromJson(String source) =>
      Binance.fromMap(json.decode(source) as Map<String, dynamic>);
}
