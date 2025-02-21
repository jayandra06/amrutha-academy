import 'package:dio/dio.dart';
import 'package:flutter_bloc_template/data/data_source/remote/dto/user/user_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../dto/api_response.dart';

part 'user_service.g.dart';

@RestApi()
@lazySingleton
abstract class UserService {
  @factoryMethod
  factory UserService(Dio dio) = _UserService;

  @GET('/profile')
  Future<ApiResponse<UserResponseDto>> fetchProfile();
}
