import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';

class CampusNetworkModel extends CampusNetworkEntity {
  const CampusNetworkModel({
    required super.id,
    required super.label,
    required super.publicIp,
    super.ipSubnet,
    super.location,
    required super.isActive,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory CampusNetworkModel.fromJson(Map<String, dynamic> json) {
    return CampusNetworkModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Wi-Fi Router',
      publicIp: json['publicIp']?.toString() ?? '127.0.0.1',
      ipSubnet: json['ipSubnet']?.toString(),
      location: json['location']?.toString(),
      isActive: json['isActive'] == true || json['is_active'] == true,
      createdBy: json['createdBy']?.toString() ?? json['created_by']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : (json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'publicIp': publicIp,
      if (ipSubnet != null && ipSubnet!.isNotEmpty) 'ipSubnet': ipSubnet,
      if (location != null && location!.isNotEmpty) 'location': location,
      'isActive': isActive,
      if (createdBy != null) 'createdBy': createdBy,
    };
  }

  /// Initial sample seed routers matching ERP standard
  static List<CampusNetworkModel> get mockNetworks => [
        CampusNetworkModel(
          id: 'mock-net-1',
          label: 'Admin Office Primary Router',
          publicIp: '103.145.72.18',
          ipSubnet: '192.168.1.0/24',
          location: 'Administrative Block - 1st Floor',
          isActive: true,
          createdBy: 'Super Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        CampusNetworkModel(
          id: 'mock-net-2',
          label: 'Dar-ul-Ifta & Library AP',
          publicIp: '103.145.72.19',
          ipSubnet: '192.168.2.0/24',
          location: 'Central Library Wing',
          isActive: true,
          createdBy: 'Super Admin',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        CampusNetworkModel(
          id: 'mock-net-3',
          label: 'Hostel Block Backup Wi-Fi',
          publicIp: '182.73.114.52',
          ipSubnet: '192.168.10.0/24',
          location: 'Resident Hall B',
          isActive: false,
          createdBy: 'Principal',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
}
