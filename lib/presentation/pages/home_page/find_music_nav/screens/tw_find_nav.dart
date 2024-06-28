import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:group_button/group_button.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';
import 'package:tidal_wave/data/result.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:tidal_wave/presentation/pages/home_page/find_music_nav/widgets/music_element_view.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/icon_button_music.dart';
import 'package:tidal_wave/presentation/pages/lista_musica/widgets/text_field_find.dart';
import 'package:tidal_wave/domain/models/music.dart';

class TWFindNav extends StatefulWidget {
  const TWFindNav({super.key});

  @override
  State<TWFindNav> createState() => _TWFindNavState();
}


class _TWFindNavState extends State<TWFindNav> {

  final _scrollController = ScrollController();

  final _musicManagerUseCase = GetIt.I<MusicManagerUseCase>();
  String? selectUUID;
  DataSourceType _selectedType = DataSourceType.online;

  static final _buttonsController = GroupButtonController(selectedIndex: 0);
  static final _buttonsOptions = ['Musicas publicas', 'Mis musicas descargadas'];


  final List<Music> _allData = [];
  Music? _lastItem;
  bool _hasMore = true;
  bool _loading = false;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchData(DataSourceType.online);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener(){
    if(!_loading && _hasMore && _scrollController.position.pixels == _scrollController.position.maxScrollExtent){
      _fetchData(_selectedType);
    }
  }

  Future<void> _fetchData(DataSourceType dataSourceType) async{
    if(_loading || !_hasMore) return;
    _loading = true;

    _lastItem = _allData.isNotEmpty ? _allData.last : null;

    final newData = await listOfMusic(dataSourceType, lastItem: _lastItem);
    setState(() {
      _allData.addAll(newData);
      if(newData.length < _limit){_hasMore = false;}
      _loading = false;
    });
  }

  void _findMusic(String query){
    setState(() {
      // _list = widget.listado.where((element) {
      //   if (value.trim().isEmpty) {
      //     return true;
      //   }
      //   return element.titulo.toLowerCase().contains(value.toLowerCase().trim()) ||
      //         element.artistasStr.toLowerCase().contains(value.toLowerCase().trim());

      // }).toList();      
    });
  }

  Future<List<Music>> listOfMusic(DataSourceType dataSourceType, {Music? lastItem}) async {
    late final Result<List<Music>> result;
    if(dataSourceType == DataSourceType.online){
      result = await _musicManagerUseCase.obtenerMusicasPublicas(lastItem: lastItem, limit: _limit);
    }
    else{
      result = await _musicManagerUseCase.obtenerMusicasDescargadas(limit: _limit);
    }
    if(result.onSuccess){return result.data!.toList();}
    throw Exception(result.errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      controller: _scrollController,
      slivers: [

        //* Barra de busqueda
        SliverAppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFieldFind(
                  hintText:'Buscar cancion...',
                  suffixIcon: IconButtonUIMusic(
                    borderColor: Colors.blue.shade400.withAlpha(50),
                    borderSize: 2.0,
                    fillColor: Colors.transparent,
                    icon: const Icon(Icons.search, size: 25),
                    onTap: () {},
                  ),
                  onChanged: _findMusic
                ),
              )
            ),
          ],
        ),
    
        SliverToBoxAdapter(child: 
        
        //* Seleccionar entre 2 opciones
        GroupButton(
          controller: _buttonsController,
          buttonIndexedBuilder: (selected, index, context) => ElevatedButton(
            onPressed: (){
              setState(() {
                _buttonsController.selectIndex(index);
                _allData.clear();
                _lastItem = null;
                _hasMore = true;
                _loading = false;
                _selectedType = index == 0 ? DataSourceType.online : DataSourceType.local;
                _fetchData(_selectedType);
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateColor.resolveWith((states) => selected ? const Color.fromARGB(255, 36, 161, 196) : const Color.fromARGB(255, 20, 84, 101))
            ),
            child: Text(_buttonsOptions[index], style: TextStyle(color: selected ? Colors.white : Colors.grey.shade300))
          ),
          isRadio: true,
          buttons: _buttonsOptions
        )
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),
    
        FutureBuilder(
          future: _fetchData(_selectedType),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));}
            if(snapshot.hasError) {return SliverToBoxAdapter(child: Center(child: Text('Ha ocurrido un error ${snapshot.error.toString()}')));}
            if(_allData.isEmpty) {return const SliverToBoxAdapter(child: Center(child: Text('No hay canciones por el momento')));}
            return StatefulBuilder(
              builder: (context, setState) {
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1
                  ),
                  delegate: SliverChildBuilderDelegate(childCount: _allData.length + (_hasMore ? 1 : 0), (context, index) {
                    final item = _allData[index];
                    if(index < _allData.length){
                      return Builder(
                        builder: (context) {
                          return MusicElementView(
                            item: item,
                            selected: [item.uuid == selectUUID],
                            onPlay: () {
                              selectUUID = item.uuid;
                              setState(() {});
                            },
                            isOnline: _selectedType == DataSourceType.online,
                          );
                        }
                      );
                    }
                    else{
                      if(_hasMore){
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        );
                      }
                      else {return const SizedBox.shrink();}
                    }
                  }),
                );
              }
            );
          }
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }
}
