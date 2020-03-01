import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

const _hostname = '0.0.0.0';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    exitCode = 64;
    return;
  }
  var app = Router();
  
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(app.handler);
  app.get('/', (shelf.Request req) async {
    var file = File(Directory.current.path + '/public/index.html');
    var content = await file.readAsString();
    return shelf.Response.ok('${content}', headers: {
      'Content-Type':'text/html; charset=UTF-8'
    });
  });
  

  
  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

shelf.Response _echoRequest(shelf.Request request) =>
    shelf.Response.ok('Request for "${request.url}"');
