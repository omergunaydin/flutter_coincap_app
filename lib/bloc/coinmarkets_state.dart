part of 'coinmarkets_bloc.dart';

abstract class CoinmarketsState extends Equatable {
  const CoinmarketsState();

  @override
  List<Object> get props => [];
}

class CoinmarketsInitial extends CoinmarketsState {}

class CoinmarketsLoadingState extends CoinmarketsState {}

class CoinmarketsLoadedState extends CoinmarketsState {
  final List<Data> coinmarketsList;

  CoinmarketsLoadedState({required this.coinmarketsList});
}

class CoinErrorState extends CoinmarketsState {}
