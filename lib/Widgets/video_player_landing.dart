import 'dart:async';
import 'package:better_player/better_player.dart';
import 'package:video_player/video_player.dart';
import '../controller.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoListData {
  final String videoTitle;
  final String videoUrl;
  Duration lastPosition;
  bool wasPlaying = false;

  VideoListData(this.videoTitle, this.videoUrl);
}

class ReusableVideoListWidget extends StatefulWidget {
  final VideoListData videoListData;
  final ReusableVideoListController videoListController;
  final Function canBuildVideo;

  const ReusableVideoListWidget({
    Key key,
    this.videoListData,
    this.videoListController,
    this.canBuildVideo,
  }) : super(key: key);

  @override
  _ReusableVideoListWidgetState createState() =>
      _ReusableVideoListWidgetState();
}

class _ReusableVideoListWidgetState extends State<ReusableVideoListWidget> {
  VideoListData get videoListData => widget.videoListData;
  BetterPlayerController controller;
  StreamController<BetterPlayerController>
      betterPlayerControllerStreamController = StreamController.broadcast();
  bool _initialized = false;
  Timer _timer;
  double _aspectRatio = 16 / 9;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    betterPlayerControllerStreamController.close();
    super.dispose();
  }

  void _setupController() async {
    // var videoController =
    //     VideoPlayerController.network(widget.videoListData.videoUrl);
    // await videoController.initialize();
    //_aspectRatio = videoController.value.aspectRatio;
    //videoController.dispose();
    if (controller == null) {
      controller = widget.videoListController.getBetterPlayerController();
      if (controller != null) {
        controller.setupDataSource(
          BetterPlayerDataSource.network(
            videoListData.videoUrl,
            cacheConfiguration: BetterPlayerCacheConfiguration(useCache: true),
          ),
        );

        if (!betterPlayerControllerStreamController.isClosed) {
          betterPlayerControllerStreamController.add(controller);
        }
        controller.addEventsListener(onPlayerEvent);
      }
    }
  }

  void _freeController() {
    if (!_initialized) {
      _initialized = true;
      return;
    }
    if (controller != null && _initialized) {
      controller.removeEventsListener(onPlayerEvent);
      widget.videoListController.freeBetterPlayerController(controller);
      controller.pause();
      controller = null;
      if (!betterPlayerControllerStreamController.isClosed) {
        betterPlayerControllerStreamController.add(null);
      }
      _initialized = false;
    }
  }

  void onPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      videoListData.lastPosition = event.parameters["progress"] as Duration;
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (videoListData.lastPosition != null) {
        controller.seekTo(videoListData.lastPosition);
      }
      if (videoListData.wasPlaying) {
        controller.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(hashCode.toString() + DateTime.now().toString()),
      onVisibilityChanged: (info) {
        if (!widget.canBuildVideo()) {
          if (_timer != null) _timer.cancel();
          _timer = null;
          _timer = Timer(Duration(milliseconds: 500), () {
            if (info.visibleFraction >= 0.9) {
              _setupController();
            } else {
              _freeController();
            }
          });
          return;
        }
        if (info.visibleFraction >= 0.9) {
          _setupController();
        } else {
          if (controller != null) controller.pause();
          _freeController();
        }
      },
      child: StreamBuilder<BetterPlayerController>(
        stream: betterPlayerControllerStreamController.stream,
        builder: (context, snapshot) {
          return controller != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BetterPlayer(
                    controller: controller,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                );
        },
      ),
    );
  }

  @override
  void deactivate() {
    if (controller != null) {
      videoListData.wasPlaying = controller.isPlaying();
    }
    _initialized = true;
    super.deactivate();
  }
}
