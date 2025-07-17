// lib/pages/test_units_page.dart
import 'package:flutter/material.dart';
import '../network/course_service.dart';

class TestUnitsPage extends StatefulWidget {
  const TestUnitsPage({super.key});

  @override
  State<TestUnitsPage> createState() => _TestUnitsPageState();
}

class _TestUnitsPageState extends State<TestUnitsPage> {
  List<Map<String, dynamic>> units = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedCourseId = '6871d9f070c5921f9c14610b'; // Basic Communication

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      print('🔍 Testing units for course: $selectedCourseId');
      
      final unitsData = await CourseService.getCourseUnits(selectedCourseId);
      
      print('📥 Units response: $unitsData');
      
      setState(() {
        units = unitsData ?? [];
        isLoading = false;
      });

      print('✅ Loaded ${units.length} units');
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
      print('❌ Error loading units: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Units'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUnits,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course ID input
            TextField(
              decoration: const InputDecoration(
                labelText: 'Course ID',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: selectedCourseId),
              onChanged: (value) {
                selectedCourseId = value;
              },
            ),
            const SizedBox(height: 16),
            
            // Test button
            ElevatedButton(
              onPressed: _loadUnits,
              child: const Text('Test Units Query'),
            ),
            const SizedBox(height: 16),
            
            // Results
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(errorMessage),
                  ],
                ),
              )
            else if (units.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Units Found',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('This course has no units. This could mean:'),
                    SizedBox(height: 4),
                    Text('• Units haven\'t been created yet'),
                    Text('• Units exist but are not published'),
                    Text('• Units exist but user doesn\'t have access'),
                    Text('• Backend query is not working correctly'),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    final unit = units[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(unit['title'] ?? 'No Title'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(unit['description'] ?? 'No Description'),
                            const SizedBox(height: 4),
                            Text('ID: ${unit['id']}'),
                            Text('Theme: ${unit['theme']}'),
                            Text('Lessons: ${unit['totalLessons']}'),
                            Text('Exercises: ${unit['totalExercises']}'),
                            Text('Published: ${unit['isPublished']}'),
                            Text('Premium: ${unit['isPremium']}'),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          // Show unit details
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(unit['title'] ?? 'Unit Details'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('ID: ${unit['id']}'),
                                    Text('Description: ${unit['description']}'),
                                    Text('Theme: ${unit['theme']}'),
                                    Text('Color: ${unit['color']}'),
                                    Text('Icon: ${unit['icon']}'),
                                    Text('Duration: ${unit['estimatedDuration']} min'),
                                    Text('XP Reward: ${unit['xpReward']}'),
                                    Text('Sort Order: ${unit['sortOrder']}'),
                                    Text('Published: ${unit['isPublished']}'),
                                    Text('Premium: ${unit['isPremium']}'),
                                    const SizedBox(height: 8),
                                    const Text('Raw Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(unit.toString()),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
} 