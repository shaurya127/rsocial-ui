import 'package:better_player/better_player.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rsocial2/Screens/bottom_nav_bar.dart';
import 'package:rsocial2/contants/constants.dart';

class ReusableVideoListController {
  final List<BetterPlayerController> _betterPlayerControllerRegistry = [];
  final List<BetterPlayerController> _usedBetterPlayerControllerRegistry = [];
  ReusableVideoListController() {
    for (int index = 0; index < 3; index++) {
      _betterPlayerControllerRegistry.add(
        BetterPlayerController(
          BetterPlayerConfiguration(
            // eventListener: (event) {
            //   if (internalCall) {
            //     return "HEy";
            //   }
            //   if (event.betterPlayerEventType ==
            //       BetterPlayerEventType.setVolume) {
            //     muted = !muted;

            //     print("Globally Muted");
            //     return "Done";
            //   }
            // },
            fit: BoxFit.contain,
            startAt: Duration.zero,
            handleLifecycle: true,
            autoDispose: false,
            autoPlay: true,
            autoDetectFullscreenDeviceOrientation: true,
            // deviceOrientationsAfterFullScreen: [
            //   DeviceOrientation.portraitUp,
            //   DeviceOrientation.portraitDown
            // ],
            // deviceOrientationsOnFullScreen: [
            //   DeviceOrientation.portraitUp,
            //   DeviceOrientation.portraitDown
            // ],
            controlsConfiguration: BetterPlayerControlsConfiguration(
              loadingColor: colorButton,
              backgroundColor: Colors.white,
              enableOverflowMenu: false,
              enableSkips: false,
              enableFullscreen: false,
              showControls: true,
            ),
          ),
        ),
      );
    }
  }

  BetterPlayerController getBetterPlayerController() {
    final freeController = _betterPlayerControllerRegistry.firstWhereOrNull(
        (controller) =>
            !_usedBetterPlayerControllerRegistry.contains(controller));
    for (int i = 0; i < _usedBetterPlayerControllerRegistry.length; i++) {
      _usedBetterPlayerControllerRegistry[i].pause();

      _usedBetterPlayerControllerRegistry[i].setVolume(0.0);
    }
    if (freeController != null) {
      _usedBetterPlayerControllerRegistry.add(freeController);

      freeController.setVolume(1.0);
    }
    if (_usedBetterPlayerControllerRegistry.length == 3) {
      _usedBetterPlayerControllerRegistry[0].pause();
      _usedBetterPlayerControllerRegistry[1].pause();
      _usedBetterPlayerControllerRegistry[0].setVolume(0.0);
      _usedBetterPlayerControllerRegistry[1].setVolume(0.0);
      _usedBetterPlayerControllerRegistry.removeAt(0);
      _usedBetterPlayerControllerRegistry.removeAt(0);
    }
    return freeController;
  }

  void freeBetterPlayerController(
      BetterPlayerController betterPlayerController) async {
    betterPlayerController.pause();
    _usedBetterPlayerControllerRegistry.remove(betterPlayerController);

    //print("Controllers in use : ${_usedBetterPlayerControllerRegistry.length}");
  }

  void dispose() {
    _betterPlayerControllerRegistry.forEach((controller) {
      controller.dispose();
    });
  }
}
