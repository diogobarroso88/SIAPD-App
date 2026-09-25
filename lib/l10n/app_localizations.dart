import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar Sessão'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tenho conta'**
  String get noAccount;

  /// No description provided for @newAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar Conta'**
  String get newAccount;

  /// No description provided for @homePage.
  ///
  /// In pt, this message translates to:
  /// **'Homepage'**
  String get homePage;

  /// No description provided for @sentObservations.
  ///
  /// In pt, this message translates to:
  /// **'Observações enviadas'**
  String get sentObservations;

  /// No description provided for @offlineObservations.
  ///
  /// In pt, this message translates to:
  /// **'Observações offline'**
  String get offlineObservations;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @aboutUs.
  ///
  /// In pt, this message translates to:
  /// **'Sobre nós'**
  String get aboutUs;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @sent.
  ///
  /// In pt, this message translates to:
  /// **'Enviadas'**
  String get sent;

  /// No description provided for @offline.
  ///
  /// In pt, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @noOfflineObservations.
  ///
  /// In pt, this message translates to:
  /// **'Não existem observações offline.'**
  String get noOfflineObservations;

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @username.
  ///
  /// In pt, this message translates to:
  /// **'Nome de utilizador'**
  String get username;

  /// No description provided for @newObservation.
  ///
  /// In pt, this message translates to:
  /// **'Nova Observação'**
  String get newObservation;

  /// No description provided for @title.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get title;

  /// No description provided for @observationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Título da observação'**
  String get observationTitle;

  /// No description provided for @description.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get description;

  /// No description provided for @optionalDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição (opcional)'**
  String get optionalDescription;

  /// No description provided for @camera.
  ///
  /// In pt, this message translates to:
  /// **'Câmara'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get gallery;

  /// No description provided for @selectedPhotos.
  ///
  /// In pt, this message translates to:
  /// **'Fotografias selecionadas (máximo 6)'**
  String get selectedPhotos;

  /// No description provided for @maxPhotos.
  ///
  /// In pt, this message translates to:
  /// **'Pode selecionar no máximo 6 fotografias.'**
  String get maxPhotos;

  /// No description provided for @privacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get privacy;

  /// No description provided for @private.
  ///
  /// In pt, this message translates to:
  /// **'Privado'**
  String get private;

  /// No description provided for @public.
  ///
  /// In pt, this message translates to:
  /// **'Público'**
  String get public;

  /// No description provided for @service.
  ///
  /// In pt, this message translates to:
  /// **'Serviço'**
  String get service;

  /// No description provided for @chooseService.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o Serviço'**
  String get chooseService;

  /// No description provided for @group.
  ///
  /// In pt, this message translates to:
  /// **'Grupo'**
  String get group;

  /// No description provided for @location.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get location;

  /// No description provided for @send.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get send;

  /// No description provided for @saveObservation.
  ///
  /// In pt, this message translates to:
  /// **'Guardar observação'**
  String get saveObservation;

  /// No description provided for @sendAllObservations.
  ///
  /// In pt, this message translates to:
  /// **'Enviar todas as observações'**
  String get sendAllObservations;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get delete;

  /// No description provided for @deleteObservation.
  ///
  /// In pt, this message translates to:
  /// **'Apagar observação'**
  String get deleteObservation;

  /// No description provided for @confirmDeleteObservation.
  ///
  /// In pt, this message translates to:
  /// **'Tem a certeza que pretende apagar esta observação?'**
  String get confirmDeleteObservation;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @list.
  ///
  /// In pt, this message translates to:
  /// **'Lista'**
  String get list;

  /// No description provided for @map.
  ///
  /// In pt, this message translates to:
  /// **'Mapa'**
  String get map;

  /// No description provided for @photos.
  ///
  /// In pt, this message translates to:
  /// **'Fotografias'**
  String get photos;

  /// No description provided for @photo.
  ///
  /// In pt, this message translates to:
  /// **'Fotografia'**
  String get photo;

  /// No description provided for @loginSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Login efetuado com sucesso.'**
  String get loginSuccess;

  /// No description provided for @loginError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao iniciar sessão.'**
  String get loginError;

  /// No description provided for @enterEmail.
  ///
  /// In pt, this message translates to:
  /// **'Introduza o email.'**
  String get enterEmail;

  /// No description provided for @enterName.
  ///
  /// In pt, this message translates to:
  /// **'Introduza o seu nome'**
  String get enterName;

  /// No description provided for @enterUsername.
  ///
  /// In pt, this message translates to:
  /// **'Introduza um nome de utilizador'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In pt, this message translates to:
  /// **'Introduza a password.'**
  String get enterPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar password.'**
  String get confirmPassword;

  /// No description provided for @matchPassword.
  ///
  /// In pt, this message translates to:
  /// **'As passwords não coincidem'**
  String get matchPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'Introduza um email válido.'**
  String get invalidEmail;

  /// No description provided for @viewDetails.
  ///
  /// In pt, this message translates to:
  /// **'Ver detalhes'**
  String get viewDetails;

  /// No description provided for @details.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get details;

  /// No description provided for @selectService.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um serviço.'**
  String get selectService;

  /// No description provided for @noObservations.
  ///
  /// In pt, this message translates to:
  /// **'Não existem observações.'**
  String get noObservations;

  /// No description provided for @observationWithoutPhotos.
  ///
  /// In pt, this message translates to:
  /// **'Esta observação não tem fotografias.'**
  String get observationWithoutPhotos;

  /// No description provided for @observationSent.
  ///
  /// In pt, this message translates to:
  /// **'Observação enviada'**
  String get observationSent;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'A carregar…'**
  String get loading;

  /// No description provided for @observationSentSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Observação enviada com sucesso.'**
  String get observationSentSuccess;

  /// No description provided for @observationSendError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar a observação.'**
  String get observationSendError;

  /// No description provided for @observationSavedForRetry.
  ///
  /// In pt, this message translates to:
  /// **'A observação ficou guardada para tentar novamente.'**
  String get observationSavedForRetry;

  /// No description provided for @noObservationsToSend.
  ///
  /// In pt, this message translates to:
  /// **'Não existem observações para enviar.'**
  String get noObservationsToSend;

  /// No description provided for @success.
  ///
  /// In pt, this message translates to:
  /// **'com sucesso'**
  String get success;

  /// No description provided for @sentSuccessfully.
  ///
  /// In pt, this message translates to:
  /// **'enviadas com sucesso.'**
  String get sentSuccessfully;

  /// No description provided for @failed.
  ///
  /// In pt, this message translates to:
  /// **'falhou'**
  String get failed;

  /// No description provided for @failedPlural.
  ///
  /// In pt, this message translates to:
  /// **'falharam'**
  String get failedPlural;

  /// No description provided for @sendingObservations.
  ///
  /// In pt, this message translates to:
  /// **'A enviar observações…'**
  String get sendingObservations;

  /// No description provided for @untitled.
  ///
  /// In pt, this message translates to:
  /// **'Sem título'**
  String get untitled;

  /// No description provided for @validTitleRequired.
  ///
  /// In pt, this message translates to:
  /// **'É necessário selecionar um título válido.'**
  String get validTitleRequired;

  /// No description provided for @locationUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Localização indisponível'**
  String get locationUnavailable;

  /// No description provided for @selectGroup.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar grupo'**
  String get selectGroup;

  /// No description provided for @serviceMinimum.
  ///
  /// In pt, this message translates to:
  /// **'É necessário selecionar um serviço.'**
  String get serviceMinimum;

  /// No description provided for @groupMinimum.
  ///
  /// In pt, this message translates to:
  /// **'É necessário selecionar um grupo.'**
  String get groupMinimum;

  /// No description provided for @photoMinimum.
  ///
  /// In pt, this message translates to:
  /// **'É necessário adicionar pelo menos uma fotografia.'**
  String get photoMinimum;

  /// No description provided for @gpsMinimum.
  ///
  /// In pt, this message translates to:
  /// **'É necessário obter a localização.'**
  String get gpsMinimum;

  /// No description provided for @gpsDenied.
  ///
  /// In pt, this message translates to:
  /// **'Se denegó el permiso de ubicación.'**
  String get gpsDenied;

  /// No description provided for @deniedGps.
  ///
  /// In pt, this message translates to:
  /// **'El permiso de ubicación ha sido denegado permanentemente.'**
  String get deniedGps;

  /// No description provided for @phenoSelect.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar estado fenológico'**
  String get phenoSelect;

  /// No description provided for @varietySearch.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar casta'**
  String get varietySearch;

  /// No description provided for @serviceChoose.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar serviço'**
  String get serviceChoose;

  /// No description provided for @individualGroup.
  ///
  /// In pt, this message translates to:
  /// **'Grupo de'**
  String get individualGroup;

  /// No description provided for @changeSaved.
  ///
  /// In pt, this message translates to:
  /// **'As alterações ficaram guardadas.'**
  String get changeSaved;

  /// No description provided for @cantSave.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível guardar as alterações.'**
  String get cantSave;

  /// No description provided for @observationEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar Observação'**
  String get observationEdit;

  /// No description provided for @latitude.
  ///
  /// In pt, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In pt, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @phenologyAWinterBud.
  ///
  /// In pt, this message translates to:
  /// **'Gomo de Inverno'**
  String get phenologyAWinterBud;

  /// No description provided for @phenologyBWoollyBud.
  ///
  /// In pt, this message translates to:
  /// **'Gomo de Algodão'**
  String get phenologyBWoollyBud;

  /// No description provided for @phenologyCBudBreak.
  ///
  /// In pt, this message translates to:
  /// **'Ponta Verde'**
  String get phenologyCBudBreak;

  /// No description provided for @phenologyDLeafEmergence.
  ///
  /// In pt, this message translates to:
  /// **'Saída de Folhas'**
  String get phenologyDLeafEmergence;

  /// No description provided for @phenologyELeavesSeparated.
  ///
  /// In pt, this message translates to:
  /// **'Folhas Livres'**
  String get phenologyELeavesSeparated;

  /// No description provided for @phenologyFInflorescencesVisible.
  ///
  /// In pt, this message translates to:
  /// **'Cachos Visíveis'**
  String get phenologyFInflorescencesVisible;

  /// No description provided for @phenologyGInflorescencesSeparated.
  ///
  /// In pt, this message translates to:
  /// **'Cachos Separados'**
  String get phenologyGInflorescencesSeparated;

  /// No description provided for @phenologyHFlowersSeparated.
  ///
  /// In pt, this message translates to:
  /// **'Botões Florais Separados'**
  String get phenologyHFlowersSeparated;

  /// No description provided for @phenologyIBloom.
  ///
  /// In pt, this message translates to:
  /// **'Floração'**
  String get phenologyIBloom;

  /// No description provided for @phenologyJFruitSet.
  ///
  /// In pt, this message translates to:
  /// **'Alimpa'**
  String get phenologyJFruitSet;

  /// No description provided for @phenologyKBerriesPeaSize.
  ///
  /// In pt, this message translates to:
  /// **'Bago de Ervilha'**
  String get phenologyKBerriesPeaSize;

  /// No description provided for @phenologyLBerriesTouching.
  ///
  /// In pt, this message translates to:
  /// **'Cacho Fechado'**
  String get phenologyLBerriesTouching;

  /// No description provided for @phenologyMVeraison.
  ///
  /// In pt, this message translates to:
  /// **'Pintor'**
  String get phenologyMVeraison;

  /// No description provided for @phenologyNMaturity.
  ///
  /// In pt, this message translates to:
  /// **'Maturação'**
  String get phenologyNMaturity;

  /// No description provided for @phenologyOCaneMaturation.
  ///
  /// In pt, this message translates to:
  /// **'Atempamento da Vara'**
  String get phenologyOCaneMaturation;

  /// No description provided for @phenologyPLeafFall.
  ///
  /// In pt, this message translates to:
  /// **'Queda de Folhas'**
  String get phenologyPLeafFall;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
