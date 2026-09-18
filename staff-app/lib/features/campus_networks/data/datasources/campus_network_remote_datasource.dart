import 'dart:async';
import 'package:dio/dio.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/features/campus_networks/data/models/campus_network_model.dart';
import 'package:staff_app/features/campus_networks/domain/entities/campus_network_entity.dart';

abstract class CampusNetworkRemoteDataSource {
  Future<List<CampusNetworkModel>> getCampusNetworks();
  Future<CurrentNetworkInfoEntity> detectCurrentNetwork();
  Future<CampusNetworkModel> createCampusNetwork({
    required String label,
    required String publicIp,
    String? ipSubnet,
    String? location,
    bool isActive = true,
  });
  Future<CampusNetworkModel> updateCampusNetwork({
    required String id,
    String? label,
    String? publicIp,
    String? ipSubnet,
    String? location,
    bool? isActive,
  });
  Future<void> deleteCampusNetwork(String id);
  Future<CampusNetworkModel> toggleNetworkStatus({
    required String id,
    required bool isActive,
  });
}

class CampusNetworkRemoteDataSourceImpl implements CampusNetworkRemoteDataSource {
  CampusNetworkRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory working list for resilience and zero-lag updates
  static final List<CampusNetworkModel> _localNetworks =
      List.from(CampusNetworkModel.mockNetworks);

  @override
  Future<List<CampusNetworkModel>> getCampusNetworks() async {
    try {
      final response = await apiClient.get<dynamic>('/v1/staff-admin/campus-networks');
      if (response.statusCode == 200 && response.data != null) {
        dynamic rawData = response.data;
        if (rawData is Map && rawData.containsKey('data')) {
          rawData = rawData['data'];
        }
        if (rawData is List) {
          final list = rawData
              .map((e) => CampusNetworkModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _localNetworks
            ..clear()
            ..addAll(list);
          return List.unmodifiable(_localNetworks);
        }
      }
    } catch (_) {
      // Return local cache on network disruption
    }
    return List.unmodifiable(_localNetworks);
  }

  @override
  Future<CurrentNetworkInfoEntity> detectCurrentNetwork() async {
    String detectedIp = '127.0.0.1';
    bool serverIsAuthorized = false;
    String? serverLabel;

    // 1. Query Backend /current-ip endpoint
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/v1/staff-admin/campus-networks/current-ip',
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final ip = data['ip']?.toString() ?? '';
        serverIsAuthorized = data['isWhitelisted'] == true || data['isAuthorized'] == true;
        serverLabel = data['networkLabel']?.toString();

        if (ip.isNotEmpty && !_isPrivateOrLocalIp(ip)) {
          detectedIp = ip.replaceAll('::ffff:', '').trim();
        }
      }
    } catch (_) {
      // Proceed to fallback
    }

