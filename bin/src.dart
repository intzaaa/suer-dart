import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:args/args.dart';
import 'package:dartx/dartx.dart';
import 'package:path/path.dart' as path;

import 'package:suer/http.dart';

clear() {
  stdout.write('\x1B[2J\x1B[0;0H');
}

bool s = false;

void main(List<String> a) async {
  /// 初始化命令行参数
  final parser = ArgParser()
    ..addMultiOption('files',
        abbr: 'f', help: '指定一个或多个文件的路径', splitCommas: false)
    ..addFlag('silent', abbr: 's', defaultsTo: false, help: '是否开启安静模式')
    ..addCommand('help');
  final args = parser.parse(a);

  s = args['silent'];

  /// 展示帮助信息
  if (args.command?.name == 'help' || a.isEmpty) {
    print('欢迎使用 SUER-DART ，使用 Dart 语言编写的 SUER-Injector ！');
    print(parser.usage);
    exit(0);
  }

  print('(SUER-DART 已启动)');

  /// 检查文件列表
  List<String> list;
  if (args['files'].isEmpty) {
    throw ('必须指定至少一个文件，不然我怎么知道你想要劫持成什么？！');
  } else {
    list = args['files'];
    list = list.toSet().toList();

    List noAccess = [];

    // 终端文本上色
    final AnsiPen redPen = AnsiPen()..red();

    /// 检测移除不存在的项目
    list.forEachIndexed((element, index) async {
      final file = File(element);
      if (!file.existsSync()) {
        noAccess.add(element);
      }
    });
    if (noAccess.isNotEmpty) {
      print(redPen('${noAccess.length}个文件无法访问：'));
      noAccess.forEachIndexed((element, index) {
        print(redPen('  ${index + 1}: $element'));
      });
    }
    list.removeWhere((element) => noAccess.contains(element));
    // 最终展示合法的项目
    if (list.isEmpty) {
      throw ('所有路径都无法访问，请检查输入格式是否正确！');
    } else if (!s) {
      print('${list.length}个文件已被指定：');
      list.forEachIndexed((element, index) {
        print('  ${index + 1}: $element');
      });
    }
  }

  ProcessSignal.sigint.watch().listen((event) {
    Hosts().removeHosts();
    exit(1);
  });

  Hosts().removeHosts();
  Hosts().addHosts();

  redirectServer();
  print('  按下\'n\'以继续');
  await handleFileList(list);
}

class Hosts {
  Hosts();
  final String hostsPath =
      path.normalize('C:\\Windows\\System32\\drivers\\etc\\hosts');
  final String suffix = '#SUER-DART';
  List<String> get targets {
    List<String> list = [];
    for (var element in jsonDecode(File(path.join(
            path.dirname(Platform.script.toFilePath()), '../lib/targets.json'))
        .readAsStringSync())) {
      list.add('192.168.137.1  $element  $suffix');
    }
    return list;
  }

  List<String> get hosts {
    return File(hostsPath).readAsLinesSync();
  }

  addHosts() {
    List<String> newHosts = List.from(hosts);
    newHosts.addAll(targets);
    File(hostsPath).writeAsStringSync(newHosts.join('\r\n'));
  }

  removeHosts() {
    List<String> newHosts = List.from(hosts);
    hosts.forEachIndexed((element, index) {
      if (element.endsWith(suffix)) {
        newHosts.removeAt(index);
      }
    });
    File(hostsPath).writeAsStringSync(newHosts.join('\r\n'));
  }
}

handleFileList(List list) async {
  dynamic server;
  int index = -1;
  stdin.timeout(Duration(milliseconds: 10));
  stdin.echoMode = false;
  stdin.lineMode = false;
  stdin.listen((event) {
    int input = event[0];
    if (input != -1) {
      if (input == 110) {
        clear();
        if (index > -1) server.then((value) => value.close());
        index = index + 1;
        if (index + 1 > list.length) {
          if (!s) print('所有文件已处理完毕！');
          exit(0);
        }
        server = httpServer(list[index]);
        if (!s) print('正在处理：\n  ${list[index]}');
        final int max = 20;
        final int progress =
            (((index + 1).toDouble() / list.length) * max).toInt();
        print(
            '  ${index + 1}/${list.length}  [${'#' * progress}${' ' * (max - progress)}]');
        if (!s) {
          print('  按下\'e\'以正确退出本程序');
          print('  按下\'n\'以处理下一个文件');
        }
      } else if (input == 101) {
        Hosts().removeHosts();
        exit(0);
      }
    }
  });
}
