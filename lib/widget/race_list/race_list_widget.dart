import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterapp/enums/race_status.dart';
import 'package:flutterapp/model/simulate/race_config.dart';
import 'package:flutterapp/service/simulate_race_location_observer.dart';
import 'package:flutterapp/util/http_utils.dart';
import 'package:flutterapp/widget/nav_drawer_widget.dart';
import 'package:flutterapp/widget/record_activity/record_activity_widget.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:imagebutton/imagebutton.dart';

class RaceListWidget extends StatefulWidget {
  final MaterialColor materialPalette;

  RaceListWidget(this.materialPalette);

  _RaceListWidgetState createState() => _RaceListWidgetState();
}

class _RaceListWidgetState extends State<RaceListWidget> {
  final apiUrl = GlobalConfiguration().getString("sport_activity_api_url");
  List<RaceConfig> races;

  void initState() {
    super.initState();
    _findRaceConfigs();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawerWidget(widget.materialPalette),
      appBar: AppBar(
        title: Text('Choose activity type'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                ),
                padding: const EdgeInsets.all(3.0),
                itemCount: races == null ? 0 : races.length,
                itemBuilder: (BuildContext context, int index) {
                  return _prepareActivityTypeRow(
                      index + 1,
                      widget.materialPalette,
                      races[index],
                          () => RecordActivityWidget(new SimulateRaceLocationObserver(races[index]), widget.materialPalette));
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(0.0),
              color: widget.materialPalette.shade600,
              child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: RaisedButton(
                              color: widget.materialPalette.shade600,
                              onPressed: () {},
                              child: const Text(
                                  'NEW RACE',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    )
                  ]
              ),
            )
          ],
        ),
      ),
    );
  }

  void _findRaceConfigs() async {
    final Iterable iterable = json.decode(await HttpUtils.get('$apiUrl/race/list'));
    final List<RaceConfig> races = iterable
        .map((model) => RaceConfig.fromJson(model))
        .toList();
    races.sort((RaceConfig c1, RaceConfig c2) => c2.generateDate.compareTo(c1.generateDate));
    setState(() {
      this.races = races;
    });
  }

  Container _prepareActivityTypeRow(int position, MaterialColor palette, RaceConfig race, Function function) {
    return new Container(
      padding: const EdgeInsets.all(2.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[ Text(position.toString() + '.', style: TextStyle(fontSize: 20)) ],
            ),
          ),
          Expanded(
            flex: 65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[ Text(race.name, style: TextStyle(fontSize: 20)) ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.only(left: 0.0, right: 5.0),
              child: Image(
                image: AssetImage("assets/images/icons/${_chooseStatusImage(RaceStatus.findByName(race.status))}.png"),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: _renderStartButton(RaceStatus.findByName(race.status), function)
          ),
        ],
      ),
    );
  }

  Container _renderStartButton(RaceStatus status, Function function) {
    if (status == RaceStatus.IN_PROGRESS || status == RaceStatus.NOT_STARTED) {
      return Container(
        child: ImageButton(
          children: <Widget>[],
          width: 55,
          height: 45,
          pressedImage: Image.asset("assets/images/icons/start_green.png"),
          unpressedImage: Image.asset("assets/images/icons/start_green.png"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => function()),
            );
          },
        ),
      );
    }
    return Container(
      height: 45,
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
    );
  }

  String _chooseStatusImage(RaceStatus status) {
    switch (status) {
      case RaceStatus.NOT_STARTED:
        return "new";
      case RaceStatus.IN_PROGRESS:
        return "started";
      case RaceStatus.FINISHED:
        return "finished";
      default:
        return "finished";
    }
  }
}
