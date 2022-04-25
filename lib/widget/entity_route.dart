import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import 'image_item_widget.dart';

import 'dart:io';

class EntityRoute extends StatefulWidget {
  AssetEntity? entity;

  EntityRoute({Key? key, this.entity}) : super(key: key);

  @override
  State<EntityRoute> createState() => _EntityRouteState();
}

class _EntityRouteState extends State<EntityRoute> {
  VideoPlayerController? _controller;

  @override
  initState() {
    super.initState();
    test();
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller!.pause();
    }
  }

  void test() async {
    if (widget.entity!.type == AssetType.video) {
      File? videoFile = await widget.entity!.fileWithSubtype;
      if (videoFile != null) {
        _controller = VideoPlayerController.file(videoFile)
          ..initialize().then((_) {
            setState(() {});
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      floatingActionButton: _controller != null ? FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller != null) {
              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
            } else {
              print('_controller is null..');
            }
          });
        },
        child: Icon(
          _controller != null && _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ) : Container(),
      body: Center(
        child: Column(
          children: [
            _controller != null && _controller!.value.isInitialized ?
            AspectRatio(aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
            : Container(),
            _controller == null ? ImageItemWidget(
              key: ValueKey<int>(0),
              entity: widget.entity!,
              option: ThumbnailOption(
                  size: ThumbnailSize.square(width.toInt())),
            )
            : Container(),
          ],
        ),
      ),
    );
  }
}
