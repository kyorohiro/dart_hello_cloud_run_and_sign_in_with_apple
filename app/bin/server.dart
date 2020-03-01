import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:math' as math;

const _hostname = '0.0.0.0';

Map<String, int> csrf_map = {};
final PORT = Platform.environment['PORT'];
final BASE_ADDR = Platform.environment['BASE_ADDR'];

void main(List<String> args) async {
  var port = int.tryParse(PORT ?? '8080');
  var baseAddr = BASE_ADDR??'http://localhost.test';


  if (port == null || baseAddr == null) {
    stdout.writeln('Wrong "$port" or "$baseAddr".');
    return;
  }

  var app = Router();  
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(app.handler);

  app.get('/', (shelf.Request req) async {
    var file = File(Directory.current.path + '/public/index.html');
    var content = await file.readAsString();
    var csrf = Uuid.createUUID();
    csrf_map[csrf] = DateTime.now().millisecondsSinceEpoch;
    content = content.replaceAll('{{RANDOM_ID_FOR_CSRF}}', csrf);
    content = content.replaceAll('{{BASE_ADDR}}', baseAddr);
    return shelf.Response.ok('${content}', headers: {
      'Content-Type':'text/html; charset=UTF-8',
    });
  });

  app.post('/callback', (shelf.Request req) async {
    var content = await req.readAsString();
    var keyValues = FormConverter.toDict(content);
    var csrf = keyValues['state'];
    if(csrf_map.containsKey(csrf)) {
      csrf_map.remove(csrf);
      return shelf.Response.ok('${content}', headers: {
        'Content-Type':'text/html; charset=UTF-8',
      });
    } else {
      return shelf.Response.ok( 'Wrong CSRF', headers: {
        'Content-Type':'text/html; charset=UTF-8',
      });
    }
  });
  
  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

class FormConverter 
{
  static Map<String,String> toDict(String source) {
    var result = <String,String>{};
    var items = source.split('&');
    for(var item in items){
      var keyValue = item.split('=');
      result[keyValue[0]] = keyValue[1];
    }
    return result;    
  }

}

class Uuid 
{
  static final math.Random _random = math.Random();
  static String createUUID() {
    return s4()+s4()+'-'+s4()+'-'+s4()+'-'+s4()+'-'+s4()+s4()+s4();
  }
  static String s4() {
    return (_random.nextInt(0xFFFF)+0x10000).toRadixString(16).substring(0,4);
  }
}