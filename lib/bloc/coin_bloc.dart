import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coincap_app/models/coins.dart';
import 'package:http/http.dart' as http;

part 'coin_event.dart';
part 'coin_state.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  CoinBloc() : super(CoinInitial()) {
    on<CoinEvent>((event, emit) async {
      if (event is FetchCoinEvent) {
        emit(CoinLoadingState());
        try {
          var baseUrl = 'https://api.coincap.io/v2/assets';
          var result = await http.get(Uri.parse(baseUrl));
          final data = jsonDecode(result.body);
          Coins coins = Coins.fromJson(data);
          //debugPrint(coins.timestamp.toString());
          //debugPrint(coins.data![0].name.toString());
          emit(CoinLoadedState(coinsList: coins.data!));
        } catch (e) {
          //debugPrint(e.toString());
          emit(CoinErrorState());
        }
      }
    });
  }
}
