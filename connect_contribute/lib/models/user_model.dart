class User {
  final String id;
  final String name;
  final String email;
  final String userType; // 'Individual' or 'NGO'
  final String? phone;
  final String? address;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phone,
    this.address,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Debug: Print the raw JSON
    print('User.fromJson called with: $json');

    // Handle MongoDB's _id as either a String or a Map
    String parseId(dynamic id) {
      print('parseId called with: $id (type: ${id.runtimeType})');
      if (id is String) return id;
      if (id is Map && id.containsKey('\$oid')) return id['\$oid'] as String;
      return '';
    }

    final parsedId = parseId(json['_id'] ?? json['id']);
    print('Parsed ID: $parsedId');

    return User(
      id: parsedId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      profileImage: json['profile_image'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'user_type': userType,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class SignupRequest {
  final String name;
  final String email;
  final String password;
  final String userType;

  SignupRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'user_type': userType,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}
