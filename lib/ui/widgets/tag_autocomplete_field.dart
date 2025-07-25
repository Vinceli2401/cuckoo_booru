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
    print('DEBUG: Searching for tags with query: $query');
    try {
      final suggestions = await _danbooruService.searchTags(
        query: query,
        limit: 8,
      );
      
      print('DEBUG: Got ${suggestions.length} suggestions: $suggestions');
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
        
        if (_showSuggestions) {
          print('DEBUG: Showing suggestions');
        } else {
          print('DEBUG: No suggestions to show');
        }
      }
    } catch (e) {
      print('DEBUG: Error searching tags: $e');
      _hideSuggestions();
    }
  }


  void _selectSuggestion(String suggestion) {
    print('DEBUG: Selected suggestion: $suggestion');
    final text = widget.controller.text;
    final words = text.split(RegExp(r'\s+'));
    
    if (words.isNotEmpty) {
      words[words.length - 1] = suggestion;
      widget.controller.text = words.join(' ');
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
      print('DEBUG: Updated text field to: ${widget.controller.text}');
    }
    
    _hideSuggestions();
    
    // Trigger search after selection
    print('DEBUG: Triggering search with: ${widget.controller.text}');
    widget.onSubmitted(widget.controller.text);
  }

  void _hideSuggestions() {
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
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
            // Removed onTapOutside to prevent interference with suggestion clicking
          ),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Material(
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
                  return GestureDetector(
                    onTap: () {
                      print('DEBUG: GestureDetector tapped for: $suggestion');
                      _selectSuggestion(suggestion);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              suggestion,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}