import 'package:get_it/get_it.dart';
import 'package:tidal_wave/data/abstractions/connectivity_service_base.dart';
import 'package:tidal_wave/data/dataSources/firebase/firestore_database_service.dart';
import 'package:tidal_wave/data/dataSources/firebase/firestore_actions_connectivty_service_implement.dart';
import 'package:tidal_wave/data/repositories/music_list_repository_implement.dart';
import 'package:tidal_wave/data/repositories/music_repository_implement.dart';
import 'package:tidal_wave/data/repositories/user_repository_implement.dart';
import 'package:tidal_wave/domain/use_case/implementations/authentication_manager_use_case_implement.dart';
import 'package:tidal_wave/domain/use_case/implementations/music_manager_use_case_implement.dart';
import 'package:tidal_wave/domain/use_case/implementations/play_list_manager_use_case_implement.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:tidal_wave/domain/use_case/interfaces/play_list_manager_use_case.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {

  locator.registerLazySingleton<ConnectivityServiceBase>(() =>
    FirestoreActionsConnectityServiceImplement()  
  );

  locator.registerLazySingleton<AuthenticationManagerUseCase>(() => 
    AuthenticationManagerUseCaseImplement(UserRepositoryImplement(
      databaseService: FirestoreDatabaseService()
    ))
  );
  
  locator.registerLazySingleton<MusicManagerUseCase>(() => 
    MusicManagerUseCaseImplement(MusicRepositoryImplement(
      databaseService: FirestoreDatabaseService()
    ))
  );
  
  locator.registerLazySingleton<PlayListManagerUseCase>(() => 
    PlayListManagerUseCaseImplement(MusicListRepositoryImplement(
      databaseService: FirestoreDatabaseService()
    ))
  );
}