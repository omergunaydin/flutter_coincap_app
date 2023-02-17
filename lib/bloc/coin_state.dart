part of 'coin_bloc.dart';

abstract class CoinState extends Equatable {
  const CoinState();

  @override
  List<Object> get props => [];
}

class CoinInitial extends CoinState {}

class CoinLoadingState extends CoinState {}

class CoinLoadedState extends CoinState {
  final List<Data> coinsList;

  CoinLoadedState({required this.coinsList});
}

class CoinErrorState extends CoinState {}
