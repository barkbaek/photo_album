import 'package:flutter/material.dart';
import 'package:list_photo_album_test/selected_asset_notifier.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class ImageItemWidget extends StatefulWidget {
  ImageItemWidget({
    Key? key,
    required this.entity,
    required this.option,
    required this.useToggle,
  }) : super(key: key);

  final AssetEntity entity;
  final ThumbnailOption option;
  final bool useToggle;

  @override
  State<ImageItemWidget> createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  bool _isSelected = false;

  Widget buildContent(BuildContext context) {
    if (widget.entity.type == AssetType.audio) {
      return const Center(
        child: Icon(Icons.audiotrack, size: 30),
      );
    }
    return _buildImageWidget(widget.entity, widget.option);
  }

  Widget _buildImageWidget(AssetEntity entity, ThumbnailOption option) {
    if (_isSelected) {
      return Stack(children: [
        AssetEntityImage(
          entity,
          isOriginal: false,
          thumbnailSize: option.size,
          width: option.size.width.toDouble(),
          height: option.size.height.toDouble(),
          thumbnailFormat: option.format,
          fit: BoxFit.cover,
        ),
        widget.entity.type == AssetType.video ?
        Container(
          width: option.size.width.toDouble(),
          height: option.size.width.toDouble(),
          alignment: Alignment.center,
          child: Icon(
            Icons.play_arrow,
            color: Colors.black,
            size: 40,
          ),
        ) : Container(),
        Container(
          width: option.size.width.toDouble(),
          height: option.size.width.toDouble(),
          alignment: Alignment.center,
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 30,
          ),
        ),
      ]);
    } else if (widget.entity.type == AssetType.video) {
      return Stack(children: [
        AssetEntityImage(
          entity,
          isOriginal: false,
          thumbnailSize: option.size,
          width: option.size.width.toDouble(),
          height: option.size.height.toDouble(),
          thumbnailFormat: option.format,
          fit: BoxFit.cover,
        ),
        widget.entity.type == AssetType.video ?
        Container(
          width: option.size.width.toDouble(),
          height: option.size.width.toDouble(),
          alignment: Alignment.center,
          child: Icon(
            Icons.play_arrow,
            color: Colors.black,
            size: 40,
          ),
        ) : Container(),
      ]);
    } else {
      return AssetEntityImage(
        entity,
        isOriginal: false,
        thumbnailSize: option.size,
        width: option.size.width.toDouble(),
        height: option.size.height.toDouble(),
        thumbnailFormat: option.format,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<SelectedAssetNotifier>(
      builder: (context, selectedAssetNotifier, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (widget.useToggle) {
              if (!_isSelected) {
                selectedAssetNotifier.insertSelectedAsset(widget.entity);
              } else {
                selectedAssetNotifier.deleteSelectedAsset(widget.entity);
              }
              setState(() {
                _isSelected = !_isSelected;
              });
            }
          },
          child: buildContent(context),
        );
      }
    );
  }
}
