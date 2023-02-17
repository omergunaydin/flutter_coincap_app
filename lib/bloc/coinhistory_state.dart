part of 'coinhistory_bloc.dart';

abstract class CoinhistoryState extends Equatable {
  const CoinhistoryState();

  @override
  List<Object> get props => [];
}

class CoinhistoryInitial extends CoinhistoryState {}

class CoinhistoryLoadingState extends CoinhistoryState {}

class CoinhistoryLoadedState extends CoinhistoryState {
  final List<Data> coinhistoryList;

  CoinhistoryLoadedState({required this.coinhistoryList});
}

class CoinErrorState extends CoinhistoryState {}
