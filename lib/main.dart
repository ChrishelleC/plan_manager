import 'package:flutter/material.dart';

void main() {
  runApp(PlanManagerApp());
}

class PlanManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlanManagerScreen(),
    );
  }
}


class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;
  String priority;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.priority = 'Medium',
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = []; 

  
  void _addPlan(String name, String description, DateTime date, String priority) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date, priority: priority));
      _sortPlans();
    });
  }

  
  void _editPlan(int index, String name, String description, DateTime date, String priority) {
    setState(() {
      plans[index] = Plan(name: name, description: description, date: date, priority: priority);
      _sortPlans();
    });
  }

  // Toggle completion status of a plan
  void _toggleComplete(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  // Delete a plan
  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  // Sort plans based on priority
  void _sortPlans() {
    plans.sort((a, b) {
      const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });
  }

  // Show a dialog for adding/editing a plan
  void _showPlanDialog({int? index}) {
    final TextEditingController nameController = TextEditingController(text: index != null ? plans[index].name : '');
    final TextEditingController descriptionController = TextEditingController(text: index != null ? plans[index].description : '');
    DateTime selectedDate = index != null ? plans[index].date : DateTime.now();
    String priority = index != null ? plans[index].priority : 'Medium';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Create Plan' : 'Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Plan Name')),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
              DropdownButton<String>(
                value: priority,
                items: ['High', 'Medium', 'Low'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    priority = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (index == null) {
                  _addPlan(nameController.text, descriptionController.text, selectedDate, priority);
                } else {
                  _editPlan(index, nameController.text, descriptionController.text, selectedDate, priority);
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Manager')),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return GestureDetector(
            onDoubleTap: () => _deletePlan(index), // Delete plan on double tap
            onLongPress: () => _showPlanDialog(index: index), // Edit plan on long press
            child: Dismissible(
              key: Key(plan.name),
              onDismissed: (_) => _toggleComplete(index), // Swipe to mark complete
              background: Container(color: Colors.green, alignment: Alignment.centerLeft, child: Icon(Icons.check, color: Colors.white)),
              secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.white)),
              child: ListTile(
                title: Text(plan.name, style: TextStyle(decoration: plan.isCompleted ? TextDecoration.lineThrough : null)),
                subtitle: Text('Priority: ${plan.priority} | ${plan.description}'),
                tileColor: plan.isCompleted ? Colors.green[100] : Colors.white,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanDialog(), // Open dialog to create a plan
        child: Icon(Icons.add),
      ),
    );
  }
}
