import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/coinhistory.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'coinhistory_event.dart';
part 'coinhistory_state.dart';

class CoinhistoryBloc extends Bloc<CoinhistoryEvent, CoinhistoryState> {
  CoinhistoryBloc() : super(CoinhistoryInitial()) {
    on<CoinhistoryEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is FetchCoinHistoryEvent) {
        emit(CoinhistoryLoadingState());
        try {
          var baseUrl = 'https://api.coincap.io/v2/assets/' +
              event.id +
              '/history?interval=' +
              event.interval +
              '&start=' +
              event.start +
              '&end=' +
              event.end;
          var result = await http.get(Uri.parse(baseUrl));
          final data = jsonDecode(result.body);
          CoinHistory coinHistory = CoinHistory.fromJson(data);
          /*debugPrint(coinHistory.timestamp.toString());
          debugPrint(coinHistory.data![0].time.toString() +
              ' - ' +
              coinHistory.data![0].priceUsd.toString());*/
          emit(CoinhistoryLoadedState(coinhistoryList: coinHistory.data!));
        } catch (e) {
          //debugPrint(e.toString());
          emit(CoinErrorState());
        }
      }
    });
  }
}
