import 'package:flutter/material.dart';

class ContributorItem {
  final String id;
  final String name;
  final String role;
  final String githubUrl;
  final String linkedinUrl;
  final String imagePath;
  final String contribution;

  ContributorItem({
    required this.id,
    required this.name,
    required this.role,
    this.githubUrl = '',
    this.linkedinUrl = '',
    this.imagePath = '',
    this.contribution = '',
  });

  factory ContributorItem.fromJson(Map<String, dynamic> json) {
    return ContributorItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      githubUrl: json['github_url'] as String? ?? '',
      linkedinUrl: json['linkedin_url'] as String? ?? '',
      imagePath: json['image_path'] as String? ?? '',
      contribution: json['contribution'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'github_url': githubUrl,
      'linkedin_url': linkedinUrl,
      'image_path': imagePath,
      'contribution': contribution,
    };
  }
}

final ValueNotifier<List<ContributorItem>> contributorsState = ValueNotifier([]);
