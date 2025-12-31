import 'package:equatable/equatable.dart';

enum SplitStatus { pending, paid, confirmed }

class SplitParticipant extends Equatable {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final SplitStatus status;

  const SplitParticipant({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.status = SplitStatus.pending,
  });

  SplitParticipant copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    SplitStatus? status,
  }) {
    return SplitParticipant(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [userId, displayName, photoUrl, status];
}
