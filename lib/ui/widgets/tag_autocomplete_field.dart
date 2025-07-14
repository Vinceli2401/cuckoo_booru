import 'package:flutter/material.dart';
import 'package:cuckoo_booru/danbooru_service.dart';
import 'dart:async';

class TagAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final String hintText;
  final Widget? prefixIcon;

  const TagAutocompleteField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.hintText = 'Search tags',
    this.prefixIcon,
  });

  @override
  State<TagAutocompleteField> createState() => _TagAutocompleteFieldState();
}

class _TagAutocompleteFieldState extends State<TagAutocompleteField> {
  final DanbooruService _danbooruService = DanbooruService();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];
  Timer? _debounceTimer;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    _danbooruService.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final lastWord = _getLastWord(text);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (lastWord.length >= 2) {
        _searchTags(lastWord);
      } else {
        _hideSuggestions();
      }
    });
  }

  String _getLastWord(String text) {
    final words = text.split(RegExp(r'\s+'));
    return words.isNotEmpty ? words.last : '';
  }

  Future<void> _searchTags(String query) async {
    try {
      final suggestions = await _danbooruService.searchTags(
        query: query,
        limit: 8,
      );
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
        
        if (_showSuggestions) {
          _showOverlay();
        } else {
          _hideOverlay();
        }
      }
    } catch (e) {
      _hideSuggestions();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getTextFieldWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () => _selectSuggestion(suggestion),
                    hoverColor: Theme.of(context).colorScheme.primaryContainer,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectSuggestion(String suggestion) {
    final text = widget.controller.text;
    final words = text.split(RegExp(r'\s+'));
    
    if (words.isNotEmpty) {
      words[words.length - 1] = suggestion;
      widget.controller.text = words.join(' ');
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
    }
    
    _hideSuggestions();
  }

  void _hideSuggestions() {
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });
    _hideOverlay();
  }

  void _hideOverlay() {
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getTextFieldWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          prefixIcon: widget.prefixIcon,
          suffixIcon: _showSuggestions
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _hideSuggestions,
                )
              : null,
        ),
        onSubmitted: (value) {
          _hideSuggestions();
          widget.onSubmitted(value);
        },
        onTapOutside: (_) => _hideSuggestions(),
      ),
    );
  }
}