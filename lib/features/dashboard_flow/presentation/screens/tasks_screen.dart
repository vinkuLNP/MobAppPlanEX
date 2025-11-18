import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        Center(child: Text("All Tasks")),
        Center(child: Text("Pending Tasks")),
        Center(child: Text("Completed Tasks")),
      ],
    );
  }
}
