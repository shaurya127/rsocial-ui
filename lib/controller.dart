import 'package:better_player/better_player.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/services.dart';

class ReusableVideoListController {
  final List<BetterPlayerController> _betterPlayerControllerRegistry = [];
  final List<BetterPlayerController> _usedBetterPlayerControllerRegistry = [];

  ReusableVideoListController() {
    for (int index = 0; index < 3; index++) {
      _betterPlayerControllerRegistry.add(
        BetterPlayerController(
          BetterPlayerConfiguration(
            handleLifecycle: false,
            autoDispose: false,
            autoPlay: true,
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown
            ],
            deviceOrientationsOnFullScreen: [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown
            ],
            controlsConfiguration: BetterPlayerControlsConfiguration(
              enableSkips: false,
              enableFullscreen: false,
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
    }
    if (freeController != null) {
      _usedBetterPlayerControllerRegistry.add(freeController);
    }
    if (_usedBetterPlayerControllerRegistry.length == 3) {
      _usedBetterPlayerControllerRegistry[0].pause();
      _usedBetterPlayerControllerRegistry[1].pause();
      _usedBetterPlayerControllerRegistry.removeAt(0);
      _usedBetterPlayerControllerRegistry.removeAt(0);
    }

    return freeController;
  }

  void freeBetterPlayerController(
      BetterPlayerController betterPlayerController) {
    betterPlayerController.pause();

    _usedBetterPlayerControllerRegistry.remove(betterPlayerController);
    print("Controllers in use : ${_usedBetterPlayerControllerRegistry.length}");
  }

  void dispose() {
    _betterPlayerControllerRegistry.forEach((controller) {
      controller.dispose();
    });
  }
}
