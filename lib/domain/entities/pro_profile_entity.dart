import 'package:equatable/equatable.dart';

class ProProfile extends Equatable {
  final String userId;
  final String businessName;
  final String profession;
  final String bio;
  final double hourlyRate;
  final List<String> skills;
  final bool isProModeEnabled;
  final String? portfolioUrl;

  const ProProfile({
    required this.userId,
    required this.businessName,
    required this.profession,
    this.bio = '',
    this.hourlyRate = 0.0,
    this.skills = const [],
    this.isProModeEnabled = false,
    this.portfolioUrl,
  });

  ProProfile copyWith({
    String? userId,
    String? businessName,
    String? profession,
    String? bio,
    double? hourlyRate,
    List<String>? skills,
    bool? isProModeEnabled,
    String? portfolioUrl,
  }) {
    return ProProfile(
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      profession: profession ?? this.profession,
      bio: bio ?? this.bio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      skills: skills ?? this.skills,
      isProModeEnabled: isProModeEnabled ?? this.isProModeEnabled,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        businessName,
        profession,
        bio,
        hourlyRate,
        skills,
        isProModeEnabled,
        portfolioUrl,
      ];
}
