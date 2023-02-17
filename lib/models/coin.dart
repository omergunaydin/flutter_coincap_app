// To parse this JSON data, do
//
//     final coin = coinFromJson(jsonString);

import 'dart:convert';

import 'package:meta/meta.dart';

class Coin {
  Coin({
    required this.id,
    required this.rank,
    required this.symbol,
    required this.name,
    required this.supply,
    required this.maxSupply,
    required this.marketCapUsd,
    required this.volumeUsd24Hr,
    required this.priceUsd,
    required this.changePercent24Hr,
    required this.vwap24Hr,
    required this.explorer,
  });

  final String id;
  final String rank;
  final String symbol;
  final String name;
  final String supply;
  final String maxSupply;
  final String marketCapUsd;
  final String volumeUsd24Hr;
  final String priceUsd;
  final String changePercent24Hr;
  final String vwap24Hr;
  final String explorer;

  Coin copyWith({
    String? id,
    String? rank,
    String? symbol,
    String? name,
    String? supply,
    String? maxSupply,
    String? marketCapUsd,
    String? volumeUsd24Hr,
    String? priceUsd,
    String? changePercent24Hr,
    String? vwap24Hr,
    String? explorer,
  }) {
    return Coin(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      supply: supply ?? this.supply,
      maxSupply: maxSupply ?? this.maxSupply,
      marketCapUsd: marketCapUsd ?? this.marketCapUsd,
      volumeUsd24Hr: volumeUsd24Hr ?? this.volumeUsd24Hr,
      priceUsd: priceUsd ?? this.priceUsd,
      changePercent24Hr: changePercent24Hr ?? this.changePercent24Hr,
      vwap24Hr: vwap24Hr ?? this.vwap24Hr,
      explorer: explorer ?? this.explorer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rank': rank,
      'symbol': symbol,
      'name': name,
      'supply': supply,
      'maxSupply': maxSupply,
      'marketCapUsd': marketCapUsd,
      'volumeUsd24Hr': volumeUsd24Hr,
      'priceUsd': priceUsd,
      'changePercent24Hr': changePercent24Hr,
      'vwap24Hr': vwap24Hr,
      'explorer': explorer,
    };
  }

  factory Coin.fromMap(Map<String, dynamic> map) {
    return Coin(
      id: map['id'] ?? '',
      rank: map['rank'] ?? '',
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      supply: map['supply'] ?? '',
      maxSupply: map['maxSupply'] ?? '',
      marketCapUsd: map['marketCapUsd'] ?? '',
      volumeUsd24Hr: map['volumeUsd24Hr'] ?? '',
      priceUsd: map['priceUsd'] ?? '',
      changePercent24Hr: map['changePercent24Hr'] ?? '',
      vwap24Hr: map['vwap24Hr'] ?? '',
      explorer: map['explorer'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Coin.fromJson(String source) => Coin.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Coin(id: $id, rank: $rank, symbol: $symbol, name: $name, supply: $supply, maxSupply: $maxSupply, marketCapUsd: $marketCapUsd, volumeUsd24Hr: $volumeUsd24Hr, priceUsd: $priceUsd, changePercent24Hr: $changePercent24Hr, vwap24Hr: $vwap24Hr, explorer: $explorer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Coin &&
        other.id == id &&
        other.rank == rank &&
        other.symbol == symbol &&
        other.name == name &&
        other.supply == supply &&
        other.maxSupply == maxSupply &&
        other.marketCapUsd == marketCapUsd &&
        other.volumeUsd24Hr == volumeUsd24Hr &&
        other.priceUsd == priceUsd &&
        other.changePercent24Hr == changePercent24Hr &&
        other.vwap24Hr == vwap24Hr &&
        other.explorer == explorer;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        rank.hashCode ^
        symbol.hashCode ^
        name.hashCode ^
        supply.hashCode ^
        maxSupply.hashCode ^
        marketCapUsd.hashCode ^
        volumeUsd24Hr.hashCode ^
        priceUsd.hashCode ^
        changePercent24Hr.hashCode ^
        vwap24Hr.hashCode ^
        explorer.hashCode;
  }
}
