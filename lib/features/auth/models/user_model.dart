class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String userType; // 'user' or 'admin'
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isEmailVerified;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.userType,
    this.phoneNumber,
    this.profileImageUrl,
    this.isEmailVerified = false,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      userType: json['userType'] ?? 'user',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'userType': userType,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? userType,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final bool isLoggedIn;
  final String? error;

  const AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.isLoggedIn = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    bool? isLoggedIn,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error ?? this.error,
    );
  }
} 