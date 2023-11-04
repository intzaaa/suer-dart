// 导入shelf库
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' as path;

// 创建一个http文件服务器
Future httpServer(String src) async {
  // 定义一个处理器函数，对于任何请求都返回指定文件
  shelf.Response handleRequest(shelf.Request request) {
    var fileStream = File(src).openRead();
    return shelf.Response.ok(fileStream);
  }

  var server = io.serve(handleRequest, 'localhost', 443,
      securityContext: SecurityContext()
        ..useCertificateChain(path.join(
            path.dirname(Platform.script.toFilePath()), '../lib/tls/cert'))
        ..usePrivateKey(path.join(
            path.dirname(Platform.script.toFilePath()), '../lib/tls/key')));

  return server;
}

Future redirectServer() async {
  var redirect = io.serve((shelf.Request request) {
    Uri uri = Uri.parse(request.requestedUri.toString()).replace(port: 443);
    return shelf.Response.movedPermanently(uri);
  }, 'localhost', 80);
  return redirect;
}
