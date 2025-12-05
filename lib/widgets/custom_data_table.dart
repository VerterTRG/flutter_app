import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDataTable<T> extends StatefulWidget {
  final List<String> columns;
  final List<T> data;
  final List<Widget> Function(T item) rowBuilder;
  final Function(T item)? onRowTap;
  final Function(T item)? onRowDoubleTap;
  final Function(int columnIndex, bool ascending)? onSort;
  final ScrollController? scrollController;
  final List<T> selectedItems;
  final Function(List<T> selectedItems)? onSelectionChanged;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.rowBuilder,
    this.onRowTap,
    this.onRowDoubleTap,
    this.onSort,
    this.scrollController,
    this.selectedItems = const [],
    this.onSelectionChanged,
  });

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(CustomDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItems != oldWidget.selectedItems) {
      setState(() {
         _selectedItems = List.from(widget.selectedItems);
      });
    }
  }

  void _onRowTap(T item) {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final isMultiSelect = keys.contains(LogicalKeyboardKey.controlLeft) ||
                          keys.contains(LogicalKeyboardKey.controlRight) ||
                          keys.contains(LogicalKeyboardKey.metaLeft) ||
                          keys.contains(LogicalKeyboardKey.metaRight);

    setState(() {
      if (isMultiSelect) {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      } else {
        if (!_selectedItems.contains(item) || _selectedItems.length > 1) {
           _selectedItems = [item];
        }
      }
    });

    widget.onSelectionChanged?.call(_selectedItems);
    widget.onRowTap?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          children: List.generate(widget.columns.length, (index) {
            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_sortColumnIndex == index) {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortColumnIndex = index;
                      _sortAscending = true;
                    }
                  });
                  widget.onSort?.call(index, _sortAscending);
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    color: Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      Text(
                        widget.columns[index],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_sortColumnIndex == index)
                        Icon(
                          _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        // List
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: widget.data.length,
            itemBuilder: (context, index) {
              final item = widget.data[index];
              final isSelected = _selectedItems.contains(item);
              final rowContent = widget.rowBuilder(item);

              return InkWell(
                onTap: () => _onRowTap(item),
                onDoubleTap: () => widget.onRowDoubleTap?.call(item),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : null,
                    border: isSelected ? Border.all(color: Colors.blue, width: 2) : Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: rowContent.asMap().entries.map((entry) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: entry.value,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
