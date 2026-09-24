import 'admin_user.dart';
import 'create_user_request.dart';

/// Contrato de acceso a los datos administrativos de usuarios.
abstract class AdminUserRepository {
  Future<List<AdminUser>> fetchAll();
  Future<void> create(CreateUserRequest request);
}
