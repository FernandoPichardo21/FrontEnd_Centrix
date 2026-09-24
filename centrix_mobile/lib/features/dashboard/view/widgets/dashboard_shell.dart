import 'package:flutter/material.dart';

const _navy = Color(0xFF112D4E);
const _navyLight = Color(0xFF1B4B73);
const _blue = Color(0xFF2563EB);
const _teal = Color(0xFF0F766E);
const _background = Color(0xFFF3F6FA);
const _mutedText = Color(0xFF64748B);
const _border = Color(0xFFDCE4EE);

/// Describe una opción disponible dentro de un dashboard.
class DashboardAction {
  const DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.enabled = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
}

/// Estructura visual compartida por todos los dashboards de la aplicación.
class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.roleLabel,
    required this.actions,
    required this.onLogout,
  });

  final String userName;
  final String userEmail;
  final String roleLabel;
  final List<DashboardAction> actions;
  final VoidCallback onLogout;

  String get _initials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'CU';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        toolbarHeight: 76,
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 24,
        title: const _Brand(),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Notificaciones',
              onPressed: () => _showComingSoon(context, 'Notificaciones'),
              icon: const Icon(Icons.notifications_none_rounded, size: 21),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: PopupMenuButton<String>(
              tooltip: 'Cuenta',
              offset: const Offset(0, 54),
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: _border),
              ),
              onSelected: (value) {
                if (value == 'logout') onLogout();
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: SizedBox(
                    width: 230,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          userEmail,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          color: Color(0xFFB42318), size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Color(0xFFB42318),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: const Color(0xFFE3EEFC),
                    foregroundColor: _navy,
                    child: Text(
                      _initials,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (MediaQuery.sizeOf(context).width >= 700)
                    _TopUserName(name: userName, role: roleLabel),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 19),
                ],
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _border),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 900 ? 40.0 : 20.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                30,
                horizontalPadding,
                44,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WelcomeBanner(
                        userName: userName,
                        userEmail: userEmail,
                        roleLabel: roleLabel,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Centro de operaciones',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _navy,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Selecciona un módulo para comenzar.',
                        style: TextStyle(color: _mutedText, fontSize: 14),
                      ),
                      const SizedBox(height: 18),
                      _ActionGrid(actions: actions),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature estará disponible próximamente.')),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_navy, _navyLight]),
            borderRadius: BorderRadius.all(Radius.circular(11)),
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Text(
                'C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(
          'CENTRIX',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _TopUserName extends StatelessWidget {
  const _TopUserName({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        Text(
          role,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: _mutedText),
        ),
      ],
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.userName,
    required this.userEmail,
    required this.roleLabel,
  });

  final String userName;
  final String userEmail;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 24 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26112D4E),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -24,
            top: -42,
            child: _DecorativeCircle(size: 170),
          ),
          const Positioned(
            right: 90,
            bottom: -75,
            child: _DecorativeCircle(size: 130),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF36B6A7).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0x6636B6A7)),
                      ),
                      child: Text(
                        roleLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFC8FFF7),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Bienvenido, $userName',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Color(0xFFCFDEED),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(Icons.verified_user_outlined,
                            color: Color(0xFF8DE4D8), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Sesión segura y activa',
                          style: TextStyle(
                            color: Color(0xFFE7F3F8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 28),
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0x26FFFFFF)),
                  ),
                  child: const Icon(
                    Icons.dashboard_outlined,
                    size: 55,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x14FFFFFF), width: 22),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<DashboardAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 580
                ? 2
                : 1;
        const spacing = 18.0;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actions
              .asMap()
              .entries
              .map(
                (entry) => SizedBox(
                  width: width,
                  child: _ActionCard(
                    action: entry.value,
                    accent: entry.key.isEven ? _blue : _teal,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.accent});

  final DashboardAction action;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final foreground = action.enabled ? _navy : _mutedText;
    return Material(
      color: action.enabled ? Colors.white : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: action.enabled ? action.onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 190),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(18),
            boxShadow: action.enabled
                ? const [
                    BoxShadow(
                      color: Color(0x0F112D4E),
                      blurRadius: 16,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: action.enabled
                          ? accent.withValues(alpha: 0.10)
                          : const Color(0xFFE9EEF4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.enabled ? accent : _mutedText,
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: action.enabled
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFE9EEF4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      action.enabled
                          ? Icons.arrow_forward_rounded
                          : Icons.lock_outline_rounded,
                      size: 17,
                      color: action.enabled ? accent : _mutedText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                action.title,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                action.subtitle,
                style: const TextStyle(
                  color: _mutedText,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
