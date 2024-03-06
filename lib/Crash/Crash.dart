import 'dart:async';

import 'package:crash/CrashSocket/CrashSocketIO.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Crash extends StatefulWidget {
  const Crash({super.key});

  @override
  State<Crash> createState() => _CrashState();
}

class _CrashState extends State<Crash> with TickerProviderStateMixin {
  CrashSocket socket = CrashSocket();

  Timer? timer;

  bool isRocket = false;
  bool isJump = false;
  bool isBlast = false;
  bool isBackground = false;
  bool isButton = false;
  bool isCountdown = false;
  bool isRocketLoading = false;

  AnimationController? rocketController;
  Animation<double>? rocketAnimation;

  AnimationController? jumpController;
  Animation<double>? jumpAnimation;

  AnimationController? blastController;
  Animation<double>? blastAnimation;

  initiate() {
    rocketController =
        AnimationController(duration: Duration(seconds: 20), vsync: this);

    rocketAnimation =
        Tween<double>(begin: 600, end: 150).animate(rocketController!)
          ..addListener(() {
            setState(() {});
          });

    jumpController =
        AnimationController(duration: Duration(seconds: 10), vsync: this);

    jumpAnimation = Tween<double>(begin: 100, end: 600).animate(jumpController!)
      ..addListener(() {
        setState(() {});
      });

    blastController =
        AnimationController(duration: Duration(seconds: 5), vsync: this);

    blastAnimation = Tween(begin: 30.0, end: 0.0).animate(blastController!);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiate();

    Future.delayed(Duration(seconds: 2), () {
      isRocketLoading = true;

      setState(() {});
      Future.delayed(Duration(seconds: 5), () {
        isRocketLoading = false;

        isRocket = true;
        isButton = true;
        rocketController!.forward();
        setState(() {});
      });
    });

    connectSocket();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    rocketController!.dispose();
    jumpController!.dispose();
    blastController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Visibility(
          //    visible: isBackground,
          //    child: Lottie.asset('assets/animations/crack bg.json',fit: BoxFit.cover),),

          // Visibility(
          //   visible: isCountdown,
          //   child: Lottie.asset('assets/animations/rocket.json'),),

          Visibility(
            visible: isRocketLoading,
            child: Lottie.asset('assets/animations/rocket loading.json'),
          ),

          Transform.translate(
            offset: Offset(0, rocketAnimation!.value),
            child: Visibility(
              visible: isRocket,
              child: Lottie.asset('assets/animations/rocket.json'),
            ),
          ),

          Transform.translate(
            offset: Offset(
                MediaQuery.of(context).size.width * 0.7, jumpAnimation!.value),
            child: Visibility(
              visible: isJump,
              child: Container(
                  height: 100,
                  child: Lottie.asset('assets/animations/jump.json')),
            ),
          ),
          // Visibility(
          //   visible: isBlast,
          //   child: Lottie.asset('assets/animations/blast.json'),
          // ),
          Visibility(
            visible: isButton,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      isJump = true;
                      jumpController!.forward();
                      setState(() {});
                    },
                    child: Container(
                      width: 120,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.blue.shade900),
                      child: Center(
                        child: Text(
                          "Jump",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void connectSocket() async {
    await socket.initSocket().then((value) async => {
          await socket
              .connection()
              .then((value) async => {await socket.joinGame()})
              .then((value) => {socket.listenJoinGame()})
              .then((value) => {
                    timer = Timer.periodic(Duration(seconds: 10), (timer) {
                      checkMatchResponse();
                    })
                  })
        });
  }

  Future<void> checkMatchResponse() async {
    await socket.checkGame().then((value) {
      socket.listenCheckGame();
    });
  }
}
