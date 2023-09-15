// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'base.dart';

class GateIo extends Paire {
  String symbol;
  String bid;
  String ask;
  List<double> ks;
  GateIo({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.ks,
  });

  factory GateIo.fromMap(Map<String, dynamic> map) {
    return GateIo(
      symbol: (map['currency_pair'] as String).replaceAll('_', ''),
      bid: map['highest_bid'] as String,
      ask: map['lowest_ask'] as String,
      ks: [],
    );
  }

  factory GateIo.fromJson(String source) =>
      GateIo.fromMap(json.decode(source) as Map<String, dynamic>);
}
