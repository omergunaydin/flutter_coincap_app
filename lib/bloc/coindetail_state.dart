part of 'coindetail_bloc.dart';

abstract class CoindetailState extends Equatable {
  const CoindetailState();

  @override
  List<Object> get props => [];
}

class CoindetailInitial extends CoindetailState {}

class CoindetailLoadingState extends CoindetailState {}

class CoindetailLoadedState extends CoindetailState {
  final CoinInfo coin;

  CoindetailLoadedState({required this.coin});
}

class CoindetailErrorState extends CoindetailState {}
