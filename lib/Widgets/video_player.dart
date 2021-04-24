import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rsocial2/contants/constants.dart';
import 'package:better_player/better_player.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends StatefulWidget {
  final File video;
  final Function removeVideo;
  final VideoPlayerController videoPlayerController;
  VideoPlayer(
    this.video,
    this.videoPlayerController,
    this.removeVideo,
  );
  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  BetterPlayerController _betterPlayerController;
  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file, widget.video.path);
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown
          ],
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown
          ],
          fullScreenAspectRatio: widget.videoPlayerController.value.aspectRatio,
          aspectRatio: widget.videoPlayerController.value.aspectRatio,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: false,
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource);
    super.initState();
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
              height: 400,
              decoration: BoxDecoration(
                color: colorGreyTint.withOpacity(0.03),
              ),
              child: AspectRatio(
                aspectRatio: widget.videoPlayerController.value.aspectRatio,
                child: BetterPlayer(
                  controller: _betterPlayerController,
                ),
              )),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.black,
              ),
              onPressed: () {
                widget.removeVideo();
              },
            ),
          ),
        ],
      ),
    );
  }
}
