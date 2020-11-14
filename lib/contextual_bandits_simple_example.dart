import 'dart:math';

import 'package:matrix2d/matrix2d.dart';
// import 'package:sample_statistics/sample_statistics.dart';
import 'package:scidart/numdart.dart';

/// Square root of pi.
const sqrtPi = 1.77245385090551602729816748334;

/// Constant: 1.0/(sqrt(pi)).
const invSqrtPi = 1.0 / sqrtPi;

/// Constant: sqrt(2.0*pi).
const sqrt2Pi = sqrt2 * sqrtPi;

const invSqrt2Pi = 1.0 / sqrt2Pi;

Matrix2d m2d = Matrix2d();
Random random = Random();

class SlotMachine {
  List action;
  String color;
  List Q;
  List N;

  @override
  String toString(){
    return color;
  }

  SlotMachine(numOfActions, color) {
    var standardDeviations = m2d.fill(numOfActions, 1, 0.01);
    // print(standardDeviations);
    // var means = m2d.random.rand(numOfActions, 1);
    var means = sampleUniformPdf(numOfActions, 0, 1).map((element) => [element]).toList();
    // print(means);
    action = m2d.concatenate(standardDeviations, means, axis: 1);
    // print(action);
    this.color = color;
    Q = m2d.zeros(numOfActions, 1);
    N = m2d.zeros(numOfActions, 1);
    print('Machine: ${this.color}');
    print('num_of_actions: $numOfActions');
    // print('expected reward: ${round(m2d.max(means), 2)}');
    print('expected reward: ${double.parse(m2d.max(means)[0].toStringAsFixed(2))}');
    print('--------------');
  }

  List pull(action_num) {
    // print('action_num: $action_num');
    // mean and standard deviation
    var standardDeviation = action[action_num][0];
    // print('standard_deviation: $standardDeviation');
    var mean = action[action_num][1];
    // print('mean: $mean');
    // return m2d.random.normal(mean, standard_deviation);
    return sampleNormalPdf(1, mean, standardDeviation); //ERROR NO FUNCIONA

  }
}

typedef ProbabilityDensity = num Function(num x);

List<num> samplePdf(
    int n,
    num min,
    num max,
    num probDistMax,
    ProbabilityDensity pdf) {
  final result = <num>[];
  final random = Random();

  final range = max - min;

  while (result.length < n) {
    final x = range * random.nextDouble() + min;
    final y = probDistMax * random.nextDouble();

    if (y < pdf(x)) {
      result.add(x);
    }
  }
  return result;
}

List<num> sampleNormalPdf(int n, num mean, num stdDev) {
  var min = mean - 10 * stdDev;
  var max = mean + 10 * stdDev;

  return samplePdf(n, min, max, normalPdf(mean, mean, stdDev),
          (x) => normalPdf(x, mean, stdDev));
}

List<num> sampleUniformPdf(int n, num min, num max) {
  if (min >= max) {
    throw 'invalidState: min: $min >= max: $max expectedState: min < max';
  }

  final random = Random();
  final range = max - min;
  return List<num>.generate(n, (_) => min + random.nextDouble() * range);
}

num normalPdf(num x, num mean, num stdDev) {
  if (stdDev <= 0.0) {
    throw 'invalidState: stdDev: $stdDev <= 0. expectedState: stdDev > 0';
  }
  final invStdDev = 1.0 / stdDev;
  x = (x - mean) * invStdDev;
  return invSqrt2Pi * invStdDev * exp(-0.5 * x * x);
}

dynamic chooseAction(List<num> Q, epsilon) {
  if (random.nextDouble() < epsilon) {
    // return random.randint(0, Q.shape[0] - 1);
    return random.nextInt(Q.shape[0] - 1);
  } else {
    // return m2d.argmax(Q);
    // print('Q: $Q');
    var QDouble = Q.map((e) => e.toDouble()).toList();
    // print('Q_double: $QDouble');
    return arrayArgMax(Array(QDouble));
  }
}

// List concatenate(List list1, list2, {int axis = 0}) {
//   if (axis > 1 || axis < 0) throw ('axis only support 0 and 1');
//   var shape1 = m2d.shape(list1);
//   print(shape1);
//   var shape2 = m2d.shape(list2);
//   print(shape2);
//   if (axis == 1) {
//     if (shape1[0] == shape2[0]) {
//       var temp = m2d.fill(shape1[0], shape1[1] + shape2[1], null);
//       var jwal = shape1[1] >= shape2[1] ? shape1[1] : shape2[1];
//       for (var i = 0; i < shape1[0]; i++) {
//         for (var j = 0; j < jwal; j++) {
//           if (shape1[1] == shape2[1]) {
//             temp[i][j] = list1[i][j];
//             temp[i][j + shape2[1]] = list2[i][j];
//           } else if (shape1[1] > shape2[1]) {
//             temp[i][j] = list1[i][j];
//             if (j < shape2[1]) {
//               temp[i][j + shape1[1]] = list2[i][j];
//             }
//           } else {
//             if (j < shape1[1]) {
//               temp[i][j] = list1[i][j];
//             }
//             temp[i][j + shape2[1] - (shape2[1] - shape1[1])] = list2[i][j];
//           }
//         }
//       }
//       return temp;
//     } else {
//       throw ('all the input array dimensions for the concatenation axis must match exactly');
//     }
//   } else {
//     if (shape1[1] == shape2[1]) {
//       return list1 + list2;
//     } else {
//       throw Exception(
//           'all the input array dimensions for the concatenation axis must match exactly');
//     }
//   }
// }