import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/centrix_page_header.dart';

import '../../auth/viewmodels/auth_view_model.dart';
import '../models/ticket_priority.dart';
import '../viewmodels/create_ticket_view_model.dart';

class CreateTicketView extends StatefulWidget {
  const CreateTicketView({super.key});

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<CreateTicketViewModel>().submit(
      title: _titleController.text,
      description: _descriptionController.text,
      token: context.read<AuthViewModel>().session!.token,
    );
  }

  void _createAnother() {
    _titleController.clear();
    _descriptionController.clear();
    context.read<CreateTicketViewModel>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    final viewModel = context.watch<CreateTicketViewModel>();
    final token = auth.session!.token;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear ticket')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: _content(context, viewModel, auth, token),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    CreateTicketViewModel viewModel,
    AuthViewModel auth,
    String token,
  ) {
    if (viewModel.isLoadingDepartments) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.departments.isEmpty) {
      return _StatusMessage(
        icon: viewModel.errorMessage == null
            ? Icons.apartment_outlined
            : Icons.cloud_off_outlined,
        title: viewModel.requiresLogin
            ? 'Sesión vencida'
            : viewModel.errorMessage == null
            ? 'No hay departamentos disponibles'
            : 'No pudimos cargar los departamentos',
        message:
            viewModel.errorMessage ??
            'Necesitas un departamento para crear un ticket.',
        buttonLabel: viewModel.requiresLogin
            ? 'Volver a iniciar sesión'
            : 'Actualizar',
        onPressed: viewModel.requiresLogin
            ? auth.logout
            : () => viewModel.loadDepartments(token),
      );
    }
    if (viewModel.createdTicketId != null) {
      return _SuccessMessage(
        ticketId: viewModel.createdTicketId!,
        onCreateAnother: _createAnother,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CentrixPageHeader(
              title: 'Nueva incidencia',
              description: 'Describe el problema y selecciona el departamento que lo atenderá.',
              icon: Icons.add_task_rounded,
              eyebrow: 'CREAR TICKET',
            ),
            const SizedBox(height: 28),
            TextFormField(
              key: const Key('ticket-title'),
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingresa un título'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('ticket-description'),
              controller: _descriptionController,
              minLines: 4,
              maxLines: 7,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Describe la incidencia'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TicketPriority>(
              key: const Key('ticket-priority'),
              initialValue: viewModel.selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final priority in TicketPriority.values)
                  DropdownMenuItem(
                    value: priority,
                    child: Text(priority.label),
                  ),
              ],
              onChanged: viewModel.isSubmitting
                  ? null
                  : viewModel.selectPriority,
              validator: (value) =>
                  value == null ? 'Selecciona una prioridad' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('ticket-department'),
              initialValue: viewModel.selectedDepartmentId,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final department in viewModel.departments)
                  DropdownMenuItem(
                    value: department.departmentId,
                    child: Text(department.name),
                  ),
              ],
              onChanged: viewModel.isSubmitting
                  ? null
                  : viewModel.selectDepartment,
              validator: (value) =>
                  value == null ? 'Selecciona un departamento' : null,
            ),
            if (viewModel.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              if (viewModel.requiresLogin)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: auth.logout,
                    child: const Text('Volver a iniciar sesión'),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: viewModel.isSubmitting ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: viewModel.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({
    required this.ticketId,
    required this.onCreateAnother,
  });

  final String ticketId;
  final VoidCallback onCreateAnother;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Ticket creado',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'La incidencia se registró correctamente.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SelectableText(
              'ID del ticket: $ticketId',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/tickets/$ticketId'),
              icon: const Icon(Icons.attach_file),
              label: const Text('Ver ticket y adjuntar evidencia'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onCreateAnother,
              child: const Text('Crear otro ticket'),
            ),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Volver al dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
