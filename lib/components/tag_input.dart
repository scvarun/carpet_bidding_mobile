import 'package:flutter/material.dart';

typedef _OnAdd = void Function(String v);
typedef _OnRemove = void Function(int index);
typedef _OnSuggestionSelect<T> = void Function(T item);
typedef _Builder<T> = Widget Function(T item, int index);

class TagInput<T> extends StatefulWidget {
  final bool multiple;
  final _OnAdd? onAdd;
  final _OnRemove? onRemove;
  final VoidCallback? onClear;
  final List<T> selectedValues;
  final List<T> values;
  final double spacing;
  final _Builder<T> build;
  final _Builder<T> suggestionBuilder;
  final _OnSuggestionSelect<T> onSuggestionSelect;
  final String title;

  const TagInput({
    Key? key,
    this.multiple = true,
    this.onAdd,
    this.onRemove,
    this.onClear,
    required this.selectedValues,
    required this.values,
    required this.build,
    required this.suggestionBuilder,
    required this.onSuggestionSelect,
    required this.title,
    this.spacing = 10,
  }) : super(key: key);

  @override
  _TagInputState<T> createState() => _TagInputState<T>();
}

class _TagInputState<T> extends State<TagInput<T>> {
  final _inputController = TextEditingController();
  final _inputFocus = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(() {
      setState(() {
        _showSuggestions = !_showSuggestions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var inputDecoration = Theme.of(context).inputDecorationTheme;
    InputBorder? inputBorder = inputDecoration.border;
    Widget render;

    if (widget.multiple) {
      render = Wrap(
        spacing: widget.spacing,
        runSpacing: widget.spacing,
        children: [
          ...widget.selectedValues
              .asMap()
              .keys
              .map((e) => _renderTag(context, e))
              .toList(),
          _field(context),
        ],
      );
    } else {
      render = Stack(
        children: [
          widget.selectedValues.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    if (widget.onClear != null) widget.onClear!();
                  },
                  child: widget.build(widget.selectedValues[0], 0))
              : Container(),
          widget.selectedValues.isEmpty ? _field(context) : Container(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
          decoration: BoxDecoration(
            border: Border(
              top: inputBorder!.borderSide,
              bottom: inputBorder.borderSide,
              right: inputBorder.borderSide,
              left: inputBorder.borderSide,
            ),
          ),
          child: render,
        ),
        _showSuggestions ? _suggestionList(context) : Container(),
      ],
    );
  }

  Widget _renderTag(BuildContext context, int e) {
    return Stack(
      children: [
        Container(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, right: 30, left: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(5)),
            child: widget.build(widget.selectedValues[e], e)),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              child: TextButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder(
                          side: BorderSide(width: 1, color: Colors.white))),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      minimumSize:
                          MaterialStateProperty.all(const Size.fromWidth(0))),
                  onPressed: () {
                    widget.onRemove!(e);
                  },
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.white,
                  )),
            ),
          ),
        )
      ],
    );
  }

  Widget _field(BuildContext context) {
    return TextField(
        focusNode: _inputFocus,
        controller: _inputController,
        autocorrect: false,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            widget.onAdd!(value);
            _inputController.clear();
          }
        },
        decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: widget.title,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            border: InputBorder.none,
            errorBorder: InputBorder.none,
            suffix: GestureDetector(
              onTap: () {
                _inputController.clear();
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.red,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            )));
  }

  Widget _suggestionList(BuildContext context) {
    List<T> list = widget.values;
    list = list.where((item) => !widget.selectedValues.contains(item)).toList();
    return Container(
      color: Colors.white,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: widget.suggestionBuilder(list[index], index),
            onTap: () {
              widget.onSuggestionSelect(list[index]);
              _inputFocus.unfocus();
            },
          );
        },
      ),
    );
  }
}
