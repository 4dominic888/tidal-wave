import 'package:get_it/get_it.dart';
import 'package:tidal_wave/data/abstractions/connectivity_service_base.dart';
import 'package:tidal_wave/data/abstractions/database_service.dart';
import 'package:tidal_wave/data/dataSources/firebase/firestore_database_service.dart';
import 'package:tidal_wave/data/dataSources/firebase/firestore_actions_connectivty_service_implement.dart';
import 'package:tidal_wave/data/dataSources/sqflite/sqflite_database_service.dart';
import 'package:tidal_wave/data/repositories/music_list_repository_implement.dart';
import 'package:tidal_wave/data/repositories/music_repository_implement.dart';
import 'package:tidal_wave/data/repositories/user_repository_implement.dart';
import 'package:tidal_wave/domain/use_case/implementations/authentication_manager_use_case_implement.dart';
import 'package:tidal_wave/domain/use_case/implementations/music_manager_use_case_implement.dart';
import 'package:tidal_wave/domain/use_case/implementations/music_list_manager_use_case_implement.dart';
import 'package:tidal_wave/domain/use_case/interfaces/authentication_manager_use_case.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_list_manager_use_case.dart';
import 'package:tidal_wave/presentation/bloc/download_music_cubit.dart';
import 'package:tidal_wave/presentation/bloc/music_playing_cubit.dart';
import 'package:tidal_wave/presentation/bloc/play_list_state_cubit.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {

  locator.registerLazySingleton<ConnectivityServiceBase>(() =>
    FirestoreActionsConnectityServiceImplement()  
  );

  locator.registerLazySingleton<DatabaseService<Map<String,dynamic>>>(
    () => FirestoreDatabaseService(), instanceName: 'Firestore'
  );

  locator.registerLazySingleton<DatabaseService<Map<String,dynamic>>>(
    () => SqfliteDatabaseService(), instanceName: 'Sqflite'
  );

  locator.registerLazySingleton<PlayListStateCubit>(() => PlayListStateCubit());
  locator.registerLazySingleton<DownloadMusicCubit>(() => DownloadMusicCubit());
  locator.registerLazySingleton<MusicPlayingCubit>(() => MusicPlayingCubit());

  locator.registerLazySingleton<AuthenticationManagerUseCase>(() => 
    AuthenticationManagerUseCaseImplement(UserRepositoryImplement(
      onlineContext: FirestoreDatabaseService(),
      offlineContext: SqfliteDatabaseService()
    ))
  );
  
  locator.registerLazySingleton<MusicManagerUseCase>(() => 
    MusicManagerUseCaseImplement(MusicRepositoryImplement(
      onlineContext: FirestoreDatabaseService(),
      offlineContext: SqfliteDatabaseService()
    ))
  );
  
  locator.registerLazySingleton<MusicListManagerUseCase>(() => 
    MusicListManagerUseCaseImplement(MusicListRepositoryImplement(
      onlineContext: FirestoreDatabaseService(),
      offlineContext: SqfliteDatabaseService()
    ))
  );
}