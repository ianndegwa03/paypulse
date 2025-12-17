import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const BaseState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;

  BaseState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  });

  @override
  List<Object?> get props => [isLoading, errorMessage, successMessage];
}