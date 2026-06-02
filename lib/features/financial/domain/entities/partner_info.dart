import 'package:equatable/equatable.dart';

class AnalyticOption extends Equatable {
  const AnalyticOption({
    required this.id,
    required this.name,
    required this.sharePercentage,
  });

  final int id;
  final String name;
  final double sharePercentage;

  @override
  List<Object?> get props => [id, name, sharePercentage];
}

class PartnerInfo extends Equatable {
  const PartnerInfo({
    required this.isFinancialPartner,
    this.partnerId,
    this.partnerName,
    this.analyticOptions = const [],
  });

  final bool isFinancialPartner;
  final int? partnerId;
  final String? partnerName;
  final List<AnalyticOption> analyticOptions;

  @override
  List<Object?> get props =>
      [isFinancialPartner, partnerId, partnerName, analyticOptions];
}
