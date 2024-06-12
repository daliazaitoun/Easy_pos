import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class AppTable extends StatelessWidget {
  final List<DataColumn> columns;
  final DataTableSource source;
  final double minWidth;
  final int? sortColumnIndex;
  final bool sortAscending;
 // final  IconData sortArrowIcon;

  const AppTable(
      {required this.columns,
      required this.source,
      this.minWidth = 600,
      this.sortColumnIndex,
      this.sortAscending = true,
     // this.sortArrowIcon = Icons.arrow_upward,
      
    
      super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
        empty: const Center(
          child: Text('No Data Found'),
        ),
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
       // sortArrowIcon: sortArrowIcon, 
        renderEmptyRowsInTheEnd: false,
        isHorizontalScrollBarVisible: true,
        minWidth: minWidth,
        wrapInCard: false,
        rowsPerPage: 15,
        headingTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        headingRowColor:
            MaterialStatePropertyAll(Theme.of(context).primaryColor),
        border: TableBorder.all(),
        columnSpacing: 20,
        horizontalMargin: 20,
        columns: columns,
        source: source);
  }
}
