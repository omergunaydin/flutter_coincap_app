part of 'coindetail_bloc.dart';

abstract class CoindetailEvent extends Equatable {
  const CoindetailEvent();

  @override
  List<Object> get props => [];
}

class FetchCoinDetailEvent extends CoindetailEvent {
  final String id;

  const FetchCoinDetailEvent({required this.id});
}
