import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_coincap_app/bloc/coin_bloc.dart';
import 'package:flutter_coincap_app/bloc/coindetail_bloc.dart';
import 'package:flutter_coincap_app/bloc/coinhistory_bloc.dart';
import 'package:flutter_coincap_app/bloc/coinmarkets_bloc.dart';
import 'package:flutter_coincap_app/coin_detail.dart';
import 'package:flutter_coincap_app/models/coins.dart';
import 'package:flutter_coincap_app/widgets/list_element.dart';
import 'dart:async';
import 'package:palette_generator/palette_generator.dart';

class CoinCapApp extends StatelessWidget {
  CoinCapApp({Key? key}) : super(key: key);
  GlobalKey keyListView = GlobalKey<FormState>();
  Completer<void> _refreshCompleter = Completer<void>();

  @override
  Widget build(BuildContext context) {
    context.read<CoinBloc>().add(FetchCoinEvent());
    debugPrint('build tetiklendi');
    return Scaffold(
        appBar: AppBar(
          title: const Text('CoinCap App'),
          actions: [
            IconButton(
                onPressed: () {
                  context.read<CoinBloc>().add(FetchCoinEvent());
                },
                icon: const Icon(Icons.refresh)),
            BlocBuilder<CoinBloc, CoinState>(
              builder: (context, state) {
                return IconButton(
                    onPressed: () async {
                      final result = await showSearch(
                          context: context, delegate: MySearchDelegate());
                      debugPrint(result); //Seçilen eleman buraya geldi
                      //Hangi indexteki elemanı göndericez o önemli!!!
                      int bulunanIndex = 0;
                      int size = (state as CoinLoadedState).coinsList.length;
                      String name = 'Bitcoin';
                      String id = 'bitcoin';
                      for (int i = 0; i < size; i++) {
                        /**/
                        if (state.coinsList[i].id
                            .toString()
                            .contains(result.toString().toLowerCase())) {
                          name = state.coinsList[i].name.toString();
                          id = state.coinsList[i].id.toString();
                          bulunanIndex = i;
                          debugPrint('BulunanIndex' + bulunanIndex.toString());
                        }
                        if (state.coinsList[i].id.toString() ==
                            result.toString().toLowerCase()) {
                          name = state.coinsList[i].name.toString();
                          id = state.coinsList[i].id.toString();
                          bulunanIndex = i;
                          debugPrint('BulunanIndex' + bulunanIndex.toString());
                          break;
                        }
                      }

                      var color = await _updatePaletteGenerator(
                          'https://assets.coincap.io/assets/icons/' +
                              (state as CoinLoadedState)
                                  .coinsList[bulunanIndex]
                                  .symbol
                                  .toString()
                                  .toLowerCase() +
                              '@2x.png');
                      debugPrint('Color : ' +
                          color.toString() +
                          'Color IntTotal : ' +
                          getRGBTotal(color).toString());

                      if (getRGBTotal(color) > 500) {
                        color = Colors.blueGrey;
                      }

                      debugPrint('id : ' + id + ' name : ' + name + ' --->');
                      debugPrint(state.coinsList[bulunanIndex].toString());
                      if (state is CoinLoadedState) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: ((context) => CoinBloc()),
                                ),
                                BlocProvider(
                                  create: ((context) => CoinmarketsBloc()),
                                ),
                                BlocProvider(
                                  create: (context) => CoinhistoryBloc(),
                                ),
                                BlocProvider(
                                  create: (context) => CoindetailBloc(),
                                ),
                              ],
                              //burda hata var burayı düzelt result olarak alma state'ten gelen veriye göre al!!!

                              child: CoinDetail(
                                  id: id,
                                  name: name,
                                  coin: state.coinsList[bulunanIndex],
                                  color: color)),
                        ));
                      }
                    },
                    icon: const Icon(Icons.search));
              },
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
        ),
        body: BlocBuilder<CoinBloc, CoinState>(
          builder: (context, state) {
            if (state is CoinInitial) {
              debugPrint('buraya geldi initial!!');

              return const Center(
                child: Text('Initial State!!'),
              );
            }
            if (state is CoinLoadingState) {
              debugPrint('buraya geldi loadingg!!');
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is CoinLoadedState) {
              debugPrint('coinlooadedstate çalıştı!!');
              _refreshCompleter.complete();
              _refreshCompleter = Completer<void>();

              return RefreshIndicator(
                onRefresh: () {
                  context.read<CoinBloc>().add(FetchCoinEvent());
                  return _refreshCompleter.future;
                },
                child: ListView.builder(
                    key: keyListView,
                    itemCount: state.coinsList.length,
                    itemBuilder: (context, index) {
                      return BlocBuilder<CoinBloc, CoinState>(
                        builder: (context, state) {
                          return ListElement(index: index);
                        },
                      );
                    }),
              );
            } else {
              return const Center(
                child: Text('Hata Oluştu'),
              );
            }
          },
        ));
  }

  Future<Color> _updatePaletteGenerator(String imgUrl) async {
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image.network(imgUrl).image,
    );
    try {
      return paletteGenerator.dominantColor!.color;
    } catch (Exception) {
      return Colors.blueGrey;
    }
  }

  int getRGBTotal(Color c) {
    return c.red + c.blue + c.green;
  }
}

class MySearchDelegate extends SearchDelegate {
  List<String> searchResults = [
    'Bitcoin',
    'Ethereum',
    'Cardano',
    'XRP',
    'Shiba',
    'LiteCoin',
    'TRON',
    'Ripple',
    'Eos',
    'Tether',
    'BNB',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isEmpty) {
                close(context, null);
              } else {
                query = '';
              }
            },
            icon: const Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () {
        close(context, query);
      },
      icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    //close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults.where((searchResult) {
      final result = searchResult.toLowerCase();
      final input = query.toLowerCase();
      return result.contains(input);
    }).toList();
    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            title: Text(suggestion),
            onTap: () {
              query = suggestion;
              /*showResults(context);*/
              close(context, query);
            },
          );
        });
  }
}
