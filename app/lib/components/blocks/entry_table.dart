import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../model/entry_model.dart' as EntryModel;
import '../../model/entry_table_model.dart';
import '../parts/entry_dialog.dart' as EntryDialog;
import '../../view_model/providers.dart';

class EntryStatusTable extends HookConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    EntryTable _entryTable = ref.watch(entryTableStateNotifierProvider);
    var _screenSize = MediaQuery.of(context).size;
    List<PlutoColumn> _columnList = this.getEntryColumns(_screenSize.width);

    return (() {
          if (_entryTable.entries.length == 0) {
          // 初期化後、通信中
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return PlutoGrid(
                columns: _columnList,
                rows: _entryTable.entries.map((EntryModel.EntryModel entry) => PlutoRow(
                  cells: this.mapToDataCells(_screenSize.width, entry)
                )).toList(),
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  event.stateManager.setSelectingMode(PlutoGridSelectingMode.row);
                },
                rowColorCallback: (PlutoRowColorContext rowColorContext) {
                  String status = rowColorContext.row.cells['status']?.value;
                  Color color = Colors.white;
                  if (status=="succeeded"){
                    color = Color(0xFFE2F6DF);
                  } else if (status=="error"){
                    color = Color(0xFFFADBDF);
                  }
                  return color;
                }
          );
        }
        )();
  }
   
  List<PlutoColumn> getEntryColumns(var width){
    List<PlutoColumn> res = [
      PlutoColumn(
        title: 'Created at',
        field: 'created_at',
        type: PlutoColumnType.text()
      ),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text()
      ),
      PlutoColumn(
        title: 'URL',
        field: 'repository_url',
        type: PlutoColumnType.text()
      ),
      PlutoColumn(
        title: 'Branch',
        field: 'branch',
        type: PlutoColumnType.text()
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text()
      ),
      PlutoColumn(
        title: 'Level',
        field: 'level',
        type: PlutoColumnType.number()
      ),
      PlutoColumn(
        title: 'GameMode',
        field: 'game_mode',
        type: PlutoColumnType.text()
      ),
      PlutoColumn(
        title: 'ErrorMessage',
        field: 'error_message',
        type: PlutoColumnType.text()
      ),
    ];
    return res;
  }

  Map<String, PlutoCell> mapToDataCells(var width, EntryModel.EntryModel entry){
    Map<String, PlutoCell> cells = {
      'created_at': PlutoCell(value: EntryModel.datetimeToString(entry.created_at)),
      'name': PlutoCell(value: entry.name),
      'level': PlutoCell(value: entry.level),
      'repository_url': PlutoCell(value: entry.repository_url),
      'branch': PlutoCell(value: entry.branch),
      'status': PlutoCell(value: entry.status),
      'game_mode': PlutoCell(value: entry.game_mode),
      'error_message': PlutoCell(value: entry.error_message),
    };
    return cells;
  }
}