import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/centrix_theme.dart';
import '../../../core/widgets/centrix_glass.dart';
import '../../../core/widgets/centrix_page_header.dart';
import '../../auth/viewmodels/auth_view_model.dart';
import '../models/manager_api_service.dart';

class CreateResourceRequestView extends StatefulWidget {
  const CreateResourceRequestView({super.key});

  @override
  State<CreateResourceRequestView> createState() =>
      _CreateResourceRequestViewState();
}

class _CreateResourceRequestViewState extends State<CreateResourceRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedCategory = 'Equipo';
  bool _isLoading = false;
  String? _error;

  static const _categories = [
    {
      'value': 'Equipo',
      'label': 'Equipo (Cómputo, laptops, periféricos)',
      'icon': Icons.devices_rounded,
    },
    {
      'value': 'Mobiliario',
      'label': 'Mobiliario (Sillas, escritorios, estantes)',
      'icon': Icons.chair_outlined,
    },
    {
      'value': 'Material',
      'label': 'Material e Insumos operativos',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'value': 'Papeleria',
      'label': 'Papelería y consumibles de oficina',
      'icon': Icons.edit_note_rounded,
    },
    {
      'value': 'Economico',
      'label': 'Recurso económico o viáticos',
      'icon': Icons.payments_outlined,
    },
    {
      'value': 'Otro',
      'label': 'Otro tipo de recurso',
      'icon': Icons.more_horiz_rounded,
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();
    if (!auth.isAuthenticated) {
      context.go('/login');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ManagerApiService();
      await api.createRequest(
        auth.session!.token,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        estimatedAmount: amount,
        departmentId: auth.session!.user.departmentId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de recurso creada exitosamente.'),
          backgroundColor: CentrixColors.leaf,
        ),
      );
      context.go('/resource-requests/my');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar recursos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(wide ? 32 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CentrixPageHeader(
                  title: 'Nueva solicitud de recurso',
                  description: 'Describe el material, equipo o presupuesto necesario para que tu gerencia lo revise.',
                  icon: Icons.add_shopping_cart_rounded,
                  eyebrow: 'RECURSOS Y PRESUPUESTO',
                ),
                const SizedBox(height: 24),
                CentrixGlass(
                  child: Padding(
                    padding: EdgeInsets.all(wide ? 28 : 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CentrixColors.error.withValues(
                                  alpha: .15,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: CentrixColors.error),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: CentrixColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: CentrixColors.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Concepto o título de la solicitud *',
                              hintText: 'Ej. Laptop para soporte, Renovación de licencias...',
                              prefixIcon: Icon(Icons.title_rounded),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Ingresa el concepto de la solicitud'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Categoría *',
                              prefixIcon: Icon(Icons.category_rounded),
                            ),
                            items: _categories.map((c) {
                              return DropdownMenuItem<String>(
                                value: c['value'] as String,
                                child: Row(
                                  children: [
                                    Icon(
                                      c['icon'] as IconData,
                                      size: 18,
                                      color: CentrixColors.leaf,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        c['label'] as String,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCategory = val);
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Monto estimado (MXN) *',
                              hintText: '0.00',
                              prefixText: '\$ ',
                              suffixText: 'MXN',
                              prefixIcon: Icon(Icons.attach_money_rounded),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Ingresa el monto estimado';
                              }
                              final parsed = double.tryParse(v.trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Ingresa un monto numérico mayor a cero';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText:
                                  'Justificación / Descripción detallada *',
                              hintText: 'Explica por qué es necesario este recurso y el impacto en tu área...',
                              alignLabelWithHint: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Describe la justificación del recurso'
                                : null,
                          ),
                          const SizedBox(height: 28),
                          FilledButton.icon(
                            onPressed: _isLoading ? null : _submit,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(
                              _isLoading
                                  ? 'Enviando solicitud...'
                                  : 'Enviar solicitud',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
