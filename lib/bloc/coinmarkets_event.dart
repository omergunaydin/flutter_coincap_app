part of 'coinmarkets_bloc.dart';

abstract class CoinmarketsEvent extends Equatable {
  const CoinmarketsEvent();

  @override
  List<Object> get props => [];
}

class FetchCoinMarketsEvent extends CoinmarketsEvent {
  final String id;

  const FetchCoinMarketsEvent({required this.id});
}
