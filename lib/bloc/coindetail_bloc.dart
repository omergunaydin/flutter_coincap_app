import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coincap_app/models/coindetail.dart';
import 'package:http/http.dart' as http;

part 'coindetail_event.dart';
part 'coindetail_state.dart';

class CoindetailBloc extends Bloc<CoindetailEvent, CoindetailState> {
  CoindetailBloc() : super(CoindetailInitial()) {
    on<CoindetailEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is FetchCoinDetailEvent) {
        emit(CoindetailLoadingState());
        try {
          var baseUrl = 'https://api.coincap.io/v2/assets/' + event.id;
          var result = await http.get(Uri.parse(baseUrl));
          final data = jsonDecode(result.body);
          CoinInfo coin = CoinInfo.fromJson(data);

          //debugPrint('coindetailçalıştı1!');
          //debugPrint('deneme123' + coin.data!.name.toString());
          emit(CoindetailLoadedState(coin: coin));
          //emit(CoindetailErrorState());
        } catch (e) {
          //debugPrint(e.toString());
          emit(CoindetailErrorState());
        }
      }
    });
  }
}