    // 2. If IP is still loopback or local, query external public WAN service
    if (_isPrivateOrLocalIp(detectedIp)) {
      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ));
        final res = await dio.get<Map<String, dynamic>>('https://api64.ipify.org?format=json');
        final wanIp = res.data?['ip']?.toString();
        if (wanIp != null && wanIp.isNotEmpty) {
          detectedIp = wanIp.trim();
        }
      } catch (_) {
        // Fallback to secondary endpoint
        try {
          final dio = Dio(BaseOptions(
            connectTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          ));
          final res = await dio.get<Map<String, dynamic>>('https://api.ipify.org?format=json');
          final wanIp = res.data?['ip']?.toString();
          if (wanIp != null && wanIp.isNotEmpty) {
            detectedIp = wanIp.trim();
          }
        } catch (_) {}
      }
    }

    // 3. Match against current database networks
    final networks = await getCampusNetworks();
    CampusNetworkEntity? matched;
    for (final net in networks) {
      if (!net.isActive) continue;
      if (net.publicIp == detectedIp) {
        matched = net;
        break;
      }
      if (net.ipSubnet != null && net.ipSubnet!.isNotEmpty) {
        final subnetBase = net.ipSubnet!.split('/')[0];
        final subnetPrefix = subnetBase.split('.').take(3).join('.');
        final ipPrefix = detectedIp.split('.').take(3).join('.');
        if (subnetPrefix == ipPrefix) {
          matched = net;
          break;
        }
      }
    }

    final isAuthorized = serverIsAuthorized || matched != null;
    return CurrentNetworkInfoEntity(
      clientIp: detectedIp,
      isAuthorized: isAuthorized,
      matchedNetwork: matched ??
          (serverLabel != null
              ? CampusNetworkEntity(
                  id: 'matched-server',
                  label: serverLabel,
                  publicIp: detectedIp,
                  isActive: true,
                )
              : null),
      connectionType: 'WIFI',
    );
  }

  @override
  Future<CampusNetworkModel> createCampusNetwork({
    required String label,
    required String publicIp,
    String? ipSubnet,
    String? location,
    bool isActive = true,
  }) async {
    final payload = {
      'label': label.trim(),
      'publicIp': publicIp.trim(),
      if (ipSubnet != null && ipSubnet.trim().isNotEmpty) 'ipSubnet': ipSubnet.trim(),
      if (location != null && location.trim().isNotEmpty) 'location': location.trim(),
      'isActive': isActive,
    };

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/v1/staff-admin/campus-networks',
        data: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic raw = response.data!['data'] ?? response.data;
        final created = CampusNetworkModel.fromJson(raw as Map<String, dynamic>);
        _localNetworks.insert(0, created);
        return created;
      }
    } catch (_) {}

    // Fallback in-memory creation
    final fallback = CampusNetworkModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      label: label.trim(),
      publicIp: publicIp.trim(),
      ipSubnet: ipSubnet?.trim(),
      location: location?.trim(),
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _localNetworks.insert(0, fallback);
    return fallback;
  }

  @override
  Future<CampusNetworkModel> updateCampusNetwork({
    required String id,
    String? label,
    String? publicIp,
    String? ipSubnet,
    String? location,
    bool? isActive,
  }) async {
    final payload = <String, dynamic>{
      if (label != null) 'label': label.trim(),
      if (publicIp != null) 'publicIp': publicIp.trim(),
      if (ipSubnet != null) 'ipSubnet': ipSubnet.trim(),
      if (location != null) 'location': location.trim(),
      if (isActive != null) 'isActive': isActive,
    };

    try {
      final response = await apiClient.patch<Map<String, dynamic>>(
        '/v1/staff-admin/campus-networks/$id',
        data: payload,
      );
      if (response.statusCode == 200 && response.data != null) {
        final dynamic raw = response.data!['data'] ?? response.data;
        final updated = CampusNetworkModel.fromJson(raw as Map<String, dynamic>);
        final idx = _localNetworks.indexWhere((n) => n.id == id);
        if (idx != -1) {
          _localNetworks[idx] = updated;
        }
        return updated;
      }
    } catch (_) {}

    final idx = _localNetworks.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final existing = _localNetworks[idx];
      final updated = existing.copyWith(
        label: label ?? existing.label,
        publicIp: publicIp ?? existing.publicIp,
        ipSubnet: ipSubnet ?? existing.ipSubnet,
        location: location ?? existing.location,
        isActive: isActive ?? existing.isActive,
        updatedAt: DateTime.now(),
      );
      final model = CampusNetworkModel(
        id: updated.id,
        label: updated.label,
        publicIp: updated.publicIp,
        ipSubnet: updated.ipSubnet,
        location: updated.location,
        isActive: updated.isActive,
        createdBy: updated.createdBy,
        createdAt: updated.createdAt,
        updatedAt: updated.updatedAt,
      );
      _localNetworks[idx] = model;
      return model;
    }
    throw Exception('Campus network router with ID $id not found');
  }

  @override
  Future<void> deleteCampusNetwork(String id) async {
    try {
      await apiClient.delete<void>('/v1/staff-admin/campus-networks/$id');
    } catch (_) {}
    _localNetworks.removeWhere((n) => n.id == id);
  }

  @override
  Future<CampusNetworkModel> toggleNetworkStatus({
    required String id,
    required bool isActive,
  }) async {
    return updateCampusNetwork(id: id, isActive: isActive);
  }

  bool _isPrivateOrLocalIp(String ip) {
    if (ip.isEmpty) return true;
    final clean = ip.replaceAll('::ffff:', '').trim();
    return clean == '127.0.0.1' ||
        clean == '::1' ||
        clean == 'localhost' ||
        clean.startsWith('192.168.') ||
        clean.startsWith('10.') ||
        clean.startsWith('172.16.') ||
        clean.startsWith('172.17.') ||
        clean.startsWith('172.18.') ||
        clean.startsWith('172.19.') ||
        clean.startsWith('172.2') ||
        clean.startsWith('172.30.') ||
        clean.startsWith('172.31.') ||
        clean.startsWith('fe80:');
  }
}
