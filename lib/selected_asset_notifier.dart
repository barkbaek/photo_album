import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectedAssetNotifier extends ChangeNotifier {
  final Set<AssetEntity> _selectedAsset = <AssetEntity>{};

  void insertSelectedAsset(AssetEntity newAsset) {
    _selectedAsset.add(newAsset);
    notifyListeners();
  }

  void deleteSelectedAsset(AssetEntity asset) {
    _selectedAsset.remove(asset);
    notifyListeners();
  }

  void clearSelectedAsset() {
    _selectedAsset.clear();
    notifyListeners();
  }

  Set<AssetEntity> get selectedAsset => _selectedAsset;
}