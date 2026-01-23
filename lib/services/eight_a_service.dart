import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ascent.dart';

class EightAService {
  static const String _baseUrl = 'https://www.8a.nu/api/unification';
  static const int _pageSize = 50;

  String? _sessionCookie;

  EightAService({String? sessionCookie}) : _sessionCookie = sessionCookie;

  void setSessionCookie(String cookie) {
    _sessionCookie = cookie;
  }

  Map<String, String> get _headers => {
    'Accept': '*/*',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
    'Referer': 'https://www.8a.nu/',
    if (_sessionCookie != null) 'Cookie': 'nu8a_session=$_sessionCookie',
  };

  Future<List<Ascent>> fetchAllAscents(String userSlug, {String category = 'sportclimbing'}) async {
    List<Ascent> allAscents = [];
    int pageIndex = 0;
    int totalItems = 0;

    do {
      final response = await _fetchAscentsPage(userSlug, pageIndex, category: category);
      allAscents.addAll(response.ascents);
      totalItems = response.totalItems;
      pageIndex++;
    } while (allAscents.length < totalItems);

    return allAscents;
  }

  Future<AscentsResponse> _fetchAscentsPage(String userSlug, int pageIndex, {String category = 'sportclimbing'}) async {
    final uri = Uri.parse('$_baseUrl/ascent/v1/web/users/$userSlug/ascents').replace(
      queryParameters: {
        'category': category,
        'pageIndex': pageIndex.toString(),
        'pageSize': _pageSize.toString(),
        'sortField': 'grade_desc',
        'timeFilter': '0',
        'gradeFilter': '0',
        'includeProjects': 'false',
        'showRepeats': 'false',
        'showDuplicates': 'false',
      },
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AscentsResponse.fromJson(json);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw EightAAuthException('Session expired or invalid. Please log in again.');
    } else {
      throw EightAException('Failed to fetch ascents: ${response.statusCode}');
    }
  }

  Future<UserProfile?> fetchUserProfile(String userSlug) async {
    final uri = Uri.parse('$_baseUrl/profile/v1/web/users/$userSlug');

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserProfile.fromJson(json);
    }
    return null;
  }

  Future<String?> searchUser(String username) async {
    final uri = Uri.parse('$_baseUrl/search/v1/web').replace(
      queryParameters: {
        'query': username,
        'type': 'users',
      },
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final users = json['users'] as List?;
      if (users != null && users.isNotEmpty) {
        return users[0]['slug'] as String?;
      }
    }
    return null;
  }
}

class AscentsResponse {
  final List<Ascent> ascents;
  final int totalItems;
  final int pageIndex;

  AscentsResponse({required this.ascents, required this.totalItems, required this.pageIndex});

  factory AscentsResponse.fromJson(Map<String, dynamic> json) {
    final ascentsJson = json['ascents'] as List;
    return AscentsResponse(
      ascents: ascentsJson.map((item) => Ascent.fromJson(item)).toList(),
      totalItems: json['totalItems'] ?? 0,
      pageIndex: json['pageIndex'] ?? 0,
    );
  }
}

class UserProfile {
  final String slug;
  final String? name;
  final String? avatar;

  UserProfile({required this.slug, this.name, this.avatar});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      slug: json['slug'] ?? '',
      name: json['userName'] ?? json['fullName'],
      avatar: json['avatar'],
    );
  }
}

class EightAException implements Exception {
  final String message;
  EightAException(this.message);

  @override
  String toString() => message;
}

class EightAAuthException extends EightAException {
  EightAAuthException(super.message);
}
