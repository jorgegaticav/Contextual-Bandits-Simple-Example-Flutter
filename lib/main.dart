import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'contextual_bandits_simple_example.dart';

const int NUM_OF_ACTIONS = 10;

const int NUM_OF_STEPS = 10000;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

List doubleZeros(int row, int cols) =>
    List.filled(row, 0.0).map((e) => List.filled(cols, 0.0)).toList();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  SlotMachine sm1;
  SlotMachine sm2;
  SlotMachine sm3;
  SlotMachine sm4;
  List<SlotMachine> machines;

  Map machineToIndex = {};

  List Q;
  List N;

  Map rewards = {};
  List averageRewards = [];
  double cumulativeReward = 0.0;

  bool ready = false;

  @override
  void initState() {
    super.initState();
    run();
  }

  void run(){
    sm1 = SlotMachine(NUM_OF_ACTIONS,'blue');
    sm2 = SlotMachine(NUM_OF_ACTIONS,'red');
    sm3 = SlotMachine(NUM_OF_ACTIONS,'green');
    sm4 = SlotMachine(NUM_OF_ACTIONS,'yellow');
    machines = [sm1,sm2,sm3,sm4];

    // var machineToIndex = {};
    var n = 0;
    for (var machine in machines){
      machineToIndex[machine.color] = n;
      n += 1;
    }

    print(machineToIndex);

    // var Q = m2d.zeros(machines.length,NUM_OF_ACTIONS);
    Q = doubleZeros(machines.length,NUM_OF_ACTIONS);
    // Q = Q.map((e) => e.toDouble()).toList();

    // var N = m2d.zeros(machines.length,NUM_OF_ACTIONS);
    N = doubleZeros(machines.length,NUM_OF_ACTIONS);
    // N = N.map((e) => e.toDouble()).toList();

    print(Q);
    print(N);



    // var rewards = {};
    // var averageRewards = [];
    // var cumulativeReward = 0.0;
    for (var i = 0; i < NUM_OF_STEPS; i++) {
      // var random.shuffle(machines);
      // print(machines);
      machines.shuffle();
      // print(machines);
      var machine = machines[0];
      // print('machine: $machine');
      var index = machineToIndex[machine.color];
      // print('index: $index');

      var action = chooseAction(Q[index], 0.01);
      // print('action: $action');
      // Take the action
      var reward = machine.pull(action);
      // print('rewards: $rewards');
      if (!rewards.containsKey(machine.color[0])){
        // print('!rewards.containsKey(${machine.color[0]})');
        // rewards[machine.color[0]] = m2d.array([[i, reward]]);
        // rewards[machine.color[0]] = [[i, reward]];
        rewards[machine.color[0]] = [[i, reward[0]]];
        // print('created: ${rewards[machine.color[0]]}');
      }else {
        // print('rewards.containsKey(${machine.color[0]})');
        // print(rewards[machine.color[0]]);
        // rewards[machine.color[0]] = rewards[machine.color[0]].add([[i,reward]]);
        // print('[i,reward]: ${[i,reward[0]]}');
        (rewards[machine.color[0]] as List).add([i,reward[0]]);
        // rewards[machine.color[0]] = (rewards[machine.color[0]] as List).add([i,reward[0]]);
        // print('append: ${rewards[machine.color[0]]}');
        // rewards[machine.color[0]].add([[i,reward]], axis:0);
        // cumulative_reward += reward;
        cumulativeReward += reward[0];
        // print('cumulative_reward: $cumulativeReward');
        // average_rewards.append(cumulative_reward/(average_rewards.length + 1));
        averageRewards.add(cumulativeReward/(averageRewards.length + 1));
      }
      // Update
      // print('N: ${N[index][action]}');
      N[index][action] = N[index][action] + 1;
      // print('N updated: ${N[index][action]}');
      // print('Q: ${Q[index][action]}');
      // print('Reward: ${reward[0]}');
      Q[index][action] = (Q[index][action] + 1).toDouble() / N[index][action] * (reward[0] - (Q[index][action]).toDouble());
      // print('Q updated: ${Q[index][action]}');
    }
    print('rewards: $rewards');
    print('FINISHED');
  }

  void generatePlot(){
    setState(() {
      ready = true;
    });
  }

  List<charts.Series<Reward, num>> plotRewards() {

    List<Reward> data = [];

    rewards.forEach((key, value) {
      // print('rewards[$key][:,0]  ${value[0]}');
      // print('rewards[$key][:,1] ${value[1]}');

      print('value.length: ${value.length}');
      for(int i = 0; i < value.length; i++){
        data.add(Reward(value[i][0], value[i][1], key));
      }
    });

    data.forEach((element) => print(element));

    return [
      new charts.Series<Reward, num>(
        id: 'Rewards',
        // Providing a color function is optional.
        colorFn: (Reward reward, _) {
          if (reward.color == 'b') {
            return charts.MaterialPalette.blue.shadeDefault;
          } else if (reward.color == 'r') {
            return charts.MaterialPalette.red.shadeDefault;
          } else if (reward.color == 'y') {
            return charts.MaterialPalette.yellow.shadeDefault;
          }else {
            return charts.MaterialPalette.green.shadeDefault;
          }
        },
        domainFn: (Reward reward, _) => reward.x,
        measureFn: (Reward reward, _) => reward.y,
        // Providing a radius function is optional.
        // radiusPxFn: (LinearSales sales, _) => sales.radius,
        data: data,
      )
    ];
  }

  List<charts.Series<AverageReward, num>> plotAverageRewards() {

    print(averageRewards.length);
    print(averageRewards);

    List<AverageReward> data = [];

    // for(int i = 0; i < NUM_OF_STEPS; i++){
    for(int i = 0; i < 9996; i++){
      data.add(AverageReward(i, averageRewards[i]));
    }

    return [
      new charts.Series<AverageReward, num>(
        id: 'Rewards',
        domainFn: (AverageReward reward, _) => reward.step,
        measureFn: (AverageReward reward, _) => reward.value,

        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (ready) ? Center(
        child: charts.ScatterPlotChart(plotRewards(), animate: true)
        // child: charts.ScatterPlotChart(plotAverageRewards(), animate: true)
      ) : Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: generatePlot,
        tooltip: 'Generate Plot',
        child: Icon(Icons.add),
      ),
    );
  }
}

class Reward {
  final int x;
  final double y;
  final String color;

  Reward(this.x, this.y, this.color);

  @override
  String toString(){
    return '$color $x, $y';
  }
}

class AverageReward {
  final int step;
  final double value;

  AverageReward(this.step, this.value);

  @override
  String toString(){
    return '$step, $value';
  }
}