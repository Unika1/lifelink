import 'package:equatable/equatable.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';

enum AuthStatus{initial,loading,authenticated,unauthenticated,registered, message,error}
class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;
  final String? message;

  const AuthState({
    this.status=AuthStatus.initial, 
    this.authEntity, 
    this.errorMessage,
    this.message,
  });
  AuthState copywith({
    AuthStatus?status,
    AuthEntity?authEntity,
    String? errorMessage,
    String? message,
  }) {
    return AuthState(
      status: status?? this.status,
      authEntity: authEntity??this.authEntity,
      errorMessage: errorMessage?? this.errorMessage,
      message: message?? this.message,
    );
  }
  
  @override
  
  List<Object?> get props => [status,authEntity,errorMessage];
}