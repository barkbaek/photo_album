import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'model/photo_provider.dart';
import 'widget/image_item_widget.dart';
import 'dart:math';

final PhotoProvider provider = PhotoProvider();

void main() => runApp(const _SimpleExampleApp());

class _SimpleExampleApp extends StatelessWidget {
  const _SimpleExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ChangeNotifierProvider<PhotoProvider>.value(
        value: provider, // This is for the advanced usages.
        child: const MaterialApp(home: _SimpleExamplePage()),
      ),
    );
  }
}

class _SimpleExamplePage extends StatefulWidget {
  const _SimpleExamplePage({Key? key}) : super(key: key);

  @override
  _SimpleExamplePageState createState() => _SimpleExamplePageState();
}

class _SimpleExamplePageState extends State<_SimpleExamplePage> {
  /// Customize your own filter options.
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );
  final int _sizePerPage = 50;

  String? _selectedFolderId;
  List<AssetPathEntity>? _paths;
  AssetPathEntity? _path;
  List<AssetEntity>? _entities;
  List _folders = [];
  int _totalEntitiesCount = 0;
  bool _isOpened = false;

  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;

  @override
  void initState() {
    super.initState();
    _requestAssets();
  }

  void changeSelectedFolder(id) {
    print(id);
    setState(() {
      _selectedFolderId = id;
    });
    _requestAssets();
  }

  Future<void> _requestAssets() async {
    setState(() {
      _isLoading = true;
    });
    // Request permissions.
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    // Further requests can be only procceed with authorized or limited.
    if (_ps != PermissionState.authorized && _ps != PermissionState.limited) {
      setState(() {
        _isLoading = false;
      });
      showToast('Permission is not granted.');
      return;
    }
    // Obtain assets using the path entity.
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        // onlyAll: true,
        // filterOption: _filterOptionGroup,
        );
    print("paths are : ");
    print(paths);
    if (!mounted) {
      return;
    }
    // Return if not paths found.
    if (paths.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      showToast('No paths found.');
      return;
    }

    List folders = [];
    String selectedFolderId = "";
    AssetPathEntity currentPath = paths.first;
    for (int i = 0; i < paths.length; i++) {
      AssetPathEntity path = paths[i];
      if (i == 0) {
        if (_selectedFolderId == null) {
          selectedFolderId = path.id;
          currentPath = path;
        } else {
          _selectedFolderId = _selectedFolderId;
        }
      }
      if (_selectedFolderId == path.id) {
        currentPath = path;
      }
      final List<AssetEntity> entities =
          await path.getAssetListPaged(page: 0, size: 1);
      final AssetEntity entity = entities[0];
      folders.add(GestureDetector(
        onTap: () {
          changeSelectedFolder(path.id);
        },
        child: ListTile(
          leading: ImageItemWidget(
            key: ValueKey<int>(new Random().nextInt(1000)),
            entity: entity,
            option: const ThumbnailOption(size: ThumbnailSize.square(50)),
          ),
          title: Text(path.name),
          trailing: Text(
            _selectedFolderId == null
                ? (selectedFolderId == path.id ? "✔" : "")
                : (_selectedFolderId == path.id ? "✔" : ""),
            style: TextStyle(
              color: Colors.lightBlue,
            ),
          ),
        ),
      ));
    }

    setState(() {
      _selectedFolderId = selectedFolderId;
      _folders = folders;
      _paths = paths;
      _path = currentPath;
    });
    _totalEntitiesCount = _path!.assetCount;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entities = entities;
      _isLoading = false;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _entities!.addAll(entities);
      _page++;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_path == null) {
      return const Center(child: Text('Request paths first.'));
    }
    if (_entities?.isNotEmpty != true) {
      return const Center(child: Text('No assets found on this device.'));
    }
    return GridView.custom(
      padding: EdgeInsets.all(0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == _entities!.length - 8 &&
              !_isLoadingMore &&
              _hasMoreToLoad) {
            _loadMoreAsset();
          }
          final AssetEntity entity = _entities![index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ImageItemWidget(
              key: ValueKey<int>(index),
              entity: entity,
              option: const ThumbnailOption(size: ThumbnailSize.square(200)),
            ),
          );
        },
        childCount: _entities!.length,
        findChildIndexCallback: (Key key) {
          // Re-use elements.
          if (key is ValueKey<int>) {
            return key.value;
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: DefaultTabController(
              length: 4,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    "사진과 동영상 추가",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(30.0),
                    child: TabBar(
                      isScrollable: true,
                      labelColor: Colors.black,
                      indicatorColor: Colors.greenAccent,
                      unselectedLabelColor: Colors.grey,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 5.0,
                          color: Colors.greenAccent,
                        ),
                      ),
                      tabs: <Widget>[
                        Container(
                          width: 100.0,
                          child: Tab(text: "내 미디어"),
                        ),
                        Container(
                          width: 100.0,
                          child: Tab(text: "Google Photo"),
                        ),
                        Container(
                          width: 100.0,
                          child: Tab(text: "스톡"),
                        ),
                        Container(
                          width: 100.0,
                          child: Tab(text: "최근항목"),
                        ),
                      ],
                    ),
                  ),
                ),
                body: Container(
                  height: 400,
                  child: TabBarView(
                    children: <Widget>[
                      Tab(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isOpened = !_isOpened;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 20.0),
                                  child: Container(
                                      child: Row(
                                    children: [
                                      Text(_path != null ? _path!.name : ""),
                                      _isOpened
                                          ? Icon(Icons.arrow_drop_up_outlined)
                                          : Icon(
                                              Icons.arrow_drop_down_outlined),
                                    ],
                                  )),
                                ),
                              ),
                            ),
                            _isOpened
                                ? Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(4),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount:
                                          _paths != null ? _paths!.length : 0,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return _folders[index];
                                      },
                                    ),
                                  )
                                : Container(height: 0),
                          ],
                        ),
                      ),
                      Tab(child: Container()),
                      Tab(child: Container()),
                      Tab(child: Container())
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: _isOpened ? MediaQuery.of(context).size.height - 470 : MediaQuery.of(context).size.height - 170,
            child: _buildBody(context),
          ),
        ],
      ),
      // persistentFooterButtons: <TextButton>[
      //   TextButton(
      //     onPressed: () {
      //       Navigator.of(context).push<void>(
      //         MaterialPageRoute<void>(builder: (_) => const IndexPage()),
      //       );
      //     },
      //     child: const Text('Advanced usages'),
      //   ),
      // ],
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _requestAssets,
      //   child: const Icon(Icons.developer_board),
      // ),
    );
  }
}
