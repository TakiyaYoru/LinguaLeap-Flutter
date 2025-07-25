import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../network/lesson_reorder_service.dart';

class LessonReorderWidget extends StatefulWidget {
  final String unitId;
  final String unitTitle;

  const LessonReorderWidget({
    Key? key,
    required this.unitId,
    required this.unitTitle,
  }) : super(key: key);

  @override
  State<LessonReorderWidget> createState() => _LessonReorderWidgetState();
}

class _LessonReorderWidgetState extends State<LessonReorderWidget> {
  final LessonReorderService _reorderService = LessonReorderService();
  List<dynamic> _lessons = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _reorderService.getUnitLessonsForAdmin(widget.unitId);
      
      if (result['success']) {
        setState(() {
          _lessons = _reorderService.sortLessonsByOrder(result['lessons']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load lessons: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNewOrder() async {
    if (_lessons.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final lessonIds = _reorderService.extractLessonIds(_lessons);
      final result = await _reorderService.reorderLessons(widget.unitId, lessonIds);
      
      if (result['success']) {
        // Refresh lessons để lấy sortOrder mới
        await _loadLessons();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _moveLesson(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    setState(() {
      final lesson = _lessons.removeAt(oldIndex);
      _lessons.insert(newIndex, lesson);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reorder Lessons - ${widget.unitTitle}'),
        actions: [
          if (!_isLoading && _lessons.isNotEmpty)
            IconButton(
              icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveNewOrder,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLessons,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _lessons.isEmpty
                  ? const Center(
                      child: Text('No lessons found'),
                    )
                  : ReorderableListView.builder(
                      itemCount: _lessons.length,
                      onReorder: _moveLesson,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index];
                        return Card(
                          key: ValueKey(lesson['id']),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(lesson['title'] ?? 'Untitled'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type: ${lesson['type'] ?? 'Unknown'}'),
                                Text('Sort Order: ${lesson['sortOrder'] ?? 0}'),
                                Text('Status: ${lesson['isPublished'] ? 'Published' : 'Draft'}'),
                              ],
                            ),
                            trailing: const Icon(Icons.drag_handle),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
} 