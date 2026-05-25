import 'package:dio/dio.dart';
import 'package:street_team/core/config/env_config.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_service.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  // Authenticate on Murugo
  Future<Response<dynamic>> authenticateMurugo({
    required String email,
    required String password,
  }) async {
    try {
      talker.info(' MURUGO LOGIN');
      final url = '${EnvConfig.murugoBaseUrl}${Endpoints.murugoToken}';
      final body = {
        'grant_type': 'password',
        'client_id': EnvConfig.murugoClientId,
        'client_secret': EnvConfig.murugoClientSecret,
        'username': email,
        'password': password,
      };
      talker.debug('EMAIL => $email');
      final response = await _dio.post(
        url,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': 'application/json',
            'APPKEY': EnvConfig.appKey,
            'AUTHVERSION': '2',
          },
        ),
        data: body,
      );
      talker.info('Murugo auth sucess ${response.statusCode}');
      talker.info('Murugo Response ${response.data}');

      return response;
    } on DioException catch (e) {
      final responseData = e.response?.data;

      final apiMessage = responseData is Map<String, dynamic>
          ? responseData['message'] ??
                responseData['error_description'] ??
                responseData['error'] ??
                'Unknown error'
          : 'Unknown error';

      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: apiMessage, 
      );
    }
  }
  // Get User Information

  Future<Response<dynamic>> getUserInfo({required String accessToken}) async {
    try {
      talker.info('GET USER INFO');
      final url = '${EnvConfig.murugoBaseUrl}${Endpoints.thirdPartyMe}';

      talker.debug('GET => $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'APPKEY': EnvConfig.appKey,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      talker.info('USER INFO SUCCESS => ${response.statusCode}');
      talker.debug('USER INFO RESPONSE => ${response.data}');

      return response;
    } on DioException catch (e, stackTrace) {
      talker.error(
        ''' GET USER INFO FAILED STATUS => ${e.response?.statusCode}

MESSAGE =>${e.message}

RESPONSE =>
${e.response?.data}
''',
        e,
        stackTrace,
      );

      rethrow;
    } catch (e, stackTrace) {
      talker.error(
        '''
UNKNOWN USER INFO ERROR

ERROR =>
$e
''',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  // Login Street Team User
  Future<Response<dynamic>> loginStreetTeam({
    required String userIdentifier,
  }) async {
    try {
      talker.info(' STREET TEAM LOGIN');
      final url = '${EnvConfig.baseUrl}${Endpoints.ccLogin}';

      final headers = {
        'Accept': 'application/json',
        'CLIENTID': EnvConfig.streetTeamClientId,
        'CLIENTSECRET': EnvConfig.streetTeamClientSecret,
        'SCOPE': 'street-team-user',
        'Content-Type': 'application/json',
      };

      final body = {'user_identifier': userIdentifier};

      talker.debug('REQUEST URL => $url');

      final response = await _dio.post(
        url,
        options: Options(headers: headers, validateStatus: (_) => true),
        data: body,
      );

      talker.debug('RESPONSE STATUS => ${response.statusCode}');

      talker.debug('RESPONSE DATA => ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        talker.info('STREET TEAM LOGIN SUCCESS');

        return response;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: response.data,
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e, stackTrace) {
      talker.error(
        '''
STREET TEAM LOGIN FAILED

STATUS =>
${e.response?.statusCode}

MESSAGE =>
${e.message}

RESPONSE =>
${e.response?.data}
''',
        e,
        stackTrace,
      );

      rethrow;
    } catch (e, stackTrace) {
      talker.error(
        '''
UNKNOWN STREET TEAM LOGIN ERROR

ERROR =>
$e
''',
        e,
        stackTrace,
      );

      rethrow;
    }
  }

  //LOGOUT

  Future<void> logout() async {
    try {
      // Clear Authorization Header
      _dio.options.headers.remove('Authorization');
      _dio.options.headers.clear();
      // Reset Default Headers
      _dio.options.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      AuthStorageService.clear();

      talker.info('LOGOUT SUCCESS');
    } catch (e, stackTrace) {
      talker.error(
        '''
LOGOUT FAILED

ERROR =>
$e
''',
        e,
        stackTrace,
      );

      rethrow;
    }
  }
}
