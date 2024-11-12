
class UserDto {
  final String id;
  final String username;
  final List<String> permissions;
  final int createdAt;

  UserDto({
    required this.id,
    required this.username,
    required this.permissions,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    var list = json['permissions'] as List;
    List<String> permissionsList =
        list.map((i) => "$i").toList();

    return UserDto(
      id: json['id'].toString(),
      username: json['username'],
      permissions: permissionsList,
      createdAt: json['createdAt'],
    );
  }
}