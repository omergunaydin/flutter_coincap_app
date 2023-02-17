import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_coincap_app/bloc/coindetail_bloc.dart';
import 'package:flutter_coincap_app/bloc/coinhistory_bloc.dart';
import 'package:flutter_coincap_app/bloc/coinmarkets_bloc.dart';
import 'package:flutter_coincap_app/models/coins.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CoinDetail extends StatelessWidget {
  final String id, name;
  final Data coin;
  final Color color;
  CoinDetail({
    Key? key,
    required this.id,
    required this.name,
    required this.coin,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _coinMarketsBloc = BlocProvider.of<CoinmarketsBloc>(context);
    context.read<CoinmarketsBloc>().add(FetchCoinMarketsEvent(id: id));

    final _coinDetailBloc = BlocProvider.of<CoindetailBloc>(context);
    context.read<CoindetailBloc>().add(FetchCoinDetailEvent(id: id));

    final _coinHistoryBloc = BlocProvider.of<CoinhistoryBloc>(context);
    context.read<CoinhistoryBloc>().add(FetchCoinHistoryEvent(
        id: id,
        start: (DateTime.now().millisecondsSinceEpoch - 86400000).toString(),
        end: DateTime.now().millisecondsSinceEpoch.toString(),
        interval: 'm30'));

    final NumberFormat numberFormat = NumberFormat("#,##0.00", "en_US");
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    final DateFormat dateFormat2 = DateFormat('dd-MM');
    final DateFormat dateFormat3 = DateFormat('MM-yyyy');
    final DateFormat hourFormat = DateFormat('HH:mm');
    bool selectedYears = false;

    TooltipBehavior _tooltipBehavior = TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          var text1 = hourFormat
              .format(DateTime.fromMillisecondsSinceEpoch(data.time.toInt()));
          var text2 = dateFormat
              .format(DateTime.fromMillisecondsSinceEpoch(data.time.toInt()));
          //debugPrint('>>' + text1);

          return Container(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${text2}\n' +
                  '${text1}\n' +
                  '\$${numberFormat.format(data.price)}',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              //miliseconds çevir tarih saate ona göre göster!!!
            ),
          ));
        });

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
              onPressed: () {
                context
                    .read<CoindetailBloc>()
                    .add(FetchCoinDetailEvent(id: id));
              },
              icon: const Icon(Icons.refresh))
        ],
        backgroundColor: color,
      ),
      body: BlocBuilder<CoindetailBloc, CoindetailState>(
        bloc: _coinDetailBloc,
        builder: (context, state) {
          if (state is CoindetailInitial) {
            debugPrint('buraya geldi initial!!');

            return const Center(
              child: Text('Initial State 11!!'),
            );
          }
          if (state is CoindetailLoadingState) {
            debugPrint('buraya geldi loadingg!!');
            return Center(
              child: CircularProgressIndicator(
                color: color,
              ),
            );
          }
          if (state is CoindetailLoadedState) {
            debugPrint('coindetailloaded tetiklendi!!');
            return ListView(
              children: [
                coinTopBar(state, context, numberFormat),
                BlocBuilder<CoinhistoryBloc, CoinhistoryState>(
                  bloc: _coinHistoryBloc,
                  builder: (context, state) {
                    if (state is CoinhistoryInitial) {
                      debugPrint('buraya geldi initial!!');

                      return Container(
                        height: MediaQuery.of(context).size.height / 2,
                      );
                    }
                    if (state is CoinhistoryLoadingState) {
                      debugPrint('buraya geldi loadingg!!');
                      return Container(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Center(
                            child: CircularProgressIndicator(
                          color: color,
                        )),
                      );
                    }
                    if (state is CoinhistoryLoadedState) {
                      List<CoinData> _chartCoinData = [];

                      for (var element in state.coinhistoryList) {
                        var date = DateTime.fromMillisecondsSinceEpoch(
                            int.parse(element.time.toString()));
                        //debugPrint(date.toString());
                        _chartCoinData.add(CoinData(
                            double.parse(element.time.toString()),
                            double.parse(element.priceUsd.toString())));
                      }
                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: SfCartesianChart(
                          series: <ChartSeries>[
                            LineSeries<CoinData, double>(
                                dataSource: _chartCoinData,
                                xValueMapper: (CoinData coin, _) => coin.time,
                                yValueMapper: (CoinData coin, _) => coin.price,
                                //dataLabelSettings: DataLabelSettings(isVisible: true),
                                enableTooltip: true,
                                color: color,
                                name: id)
                          ],
                          primaryXAxis: /*DateTimeAxis(
                              minimum: DateTime(2022, 4),
                              maximum: DateTime(2022, 4)),*/
                              NumericAxis(
                                  edgeLabelPlacement: EdgeLabelPlacement.none,
                                  axisLabelFormatter:
                                      (AxisLabelRenderDetails args) {
                                    var text1;
                                    if (selectedYears) {
                                      text1 = dateFormat3.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              args.value.toInt()));
                                    } else {
                                      text1 = dateFormat2.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              args.value.toInt()));
                                    }

                                    return ChartAxisLabel(
                                        text1, args.textStyle);
                                  }),
                          primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.simpleCurrency(
                                  decimalDigits: 0)),
                          tooltipBehavior: _tooltipBehavior,
                          legend: Legend(
                              isVisible: false, alignment: ChartAlignment.far),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                ChartButtons(
                  selectedYears: selectedYears,
                  id: id,
                  color: color,
                  sendToParentWidget: (bool value) {
                    selectedYears = value;
                    debugPrint('selectedYears -> ' + selectedYears.toString());
                  },
                ),
                BlocBuilder<CoinmarketsBloc, CoinmarketsState>(
                  bloc: _coinMarketsBloc,
                  builder: (context, state) {
                    if (state is CoinmarketsInitial) {
                      debugPrint('buraya geldi initial!!');
                      return const SizedBox(
                        child: Text('CoinMarkets Initial State'),
                      );
                    }
                    if (state is CoinmarketsLoadingState) {
                      debugPrint('buraya geldi loadingg!!');
                      return SizedBox(
                        child: Center(
                            child: CircularProgressIndicator(
                          color: color,
                        )),
                      );
                    }

                    if (state is CoinmarketsLoadedState) {
                      return Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: state.coinmarketsList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          100 *
                                          20,
                                      child: const Text(
                                        'Exchange',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          100 *
                                          20,
                                      child: const Center(
                                          child: Text(
                                        'Pair',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          100 *
                                          20,
                                      child: const Center(
                                          child: Text(
                                        'Price',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          100 *
                                          20,
                                      child: const Center(
                                          child: Text(
                                        'Vol24h',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          100 *
                                          15,
                                      child: const Center(
                                          child: Text(
                                        'Vol%',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ],
                                ),
                              );
                            }

                            index -= 1;
                            var volumeUsd24hr =
                                state.coinmarketsList[index].volumeUsd24Hr;

                            if (volumeUsd24hr != null) {
                              return Container(
                                color: index % 2 == 0
                                    ? Colors.grey.shade200
                                    : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                100 *
                                                20,
                                        child: Text(
                                          state
                                              .coinmarketsList[index].exchangeId
                                              .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                100 *
                                                20,
                                        child: Center(
                                          child: Text(
                                            state.coinmarketsList[index]
                                                    .baseSymbol
                                                    .toString() +
                                                '/' +
                                                state.coinmarketsList[index]
                                                    .quoteSymbol
                                                    .toString(),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                100 *
                                                20,
                                        child: Center(
                                          child: Text(
                                            '\$' +
                                                numberFormat.format(
                                                    double.parse(state
                                                        .coinmarketsList[index]
                                                        .priceUsd
                                                        .toString())),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                100 *
                                                20,
                                        child: Center(
                                          child: Text(
                                            k_m_b_generator(
                                                double.parse(volumeUsd24hr)),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                100 *
                                                15,
                                        child: Center(
                                          child: Text(
                                            double.parse(state
                                                    .coinmarketsList[index]
                                                    .volumePercent
                                                    .toString())
                                                .toStringAsFixed(2),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              ],
            );
          } else {
            return const Center(
              child: Text('Hata Oluştu'),
            );
          }
        },
      ),
    );
  }

  bool toogleSelectedYears(bool selectedYears) {
    return !selectedYears;
  }

  Container coinTopBar(CoindetailLoadedState state, BuildContext context,
      NumberFormat numberFormat) {
    var changePercent =
        double.parse(state.coin.data!.changePercent24Hr.toString());
    return Container(
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 75,
                  height: 75,
                  child: Image.network(
                      'https://assets.coincap.io/assets/icons/' +
                          state.coin.data!.symbol.toString().toLowerCase() +
                          '@2x.png'),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Wrap(direction: Axis.horizontal, children: [
                              Text(
                                state.coin.data!.name.toString(),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ]),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '(' + state.coin.data!.symbol.toString() + ')',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            '\$' +
                                numberFormat.format(double.parse(
                                    state.coin.data!.priceUsd.toString())),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 90, 90, 90)),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          changePercent >= 0
                              ? Icon(
                                  Icons.arrow_drop_up,
                                  color: changePercent > 0
                                      ? Colors.green
                                      : Colors.red,
                                )
                              : Icon(
                                  Icons.arrow_drop_down,
                                  color: changePercent > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                          Text(
                            numberFormat.format(
                              double.parse(
                                state.coin.data!.changePercent24Hr.toString(),
                              ),
                            ),
                            style: TextStyle(
                                color: changePercent > 0
                                    ? Colors.green
                                    : Colors.red),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Card(
                  color: color,
                  child: Padding(
                    padding: const EdgeInsets.all(11),
                    child: Text(
                      state.coin.data!.rank.toString(),
                      textScaleFactor: 2,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Market Cap',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '\$' +
                          k_m_b_generator(double.parse(
                              state.coin.data!.marketCapUsd.toString())),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Volume(24h)',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '\$' +
                          k_m_b_generator(double.parse(
                              state.coin.data!.volumeUsd24Hr.toString())),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Supply',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      k_m_b_generator(
                          double.parse(state.coin.data!.supply.toString())),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  formatNumber(dynamic myNumber) {
    // Convert number into a string if it was not a string previously
    String stringNumber = myNumber.toString();

    // Convert number into double to be formatted.
    // Default to zero if unable to do so
    double doubleNumber = double.tryParse(stringNumber) ?? 0;

    // Set number format to use
    NumberFormat numberFormat = NumberFormat.compact();

    return numberFormat.format(doubleNumber);
  }

  String k_m_b_generator(double num) {
    try {
      if (num > 999 && num < 99999) {
        return "${(num / 1000).toStringAsFixed(2)} K";
      } else if (num > 99999 && num < 999999) {
        return "${(num / 1000).toStringAsFixed(2)} K";
      } else if (num > 999999 && num < 999999999) {
        return "${(num / 1000000).toStringAsFixed(2)} M";
      } else if (num > 999999999) {
        return "${(num / 1000000000).toStringAsFixed(2)} B";
      } else {
        return num.toString();
      }
    } catch (exception) {
      debugPrint('Dönüşüm Hatası: ' + exception.toString());
      return '-----';
    }
  }

  void fetchChartData(
      String interval, int minusDateTime, BuildContext context) {
    context.read<CoinhistoryBloc>().add(FetchCoinHistoryEvent(
        id: id,
        start:
            (DateTime.now().millisecondsSinceEpoch - minusDateTime).toString(),
        end: DateTime.now().millisecondsSinceEpoch.toString(),
        interval: interval));
  }
}

class ChartButtons extends StatefulWidget {
  final Function(bool) sendToParentWidget;
  bool selectedYears;
  String id;
  Color color;
  ChartButtons(
      {Key? key,
      required this.selectedYears,
      required this.id,
      required this.color,
      required this.sendToParentWidget})
      : super(key: key);

  @override
  State<ChartButtons> createState() => _ChartButtonsState();
}

class _ChartButtonsState extends State<ChartButtons> {
  List<bool> btnList = [true, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              setButtonsFalse();
              btnList[0] = true;
            });
            widget.sendToParentWidget(false);
            widget.selectedYears = false;
            fetchChartData(widget.id, 'm30', 86400000, context);
          },
          child: Chip(
            label: const Text(
              '1D',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                btnList[0] == true ? widget.color : Colors.grey.shade400,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              setButtonsFalse();
              btnList[1] = true;
            });
            widget.sendToParentWidget(false);
            widget.selectedYears = false;
            fetchChartData(widget.id, 'h1', 86400000 * 7, context);
          },
          child: Chip(
            label: const Text(
              '1W',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                btnList[1] == true ? widget.color : Colors.grey.shade400,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              setButtonsFalse();
              btnList[2] = true;
            });
            widget.sendToParentWidget(false);
            widget.selectedYears = false;
            fetchChartData(widget.id, 'h6', 86400000 * 30, context);
          },
          child: Chip(
            label: const Text(
              '1M',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                btnList[2] == true ? widget.color : Colors.grey.shade400,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              setButtonsFalse();
              btnList[3] = true;
            });
            widget.sendToParentWidget(false);
            widget.selectedYears = false;
            fetchChartData(widget.id, 'h12', 86400000 * 90, context);
          },
          child: Chip(
            label: const Text(
              '3M',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                btnList[3] == true ? widget.color : Colors.grey.shade400,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              setButtonsFalse();
              btnList[4] = true;
            });
            widget.sendToParentWidget(false);
            widget.selectedYears = false;
            fetchChartData(widget.id, 'd1', 86400000 * 180, context);
          },
          child: Chip(
            label: const Text(
              '6M',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                btnList[4] == true ? widget.color : Colors.grey.shade400,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              setButtonsFalse();
              btnList[5] = true;
            });

            widget.sendToParentWidget(true);
            widget.selectedYears = true;
            fetchChartData(widget.id, 'd1', 86400000 * 365, context);
          },
          child: Chip(
            label: const Text(
              '1Y',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                btnList[5] == true ? widget.color : Colors.grey.shade400,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              setButtonsFalse();
              btnList[6] = true;
            });

            widget.sendToParentWidget(true);
            widget.selectedYears = true;
            fetchChartData(widget.id, 'd1', 86400000 * 365 * 10, context);
          },
          child: Chip(
            label: const Text(
              'ALL',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor:
                btnList[6] == true ? widget.color : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  void fetchChartData(
      String id, String interval, int minusDateTime, BuildContext context) {
    context.read<CoinhistoryBloc>().add(FetchCoinHistoryEvent(
        id: id,
        start:
            (DateTime.now().millisecondsSinceEpoch - minusDateTime).toString(),
        end: DateTime.now().millisecondsSinceEpoch.toString(),
        interval: interval));
  }

  void setButtonsFalse() {
    for (int i = 0; i <= 6; i++) {
      btnList[i] = false;
    }
  }
}

class CoinData {
  final double time;
  final double price;
  CoinData(this.time, this.price);
}
