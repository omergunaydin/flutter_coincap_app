import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coincap_app/bloc/coinhistory_bloc.dart';

import '../models/coinmarkets.dart';
import 'package:http/http.dart' as http;

part 'coinmarkets_event.dart';
part 'coinmarkets_state.dart';

class CoinmarketsBloc extends Bloc<CoinmarketsEvent, CoinmarketsState> {
  CoinmarketsBloc() : super(CoinmarketsInitial()) {
    on<CoinmarketsEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is FetchCoinMarketsEvent) {
        try {
          var baseUrl =
              'https://api.coincap.io/v2/assets/' + event.id + '/markets';

          var result = await http.get(Uri.parse(baseUrl));
          final data = jsonDecode(result.body);
          CoinMarkets coinHistory = CoinMarkets.fromJson(data);
          debugPrint(coinHistory.timestamp.toString());
          emit(CoinmarketsLoadedState(coinmarketsList: coinHistory.data!));
        } catch (e) {
          //debugPrint(e.toString());
          emit(CoinErrorState());
        }
      }
    });
  }
}
