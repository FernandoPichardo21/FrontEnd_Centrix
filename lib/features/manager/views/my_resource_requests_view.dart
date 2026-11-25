import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../../core/widgets/centrix_glass.dart';
import '../../../core/widgets/centrix_page_header.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../models/manager_api_service.dart';
import '../models/manager_request.dart';
import 'widgets/manager_widgets.dart';

class MyResourceRequestsView extends StatefulWidget {
  const MyResourceRequestsView({super.key});

  @override
  State<MyResourceRequestsView> createState() => _MyResourceRequestsViewState();
}

class _MyResourceRequestsViewState extends State<MyResourceRequestsView> {
  final _api = ManagerApiService();
  List<ManagerRequest>? _requests;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthViewModel>();
    if (!auth.isAuthenticated) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _api.fetchMyRequests(auth.session!.token);
      if (!mounted) return;
      setState(() {
        _requests = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    final auth = context.read<AuthViewModel>();
    if (!auth.isAuthenticated) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar solicitud'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta solicitud?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.deleteRequest(auth.session!.token, requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Solicitud cancelada.')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes de recursos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _load,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/resource-requests/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva solicitud'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(wide ? 32 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CentrixPageHeader(
                  title: 'Mis recursos solicitados',
                  description: 'Consulta el historial de solicitudes enviadas a tu gerencia y su estado de aprobación.',
                  icon: Icons.inventory_2_outlined,
                  eyebrow: 'HISTORIAL PERSONAL',
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  CentrixGlass(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: CentrixColors.error,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(color: CentrixColors.error),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_requests == null || _requests!.isEmpty)
                  CentrixGlass(
                    child: Padding(
                      padding: const EdgeInsets.all(36),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.folder_open_rounded,
                            size: 48,
                            color: CentrixColors.leaf,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No tienes solicitudes registradas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cuando solicites equipo, material o presupuesto para tu área, aparecerá aquí.',
                            style: TextStyle(
                              color: CentrixColors.forest,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () =>
                                context.go('/resource-requests/new'),
                            icon: const Icon(Icons.add_shopping_cart_rounded),
                            label: const Text('Crear primera solicitud'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final item in _requests!) ...[
                    CentrixGlass(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ManagerStatusChip(item.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 6,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.category_outlined,
                                      size: 14,
                                      color: CentrixColors.forest,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.category.label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CentrixColors.forest,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 14,
                                      color: CentrixColors.forest,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      managerDate(item.date),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CentrixColors.forest,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.attach_money_rounded,
                                      size: 14,
                                      color: CentrixColors.leaf,
                                    ),
                                    Text(
                                      managerMoney(item.amountCents),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: CentrixColors.leaf,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: CentrixColors.mint,
                                height: 1.4,
                              ),
                            ),
                            if (item.status == ManagerRequestStatus.rejected &&
                                item.comment != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: CentrixColors.error.withValues(
                                    alpha: .12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: CentrixColors.error.withValues(
                                      alpha: .3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: CentrixColors.error,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Motivo del rechazo:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: CentrixColors.error,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.comment!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: CentrixColors.mint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (item.status ==
                                ManagerRequestStatus.pending) ...[
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _deleteRequest(item.id),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: CentrixColors.error,
                                  ),
                                  label: const Text(
                                    'Cancelar solicitud',
                                    style: TextStyle(
                                      color: CentrixColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
