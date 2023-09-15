// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'base.dart';

class Bittrex extends Paire {
  String symbol;
  String bid;
  String ask;
  List<double> ks;
  Bittrex({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.ks,
  });

  factory Bittrex.fromMap(Map<String, dynamic> map) {
    return Bittrex(
      symbol: (map['symbol'] as String).replaceAll('-', ''),
      bid: map['bidRate'] as String,
      ask: map['askRate'] as String,
      ks: [],
    );
  }

  factory Bittrex.fromJson(String source) =>
      Bittrex.fromMap(json.decode(source) as Map<String, dynamic>);
}
