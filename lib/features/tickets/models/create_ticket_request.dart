import 'ticket_priority.dart';

class CreateTicketRequest {
  const CreateTicketRequest({
    required this.title,
    required this.description,
    required this.priority,
    required this.departmentId,
  });

  final String title;
  final String description;
  final TicketPriority priority;
  final String departmentId;

  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'description': description.trim(),
    'priority': priority.apiValue,
    'department_id': departmentId,
  };
}
