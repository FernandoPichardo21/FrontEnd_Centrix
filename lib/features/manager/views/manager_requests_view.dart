import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../models/manager_request.dart';
import '../viewmodels/manager_view_model.dart';
import 'widgets/manager_widgets.dart';

class ManagerRequestsView extends StatelessWidget {
  const ManagerRequestsView({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManagerViewModel>();
    void open(ManagerRequest request) => showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 760),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ManagerRequestDetail(request: request, viewModel: vm),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar detalle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ManagerPageTitle(
          title: 'Tu departamento, en perspectiva.',
          description: 'Consulta el estado de cada solicitud y encuentra lo que necesitas.',
          action: Chip(
            avatar: const Icon(Icons.apartment_outlined, size: 16),
            label: const Text('Operaciones'),
          ),
        ),
        const SizedBox(height: 24),
        ManagerStats(
          children: [
            ManagerStat(
              label: 'Solicitudes registradas',
              value: '${vm.requests.length}',
              caption: 'Historial del departamento',
              icon: Icons.folder_open_rounded,
            ),
            ManagerStat(
              label: 'En espera de revisión',
              value: '${vm.pending.length}',
              caption: 'Noviembre de 2026',
              icon: Icons.schedule_rounded,
              highlight: true,
            ),
            ManagerStat(
              label: 'Equipo conectado',
              value: '${vm.requests.map((r) => r.applicant).toSet().length}',
              caption: 'Personas con solicitudes',
              icon: Icons.people_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: 24),
        ManagerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Solicitudes del departamento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: ValueKey('manager-request-search-${vm.resetVersion}'),
                initialValue: vm.searchQuery,
                onChanged: vm.search,
                decoration: const InputDecoration(
                  hintText: 'Buscar por folio, concepto o solicitante',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todas'),
                    selected: vm.statusFilter == null,
                    onSelected: (_) => vm.filterStatus(null),
                  ),
                  for (final status in ManagerRequestStatus.values)
                    ChoiceChip(
                      label: Text(status.label),
                      selected: vm.statusFilter == status,
                      onSelected: (_) => vm.filterStatus(status),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<ManagerCategory>(
                isExpanded: true,
                key: ValueKey(vm.categoryFilter),
                initialValue: vm.categoryFilter,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.tune_rounded),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(
                      'Todas las categorías',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  for (final category in ManagerCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(
                        category.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: vm.filterCategory,
              ),
              const SizedBox(height: 20),
              Text(
                '${vm.filteredRequests.length} resultados',
                style: const TextStyle(
                  color: CentrixColors.forest,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              if (vm.filteredRequests.isEmpty)
                const ManagerEmpty(
                  title: 'No encontramos solicitudes',
                  message: 'Prueba otro texto o cambia los filtros.',
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 720) {
                    return Column(
                      children: [
                        for (final request in vm.filteredRequests)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: InkWell(
                              onTap: () => open(request),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CentrixColors.sage.withValues(
                                      alpha: .3,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          request.id,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: CentrixColors.leaf,
                                          ),
                                        ),
                                        const Spacer(),
                                        ManagerStatusChip(request.status),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      request.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      request.applicant,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CentrixColors.forest,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            managerMoney(request.amountCents),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_outward_rounded,
                                          size: 17,
                                          color: CentrixColors.leaf,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        CentrixColors.raised.withValues(alpha: .75),
                      ),
                      horizontalMargin: 12,
                      columnSpacing: 25,
                      dataRowMinHeight: 70,
                      dataRowMaxHeight: 78,
                      columns: const [
                        DataColumn(label: Text('Solicitud')),
                        DataColumn(label: Text('Solicitante')),
                        DataColumn(label: Text('Monto')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('')),
                      ],
                      rows: [
                        for (final request in vm.filteredRequests)
                          DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 210,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.id,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: CentrixColors.leaf,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        request.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () => open(request),
                              ),
                              DataCell(
                                Text(
                                  request.applicant,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(
                                Text(
                                  managerMoney(request.amountCents),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              DataCell(ManagerStatusChip(request.status)),
                              DataCell(
                                Text(
                                  managerDate(request.date),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  tooltip: 'Ver ${request.id}',
                                  onPressed: () => open(request),
                                  icon: const Icon(
                                    Icons.arrow_outward_rounded,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
