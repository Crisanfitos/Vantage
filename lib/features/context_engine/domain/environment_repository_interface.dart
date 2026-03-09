import '../domain/environment.dart';

abstract class IEnvironmentRepository {
  Future<void> saveEnvironment(String userId, VantageEnvironment environment);
  Future<void> deleteEnvironment(String userId, String environmentId);
  Stream<List<VantageEnvironment>> watchEnvironments(String userId);
}
