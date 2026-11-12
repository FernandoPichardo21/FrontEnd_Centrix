import 'package:flutter/material.dart';

import '../../../../core/theme/centrix_theme.dart';
import '../../../../core/widgets/centrix_glass.dart';
import '../../models/manager_request.dart';
import '../../viewmodels/manager_view_model.dart';

String managerMoney(int cents) {
  final whole = (cents.abs() ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${cents < 0 ? '-' : ''}\$$whole.${(cents.abs() % 100).toString().padLeft(2, '0')}';
}

String managerDate(DateTime date) =>
    '${date.day} ${const ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'][date.month - 1]} ${date.year}';

IconData managerSectionIcon(ManagerSection section) => switch (section) {
  ManagerSection.approvals => Icons.fact_check_outlined,
  ManagerSection.budget => Icons.account_balance_wallet_outlined,
  ManagerSection.requests => Icons.folder_open_rounded,
  ManagerSection.reports => Icons.bar_chart_rounded,
};
IconData managerCategoryIcon(ManagerCategory category) => switch (category) {
  ManagerCategory.equipment => Icons.devices_rounded,
  ManagerCategory.software => Icons.layers_outlined,
  ManagerCategory.operations => Icons.inventory_2_outlined,
  ManagerCategory.maintenance => Icons.build_outlined,
};

class ManagerCard extends StatelessWidget {
  const ManagerCard({
    super.key,
    required this.child,
    this.dark = false,
    this.padding = 24,
  });
  final Widget child;
  final bool dark;
  final double padding;
  @override
  Widget build(BuildContext context) => CentrixGlass(
    dark: dark,
    child: Padding(padding: EdgeInsets.all(padding), child: child),
  );
}

class ManagerPageTitle extends StatelessWidget {
  const ManagerPageTitle({
    super.key,
    required this.title,
    required this.description,
    this.action,
  });
  final String title;
  final String description;
  final Widget? action;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final text = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUPERVISIÓN / OPERACIONES',
            style: TextStyle(
              color: CentrixColors.leaf,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: CentrixColors.forest, height: 1.5),
          ),
        ],
      );
      if (constraints.maxWidth < 700) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text,
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: text),
          if (action != null) ...[const SizedBox(width: 20), action!],
        ],
      );
    },
  );
}

class ManagerStat extends StatelessWidget {
  const ManagerStat({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    this.highlight = false,
  });
  final String label, value, caption;
  final IconData icon;
  final bool highlight;
  @override
  Widget build(BuildContext context) => ManagerCard(
    dark: highlight,
    padding: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: highlight ? CentrixColors.mint : CentrixColors.forest,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: highlight ? CentrixColors.sage : CentrixColors.leaf,
            ),
          ],
        ),
        const SizedBox(height: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 30,
              letterSpacing: -1,
              fontWeight: FontWeight.w800,
              color: highlight ? Colors.white : CentrixColors.mint,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          style: TextStyle(
            fontSize: 11,
            color: highlight ? CentrixColors.sage : CentrixColors.forest,
          ),
        ),
      ],
    ),
  );
}

class ManagerStats extends StatelessWidget {
  const ManagerStats({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900
          ? children.length
          : constraints.maxWidth >= 480
          ? 2
          : 1;
      final width = (constraints.maxWidth - 14 * (columns - 1)) / columns;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: children
            .map((child) => SizedBox(width: width, child: child))
            .toList(),
      );
    },
  );
}

