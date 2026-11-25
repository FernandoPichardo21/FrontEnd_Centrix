import 'user_list_item.dart';
import 'user_pagination.dart';

class UsersResponse {
  const UsersResponse({required this.items, required this.pagination});

  final List<UserListItem> items;
  final UserPagination pagination;

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final itemsList = rawItems is List
        ? rawItems
              .map(
                (item) => UserListItem.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
        : <UserListItem>[];

    final rawPagination = json['pagination'];
    final pagination = rawPagination is Map
        ? UserPagination.fromJson(Map<String, dynamic>.from(rawPagination))
        : UserPagination(
            total: itemsList.length,
            page: 1,
            limit: itemsList.isEmpty ? 20 : itemsList.length,
            totalPages: 1,
          );

    return UsersResponse(items: itemsList, pagination: pagination);
  }
}
