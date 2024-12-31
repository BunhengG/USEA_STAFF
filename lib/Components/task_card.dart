import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usea_staff_test/constant/constant.dart';

import '../provider/task_provider.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: mdMargin),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(roundedCornerSM),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Lorem Ipsum', style: getSubTitle()),
                  Text('See All', style: getSubTitle().copyWith(fontSize: 15)),
                ],
              ),
              const SizedBox(height: smPadding),
              Text(
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry...',
                style: getBody().copyWith(fontSize: 12),
              ),
              const SizedBox(height: smPadding),
              CheckboxListTile(
                checkColor: secondaryColor,
                activeColor: primaryColor,
                title: Text(
                  tasks[index].title,
                  style: getBody().copyWith(
                    decoration: tasks[index].isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                value: tasks[index].isCompleted,
                onChanged: (_) {
                  Provider.of<TaskProvider>(context, listen: false)
                      .toggleTaskStatus(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
