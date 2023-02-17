import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_coincap_app/bloc/coin_bloc.dart';
import 'package:flutter_coincap_app/bloc/coindetail_bloc.dart';
import 'package:flutter_coincap_app/bloc/coinhistory_bloc.dart';
import 'package:flutter_coincap_app/bloc/coinmarkets_bloc.dart';
import 'package:flutter_coincap_app/coin_detail.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:intl/intl.dart';

class ListElement extends StatelessWidget {
  final int index;
  ListElement({Key? key, required this.index}) : super(key: key);

  final NumberFormat numberFormat = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinBloc, CoinState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            var color = await _updatePaletteGenerator(
                'https://assets.coincap.io/assets/icons/' +
                    (state as CoinLoadedState)
                        .coinsList[index]
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
            //history,detail,markets
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: ((context) => CoinhistoryBloc()),
                  ),
                  BlocProvider(
                    create: (context) => CoindetailBloc(),
                  ),
                  BlocProvider(
                    create: (context) => CoinmarketsBloc(),
                  ),
                ],
                child: CoinDetail(
                    id: state.coinsList[index].id.toString(),
                    name: state.coinsList[index].name.toString(),
                    coin: state.coinsList[index],
                    color: color),
              ),
            ));
          },
          child: Card(
            color: index % 2 == 0 ? Colors.grey.shade100 : Colors.white,
            child: ListTile(
              leading: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                          'https://assets.coincap.io/assets/icons/' +
                              (state as CoinLoadedState)
                                  .coinsList[index]
                                  .symbol
                                  .toString()
                                  .toLowerCase() +
                              '@2x.png'),
                    ),
                  ],
                ),
              ),
              title: Text((state).coinsList[index].name.toString()),
              subtitle: Text((state).coinsList[index].symbol.toString()),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(numberFormat.format(double.parse(
                          state.coinsList[index].priceUsd.toString())) +
                      ' \$'),
                  Text(
                    double.parse(state.coinsList[index].changePercent24Hr
                                .toString())
                            .toStringAsFixed(2) +
                        ' %',
                    style: TextStyle(
                        color: double.parse(state
                                    .coinsList[index].changePercent24Hr
                                    .toString()) <
                                0
                            ? Colors.red
                            : Colors.green),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
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
