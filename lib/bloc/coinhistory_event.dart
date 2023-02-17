part of 'coinhistory_bloc.dart';

abstract class CoinhistoryEvent extends Equatable {
  const CoinhistoryEvent();

  @override
  List<Object> get props => [];
}

class FetchCoinHistoryEvent extends CoinhistoryEvent {
  final String id;
  final String interval;
  final String start;
  final String end;

  const FetchCoinHistoryEvent(
      {required this.interval,
      required this.start,
      required this.end,
      required this.id});
}
