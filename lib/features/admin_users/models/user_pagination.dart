class UserPagination {
  const UserPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;

  factory UserPagination.fromJson(Map<String, dynamic> json) {
    return UserPagination(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      totalPages:
          json['totalPages'] as int? ?? (json['total_pages'] as int? ?? 1),
    );
  }
}