class ManagerStatusChip extends StatelessWidget {
  const ManagerStatusChip(this.status, {super.key});
  final ManagerRequestStatus status;
  @override
  Widget build(BuildContext context) {
    final (color, background, icon) = switch (status) {
      ManagerRequestStatus.pending => (
        const Color(0xFFFFB97D),
        const Color(0xFF3A2918),
        Icons.schedule_rounded,
      ),
      ManagerRequestStatus.approved => (
        CentrixColors.leaf,
        const Color(0xFF133C26),
        Icons.check_circle_outline_rounded,
      ),
      ManagerRequestStatus.rejected => (
        const Color(0xFFFF9BA9),
        const Color(0xFF3B1F25),
        Icons.cancel_outlined,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ManagerEmpty extends StatelessWidget {
  const ManagerEmpty({super.key, required this.title, required this.message});
  final String title, message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(30),
    child: Column(
      children: [
        const Icon(Icons.task_alt_rounded, size: 44, color: CentrixColors.leaf),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: CentrixColors.forest, height: 1.5),
        ),
      ],
    ),
  );
}

class ManagerRequestDetail extends StatelessWidget {
  const ManagerRequestDetail({
    super.key,
    required this.request,
    required this.viewModel,
    this.canDecide = false,
  });
  final ManagerRequest request;
  final ManagerViewModel viewModel;
  final bool canDecide;
  @override
  Widget build(BuildContext context) => ManagerCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              request.id,
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: CentrixColors.leaf,
              ),
            ),
            const Spacer(),
            ManagerStatusChip(request.status),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          request.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.3),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: CentrixColors.raised.withValues(alpha: .75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MONTO SOLICITADO',
                style: TextStyle(
                  color: CentrixColors.leaf,
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  managerMoney(request.amountCents),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Pesos mexicanos · MXN',
                style: TextStyle(fontSize: 11, color: CentrixColors.forest),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _DetailLine(
          icon: Icons.person_outline_rounded,
          label: 'Solicitante',
          value: request.applicant,
        ),
        _DetailLine(
          icon: Icons.apartment_rounded,
          label: 'Departamento',
          value: 'Operaciones',
        ),
        _DetailLine(
          icon: managerCategoryIcon(request.category),
          label: 'Categoría',
          value: request.category.label,
        ),
        _DetailLine(
          icon: Icons.calendar_today_outlined,
          label: 'Fecha',
          value: managerDate(request.date),
        ),
        const Divider(height: 32),
        const Text(
          'Justificación',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          request.description,
          style: const TextStyle(color: CentrixColors.forest, height: 1.6),
        ),
        if (request.attachment != null) ...[
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Documento de ejemplo'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: CentrixColors.leaf,
                    ),
                    const SizedBox(height: 20),
                    Text(request.attachment!),
                    const SizedBox(height: 10),
                    const Text(
                      'Aquí podrás consultar el documento de la solicitud.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.attach_file_rounded, size: 18),
            label: Text(request.attachment!, overflow: TextOverflow.ellipsis),
          ),
        ],
        if (request.comment?.isNotEmpty == true) ...[
          const SizedBox(height: 18),
          const Text(
            'Comentario de revisión',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            request.comment!,
            style: const TextStyle(color: CentrixColors.forest, height: 1.5),
          ),
        ],
        if (canDecide && request.status == ManagerRequestStatus.pending) ...[
          const Divider(height: 36),
          FilledButton.icon(
            key: Key('approve-${request.id}'),
            onPressed: () => showManagerDecision(
              context,
              viewModel,
              request,
              ManagerRequestStatus.approved,
            ),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Aprobar solicitud'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: Key('reject-${request.id}'),
            onPressed: () => showManagerDecision(
              context,
              viewModel,
              request,
              ManagerRequestStatus.rejected,
            ),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Rechazar solicitud'),
          ),
        ],
      ],
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: CentrixColors.leaf),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: CentrixColors.forest,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> showManagerDecision(
  BuildContext context,
  ManagerViewModel vm,
  ManagerRequest request,
  ManagerRequestStatus decision,
) => showDialog<void>(
  context: context,
  builder: (_) =>
      _DecisionDialog(viewModel: vm, request: request, decision: decision),
);

class _DecisionDialog extends StatefulWidget {
  const _DecisionDialog({
    required this.viewModel,
    required this.request,
    required this.decision,
  });
  final ManagerViewModel viewModel;
  final ManagerRequest request;
  final ManagerRequestStatus decision;
  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  final _comment = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approve = widget.decision == ManagerRequestStatus.approved;
    return AlertDialog(
      title: Text(approve ? 'Aprobar solicitud' : 'Rechazar solicitud'),
      content: SizedBox(
        width: 430,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.request.id} · ${widget.request.title}'),
              const SizedBox(height: 12),
              Text(
                managerMoney(widget.request.amountCents),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              TextField(
                key: const Key('decision-comment'),
                controller: _comment,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: approve
                      ? 'Comentario (opcional)'
                      : 'Motivo del rechazo',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Vista previa: este cambio es temporal.',
                style: TextStyle(color: CentrixColors.forest, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('confirm-manager-decision'),
          onPressed: () {
            final error = widget.viewModel.decide(
              widget.request,
              widget.decision,
              _comment.text,
            );
            if (error != null) {
              setState(() => _error = error);
              return;
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  approve
                      ? 'Solicitud aprobada en la vista previa.'
                      : 'Solicitud rechazada en la vista previa.',
                ),
              ),
            );
          },
          child: Text(approve ? 'Confirmar aprobación' : 'Confirmar rechazo'),
        ),
      ],
    );
  }
}
