import '../../../../core/utils/typedefs.dart';

class DashboardProfileModel {
  const DashboardProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.isActive = true,
    this.status,
    this.hasAppliedForKyc = false,
    this.profile,
    this.kycDocuments = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? role;
  final bool isActive;
  final String? status;
  final bool hasAppliedForKyc;
  final DashboardProfileDetails? profile;
  final List<DashboardKycDocument> kycDocuments;
  final String? createdAt;

  String get initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  bool get isApproved =>
      (status ?? '').toLowerCase() == 'approved' ||
      (profile?.kycStatus ?? '').toLowerCase() == 'approved';

  factory DashboardProfileModel.fromJson(Json json) => DashboardProfileModel(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        status: json['status'] as String?,
        hasAppliedForKyc: json['has_applied_for_kyc'] as bool? ?? false,
        profile: json['profile'] is Json
            ? DashboardProfileDetails.fromJson(json['profile'] as Json)
            : null,
        kycDocuments: (json['kyc_documents'] as List<dynamic>?)
                ?.map((e) => DashboardKycDocument.fromJson(e as Json))
                .toList() ??
            const [],
        createdAt: json['created_at'] as String?,
      );
}

class DashboardProfileDetails {
  const DashboardProfileDetails({
    this.cnic,
    this.fatherSpouseName,
    this.gender,
    this.maritalStatus,
    this.nationality,
    this.residentStatus,
    this.phone,
    this.address,
    this.mailingAddress,
    this.permanentAddress,
    this.city,
    this.bankAccountTitle,
    this.iban,
    this.bankName,
    this.branchName,
    this.occupation,
    this.employer,
    this.sourceOfIncome,
    this.annualIncome,
    this.nomineeName,
    this.nomineeRelation,
    this.nomineeCnic,
    this.kycStatus,
    this.tradingAccountNo,
    this.profileComplete = false,
  });

  final String? cnic;
  final String? fatherSpouseName;
  final String? gender;
  final String? maritalStatus;
  final String? nationality;
  final String? residentStatus;
  final String? phone;
  final String? address;
  final String? mailingAddress;
  final String? permanentAddress;
  final String? city;
  final String? bankAccountTitle;
  final String? iban;
  final String? bankName;
  final String? branchName;
  final String? occupation;
  final String? employer;
  final String? sourceOfIncome;
  final String? annualIncome;
  final String? nomineeName;
  final String? nomineeRelation;
  final String? nomineeCnic;
  final String? kycStatus;
  final String? tradingAccountNo;
  final bool profileComplete;

  factory DashboardProfileDetails.fromJson(Json json) =>
      DashboardProfileDetails(
        cnic: json['cnic'] as String?,
        fatherSpouseName: json['father_spouse_name'] as String?,
        gender: json['gender'] as String?,
        maritalStatus: json['marital_status'] as String?,
        nationality: json['nationality'] as String?,
        residentStatus: json['resident_status'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        mailingAddress: json['mailing_address'] as String?,
        permanentAddress: json['permanent_address'] as String?,
        city: json['city'] as String?,
        bankAccountTitle: json['bank_account_title'] as String?,
        iban: json['iban'] as String?,
        bankName: json['bank_name'] as String?,
        branchName: json['branch_name'] as String?,
        occupation: json['occupation'] as String?,
        employer: json['employer'] as String?,
        sourceOfIncome: json['source_of_income'] as String?,
        annualIncome: json['annual_income'] as String?,
        nomineeName: json['nominee_name'] as String?,
        nomineeRelation: json['nominee_relation'] as String?,
        nomineeCnic: json['nominee_cnic'] as String?,
        kycStatus: json['kyc_status'] as String?,
        tradingAccountNo: json['trading_account_no'] as String?,
        profileComplete: json['profile_complete'] as bool? ?? false,
      );
}

class DashboardKycDocument {
  const DashboardKycDocument({
    required this.id,
    this.documentType,
    this.status,
    this.filePath,
    this.fileUrl,
    this.createdAt,
  });

  final int id;
  final String? documentType;
  final String? status;
  final String? filePath;
  final String? fileUrl;
  final String? createdAt;

  String get displayTitle {
    switch (documentType?.toLowerCase()) {
      case 'selfie':
        return 'Selfie Photo';
      case 'cnic_front':
        return 'CNIC Front';
      case 'cnic_back':
        return 'CNIC Back';
      default:
        return (documentType ?? 'Document')
            .replaceAll('_', ' ')
            .toUpperCase();
    }
  }

  bool get isApproved => (status ?? '').toLowerCase() == 'approved';
  bool get isPending => (status ?? '').toLowerCase() == 'pending';

  factory DashboardKycDocument.fromJson(Json json) => DashboardKycDocument(
        id: json['id'] as int? ?? 0,
        documentType: json['document_type'] as String?,
        status: json['status'] as String?,
        filePath: json['file_path'] as String?,
        fileUrl: json['file_url'] as String?,
        createdAt: json['created_at'] as String?,
      );
}
