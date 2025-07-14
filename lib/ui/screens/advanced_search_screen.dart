import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/models/search_filters.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  late SearchFilters _filters;
  final TextEditingController _minScoreController = TextEditingController();
  final TextEditingController _maxScoreController = TextEditingController();
  final TextEditingController _minWidthController = TextEditingController();
  final TextEditingController _minHeightController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  final List<String> _selectedFileTypes = [];

  final List<String> _availableFileTypes = ['jpg', 'png', 'gif', 'webm', 'mp4'];

  @override
  void initState() {
    super.initState();
    _filters = context.read<AppState>().currentFilters;
    _initializeControllers();
  }

  void _initializeControllers() {
    _minScoreController.text = _filters.minScore?.toString() ?? '';
    _maxScoreController.text = _filters.maxScore?.toString() ?? '';
    _minWidthController.text = _filters.minWidth ?? '';
    _minHeightController.text = _filters.minHeight ?? '';
    _dateFrom = _filters.dateFrom;
    _dateTo = _filters.dateTo;
    _selectedFileTypes.addAll(_filters.fileTypes);
  }

  @override
  void dispose() {
    _minScoreController.dispose();
    _maxScoreController.dispose();
    _minWidthController.dispose();
    _minHeightController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final updatedFilters = _filters.copyWith(
      minScore: int.tryParse(_minScoreController.text.trim()),
      maxScore: int.tryParse(_maxScoreController.text.trim()),
      minWidth: _minWidthController.text.trim().isEmpty ? null : _minWidthController.text.trim(),
      minHeight: _minHeightController.text.trim().isEmpty ? null : _minHeightController.text.trim(),
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      fileTypes: List.from(_selectedFileTypes),
    );

    context.read<AppState>().updateSearchFilters(updatedFilters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _minScoreController.clear();
      _maxScoreController.clear();
      _minWidthController.clear();
      _minHeightController.clear();
      _dateFrom = null;
      _dateTo = null;
      _selectedFileTypes.clear();
    });
  }

  Future<void> _selectDate(bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2005),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minScoreController,
                            decoration: const InputDecoration(
                              labelText: 'Min Score',
                              border: OutlineInputBorder(),
                              hintText: '0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _maxScoreController,
                            decoration: const InputDecoration(
                              labelText: 'Max Score',
                              border: OutlineInputBorder(),
                              hintText: '1000',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(true),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_dateFrom != null
                                ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}'
                                : 'From Date'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(false),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(_dateTo != null
                                ? '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
                                : 'To Date'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image Resolution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minWidthController,
                            decoration: const InputDecoration(
                              labelText: 'Min Width',
                              border: OutlineInputBorder(),
                              hintText: '1920',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _minHeightController,
                            decoration: const InputDecoration(
                              labelText: 'Min Height',
                              border: OutlineInputBorder(),
                              hintText: '1080',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File Types',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _availableFileTypes.map((type) {
                        return FilterChip(
                          label: Text(type.toUpperCase()),
                          selected: _selectedFileTypes.contains(type),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFileTypes.add(type);
                              } else {
                                _selectedFileTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}