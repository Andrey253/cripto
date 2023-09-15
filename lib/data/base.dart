// ignore_for_file: public_member_api_docs, sort_constructors_first
abstract class Paire {
  late String symbol;
  late String bid;
  late String ask;
  late List<double> ks;

  String get toView =>
      symbol +
      ' bid:' +
      bid +
      ' ask:' +
      ask +
      "  " +
      this.runtimeType.toString();
}

class Pairs {
  Paire? binance;
  Paire? bittrex;
  Paire? gate;
  Pairs({
    this.binance,
    this.bittrex,
    this.gate,
  });
}
