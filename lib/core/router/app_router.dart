import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/viewmodels/auth_view_model.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/admin_users/models/user_model.dart';
import '../../features/admin_users/viewmodels/create_user_view_model.dart';
import '../../features/admin_users/views/create_user_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/departments/models/department_model.dart';
import '../../features/departments/viewmodels/department_view_model.dart';
import '../../features/departments/views/department_view.dart';
import '../../features/tickets/models/ticket_model.dart';
import '../../features/tickets/viewmodels/create_ticket_view_model.dart';
import '../../features/tickets/viewmodels/department_tickets_view_model.dart';
import '../../features/tickets/viewmodels/ticket_list_view_model.dart';
import '../../features/tickets/viewmodels/ticket_detail_view_model.dart';
import '../../features/tickets/views/create_ticket_view.dart';
import '../../features/tickets/views/department_tickets_view.dart';
import '../../features/tickets/views/ticket_list_view.dart';
import '../../features/tickets/views/ticket_detail_view.dart';

GoRouter createAppRouter(
  AuthViewModel auth,
  DepartmentModel departmentModel,
  TicketModel ticketModel,
  UserModel userModel,
) => GoRouter(
  initialLocation: '/login',
  refreshListenable: auth,
  redirect: (context, state) {
    final isLoginPage = state.matchedLocation == '/login';
    if (!auth.isAuthenticated && !isLoginPage) return '/login';
    if (auth.isAuthenticated && isLoginPage) return '/home';
    if (state.matchedLocation == '/tickets/new' &&
        !auth.session!.user.canCreateTicket) {
      return '/home';
    }
    if (state.matchedLocation == '/tickets/department' &&
        !auth.session!.user.canViewDepartmentTickets) {
      return '/home';
    }
    if (state.matchedLocation == '/tickets/pending' &&
        !auth.session!.user.canManageTickets) {
      return '/home';
    }
    if (state.matchedLocation == '/admin/users/new' &&
        !auth.session!.user.canCreateUser) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    GoRoute(path: '/home', builder: (context, state) => const DashboardView()),
    GoRoute(
      path: '/departments',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) =>
            DepartmentViewModel(departmentModel)..load(auth.session!.token),
        child: const DepartmentView(),
      ),
    ),
    GoRoute(
      path: '/tickets/new',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) =>
            CreateTicketViewModel(ticketModel, departmentModel)
              ..loadDepartments(auth.session!.token),
        child: const CreateTicketView(),
      ),
    ),
    GoRoute(
      path: '/tickets/department',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) =>
            DepartmentTicketsViewModel(ticketModel, departmentModel)
              ..loadDepartments(auth.session!.token),
        child: const DepartmentTicketsView(),
      ),
    ),
    GoRoute(
      path: '/tickets/my',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) =>
            TicketListViewModel(ticketModel, TicketListMode.mine)
              ..load(auth.session!.token),
        child: const TicketListView(),
      ),
    ),
    GoRoute(
      path: '/tickets/pending',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) =>
            TicketListViewModel(ticketModel, TicketListMode.pending)
              ..load(auth.session!.token),
        child: const TicketListView(),
      ),
    ),
    GoRoute(
      path: '/tickets/:ticketId',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => TicketDetailViewModel(
          ticketModel,
          state.pathParameters['ticketId']!,
          auth.session!.user.canManageTickets,
        )..load(auth.session!.token),
        child: const TicketDetailView(),
      ),
    ),
    GoRoute(
      path: '/admin/users/new',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => CreateUserViewModel(userModel),
        child: const CreateUserView(),
      ),
    ),
  ],
);
