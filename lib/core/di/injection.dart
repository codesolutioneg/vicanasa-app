import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/financial/data/datasources/financial_remote_datasource.dart';
import '../../features/financial/data/repositories/financial_repository_impl.dart';
import '../../features/financial/domain/repositories/financial_repository.dart';
import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/reports/data/financial_pdf_builder.dart';
import '../../features/reports/data/pdf_export_service.dart';
import '../../features/shell/presentation/cubit/filter_cubit.dart';
import '../network/connectivity_service.dart';
import '../network/odoo_client.dart';
import '../network/odoo_cookie_jar.dart';
import '../review/mobile_versions_service.dart';
import '../review/review_mode_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<ConnectivityService>(ConnectivityService.new);
  final cookieJar = await createOdooCookieJar();
  sl.registerLazySingleton<OdooClient>(() => OdooClient(cookieJar: cookieJar));
  sl.registerLazySingleton(
    () => FinancialRemoteDataSource(sl<OdooClient>()),
  );
  sl.registerLazySingleton<FinancialRepository>(
    () => FinancialRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton(() => OnboardingRepository(sl()));
  sl.registerLazySingleton(FinancialPdfBuilder.new);
  sl.registerLazySingleton(PdfExportService.new);
  sl.registerLazySingleton(MobileVersionsService.new);
  sl.registerLazySingleton(ReviewModeCubit.new);
  sl.registerFactory(() => AuthCubit(sl(), sl()));
  sl.registerFactory(FilterCubit.new);
}
