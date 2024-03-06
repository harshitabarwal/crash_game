import 'package:socket_io_client/socket_io_client.dart' as io;

class CrashSocket {
  io.Socket? socket;
  String? matchId;
  var playersLength = [];

  Future<void> initSocket() async {
    socket = io.io('http://crash-staging.super4.in/', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
  }

  Future<void> connection() async {
    socket!.connect();
    socket!.onConnect((_) {
      print("connected");
    });
    socket!.onDisconnect((_) {
      socket!.disconnect();
    });

    socket!.onConnectError((err) {
      print("connect error");
    });
    socket!.onError((err) {
      print("error");
    });
  }

  Future<void> joinGame() async {
    Map crashJoinResponse = {
      'contestId': '0000',
      "userId": '1234',
      //'time': DateTime.now().millisecondsSinceEpoch,
    };
    print(crashJoinResponse);
    socket!.emit('join game', crashJoinResponse);
  }

  Future<void> listenJoinGame() async{
    socket!.on("join game", (data)  {
      print("join data");
      matchId = data['_id'];
      print(matchId);
      print(data);
    });
  }

  Future<void> checkGame() async{
    Map checkGameResponse = {
      'matchId': matchId
    };
    socket!.emit('checkGame', checkGameResponse);
  }

  Future<void> listenCheckGame() async{
    socket!.on("checkGame", (data) {
      print("check game data");
      playersLength = data['players'];
      print(playersLength.length);
      print(data);
    });
  }
}
