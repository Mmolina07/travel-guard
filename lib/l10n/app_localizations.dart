import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  ];

  /// Nombre de la aplicación mostrado en la barra de título
  ///
  /// In es, this message translates to:
  /// **'Travel Guard'**
  String get appTitle;

  /// Título de la pantalla de selección de tipo de registro
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te quieres registrar?'**
  String get registerTypeTitle;

  /// Subtítulo de la pantalla de selección de tipo de registro
  ///
  /// In es, this message translates to:
  /// **'Selecciona cómo quieres registrarte en TravelGuard.'**
  String get registerTypeSubtitle;

  /// Título de la tarjeta de registro como turista
  ///
  /// In es, this message translates to:
  /// **'Turista'**
  String get registerTypeTouristTitle;

  /// Descripción de la tarjeta de registro como turista
  ///
  /// In es, this message translates to:
  /// **'Accede a experiencias, mapas, recomendaciones y más.'**
  String get registerTypeTouristDescription;

  /// Título de la tarjeta de registro como comercio
  ///
  /// In es, this message translates to:
  /// **'Comercio'**
  String get registerTypeCommerceTitle;

  /// Descripción de la tarjeta de registro como comercio
  ///
  /// In es, this message translates to:
  /// **'Registra tu negocio y llega a más visitantes.'**
  String get registerTypeCommerceDescription;

  /// Eslogan de marca mostrado en el panel de las pantallas de autenticación
  ///
  /// In es, this message translates to:
  /// **'Tu itinerario, tu presupuesto y tu seguridad, en un solo lugar.'**
  String get authBrandTagline;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar sesión.'**
  String get loginErrorGeneric;

  /// No description provided for @loginSuccessSnackbar.
  ///
  /// In es, this message translates to:
  /// **'¡Ingreso exitoso!'**
  String get loginSuccessSnackbar;

  /// No description provided for @loginErrorEnterEmail.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu correo'**
  String get loginErrorEnterEmail;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo inválido'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorEnterPassword.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu contraseña'**
  String get loginErrorEnterPassword;

  /// No description provided for @loginWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get loginWelcome;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In es, this message translates to:
  /// **'de nuevo'**
  String get loginWelcomeBack;

  /// No description provided for @loginHeroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Explora Medellín con seguridad y control de tu presupuesto.'**
  String get loginHeroSubtitle;

  /// No description provided for @loginStatStepsLabel.
  ///
  /// In es, this message translates to:
  /// **'PASOS PARA CREAR TU VIAJE'**
  String get loginStatStepsLabel;

  /// No description provided for @loginStatBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'CONTROL DE TU PRESUPUESTO'**
  String get loginStatBudgetLabel;

  /// No description provided for @loginRoleTourist.
  ///
  /// In es, this message translates to:
  /// **'Turista'**
  String get loginRoleTourist;

  /// No description provided for @loginRoleCommerce.
  ///
  /// In es, this message translates to:
  /// **'Comercio'**
  String get loginRoleCommerce;

  /// No description provided for @loginFieldEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'CORREO'**
  String get loginFieldEmailLabel;

  /// No description provided for @loginFieldEmailHint.
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get loginFieldEmailHint;

  /// No description provided for @loginFieldPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'CONTRASEÑA'**
  String get loginFieldPasswordLabel;

  /// No description provided for @loginPasswordHide.
  ///
  /// In es, this message translates to:
  /// **'OCULTAR'**
  String get loginPasswordHide;

  /// No description provided for @loginPasswordShow.
  ///
  /// In es, this message translates to:
  /// **'VER'**
  String get loginPasswordShow;

  /// No description provided for @loginFeatureInDevelopment.
  ///
  /// In es, this message translates to:
  /// **'Función en desarrollo'**
  String get loginFeatureInDevelopment;

  /// No description provided for @loginForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmitAsCommerce.
  ///
  /// In es, this message translates to:
  /// **'Ingresar como comercio'**
  String get loginSubmitAsCommerce;

  /// No description provided for @loginSubmitAsTourist.
  ///
  /// In es, this message translates to:
  /// **'Ingresar como turista'**
  String get loginSubmitAsTourist;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginNoAccountQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get loginNoAccountQuestion;

  /// No description provided for @loginRegisterLink.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get loginRegisterLink;

  /// No description provided for @commonRegisterButton.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get commonRegisterButton;

  /// No description provided for @commonEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get commonEmailLabel;

  /// No description provided for @commonEmailHint.
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get commonEmailHint;

  /// No description provided for @commonPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get commonPasswordLabel;

  /// No description provided for @commonConfirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get commonConfirmPasswordLabel;

  /// No description provided for @commonTermsNotice.
  ///
  /// In es, this message translates to:
  /// **'Al registrarte aceptas nuestros Términos y Condiciones'**
  String get commonTermsNotice;

  /// No description provided for @commonRegisterErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar el registro.'**
  String get commonRegisterErrorGeneric;

  /// No description provided for @commonEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu correo'**
  String get commonEmailRequired;

  /// No description provided for @commonEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo inválido'**
  String get commonEmailInvalid;

  /// No description provided for @commonPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu contraseña'**
  String get commonPasswordRequired;

  /// No description provided for @commonPasswordsMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get commonPasswordsMismatch;

  /// No description provided for @clientRegisterTitle.
  ///
  /// In es, this message translates to:
  /// **'Regístrate como turista'**
  String get clientRegisterTitle;

  /// No description provided for @clientRegisterSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta para empezar a planificar tu viaje'**
  String get clientRegisterSubtitle;

  /// No description provided for @clientRegisterNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get clientRegisterNameLabel;

  /// No description provided for @clientRegisterNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get clientRegisterNameHint;

  /// No description provided for @clientRegisterNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu nombre'**
  String get clientRegisterNameRequired;

  /// No description provided for @clientRegisterPasswordHelper.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get clientRegisterPasswordHelper;

  /// No description provided for @clientRegisterPasswordMin.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get clientRegisterPasswordMin;

  /// No description provided for @clientRegisterConfirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor confirma tu contraseña'**
  String get clientRegisterConfirmPasswordRequired;

  /// No description provided for @clientRegisterSuccessSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Registro exitoso'**
  String get clientRegisterSuccessSnackbar;

  /// No description provided for @clientRegisterOrContinueWith.
  ///
  /// In es, this message translates to:
  /// **'o continúa con'**
  String get clientRegisterOrContinueWith;

  /// No description provided for @clientRegisterGoogleButton.
  ///
  /// In es, this message translates to:
  /// **'Registrarse con Google'**
  String get clientRegisterGoogleButton;

  /// No description provided for @commerceRegisterTitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tu comercio'**
  String get commerceRegisterTitle;

  /// No description provided for @commerceRegisterSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Llega a más viajeros con tu negocio en TravelGuard'**
  String get commerceRegisterSubtitle;

  /// No description provided for @commerceRegisterNitLabel.
  ///
  /// In es, this message translates to:
  /// **'NIT'**
  String get commerceRegisterNitLabel;

  /// No description provided for @commerceRegisterNitHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el NIT'**
  String get commerceRegisterNitHint;

  /// No description provided for @commerceRegisterNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del negocio'**
  String get commerceRegisterNameLabel;

  /// No description provided for @commerceRegisterNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre del negocio'**
  String get commerceRegisterNameHint;

  /// No description provided for @commerceRegisterAddressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get commerceRegisterAddressLabel;

  /// No description provided for @commerceRegisterAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la dirección'**
  String get commerceRegisterAddressHint;

  /// No description provided for @commerceRegisterAddressHelper.
  ///
  /// In es, this message translates to:
  /// **'Escribe la dirección y toca el ícono de ubicación (o presiona Enter) para verla en el mapa de abajo.'**
  String get commerceRegisterAddressHelper;

  /// No description provided for @commerceRegisterAddressSearchTooltip.
  ///
  /// In es, this message translates to:
  /// **'Buscar esta dirección en el mapa'**
  String get commerceRegisterAddressSearchTooltip;

  /// No description provided for @commerceRegisterPhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Número telefónico'**
  String get commerceRegisterPhoneLabel;

  /// No description provided for @commerceRegisterPhoneHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el número'**
  String get commerceRegisterPhoneHint;

  /// No description provided for @commerceRegisterSedeLabel.
  ///
  /// In es, this message translates to:
  /// **'Sede'**
  String get commerceRegisterSedeLabel;

  /// No description provided for @commerceRegisterSedeHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la sede'**
  String get commerceRegisterSedeHint;

  /// No description provided for @commerceRegisterLocationLabel.
  ///
  /// In es, this message translates to:
  /// **'Ubicación del negocio'**
  String get commerceRegisterLocationLabel;

  /// No description provided for @commerceRegisterPasswordHelper.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get commerceRegisterPasswordHelper;

  /// No description provided for @commerceRegisterSuccessSnackbar.
  ///
  /// In es, this message translates to:
  /// **'¡Registro exitoso!'**
  String get commerceRegisterSuccessSnackbar;

  /// No description provided for @commerceRegisterOr.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get commerceRegisterOr;

  /// No description provided for @commerceRegisterGoogleVerified.
  ///
  /// In es, this message translates to:
  /// **'Cuenta de Google verificada'**
  String get commerceRegisterGoogleVerified;

  /// No description provided for @commerceRegisterGoogleVerify.
  ///
  /// In es, this message translates to:
  /// **'Verificar con Google'**
  String get commerceRegisterGoogleVerify;

  /// No description provided for @commerceRegisterGoogleVerifiedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Cuenta de Google verificada. Completa los datos del negocio y presiona \"Registrarse\" para terminar.'**
  String get commerceRegisterGoogleVerifiedSnackbar;

  /// No description provided for @commerceRegisterFieldsRequired.
  ///
  /// In es, this message translates to:
  /// **'Debe completar todos los campos obligatorios'**
  String get commerceRegisterFieldsRequired;

  /// No description provided for @commerceRegisterLocationRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la ubicación de tu negocio en el mapa'**
  String get commerceRegisterLocationRequired;

  /// No description provided for @commerceRegisterNitInvalid.
  ///
  /// In es, this message translates to:
  /// **'NIT inválido o ya registrado'**
  String get commerceRegisterNitInvalid;

  /// No description provided for @commerceRegisterEmailInvalidOrTaken.
  ///
  /// In es, this message translates to:
  /// **'Email inválido o ya registrado'**
  String get commerceRegisterEmailInvalidOrTaken;

  /// No description provided for @commerceRegisterPasswordMin.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener mínimo 8 caracteres'**
  String get commerceRegisterPasswordMin;

  /// No description provided for @commerceRegisterGeocodeNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró esa dirección en el mapa. Ubica tu negocio manualmente tocando el mapa de abajo.'**
  String get commerceRegisterGeocodeNotFound;

  /// No description provided for @commerceRegisterGeocodeFound.
  ///
  /// In es, this message translates to:
  /// **'Ubicación encontrada — ajusta el marcador si hace falta.'**
  String get commerceRegisterGeocodeFound;

  /// No description provided for @configScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configScreenTitle;

  /// No description provided for @configSectionLanguageRegion.
  ///
  /// In es, this message translates to:
  /// **'Idioma y región'**
  String get configSectionLanguageRegion;

  /// No description provided for @configLanguageLabel.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get configLanguageLabel;

  /// No description provided for @configCurrencyLabel.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get configCurrencyLabel;

  /// No description provided for @configSectionNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get configSectionNotifications;

  /// No description provided for @configNotificationsToggleLabel.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get configNotificationsToggleLabel;

  /// No description provided for @configSectionSecurity.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get configSectionSecurity;

  /// No description provided for @configChangePasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get configChangePasswordLabel;

  /// No description provided for @configLogoutLabel.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get configLogoutLabel;

  /// No description provided for @configVersionLabel.
  ///
  /// In es, this message translates to:
  /// **'Versión 1.0.0'**
  String get configVersionLabel;

  /// No description provided for @configCurrentPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get configCurrentPasswordLabel;

  /// No description provided for @configCurrentPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña actual'**
  String get configCurrentPasswordHint;

  /// No description provided for @configNewPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get configNewPasswordLabel;

  /// No description provided for @configNewPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nueva contraseña'**
  String get configNewPasswordHint;

  /// No description provided for @configConfirmNewPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu nueva contraseña'**
  String get configConfirmNewPasswordHint;

  /// No description provided for @configShowPasswordCheckbox.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get configShowPasswordCheckbox;

  /// No description provided for @configCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get configCancelButton;

  /// No description provided for @configSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get configSaveButton;

  /// No description provided for @configPasswordUpdatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada correctamente'**
  String get configPasswordUpdatedSnackbar;

  /// No description provided for @configErrorChangePassword.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar la contraseña: {error}'**
  String configErrorChangePassword(String error);

  /// No description provided for @configSelectLanguageTitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona idioma'**
  String get configSelectLanguageTitle;

  /// No description provided for @configSelectCurrencyTitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona moneda'**
  String get configSelectCurrencyTitle;

  /// No description provided for @configCurrencyCOP.
  ///
  /// In es, this message translates to:
  /// **'Peso Colombiano'**
  String get configCurrencyCOP;

  /// No description provided for @configCurrencyUSD.
  ///
  /// In es, this message translates to:
  /// **'Dólar estadounidense'**
  String get configCurrencyUSD;

  /// No description provided for @configCurrencyEUR.
  ///
  /// In es, this message translates to:
  /// **'Euro'**
  String get configCurrencyEUR;

  /// No description provided for @configLogoutDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get configLogoutDialogTitle;

  /// No description provided for @configLogoutDialogContent.
  ///
  /// In es, this message translates to:
  /// **'Se cerrará tu sesión en la aplicación.'**
  String get configLogoutDialogContent;

  /// No description provided for @addExpenseInvalidAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido'**
  String get addExpenseInvalidAmount;

  /// No description provided for @addExpenseTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar gasto'**
  String get addExpenseTitle;

  /// No description provided for @addExpenseSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra un nuevo gasto real de este viaje'**
  String get addExpenseSubtitle;

  /// No description provided for @addExpenseCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get addExpenseCategoryLabel;

  /// No description provided for @addExpenseAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get addExpenseAmountLabel;

  /// No description provided for @addExpenseAmountHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 50000'**
  String get addExpenseAmountHint;

  /// No description provided for @addExpenseDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha del gasto'**
  String get addExpenseDateLabel;

  /// No description provided for @addExpenseDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get addExpenseDescriptionLabel;

  /// No description provided for @addExpenseDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Cena en el centro'**
  String get addExpenseDescriptionHint;

  /// No description provided for @addExpenseAddButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get addExpenseAddButton;

  /// No description provided for @mapScreenUserHereLabel.
  ///
  /// In es, this message translates to:
  /// **'Tú estás aquí'**
  String get mapScreenUserHereLabel;

  /// No description provided for @mapScreenActionEnableGps.
  ///
  /// In es, this message translates to:
  /// **'Activar GPS'**
  String get mapScreenActionEnableGps;

  /// No description provided for @mapScreenActionAllow.
  ///
  /// In es, this message translates to:
  /// **'Permitir'**
  String get mapScreenActionAllow;

  /// No description provided for @mapScreenActionSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get mapScreenActionSettings;

  /// No description provided for @mapScreenLocationServiceDisabled.
  ///
  /// In es, this message translates to:
  /// **'El GPS está desactivado. Actívalo para ver tu ubicación.'**
  String get mapScreenLocationServiceDisabled;

  /// No description provided for @mapScreenLocationPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos permiso de ubicación para centrar el mapa en ti.'**
  String get mapScreenLocationPermissionDenied;

  /// No description provided for @mapScreenLocationPermissionDeniedForever.
  ///
  /// In es, this message translates to:
  /// **'El permiso de ubicación está bloqueado. Actívalo desde los ajustes de la app.'**
  String get mapScreenLocationPermissionDeniedForever;

  /// No description provided for @mapScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mapScreenTitle;

  /// No description provided for @mapScreenSearchingNearbyPlaces.
  ///
  /// In es, this message translates to:
  /// **'Buscando lugares cercanos...'**
  String get mapScreenSearchingNearbyPlaces;

  /// No description provided for @mapScreenPlacesFoundCount.
  ///
  /// In es, this message translates to:
  /// **'{count} lugar(es) encontrados'**
  String mapScreenPlacesFoundCount(int count);

  /// No description provided for @comerciosCercanosLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los comercios. Intenta de nuevo.'**
  String get comerciosCercanosLoadError;

  /// No description provided for @comerciosCercanosPlacesCountLabel.
  ///
  /// In es, this message translates to:
  /// **'{count} LUGAR(ES)'**
  String comerciosCercanosPlacesCountLabel(int count);

  /// No description provided for @comerciosCercanosHeaderTitle1.
  ///
  /// In es, this message translates to:
  /// **'Cerca '**
  String get comerciosCercanosHeaderTitle1;

  /// No description provided for @comerciosCercanosHeaderTitle2.
  ///
  /// In es, this message translates to:
  /// **'de ti'**
  String get comerciosCercanosHeaderTitle2;

  /// No description provided for @comerciosCercanosHeaderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Comercios y lugares verificados cerca de tu ubicación.'**
  String get comerciosCercanosHeaderSubtitle;

  /// No description provided for @comerciosCercanosTagVerified.
  ///
  /// In es, this message translates to:
  /// **'Verificado'**
  String get comerciosCercanosTagVerified;

  /// No description provided for @comerciosCercanosTagOpenNow.
  ///
  /// In es, this message translates to:
  /// **'Abierto ahora'**
  String get comerciosCercanosTagOpenNow;

  /// No description provided for @comerciosCercanosRetryLabel.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get comerciosCercanosRetryLabel;

  /// No description provided for @comerciosCercanosEmptyAll.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay comercios ni lugares registrados'**
  String get comerciosCercanosEmptyAll;

  /// No description provided for @comerciosCercanosEmptyCategory.
  ///
  /// In es, this message translates to:
  /// **'No hay lugares en esta categoría'**
  String get comerciosCercanosEmptyCategory;

  /// No description provided for @comerciosCercanosEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otra categoría o vuelve más tarde.'**
  String get comerciosCercanosEmptyHint;

  /// No description provided for @comerciosCercanosTitle.
  ///
  /// In es, this message translates to:
  /// **'Comercios cercanos'**
  String get comerciosCercanosTitle;

  /// No description provided for @comerciosCercanosNearYourLocation.
  ///
  /// In es, this message translates to:
  /// **'Cerca de tu ubicación actual'**
  String get comerciosCercanosNearYourLocation;

  /// No description provided for @comerciosCercanosLocationUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Ubicación no disponible'**
  String get comerciosCercanosLocationUnavailable;

  /// No description provided for @comerciosCercanosPlacesFoundCount.
  ///
  /// In es, this message translates to:
  /// **'{count} lugar(es) encontrados'**
  String comerciosCercanosPlacesFoundCount(int count);

  /// No description provided for @placeDetailsErrorOpenMap.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el mapa.'**
  String get placeDetailsErrorOpenMap;

  /// No description provided for @placeDetailsCategoryDistance.
  ///
  /// In es, this message translates to:
  /// **'{category} · a {distance} de ti'**
  String placeDetailsCategoryDistance(String category, String distance);

  /// No description provided for @placeDetailsDirectionsButton.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get placeDetailsDirectionsButton;

  /// No description provided for @placeDetailsActivitiesTitle.
  ///
  /// In es, this message translates to:
  /// **'Actividades disponibles'**
  String get placeDetailsActivitiesTitle;

  /// No description provided for @placeDetailsNoActivities.
  ///
  /// In es, this message translates to:
  /// **'Sin actividades registradas todavía.'**
  String get placeDetailsNoActivities;

  /// No description provided for @locationPickerErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener tu ubicación. Toca el mapa para ubicar tu negocio manualmente.'**
  String get locationPickerErrorSnackbar;

  /// No description provided for @locationPickerHintTapMap.
  ///
  /// In es, this message translates to:
  /// **'Toca el mapa o usa el botón para ubicar tu negocio.'**
  String get locationPickerHintTapMap;

  /// No description provided for @locationPickerSelectedLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación seleccionada: {lat}, {lng} (puedes arrastrar el marcador para ajustar)'**
  String locationPickerSelectedLocation(String lat, String lng);

  /// No description provided for @appShellNavHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get appShellNavHome;

  /// No description provided for @appShellNavMyTrips.
  ///
  /// In es, this message translates to:
  /// **'Mis viajes'**
  String get appShellNavMyTrips;

  /// No description provided for @appShellNavCommerces.
  ///
  /// In es, this message translates to:
  /// **'Comercios'**
  String get appShellNavCommerces;

  /// No description provided for @appShellNavMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get appShellNavMap;

  /// No description provided for @appShellNavSectionLabel.
  ///
  /// In es, this message translates to:
  /// **'NAVEGACIÓN'**
  String get appShellNavSectionLabel;

  /// No description provided for @appShellCreateTripButton.
  ///
  /// In es, this message translates to:
  /// **'Crear viaje'**
  String get appShellCreateTripButton;

  /// No description provided for @appShellBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'PRESUPUESTO {month}'**
  String appShellBudgetLabel(String month);

  /// No description provided for @appShellBudgetPercentOf.
  ///
  /// In es, this message translates to:
  /// **'{percent}% de {amount}'**
  String appShellBudgetPercentOf(int percent, String amount);

  /// No description provided for @appShellNoActiveTrip.
  ///
  /// In es, this message translates to:
  /// **'Sin viaje activo'**
  String get appShellNoActiveTrip;

  /// No description provided for @appShellRoleTourist.
  ///
  /// In es, this message translates to:
  /// **'Turista'**
  String get appShellRoleTourist;

  /// No description provided for @appShellRoleCommerce.
  ///
  /// In es, this message translates to:
  /// **'Comercio'**
  String get appShellRoleCommerce;

  /// No description provided for @appShellSettingsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get appShellSettingsTooltip;

  /// No description provided for @appShellSignOutTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get appShellSignOutTooltip;

  /// No description provided for @appShellSignOutDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get appShellSignOutDialogTitle;

  /// No description provided for @appShellSignOutDialogContent.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cerrar tu sesión?'**
  String get appShellSignOutDialogContent;

  /// No description provided for @appShellCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get appShellCancelButton;

  /// No description provided for @appShellSignOutConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get appShellSignOutConfirmButton;

  /// No description provided for @appShellSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar viajes, comercios o ciudades'**
  String get appShellSearchHint;

  /// No description provided for @appShellMonthJan.
  ///
  /// In es, this message translates to:
  /// **'ene'**
  String get appShellMonthJan;

  /// No description provided for @appShellMonthFeb.
  ///
  /// In es, this message translates to:
  /// **'feb'**
  String get appShellMonthFeb;

  /// No description provided for @appShellMonthMar.
  ///
  /// In es, this message translates to:
  /// **'mar'**
  String get appShellMonthMar;

  /// No description provided for @appShellMonthApr.
  ///
  /// In es, this message translates to:
  /// **'abr'**
  String get appShellMonthApr;

  /// No description provided for @appShellMonthMay.
  ///
  /// In es, this message translates to:
  /// **'may'**
  String get appShellMonthMay;

  /// No description provided for @appShellMonthJun.
  ///
  /// In es, this message translates to:
  /// **'jun'**
  String get appShellMonthJun;

  /// No description provided for @appShellMonthJul.
  ///
  /// In es, this message translates to:
  /// **'jul'**
  String get appShellMonthJul;

  /// No description provided for @appShellMonthAug.
  ///
  /// In es, this message translates to:
  /// **'ago'**
  String get appShellMonthAug;

  /// No description provided for @appShellMonthSep.
  ///
  /// In es, this message translates to:
  /// **'sep'**
  String get appShellMonthSep;

  /// No description provided for @appShellMonthOct.
  ///
  /// In es, this message translates to:
  /// **'oct'**
  String get appShellMonthOct;

  /// No description provided for @appShellMonthNov.
  ///
  /// In es, this message translates to:
  /// **'nov'**
  String get appShellMonthNov;

  /// No description provided for @appShellMonthDec.
  ///
  /// In es, this message translates to:
  /// **'dic'**
  String get appShellMonthDec;

  /// No description provided for @appShellWeekdayMonday.
  ///
  /// In es, this message translates to:
  /// **'lunes'**
  String get appShellWeekdayMonday;

  /// No description provided for @appShellWeekdayTuesday.
  ///
  /// In es, this message translates to:
  /// **'martes'**
  String get appShellWeekdayTuesday;

  /// No description provided for @appShellWeekdayWednesday.
  ///
  /// In es, this message translates to:
  /// **'miércoles'**
  String get appShellWeekdayWednesday;

  /// No description provided for @appShellWeekdayThursday.
  ///
  /// In es, this message translates to:
  /// **'jueves'**
  String get appShellWeekdayThursday;

  /// No description provided for @appShellWeekdayFriday.
  ///
  /// In es, this message translates to:
  /// **'viernes'**
  String get appShellWeekdayFriday;

  /// No description provided for @appShellWeekdaySaturday.
  ///
  /// In es, this message translates to:
  /// **'sábado'**
  String get appShellWeekdaySaturday;

  /// No description provided for @appShellWeekdaySunday.
  ///
  /// In es, this message translates to:
  /// **'domingo'**
  String get appShellWeekdaySunday;

  /// No description provided for @floatingNavBarHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get floatingNavBarHome;

  /// No description provided for @floatingNavBarMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get floatingNavBarMap;

  /// No description provided for @floatingNavBarCommerces.
  ///
  /// In es, this message translates to:
  /// **'Comercios'**
  String get floatingNavBarCommerces;

  /// No description provided for @floatingNavBarCreateTripSemanticLabel.
  ///
  /// In es, this message translates to:
  /// **'Crear viaje'**
  String get floatingNavBarCreateTripSemanticLabel;

  /// No description provided for @createActivityDatePickerHelpText.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una fecha'**
  String get createActivityDatePickerHelpText;

  /// No description provided for @createActivityDatePickerCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get createActivityDatePickerCancel;

  /// No description provided for @createActivityDatePickerConfirm.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get createActivityDatePickerConfirm;

  /// No description provided for @createActivityStartDateSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de inicio de la actividad.'**
  String get createActivityStartDateSnackbar;

  /// No description provided for @createActivityEndDateSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de finalización o marca \"Sin fecha de fin\".'**
  String get createActivityEndDateSnackbar;

  /// No description provided for @createActivityAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear actividad'**
  String get createActivityAppBarTitle;

  /// No description provided for @createActivityHeading.
  ///
  /// In es, this message translates to:
  /// **'Nueva actividad'**
  String get createActivityHeading;

  /// No description provided for @createActivitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Completa la información para publicar una actividad para los turistas.'**
  String get createActivitySubtitle;

  /// No description provided for @createActivityNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la actividad'**
  String get createActivityNameLabel;

  /// No description provided for @createActivityNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Happy Hour'**
  String get createActivityNameHint;

  /// No description provided for @createActivityNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre de la actividad'**
  String get createActivityNameRequired;

  /// No description provided for @createActivityDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get createActivityDescriptionLabel;

  /// No description provided for @createActivityDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Explica de qué trata la actividad'**
  String get createActivityDescriptionHint;

  /// No description provided for @createActivityDescriptionRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una descripción'**
  String get createActivityDescriptionRequired;

  /// No description provided for @createActivityDescriptionTooShort.
  ///
  /// In es, this message translates to:
  /// **'La descripción debe ser más detallada'**
  String get createActivityDescriptionTooShort;

  /// No description provided for @createActivityCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo o categoría'**
  String get createActivityCategoryLabel;

  /// No description provided for @createActivityCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una categoría'**
  String get createActivityCategoryHint;

  /// No description provided for @createActivityCategoryRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una categoría'**
  String get createActivityCategoryRequired;

  /// No description provided for @createActivityPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get createActivityPriceLabel;

  /// No description provided for @createActivityPriceHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 25000'**
  String get createActivityPriceHint;

  /// No description provided for @createActivityPriceRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el precio o marca \"Gratis\"'**
  String get createActivityPriceRequired;

  /// No description provided for @createActivityPriceInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un precio válido'**
  String get createActivityPriceInvalid;

  /// No description provided for @createActivityFreeCheckbox.
  ///
  /// In es, this message translates to:
  /// **'Actividad gratuita'**
  String get createActivityFreeCheckbox;

  /// No description provided for @createActivityStartDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get createActivityStartDateLabel;

  /// No description provided for @createActivityStartDateHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de inicio'**
  String get createActivityStartDateHint;

  /// No description provided for @createActivityStartDateRequired.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de inicio'**
  String get createActivityStartDateRequired;

  /// No description provided for @createActivityEndDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de finalización'**
  String get createActivityEndDateLabel;

  /// No description provided for @createActivityEndDateHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de finalización'**
  String get createActivityEndDateHint;

  /// No description provided for @createActivityNoEndDateCheckbox.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de fin'**
  String get createActivityNoEndDateCheckbox;

  /// No description provided for @createActivityStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado de la actividad'**
  String get createActivityStatusLabel;

  /// No description provided for @createActivityCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get createActivityCancelButton;

  /// No description provided for @createActivityCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get createActivityCreateButton;

  /// No description provided for @createMenuAddProductDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get createMenuAddProductDialogTitle;

  /// No description provided for @createMenuProductNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del producto'**
  String get createMenuProductNameLabel;

  /// No description provided for @createMenuProductNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Hamburguesa clásica'**
  String get createMenuProductNameHint;

  /// No description provided for @createMenuProductDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get createMenuProductDescriptionLabel;

  /// No description provided for @createMenuProductDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe el producto'**
  String get createMenuProductDescriptionHint;

  /// No description provided for @createMenuProductPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get createMenuProductPriceLabel;

  /// No description provided for @createMenuProductPriceHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 18000'**
  String get createMenuProductPriceHint;

  /// No description provided for @createMenuCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get createMenuCancelButton;

  /// No description provided for @createMenuFieldsInvalidSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Completa correctamente todos los campos.'**
  String get createMenuFieldsInvalidSnackbar;

  /// No description provided for @createMenuNegativePriceSnackbar.
  ///
  /// In es, this message translates to:
  /// **'El precio no puede ser negativo.'**
  String get createMenuNegativePriceSnackbar;

  /// No description provided for @createMenuAddProductButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get createMenuAddProductButton;

  /// No description provided for @createMenuNoProductsSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un producto al menú.'**
  String get createMenuNoProductsSnackbar;

  /// No description provided for @createMenuAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear menú'**
  String get createMenuAppBarTitle;

  /// No description provided for @createMenuHeading.
  ///
  /// In es, this message translates to:
  /// **'Nuevo menú'**
  String get createMenuHeading;

  /// No description provided for @createMenuSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea un menú para mostrar tus productos a los turistas.'**
  String get createMenuSubtitle;

  /// No description provided for @createMenuNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del menú'**
  String get createMenuNameLabel;

  /// No description provided for @createMenuNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Menú de comidas rápidas'**
  String get createMenuNameHint;

  /// No description provided for @createMenuNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre del menú'**
  String get createMenuNameRequired;

  /// No description provided for @createMenuDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get createMenuDescriptionLabel;

  /// No description provided for @createMenuDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe de qué trata este menú'**
  String get createMenuDescriptionHint;

  /// No description provided for @createMenuDescriptionRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una descripción'**
  String get createMenuDescriptionRequired;

  /// No description provided for @createMenuCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get createMenuCategoryLabel;

  /// No description provided for @createMenuProductsHeading.
  ///
  /// In es, this message translates to:
  /// **'Productos del menú'**
  String get createMenuProductsHeading;

  /// No description provided for @createMenuProductsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} productos'**
  String createMenuProductsCount(int count);

  /// No description provided for @createMenuEmptyProductsTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay productos'**
  String get createMenuEmptyProductsTitle;

  /// No description provided for @createMenuEmptyProductsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Agrega los productos que formarán parte de este menú.'**
  String get createMenuEmptyProductsSubtitle;

  /// No description provided for @createMenuAddProductLabel.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get createMenuAddProductLabel;

  /// No description provided for @createMenuAvailableTitle.
  ///
  /// In es, this message translates to:
  /// **'Menú disponible'**
  String get createMenuAvailableTitle;

  /// No description provided for @createMenuAvailableSubtitleOn.
  ///
  /// In es, this message translates to:
  /// **'Los turistas podrán verlo.'**
  String get createMenuAvailableSubtitleOn;

  /// No description provided for @createMenuAvailableSubtitleOff.
  ///
  /// In es, this message translates to:
  /// **'El menú estará oculto.'**
  String get createMenuAvailableSubtitleOff;

  /// No description provided for @createMenuCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Crear menú'**
  String get createMenuCreateButton;

  /// No description provided for @homeComercioSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get homeComercioSignOut;

  /// No description provided for @homeComercioSignOutDialogContent.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cerrar tu sesión?'**
  String get homeComercioSignOutDialogContent;

  /// No description provided for @homeComercioCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get homeComercioCancelButton;

  /// No description provided for @homeComercioActivityCreatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Actividad \"{name}\" creada'**
  String homeComercioActivityCreatedSnackbar(String name);

  /// No description provided for @homeComercioCreateFirstMenuSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer menú'**
  String get homeComercioCreateFirstMenuSnackbar;

  /// No description provided for @homeComercioAddMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar menú'**
  String get homeComercioAddMenuTitle;

  /// No description provided for @homeComercioAddMenuDescription.
  ///
  /// In es, this message translates to:
  /// **'Crea y gestiona los platos, bebidas y servicios que ofrece tu negocio.'**
  String get homeComercioAddMenuDescription;

  /// No description provided for @homeComercioAddMenuButton.
  ///
  /// In es, this message translates to:
  /// **'+ Menú'**
  String get homeComercioAddMenuButton;

  /// No description provided for @homeComercioMenuCreatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Menú \"{name}\" creado'**
  String homeComercioMenuCreatedSnackbar(String name);

  /// No description provided for @homeComercioCreateActivityTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear actividad'**
  String get homeComercioCreateActivityTitle;

  /// No description provided for @homeComercioCreateActivityDescription.
  ///
  /// In es, this message translates to:
  /// **'Organiza eventos, promociones y actividades especiales para tus clientes.'**
  String get homeComercioCreateActivityDescription;

  /// No description provided for @homeComercioCreateActivityButton.
  ///
  /// In es, this message translates to:
  /// **'+ Actividad'**
  String get homeComercioCreateActivityButton;

  /// No description provided for @homeComercioMyActivitiesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis actividades'**
  String get homeComercioMyActivitiesTitle;

  /// No description provided for @homeComercioSeeAllButton.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get homeComercioSeeAllButton;

  /// No description provided for @homeComercioNoNameFallback.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre'**
  String get homeComercioNoNameFallback;

  /// No description provided for @homeComercioGreeting.
  ///
  /// In es, this message translates to:
  /// **'¡Hola, {businessName}!'**
  String homeComercioGreeting(String businessName);

  /// No description provided for @homeComercioHeroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tu negocio fácilmente'**
  String get homeComercioHeroSubtitle;

  /// No description provided for @homeComercioStatActivitiesLabel.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get homeComercioStatActivitiesLabel;

  /// No description provided for @homeComercioStatMenusLabel.
  ///
  /// In es, this message translates to:
  /// **'Menús creados'**
  String get homeComercioStatMenusLabel;

  /// No description provided for @homeComercioEmptyActivitiesTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes actividades'**
  String get homeComercioEmptyActivitiesTitle;

  /// No description provided for @homeComercioEmptyActivitiesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera actividad para tus visitantes.'**
  String get homeComercioEmptyActivitiesSubtitle;

  /// No description provided for @homeComercioNavHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeComercioNavHome;

  /// No description provided for @homeComercioNavActivities.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get homeComercioNavActivities;

  /// No description provided for @homeComercioNavMenu.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get homeComercioNavMenu;

  /// No description provided for @menuDetailAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del Menú'**
  String get menuDetailAppBarTitle;

  /// No description provided for @menuDetailStatusAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get menuDetailStatusAvailable;

  /// No description provided for @menuDetailStatusUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get menuDetailStatusUnavailable;

  /// No description provided for @menuDetailDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get menuDetailDescriptionLabel;

  /// No description provided for @menuDetailStatProductsLabel.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get menuDetailStatProductsLabel;

  /// No description provided for @menuDetailStatAverageLabel.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get menuDetailStatAverageLabel;

  /// No description provided for @menuDetailStatTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get menuDetailStatTotalLabel;

  /// No description provided for @menuDetailProductsCount.
  ///
  /// In es, this message translates to:
  /// **'Productos ({count})'**
  String menuDetailProductsCount(int count);

  /// No description provided for @menuDetailNoProductsTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay productos'**
  String get menuDetailNoProductsTitle;

  /// No description provided for @menuDetailFeatureInDevelopmentSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Función en desarrollo'**
  String get menuDetailFeatureInDevelopmentSnackbar;

  /// No description provided for @menuDetailEditButton.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get menuDetailEditButton;

  /// No description provided for @menuDetailDeleteButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get menuDetailDeleteButton;

  /// No description provided for @menuDetailDeleteDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar menú'**
  String get menuDetailDeleteDialogTitle;

  /// No description provided for @menuDetailDeleteDialogContent.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar el menú \"{name}\"? Esta acción no se puede deshacer.'**
  String menuDetailDeleteDialogContent(String name);

  /// No description provided for @menuDetailCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get menuDetailCancelButton;

  /// No description provided for @menuDetailMenuDeletedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Menú eliminado'**
  String get menuDetailMenuDeletedSnackbar;

  /// No description provided for @createTripBarrierLabel.
  ///
  /// In es, this message translates to:
  /// **'Crear viaje'**
  String get createTripBarrierLabel;

  /// No description provided for @createTripStep0TitleLine1.
  ///
  /// In es, this message translates to:
  /// **'¿A dónde'**
  String get createTripStep0TitleLine1;

  /// No description provided for @createTripStep0TitleLine2.
  ///
  /// In es, this message translates to:
  /// **'vamos?'**
  String get createTripStep0TitleLine2;

  /// No description provided for @createTripStep1TitleLine1.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde'**
  String get createTripStep1TitleLine1;

  /// No description provided for @createTripStep1TitleLine2.
  ///
  /// In es, this message translates to:
  /// **'dormimos?'**
  String get createTripStep1TitleLine2;

  /// No description provided for @createTripStep2TitleLine1.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo nos'**
  String get createTripStep2TitleLine1;

  /// No description provided for @createTripStep2TitleLine2.
  ///
  /// In es, this message translates to:
  /// **'movemos?'**
  String get createTripStep2TitleLine2;

  /// No description provided for @createTripStepNameDestination.
  ///
  /// In es, this message translates to:
  /// **'Destino y fechas'**
  String get createTripStepNameDestination;

  /// No description provided for @createTripStepNameLodging.
  ///
  /// In es, this message translates to:
  /// **'Hospedaje'**
  String get createTripStepNameLodging;

  /// No description provided for @createTripStepNameTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get createTripStepNameTransport;

  /// No description provided for @createTripErrorSelectStartDateFirst.
  ///
  /// In es, this message translates to:
  /// **'Primero selecciona la fecha de inicio'**
  String get createTripErrorSelectStartDateFirst;

  /// No description provided for @createTripErrorNameDestinationRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre y el destino del viaje'**
  String get createTripErrorNameDestinationRequired;

  /// No description provided for @createTripErrorInvalidDates.
  ///
  /// In es, this message translates to:
  /// **'Selecciona fechas válidas'**
  String get createTripErrorInvalidDates;

  /// No description provided for @createTripErrorEndDateAfterStart.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin debe ser posterior a la de inicio'**
  String get createTripErrorEndDateAfterStart;

  /// No description provided for @createTripErrorMinOnePerson.
  ///
  /// In es, this message translates to:
  /// **'Debe haber mínimo 1 persona'**
  String get createTripErrorMinOnePerson;

  /// No description provided for @createTripErrorRequiredFields.
  ///
  /// In es, this message translates to:
  /// **'Debe completar todos los campos obligatorios'**
  String get createTripErrorRequiredFields;

  /// No description provided for @createTripErrorBudgetMustBePositive.
  ///
  /// In es, this message translates to:
  /// **'El presupuesto debe ser mayor a 0'**
  String get createTripErrorBudgetMustBePositive;

  /// No description provided for @createTripErrorInvalidDatesEntered.
  ///
  /// In es, this message translates to:
  /// **'Las fechas ingresadas no son válidas'**
  String get createTripErrorInvalidDatesEntered;

  /// No description provided for @createTripErrorEndDateAfterStartFull.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin debe ser posterior a la fecha de inicio'**
  String get createTripErrorEndDateAfterStartFull;

  /// No description provided for @createTripErrorLodgingCostMustBePositive.
  ///
  /// In es, this message translates to:
  /// **'El costo debe ser mayor a 0'**
  String get createTripErrorLodgingCostMustBePositive;

  /// No description provided for @createTripErrorEmergencyAmountMustBePositive.
  ///
  /// In es, this message translates to:
  /// **'El monto debe ser mayor a 0'**
  String get createTripErrorEmergencyAmountMustBePositive;

  /// No description provided for @createTripIncompleteDataDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos incompletos'**
  String get createTripIncompleteDataDialogTitle;

  /// No description provided for @createTripIncompleteDataDialogContent.
  ///
  /// In es, this message translates to:
  /// **'La estimación será menos precisa. ¿Deseas continuar?'**
  String get createTripIncompleteDataDialogContent;

  /// No description provided for @createTripCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get createTripCancelButton;

  /// No description provided for @createTripConfirmCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Sí, crear viaje'**
  String get createTripConfirmCreateButton;

  /// No description provided for @createTripErrorMustBeLoggedIn.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión como turista para crear un viaje.'**
  String get createTripErrorMustBeLoggedIn;

  /// No description provided for @createTripCreatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'¡Viaje creado! Presupuesto total: {amount}'**
  String createTripCreatedSnackbar(String amount);

  /// No description provided for @createTripErrorSaveGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el viaje. Intenta nuevamente.'**
  String get createTripErrorSaveGeneric;

  /// No description provided for @createTripErrorDbOutdated.
  ///
  /// In es, this message translates to:
  /// **'La base de datos no está actualizada para guardar el viaje (falta una columna o tabla). Revisa docs/db/hu05_viajes_costos.sql.'**
  String get createTripErrorDbOutdated;

  /// No description provided for @createTripErrorNoPermission.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para guardar el viaje (revisa las políticas de seguridad de la tabla viajes en Supabase).'**
  String get createTripErrorNoPermission;

  /// No description provided for @createTripErrorNotRegisteredAsTourist.
  ///
  /// In es, this message translates to:
  /// **'Tu usuario no está registrado como turista todavía.'**
  String get createTripErrorNotRegisteredAsTourist;

  /// No description provided for @createTripCancelDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro?'**
  String get createTripCancelDialogTitle;

  /// No description provided for @createTripCancelDialogContent.
  ///
  /// In es, this message translates to:
  /// **'Se descartarán los datos ingresados.'**
  String get createTripCancelDialogContent;

  /// No description provided for @createTripCancelDialogNoButton.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get createTripCancelDialogNoButton;

  /// No description provided for @createTripCancelDialogConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Sí, descartar'**
  String get createTripCancelDialogConfirmButton;

  /// No description provided for @createTripStepIndicator.
  ///
  /// In es, this message translates to:
  /// **'PASO {current} DE {total}'**
  String createTripStepIndicator(int current, int total);

  /// No description provided for @createTripBackButton.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get createTripBackButton;

  /// No description provided for @createTripNextStepLabel.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE · {stepName}'**
  String createTripNextStepLabel(String stepName);

  /// No description provided for @createTripContinueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar →'**
  String get createTripContinueButton;

  /// No description provided for @createTripCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Crear viaje'**
  String get createTripCreateButton;

  /// No description provided for @createTripNextLabel.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE'**
  String get createTripNextLabel;

  /// No description provided for @createTripDoneLabel.
  ///
  /// In es, this message translates to:
  /// **'LISTO'**
  String get createTripDoneLabel;

  /// No description provided for @createTripNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del viaje'**
  String get createTripNameLabel;

  /// No description provided for @createTripNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Viaje a Cartagena'**
  String get createTripNameHint;

  /// No description provided for @createTripDestinationLabel.
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get createTripDestinationLabel;

  /// No description provided for @createTripDestinationHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Cartagena, Colombia'**
  String get createTripDestinationHint;

  /// No description provided for @createTripStartDateLabel.
  ///
  /// In es, this message translates to:
  /// **'INICIO'**
  String get createTripStartDateLabel;

  /// No description provided for @createTripEndDateLabel.
  ///
  /// In es, this message translates to:
  /// **'FIN'**
  String get createTripEndDateLabel;

  /// No description provided for @createTripDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración: {days, plural, one{{days} día} other{{days} días}}'**
  String createTripDurationLabel(num days);

  /// No description provided for @createTripTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'TIPO DE VIAJE'**
  String get createTripTypeLabel;

  /// No description provided for @createTripLodgingTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'TIPO DE HOSPEDAJE'**
  String get createTripLodgingTypeLabel;

  /// No description provided for @createTripLodgingCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo hospedaje'**
  String get createTripLodgingCostLabel;

  /// No description provided for @createTripLodgingCostHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 2000000'**
  String get createTripLodgingCostHint;

  /// No description provided for @createTripAdvancePaymentLabel.
  ///
  /// In es, this message translates to:
  /// **'Pagos anticipados'**
  String get createTripAdvancePaymentLabel;

  /// No description provided for @createTripAdvancePaymentHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 1500000'**
  String get createTripAdvancePaymentHint;

  /// No description provided for @createTripIncludedServicesLabel.
  ///
  /// In es, this message translates to:
  /// **'SERVICIOS INCLUIDOS'**
  String get createTripIncludedServicesLabel;

  /// No description provided for @createTripServiceBreakfast.
  ///
  /// In es, this message translates to:
  /// **'Desayuno'**
  String get createTripServiceBreakfast;

  /// No description provided for @createTripServiceLunch.
  ///
  /// In es, this message translates to:
  /// **'Almuerzo'**
  String get createTripServiceLunch;

  /// No description provided for @createTripServiceDinner.
  ///
  /// In es, this message translates to:
  /// **'Cena'**
  String get createTripServiceDinner;

  /// No description provided for @createTripServiceTransfer.
  ///
  /// In es, this message translates to:
  /// **'Traslado'**
  String get createTripServiceTransfer;

  /// No description provided for @createTripStartTransportLabel.
  ///
  /// In es, this message translates to:
  /// **'TRANSPORTE DE INICIO'**
  String get createTripStartTransportLabel;

  /// No description provided for @createTripDuringTransportLabel.
  ///
  /// In es, this message translates to:
  /// **'TRANSPORTE DURANTE EL VIAJE'**
  String get createTripDuringTransportLabel;

  /// No description provided for @createTripAdditionalExpensesLabel.
  ///
  /// In es, this message translates to:
  /// **'GASTOS ADICIONALES'**
  String get createTripAdditionalExpensesLabel;

  /// No description provided for @createTripAddButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get createTripAddButton;

  /// No description provided for @createTripEmergencyMoneyLabel.
  ///
  /// In es, this message translates to:
  /// **'Dinero emergencias'**
  String get createTripEmergencyMoneyLabel;

  /// No description provided for @createTripEmergencyMoneyHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 500000'**
  String get createTripEmergencyMoneyHint;

  /// No description provided for @createTripPersonsLabel.
  ///
  /// In es, this message translates to:
  /// **'PERSONAS'**
  String get createTripPersonsLabel;

  /// No description provided for @createTripMaxBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'PRESUPUESTO MÁXIMO'**
  String get createTripMaxBudgetLabel;

  /// No description provided for @createTripCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get createTripCategoryLabel;

  /// No description provided for @createTripCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Transporte interno'**
  String get createTripCategoryHint;

  /// No description provided for @createTripAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get createTripAmountLabel;

  /// No description provided for @createTripCategoryAmountHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 500000'**
  String get createTripCategoryAmountHint;

  /// No description provided for @createTripRemoveCategoryTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar categoría'**
  String get createTripRemoveCategoryTooltip;

  /// No description provided for @createTripBudgetSummaryPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Define el presupuesto máximo en el paso 1 para ver aquí el resumen.'**
  String get createTripBudgetSummaryPlaceholder;

  /// No description provided for @createTripBudgetSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen de presupuesto'**
  String get createTripBudgetSummaryTitle;

  /// No description provided for @createTripEstimatedLabel.
  ///
  /// In es, this message translates to:
  /// **'Estimado (con lo ingresado)'**
  String get createTripEstimatedLabel;

  /// No description provided for @createTripOverBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'Te excedes por'**
  String get createTripOverBudgetLabel;

  /// No description provided for @createTripAvailableLabel.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get createTripAvailableLabel;

  /// No description provided for @createTripOverBudgetWarning.
  ///
  /// In es, this message translates to:
  /// **'Lo estimado supera tu presupuesto máximo.'**
  String get createTripOverBudgetWarning;

  /// No description provided for @createTripEnterDatesForDailyBudget.
  ///
  /// In es, this message translates to:
  /// **'Ingresa las fechas del viaje para ver el presupuesto por día.'**
  String get createTripEnterDatesForDailyBudget;

  /// No description provided for @createTripRemainingBudgetSplitLabel.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto restante, repartido en:'**
  String get createTripRemainingBudgetSplitLabel;

  /// No description provided for @createTripPerDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Por día ({days} días)'**
  String createTripPerDayLabel(int days);

  /// No description provided for @createTripPerPersonLabel.
  ///
  /// In es, this message translates to:
  /// **'Por persona ({persons})'**
  String createTripPerPersonLabel(int persons);

  /// No description provided for @createTripPerPersonPerDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Por persona, por día'**
  String get createTripPerPersonPerDayLabel;

  /// No description provided for @editTripBudgetErrorMaxBudgetPositive.
  ///
  /// In es, this message translates to:
  /// **'El presupuesto máximo debe ser mayor a 0'**
  String get editTripBudgetErrorMaxBudgetPositive;

  /// No description provided for @editTripBudgetErrorMustBeLoggedIn.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para guardar cambios.'**
  String get editTripBudgetErrorMustBeLoggedIn;

  /// No description provided for @editTripBudgetErrorSaveGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el presupuesto. Intenta de nuevo.'**
  String get editTripBudgetErrorSaveGeneric;

  /// No description provided for @editTripBudgetTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar presupuesto'**
  String get editTripBudgetTitle;

  /// No description provided for @editTripBudgetMaxBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto máximo'**
  String get editTripBudgetMaxBudgetLabel;

  /// No description provided for @editTripBudgetAdvancePaymentLabel.
  ///
  /// In es, this message translates to:
  /// **'Pagos anticipados'**
  String get editTripBudgetAdvancePaymentLabel;

  /// No description provided for @editTripBudgetLodgingCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo hospedaje'**
  String get editTripBudgetLodgingCostLabel;

  /// No description provided for @editTripBudgetEmergencyMoneyLabel.
  ///
  /// In es, this message translates to:
  /// **'Dinero emergencias'**
  String get editTripBudgetEmergencyMoneyLabel;

  /// No description provided for @editTripBudgetCategoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Categorías de gasto'**
  String get editTripBudgetCategoriesTitle;

  /// No description provided for @editTripBudgetAddButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get editTripBudgetAddButton;

  /// No description provided for @editTripBudgetEstimatedLabel.
  ///
  /// In es, this message translates to:
  /// **'Estimado'**
  String get editTripBudgetEstimatedLabel;

  /// No description provided for @editTripBudgetOverBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'Te excedes por'**
  String get editTripBudgetOverBudgetLabel;

  /// No description provided for @editTripBudgetAvailableLabel.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get editTripBudgetAvailableLabel;

  /// No description provided for @editTripBudgetPerDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Por día ({days}d)'**
  String editTripBudgetPerDayLabel(int days);

  /// No description provided for @editTripBudgetPerPersonLabel.
  ///
  /// In es, this message translates to:
  /// **'Por persona ({persons})'**
  String editTripBudgetPerPersonLabel(int persons);

  /// No description provided for @editTripBudgetSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get editTripBudgetSaveButton;

  /// No description provided for @editTripBudgetCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get editTripBudgetCategoryLabel;

  /// No description provided for @editTripBudgetAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get editTripBudgetAmountLabel;

  /// No description provided for @editTripBudgetRemoveCategoryTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar categoría'**
  String get editTripBudgetRemoveCategoryTooltip;

  /// No description provided for @homeClientSignOutDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get homeClientSignOutDialogTitle;

  /// No description provided for @homeClientSignOutDialogContent.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cerrar tu sesión?'**
  String get homeClientSignOutDialogContent;

  /// No description provided for @homeClientCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get homeClientCancelButton;

  /// No description provided for @homeClientSignOutConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get homeClientSignOutConfirmButton;

  /// No description provided for @homeClientCreateTripFirstSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Crea un viaje primero para poder registrar un gasto.'**
  String get homeClientCreateTripFirstSnackbar;

  /// No description provided for @homeClientPickTripTitle.
  ///
  /// In es, this message translates to:
  /// **'¿A qué viaje pertenece?'**
  String get homeClientPickTripTitle;

  /// No description provided for @homeClientPickTripSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige el viaje para registrar el gasto.'**
  String get homeClientPickTripSubtitle;

  /// No description provided for @homeClientTripNotSavedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Este viaje no quedó guardado en el servidor; no se pueden registrar gastos.'**
  String get homeClientTripNotSavedSnackbar;

  /// No description provided for @homeClientCategoriesLoadErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las categorías de gasto.'**
  String get homeClientCategoriesLoadErrorSnackbar;

  /// No description provided for @homeClientExpenseAddedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Gasto de {amount} en {category} agregado a {tripName}'**
  String homeClientExpenseAddedSnackbar(
    String amount,
    String category,
    String tripName,
  );

  /// No description provided for @homeClientExpenseSaveErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el gasto. Intenta de nuevo.'**
  String get homeClientExpenseSaveErrorSnackbar;

  /// No description provided for @homeClientGreeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}.'**
  String homeClientGreeting(String name);

  /// No description provided for @homeClientActiveTripsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{1 viaje activo} other{{count} viajes activos}}'**
  String homeClientActiveTripsCount(int count);

  /// No description provided for @homeClientMyTripsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis viajes'**
  String get homeClientMyTripsTitle;

  /// No description provided for @homeClientViewAllLabel.
  ///
  /// In es, this message translates to:
  /// **'VER TODOS'**
  String get homeClientViewAllLabel;

  /// No description provided for @homeClientNoTripsTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes viajes'**
  String get homeClientNoTripsTitle;

  /// No description provided for @homeClientNoTripsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer viaje para comenzar a planificar.'**
  String get homeClientNoTripsSubtitle;

  /// No description provided for @homeClientCreateTripLabel.
  ///
  /// In es, this message translates to:
  /// **'Crear viaje'**
  String get homeClientCreateTripLabel;

  /// No description provided for @homeClientNearbyTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerca de ti'**
  String get homeClientNearbyTitle;

  /// No description provided for @homeClientNoNearbyPlaces.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay comercios ni lugares cerca registrados.'**
  String get homeClientNoNearbyPlaces;

  /// No description provided for @homeClientVerifiedTag.
  ///
  /// In es, this message translates to:
  /// **'Verificado'**
  String get homeClientVerifiedTag;

  /// No description provided for @homeClientViewPlacesButton.
  ///
  /// In es, this message translates to:
  /// **'Ver los {count} lugares →'**
  String homeClientViewPlacesButton(int count);

  /// No description provided for @homeClientExploreTagline.
  ///
  /// In es, this message translates to:
  /// **'Explora, planifica y viaja seguro.'**
  String get homeClientExploreTagline;

  /// No description provided for @homeClientContextLineDays.
  ///
  /// In es, this message translates to:
  /// **'{destination} empieza en {days, plural, one{{days} día} other{{days} días}}. El presupuesto va al {pct}%.'**
  String homeClientContextLineDays(String destination, num days, int pct);

  /// No description provided for @homeClientContextLineNoDays.
  ///
  /// In es, this message translates to:
  /// **'{destination} · el presupuesto va al {pct}%.'**
  String homeClientContextLineNoDays(String destination, int pct);

  /// No description provided for @homeClientCreateTripCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear un viaje'**
  String get homeClientCreateTripCardTitle;

  /// No description provided for @homeClientCreateTripCardDescription.
  ///
  /// In es, this message translates to:
  /// **'Organiza tu próxima aventura, establece tu presupuesto y descubre los mejores destinos.'**
  String get homeClientCreateTripCardDescription;

  /// No description provided for @homeClientCreateTripButtonPlus.
  ///
  /// In es, this message translates to:
  /// **'+ Crear viaje'**
  String get homeClientCreateTripButtonPlus;

  /// No description provided for @homeClientCreateTripCardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto, hospedaje e itinerario en 3 pasos'**
  String get homeClientCreateTripCardSubtitle;

  /// No description provided for @homeClientMapCardTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get homeClientMapCardTitle;

  /// No description provided for @homeClientMapCardDescription.
  ///
  /// In es, this message translates to:
  /// **'Explora destinos, encuentra comercios seguros y planifica tu ruta.'**
  String get homeClientMapCardDescription;

  /// No description provided for @homeClientViewMapButton.
  ///
  /// In es, this message translates to:
  /// **'Ver mapa'**
  String get homeClientViewMapButton;

  /// No description provided for @homeClientMapCardPlacesCount.
  ///
  /// In es, this message translates to:
  /// **'14 lugares cerca'**
  String get homeClientMapCardPlacesCount;

  /// No description provided for @homeClientNextExpenseLabel.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMO GASTO'**
  String get homeClientNextExpenseLabel;

  /// No description provided for @homeClientLodgingFallback.
  ///
  /// In es, this message translates to:
  /// **'Hospedaje'**
  String get homeClientLodgingFallback;

  /// No description provided for @homeClientLodgingPaymentDue.
  ///
  /// In es, this message translates to:
  /// **'Se paga antes del {date} · {amount}'**
  String homeClientLodgingPaymentDue(String date, String amount);

  /// No description provided for @homeClientRegisterExpenseHint.
  ///
  /// In es, this message translates to:
  /// **'Registra un gasto de tu viaje en segundos.'**
  String get homeClientRegisterExpenseHint;

  /// No description provided for @homeClientSignOutButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get homeClientSignOutButton;

  /// No description provided for @homeClientMobileGreeting.
  ///
  /// In es, this message translates to:
  /// **'¡Hola, {name}!'**
  String homeClientMobileGreeting(String name);

  /// No description provided for @homeClientMobileHeroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Explora, planifica y viaja seguro'**
  String get homeClientMobileHeroSubtitle;

  /// No description provided for @homeClientStatActiveTripsLabel.
  ///
  /// In es, this message translates to:
  /// **'Viajes activos'**
  String get homeClientStatActiveTripsLabel;

  /// No description provided for @homeClientStatNextTripLabel.
  ///
  /// In es, this message translates to:
  /// **'Próximo viaje'**
  String get homeClientStatNextTripLabel;

  /// No description provided for @homeClientStatTotalBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto total'**
  String get homeClientStatTotalBudgetLabel;

  /// No description provided for @homeClientViewAllMobileLabel.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get homeClientViewAllMobileLabel;

  /// No description provided for @homeClientMonthAbbrJan.
  ///
  /// In es, this message translates to:
  /// **'Ene'**
  String get homeClientMonthAbbrJan;

  /// No description provided for @homeClientMonthAbbrFeb.
  ///
  /// In es, this message translates to:
  /// **'Feb'**
  String get homeClientMonthAbbrFeb;

  /// No description provided for @homeClientMonthAbbrMar.
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get homeClientMonthAbbrMar;

  /// No description provided for @homeClientMonthAbbrApr.
  ///
  /// In es, this message translates to:
  /// **'Abr'**
  String get homeClientMonthAbbrApr;

  /// No description provided for @homeClientMonthAbbrMay.
  ///
  /// In es, this message translates to:
  /// **'May'**
  String get homeClientMonthAbbrMay;

  /// No description provided for @homeClientMonthAbbrJun.
  ///
  /// In es, this message translates to:
  /// **'Jun'**
  String get homeClientMonthAbbrJun;

  /// No description provided for @homeClientMonthAbbrJul.
  ///
  /// In es, this message translates to:
  /// **'Jul'**
  String get homeClientMonthAbbrJul;

  /// No description provided for @homeClientMonthAbbrAug.
  ///
  /// In es, this message translates to:
  /// **'Ago'**
  String get homeClientMonthAbbrAug;

  /// No description provided for @homeClientMonthAbbrSep.
  ///
  /// In es, this message translates to:
  /// **'Sep'**
  String get homeClientMonthAbbrSep;

  /// No description provided for @homeClientMonthAbbrOct.
  ///
  /// In es, this message translates to:
  /// **'Oct'**
  String get homeClientMonthAbbrOct;

  /// No description provided for @homeClientMonthAbbrNov.
  ///
  /// In es, this message translates to:
  /// **'Nov'**
  String get homeClientMonthAbbrNov;

  /// No description provided for @homeClientMonthAbbrDec.
  ///
  /// In es, this message translates to:
  /// **'Dic'**
  String get homeClientMonthAbbrDec;

  /// No description provided for @tripDetailTripNotSavedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Este viaje no quedó guardado en el servidor; no se pueden registrar gastos.'**
  String get tripDetailTripNotSavedSnackbar;

  /// No description provided for @tripDetailLoadExpensesError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los gastos.'**
  String get tripDetailLoadExpensesError;

  /// No description provided for @tripDetailLoadGroupError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el grupo del viaje.'**
  String get tripDetailLoadGroupError;

  /// No description provided for @tripDetailInviteDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Invitar colaborador'**
  String get tripDetailInviteDialogTitle;

  /// No description provided for @tripDetailInviteEmailHint.
  ///
  /// In es, this message translates to:
  /// **'correo@ejemplo.com'**
  String get tripDetailInviteEmailHint;

  /// No description provided for @tripDetailInviteEmailHelper.
  ///
  /// In es, this message translates to:
  /// **'Debe estar registrado en TravelGuard como turista.'**
  String get tripDetailInviteEmailHelper;

  /// No description provided for @tripDetailCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get tripDetailCancelButton;

  /// No description provided for @tripDetailInviteButton.
  ///
  /// In es, this message translates to:
  /// **'Invitar'**
  String get tripDetailInviteButton;

  /// No description provided for @tripDetailCollaboratorAddedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'{name} ahora puede ver y editar este viaje'**
  String tripDetailCollaboratorAddedSnackbar(String name);

  /// No description provided for @tripDetailInviteErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo invitar a esa persona. Intenta de nuevo.'**
  String get tripDetailInviteErrorSnackbar;

  /// No description provided for @tripDetailRemoveCollaboratorDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Quitar colaborador'**
  String get tripDetailRemoveCollaboratorDialogTitle;

  /// No description provided for @tripDetailRemoveCollaboratorDialogContent.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar a {name} de este viaje? Dejará de poder verlo y editarlo.'**
  String tripDetailRemoveCollaboratorDialogContent(String name);

  /// No description provided for @tripDetailRemoveButton.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get tripDetailRemoveButton;

  /// No description provided for @tripDetailRemoveCollaboratorErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo quitar al colaborador.'**
  String get tripDetailRemoveCollaboratorErrorSnackbar;

  /// No description provided for @tripDetailCategoriesLoadErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las categorías de gasto.'**
  String get tripDetailCategoriesLoadErrorSnackbar;

  /// No description provided for @tripDetailExpenseAddedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Gasto de {amount} en {category} agregado'**
  String tripDetailExpenseAddedSnackbar(String amount, String category);

  /// No description provided for @tripDetailExpenseSaveErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el gasto. Intenta de nuevo.'**
  String get tripDetailExpenseSaveErrorSnackbar;

  /// No description provided for @tripDetailDeleteExpenseDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar gasto'**
  String get tripDetailDeleteExpenseDialogTitle;

  /// No description provided for @tripDetailDeleteExpenseDialogContent.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar el gasto de {amount} en {category}?'**
  String tripDetailDeleteExpenseDialogContent(String amount, String category);

  /// No description provided for @tripDetailDeleteButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get tripDetailDeleteButton;

  /// No description provided for @tripDetailDeleteExpenseErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el gasto.'**
  String get tripDetailDeleteExpenseErrorSnackbar;

  /// No description provided for @tripDetailDeleteTripDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar viaje'**
  String get tripDetailDeleteTripDialogTitle;

  /// No description provided for @tripDetailDeleteTripDialogContent.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar el viaje \"{name}\"? Esta acción no se puede deshacer.'**
  String tripDetailDeleteTripDialogContent(String name);

  /// No description provided for @tripDetailTripDeletedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Viaje eliminado'**
  String get tripDetailTripDeletedSnackbar;

  /// No description provided for @tripDetailDeleteTripErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar el viaje. Intenta de nuevo.'**
  String get tripDetailDeleteTripErrorSnackbar;

  /// No description provided for @tripDetailTabResumen.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get tripDetailTabResumen;

  /// No description provided for @tripDetailTabHospedaje.
  ///
  /// In es, this message translates to:
  /// **'Hospedaje'**
  String get tripDetailTabHospedaje;

  /// No description provided for @tripDetailTabTransporte.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get tripDetailTabTransporte;

  /// No description provided for @tripDetailTabGastos.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get tripDetailTabGastos;

  /// No description provided for @tripDetailTabGrupo.
  ///
  /// In es, this message translates to:
  /// **'Grupo'**
  String get tripDetailTabGrupo;

  /// No description provided for @tripDetailBreadcrumbHome.
  ///
  /// In es, this message translates to:
  /// **'INICIO / MIS VIAJES'**
  String get tripDetailBreadcrumbHome;

  /// No description provided for @tripDetailEditButton.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get tripDetailEditButton;

  /// No description provided for @tripDetailAddExpenseButton.
  ///
  /// In es, this message translates to:
  /// **'Añadir gasto'**
  String get tripDetailAddExpenseButton;

  /// No description provided for @tripDetailHeaderTripToPrefix.
  ///
  /// In es, this message translates to:
  /// **'Viaje a '**
  String get tripDetailHeaderTripToPrefix;

  /// No description provided for @tripDetailHeaderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{startDate} – {endDate} · {persons, plural, one{{persons} PERSONA} other{{persons} PERSONAS}} · {tripType}'**
  String tripDetailHeaderSubtitle(
    String startDate,
    String endDate,
    num persons,
    String tripType,
  );

  /// No description provided for @tripDetailSpentLabel.
  ///
  /// In es, this message translates to:
  /// **'GASTADO'**
  String get tripDetailSpentLabel;

  /// No description provided for @tripDetailCapLabel.
  ///
  /// In es, this message translates to:
  /// **'TOPE'**
  String get tripDetailCapLabel;

  /// No description provided for @tripDetailOverBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'Te pasaste del tope por {amount}'**
  String tripDetailOverBudgetLabel(String amount);

  /// No description provided for @tripDetailOnTrackLabel.
  ///
  /// In es, this message translates to:
  /// **'Vas bien: {pct}% del presupuesto usado'**
  String tripDetailOnTrackLabel(int pct);

  /// No description provided for @tripDetailLodgingTitle.
  ///
  /// In es, this message translates to:
  /// **'Hospedaje'**
  String get tripDetailLodgingTitle;

  /// No description provided for @tripDetailLodgingTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get tripDetailLodgingTypeLabel;

  /// No description provided for @tripDetailCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get tripDetailCostLabel;

  /// No description provided for @tripDetailTransportLabel.
  ///
  /// In es, this message translates to:
  /// **'TRANSPORTE'**
  String get tripDetailTransportLabel;

  /// No description provided for @tripDetailDuringTransportDetail.
  ///
  /// In es, this message translates to:
  /// **'Durante: {value}'**
  String tripDetailDuringTransportDetail(String value);

  /// No description provided for @tripDetailPersonsLabel.
  ///
  /// In es, this message translates to:
  /// **'PERSONAS'**
  String get tripDetailPersonsLabel;

  /// No description provided for @tripDetailRecentExpensesTitle.
  ///
  /// In es, this message translates to:
  /// **'Últimos gastos'**
  String get tripDetailRecentExpensesTitle;

  /// No description provided for @tripDetailNoExpensesYetHint.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado gastos. Usa \"Añadir gasto\" arriba para anotar el primero.'**
  String get tripDetailNoExpensesYetHint;

  /// No description provided for @tripDetailAvailableBudgetTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto disponible'**
  String get tripDetailAvailableBudgetTitle;

  /// No description provided for @tripDetailPerDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Por día ({days} días)'**
  String tripDetailPerDayLabel(int days);

  /// No description provided for @tripDetailPerPersonLabel.
  ///
  /// In es, this message translates to:
  /// **'Por persona ({persons})'**
  String tripDetailPerPersonLabel(int persons);

  /// No description provided for @tripDetailExpenseBreakdownTitle.
  ///
  /// In es, this message translates to:
  /// **'Desglose de gastos'**
  String get tripDetailExpenseBreakdownTitle;

  /// No description provided for @tripDetailNoExpensesRegistered.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos registrados aún.'**
  String get tripDetailNoExpensesRegistered;

  /// No description provided for @tripDetailAdvancePayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos anticipados'**
  String get tripDetailAdvancePayments;

  /// No description provided for @tripDetailLodgingPlanned.
  ///
  /// In es, this message translates to:
  /// **'Hospedaje (planeado)'**
  String get tripDetailLodgingPlanned;

  /// No description provided for @tripDetailEmergencies.
  ///
  /// In es, this message translates to:
  /// **'Emergencias'**
  String get tripDetailEmergencies;

  /// No description provided for @tripDetailCategoryRealSuffix.
  ///
  /// In es, this message translates to:
  /// **'{category} (real)'**
  String tripDetailCategoryRealSuffix(String category);

  /// No description provided for @tripDetailLodgingTypeFullLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de hospedaje'**
  String get tripDetailLodgingTypeFullLabel;

  /// No description provided for @tripDetailIncludedServicesLabel.
  ///
  /// In es, this message translates to:
  /// **'Servicios incluidos'**
  String get tripDetailIncludedServicesLabel;

  /// No description provided for @tripDetailTransportTabTitle.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get tripDetailTransportTabTitle;

  /// No description provided for @tripDetailStartTransportLabel.
  ///
  /// In es, this message translates to:
  /// **'Transporte de inicio'**
  String get tripDetailStartTransportLabel;

  /// No description provided for @tripDetailDuringTransportKvLabel.
  ///
  /// In es, this message translates to:
  /// **'Transporte durante el viaje'**
  String get tripDetailDuringTransportKvLabel;

  /// No description provided for @tripDetailExpensesRegisteredTitle.
  ///
  /// In es, this message translates to:
  /// **'Gastos registrados'**
  String get tripDetailExpensesRegisteredTitle;

  /// No description provided for @tripDetailTripNotSavedExpensesHint.
  ///
  /// In es, this message translates to:
  /// **'Este viaje no quedó guardado en el servidor, así que no se pueden registrar gastos reales.'**
  String get tripDetailTripNotSavedExpensesHint;

  /// No description provided for @tripDetailRetryButton.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get tripDetailRetryButton;

  /// No description provided for @tripDetailNoRealExpensesYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no has registrado gastos reales para este viaje.'**
  String get tripDetailNoRealExpensesYet;

  /// No description provided for @tripDetailDeleteExpenseTooltip.
  ///
  /// In es, this message translates to:
  /// **'Eliminar gasto'**
  String get tripDetailDeleteExpenseTooltip;

  /// No description provided for @tripDetailInvalidDatesHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega fechas válidas para ver tu ritmo de gasto.'**
  String get tripDetailInvalidDatesHint;

  /// No description provided for @tripDetailTripStartsIn.
  ///
  /// In es, this message translates to:
  /// **'Tu viaje empieza en {days, plural, one{{days} día} other{{days} días}}.'**
  String tripDetailTripStartsIn(num days);

  /// No description provided for @tripDetailTripEnded.
  ///
  /// In es, this message translates to:
  /// **'Este viaje ya terminó.'**
  String get tripDetailTripEnded;

  /// No description provided for @tripDetailDaysRemaining.
  ///
  /// In es, this message translates to:
  /// **'Quedan {days, plural, one{{days} día} other{{days} días}} de viaje.'**
  String tripDetailDaysRemaining(num days);

  /// No description provided for @tripDetailGroupDailySpendLabel.
  ///
  /// In es, this message translates to:
  /// **'Grupo debería gastar/día'**
  String get tripDetailGroupDailySpendLabel;

  /// No description provided for @tripDetailPerPersonDailyLabel.
  ///
  /// In es, this message translates to:
  /// **'Por persona/día'**
  String get tripDetailPerPersonDailyLabel;

  /// No description provided for @tripDetailSpendingPaceTitle.
  ///
  /// In es, this message translates to:
  /// **'Ritmo de gasto'**
  String get tripDetailSpendingPaceTitle;

  /// No description provided for @tripDetailSpentPerPersonLabel.
  ///
  /// In es, this message translates to:
  /// **'Llevas gastado por persona'**
  String get tripDetailSpentPerPersonLabel;

  /// No description provided for @tripDetailForeignTouristQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Eres turista extranjero?'**
  String get tripDetailForeignTouristQuestion;

  /// No description provided for @tripDetailTaxRefundWithPurchases.
  ///
  /// In es, this message translates to:
  /// **'De lo que llevas en \"Compras\" ({comprasTotal}), aprox. {ivaEstimado} fue IVA — en Colombia los turistas extranjeros no residentes pueden pedirlo de vuelta completo antes de salir del país.'**
  String tripDetailTaxRefundWithPurchases(
    String comprasTotal,
    String ivaEstimado,
  );

  /// No description provided for @tripDetailTaxRefundNoPurchases.
  ///
  /// In es, this message translates to:
  /// **'Cuando registres compras (ropa, calzado, artesanías, joyería, electrodomésticos, etc.) con factura electrónica, aquí verás cuánto IVA podrías recuperar antes de salir del país.'**
  String get tripDetailTaxRefundNoPurchases;

  /// No description provided for @tripDetailTaxRefundRequirements.
  ///
  /// In es, this message translates to:
  /// **'Requisitos: factura electrónica de mínimo {minPurchase} por compra, pasaporte o Tarjeta Andina Migratoria, y solicitarlo en la DIAN del aeropuerto antes de viajar. Tope: {maxRefund} por solicitud. Verifica el trámite vigente en dian.gov.co.'**
  String tripDetailTaxRefundRequirements(String minPurchase, String maxRefund);

  /// No description provided for @tripDetailCollaboratorsTitle.
  ///
  /// In es, this message translates to:
  /// **'Colaboradores'**
  String get tripDetailCollaboratorsTitle;

  /// No description provided for @tripDetailCollaboratorsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Quiénes pueden ver y editar este viaje'**
  String get tripDetailCollaboratorsSubtitle;

  /// No description provided for @tripDetailOwnerTag.
  ///
  /// In es, this message translates to:
  /// **'Dueño'**
  String get tripDetailOwnerTag;

  /// No description provided for @tripDetailYouTag.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get tripDetailYouTag;

  /// No description provided for @tripDetailRemoveCollaboratorTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar colaborador'**
  String get tripDetailRemoveCollaboratorTooltip;

  /// No description provided for @tripDetailHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de cambios'**
  String get tripDetailHistoryTitle;

  /// No description provided for @tripDetailNoHistoryYet.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay cambios registrados. Cuando alguien edite el presupuesto, quedará aquí.'**
  String get tripDetailNoHistoryYet;

  /// No description provided for @tripDetailHistoryChangedText.
  ///
  /// In es, this message translates to:
  /// **' cambió '**
  String get tripDetailHistoryChangedText;

  /// No description provided for @tripDetailJustNow.
  ///
  /// In es, this message translates to:
  /// **'Justo ahora'**
  String get tripDetailJustNow;

  /// No description provided for @tripDetailMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutes} min'**
  String tripDetailMinutesAgo(int minutes);

  /// No description provided for @tripDetailHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours} h'**
  String tripDetailHoursAgo(int hours);

  /// No description provided for @tripDetailYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get tripDetailYesterday;

  /// No description provided for @tripDetailDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {days} días'**
  String tripDetailDaysAgo(int days);

  /// No description provided for @tripDetailMobileAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del Viaje'**
  String get tripDetailMobileAppBarTitle;

  /// No description provided for @tripDetailEditBudgetTooltip.
  ///
  /// In es, this message translates to:
  /// **'Editar presupuesto'**
  String get tripDetailEditBudgetTooltip;

  /// No description provided for @tripDetailMoreTooltip.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get tripDetailMoreTooltip;

  /// No description provided for @tripDetailBudgetTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get tripDetailBudgetTitle;

  /// No description provided for @tripDetailSpentKvLabel.
  ///
  /// In es, this message translates to:
  /// **'Gastado'**
  String get tripDetailSpentKvLabel;

  /// No description provided for @tripDetailAvailableKvLabel.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get tripDetailAvailableKvLabel;

  /// No description provided for @tripDetailBudgetUsedPercent.
  ///
  /// In es, this message translates to:
  /// **'{percent}% del presupuesto utilizado'**
  String tripDetailBudgetUsedPercent(String percent);

  /// No description provided for @desglosePresupuestoTitle.
  ///
  /// In es, this message translates to:
  /// **'Desglose de Presupuesto'**
  String get desglosePresupuestoTitle;

  /// No description provided for @desglosePresupuestoHospedaje.
  ///
  /// In es, this message translates to:
  /// **'Hospedaje'**
  String get desglosePresupuestoHospedaje;

  /// No description provided for @desglosePresupuestoTransporte.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get desglosePresupuestoTransporte;

  /// No description provided for @desglosePresupuestoComidas.
  ///
  /// In es, this message translates to:
  /// **'Comidas'**
  String get desglosePresupuestoComidas;

  /// No description provided for @desglosePresupuestoActividades.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get desglosePresupuestoActividades;

  /// No description provided for @desglosePresupuestoEmergencias.
  ///
  /// In es, this message translates to:
  /// **'Emergencias'**
  String get desglosePresupuestoEmergencias;

  /// No description provided for @tripHistoryPresupuestoMaximo.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto máximo'**
  String get tripHistoryPresupuestoMaximo;

  /// No description provided for @tripHistoryPagosAnticipados.
  ///
  /// In es, this message translates to:
  /// **'Pagos anticipados'**
  String get tripHistoryPagosAnticipados;

  /// No description provided for @tripHistoryCostoHospedaje.
  ///
  /// In es, this message translates to:
  /// **'Costo hospedaje'**
  String get tripHistoryCostoHospedaje;

  /// No description provided for @tripHistoryDineroEmergencias.
  ///
  /// In es, this message translates to:
  /// **'Dinero emergencias'**
  String get tripHistoryDineroEmergencias;

  /// No description provided for @tripHistoryCategoriasPresupuesto.
  ///
  /// In es, this message translates to:
  /// **'Categorías de presupuesto'**
  String get tripHistoryCategoriasPresupuesto;

  /// No description provided for @categoryFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get categoryFilterAll;

  /// No description provided for @placeCategoryComercio.
  ///
  /// In es, this message translates to:
  /// **'Comercio'**
  String get placeCategoryComercio;

  /// No description provided for @placeCategoryDiscoteca.
  ///
  /// In es, this message translates to:
  /// **'Discoteca'**
  String get placeCategoryDiscoteca;

  /// No description provided for @placeCategoryMirador.
  ///
  /// In es, this message translates to:
  /// **'Mirador'**
  String get placeCategoryMirador;

  /// No description provided for @placeCategoryMuseo.
  ///
  /// In es, this message translates to:
  /// **'Museo'**
  String get placeCategoryMuseo;

  /// No description provided for @placeCategoryOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get placeCategoryOtro;

  /// No description provided for @placeCategoryParque.
  ///
  /// In es, this message translates to:
  /// **'Parque'**
  String get placeCategoryParque;

  /// No description provided for @placeCategoryRestaurante.
  ///
  /// In es, this message translates to:
  /// **'Restaurante'**
  String get placeCategoryRestaurante;

  /// No description provided for @placeCategoryTour.
  ///
  /// In es, this message translates to:
  /// **'Tour'**
  String get placeCategoryTour;

  /// No description provided for @placeCategoryHotel.
  ///
  /// In es, this message translates to:
  /// **'Hotel'**
  String get placeCategoryHotel;

  /// No description provided for @placeCategoryTienda.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get placeCategoryTienda;

  /// No description provided for @placeCategoryTransporte.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get placeCategoryTransporte;

  /// No description provided for @configSectionReset.
  ///
  /// In es, this message translates to:
  /// **'Restablecer'**
  String get configSectionReset;

  /// No description provided for @configResetDefaultsLabel.
  ///
  /// In es, this message translates to:
  /// **'Restaurar valores predeterminados'**
  String get configResetDefaultsLabel;

  /// No description provided for @configResetDefaultsDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Restaurar valores predeterminados?'**
  String get configResetDefaultsDialogTitle;

  /// No description provided for @configResetDefaultsDialogContent.
  ///
  /// In es, this message translates to:
  /// **'Se restablecerán el idioma, la moneda y las notificaciones a sus valores originales.'**
  String get configResetDefaultsDialogContent;

  /// No description provided for @configResetDefaultsConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get configResetDefaultsConfirmButton;

  /// No description provided for @configResetDefaultsSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Configuración restaurada'**
  String get configResetDefaultsSnackbar;

  /// No description provided for @configExchangeRateLabel.
  ///
  /// In es, this message translates to:
  /// **'Tasa de cambio'**
  String get configExchangeRateLabel;

  /// No description provided for @configExchangeRatePreview.
  ///
  /// In es, this message translates to:
  /// **'1 USD = {rate}'**
  String configExchangeRatePreview(String rate);

  /// No description provided for @configExchangeRateDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Tasa de cambio'**
  String get configExchangeRateDialogTitle;

  /// No description provided for @configExchangeRateDialogHint.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a ningún servicio: ingresa tú mismo cuántos pesos colombianos equivalen a 1 dólar y a 1 euro. Solo cambia cómo se ven los montos en la app — lo guardado en tus viajes y gastos sigue siendo el valor real en pesos.'**
  String get configExchangeRateDialogHint;

  /// No description provided for @configExchangeRateUsdLabel.
  ///
  /// In es, this message translates to:
  /// **'1 USD equivale a (COP)'**
  String get configExchangeRateUsdLabel;

  /// No description provided for @configExchangeRateEurLabel.
  ///
  /// In es, this message translates to:
  /// **'1 EUR equivale a (COP)'**
  String get configExchangeRateEurLabel;

  /// No description provided for @configExchangeRateInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa valores válidos, mayores a 0'**
  String get configExchangeRateInvalid;

  /// No description provided for @configExchangeRateSavedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Tasa de cambio actualizada'**
  String get configExchangeRateSavedSnackbar;

  /// No description provided for @tripCardSpentOfBudget.
  ///
  /// In es, this message translates to:
  /// **'{spent} gastado de {maxBudget}'**
  String tripCardSpentOfBudget(String spent, String maxBudget);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recupera tu contraseña'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un enlace a tu correo para crear una nueva'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSubmitButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get forgotPasswordSubmitButton;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In es, this message translates to:
  /// **'Volver a iniciar sesión'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @forgotPasswordSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo'**
  String get forgotPasswordSuccessTitle;

  /// No description provided for @forgotPasswordSuccessBody.
  ///
  /// In es, this message translates to:
  /// **'Si {email} está registrado, te enviamos un enlace para restablecer tu contraseña. Revisa también la carpeta de spam.'**
  String forgotPasswordSuccessBody(String email);

  /// No description provided for @resetPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea una nueva contraseña'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una contraseña segura para tu cuenta'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordInvalidLink.
  ///
  /// In es, this message translates to:
  /// **'Este enlace ya no es válido. Solicita uno nuevo desde la pantalla de recuperación.'**
  String get resetPasswordInvalidLink;

  /// No description provided for @resetPasswordInvalidLinkTitle.
  ///
  /// In es, this message translates to:
  /// **'Enlace no válido'**
  String get resetPasswordInvalidLinkTitle;

  /// No description provided for @resetPasswordRequestNewLink.
  ///
  /// In es, this message translates to:
  /// **'Solicitar un nuevo enlace'**
  String get resetPasswordRequestNewLink;

  /// No description provided for @resetPasswordForEmail.
  ///
  /// In es, this message translates to:
  /// **'Restableciendo la contraseña de {email}'**
  String resetPasswordForEmail(String email);

  /// No description provided for @resetPasswordMinLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get resetPasswordMinLength;

  /// No description provided for @resetPasswordSubmitButton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get resetPasswordSubmitButton;

  /// No description provided for @resetPasswordSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada'**
  String get resetPasswordSuccessTitle;

  /// No description provided for @resetPasswordSuccessBody.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña se cambió correctamente. Ya puedes iniciar sesión con ella.'**
  String get resetPasswordSuccessBody;

  /// No description provided for @resetPasswordGoToLogin.
  ///
  /// In es, this message translates to:
  /// **'Ir a iniciar sesión'**
  String get resetPasswordGoToLogin;

  /// No description provided for @businessSettingsAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi negocio'**
  String get businessSettingsAppBarTitle;

  /// No description provided for @businessSettingsNameRequiredSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre del negocio'**
  String get businessSettingsNameRequiredSnackbar;

  /// No description provided for @businessSettingsSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos generales'**
  String get businessSettingsSectionTitle;

  /// No description provided for @businessSettingsSectionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Actualiza la información que verán tus clientes.'**
  String get businessSettingsSectionSubtitle;

  /// No description provided for @businessSettingsNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del negocio'**
  String get businessSettingsNameLabel;

  /// No description provided for @businessSettingsNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Restaurante El Sabor'**
  String get businessSettingsNameHint;

  /// No description provided for @businessSettingsScheduleLabel.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get businessSettingsScheduleLabel;

  /// No description provided for @businessSettingsScheduleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Lunes a sábado 8:00 AM - 8:00 PM'**
  String get businessSettingsScheduleHint;

  /// No description provided for @businessSettingsContactLabel.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get businessSettingsContactLabel;

  /// No description provided for @businessSettingsContactHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 300 123 4567'**
  String get businessSettingsContactHint;

  /// No description provided for @businessSettingsSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get businessSettingsSaveButton;

  /// No description provided for @subscriptionsAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Planes y suscripciones premium'**
  String get subscriptionsAppBarTitle;

  /// No description provided for @subscriptionsHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige tu plan perfecto para mejorar tu experiencia en la aplicación'**
  String get subscriptionsHeaderTitle;

  /// No description provided for @subscriptionsHeaderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Acceso a todas las características de viajes y experiencias'**
  String get subscriptionsHeaderSubtitle;

  /// No description provided for @subscriptionsBillingMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get subscriptionsBillingMonthly;

  /// No description provided for @subscriptionsBillingAnnual.
  ///
  /// In es, this message translates to:
  /// **'Anual (-20%)'**
  String get subscriptionsBillingAnnual;

  /// No description provided for @subscriptionsPlanTouristName.
  ///
  /// In es, this message translates to:
  /// **'Turista'**
  String get subscriptionsPlanTouristName;

  /// No description provided for @subscriptionsPlanTouristSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Perfecto para exploradores'**
  String get subscriptionsPlanTouristSubtitle;

  /// No description provided for @subscriptionsPeriodMonth.
  ///
  /// In es, this message translates to:
  /// **'/mes'**
  String get subscriptionsPeriodMonth;

  /// No description provided for @subscriptionsPeriodYear.
  ///
  /// In es, this message translates to:
  /// **'/año'**
  String get subscriptionsPeriodYear;

  /// No description provided for @subscriptionsFeatureMobile1.
  ///
  /// In es, this message translates to:
  /// **'Busca viajes y experiencias'**
  String get subscriptionsFeatureMobile1;

  /// No description provided for @subscriptionsFeatureMobile2.
  ///
  /// In es, this message translates to:
  /// **'Califica y comenta'**
  String get subscriptionsFeatureMobile2;

  /// No description provided for @subscriptionsFeatureMobile3.
  ///
  /// In es, this message translates to:
  /// **'Guarda favoritos'**
  String get subscriptionsFeatureMobile3;

  /// No description provided for @subscriptionsFeatureMobile4.
  ///
  /// In es, this message translates to:
  /// **'Acceso móvil completo'**
  String get subscriptionsFeatureMobile4;

  /// No description provided for @subscriptionsFeatureMobile5.
  ///
  /// In es, this message translates to:
  /// **'Soporte por email'**
  String get subscriptionsFeatureMobile5;

  /// No description provided for @subscriptionsFeatureDesktop1.
  ///
  /// In es, this message translates to:
  /// **'Guarda tus lugares favoritos'**
  String get subscriptionsFeatureDesktop1;

  /// No description provided for @subscriptionsFeatureDesktop2.
  ///
  /// In es, this message translates to:
  /// **'Conoce en qué gastas más'**
  String get subscriptionsFeatureDesktop2;

  /// No description provided for @subscriptionsFeatureDesktop3.
  ///
  /// In es, this message translates to:
  /// **'Compara tu presupuesto y tus gastos'**
  String get subscriptionsFeatureDesktop3;

  /// No description provided for @subscriptionsFeatureDesktop4.
  ///
  /// In es, this message translates to:
  /// **'Escanea tus recibos automáticamente'**
  String get subscriptionsFeatureDesktop4;

  /// No description provided for @subscriptionsPlanSelectedButton.
  ///
  /// In es, this message translates to:
  /// **'Plan seleccionado'**
  String get subscriptionsPlanSelectedButton;

  /// No description provided for @subscriptionsPlanSelectButton.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get subscriptionsPlanSelectButton;

  /// No description provided for @subscriptionsFaqTitle.
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes'**
  String get subscriptionsFaqTitle;

  /// No description provided for @subscriptionsFaqChangePlanQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Puedo cambiar de plan en cualquier momento?'**
  String get subscriptionsFaqChangePlanQuestion;

  /// No description provided for @subscriptionsFaqChangePlanAnswer.
  ///
  /// In es, this message translates to:
  /// **'Sí, puedes cambiar o cancelar tu suscripción en cualquier momento desde tu configuración.'**
  String get subscriptionsFaqChangePlanAnswer;

  /// No description provided for @subscriptionsFaqFreeTrialQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Hay período de prueba gratuita?'**
  String get subscriptionsFaqFreeTrialQuestion;

  /// No description provided for @subscriptionsFaqFreeTrialAnswer.
  ///
  /// In es, this message translates to:
  /// **'No, actualmente no ofrecemos un período de prueba gratuita. Sin embargo, puedes cancelar tu suscripción en cualquier momento.'**
  String get subscriptionsFaqFreeTrialAnswer;

  /// No description provided for @subscriptionsFaqPaymentMethodsQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué métodos de pago aceptan?'**
  String get subscriptionsFaqPaymentMethodsQuestion;

  /// No description provided for @subscriptionsFaqPaymentMethodsAnswer.
  ///
  /// In es, this message translates to:
  /// **'Aceptamos tarjetas de crédito, débito, transferencia bancaria y billeteras digitales.'**
  String get subscriptionsFaqPaymentMethodsAnswer;

  /// No description provided for @subscriptionsFooterNote.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de plan en cualquier momento sin penalización'**
  String get subscriptionsFooterNote;

  /// No description provided for @subscriptionsDialogPlanTitle.
  ///
  /// In es, this message translates to:
  /// **'Plan {planName}'**
  String subscriptionsDialogPlanTitle(String planName);

  /// No description provided for @subscriptionsDialogPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio: {price}'**
  String subscriptionsDialogPriceLabel(String price);

  /// No description provided for @subscriptionsDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Al hacer clic en \"Continuar\", serás redirigido a la pasarela de pago para completar tu suscripción.'**
  String get subscriptionsDialogBody;

  /// No description provided for @subscriptionsDialogCancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get subscriptionsDialogCancelButton;

  /// No description provided for @subscriptionsDialogContinueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get subscriptionsDialogContinueButton;

  /// No description provided for @subscriptionsDialogRedirectingSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Redirigiendo a pasarela de pago...'**
  String get subscriptionsDialogRedirectingSnackbar;

  /// No description provided for @stepProgressLabel.
  ///
  /// In es, this message translates to:
  /// **'Paso'**
  String get stepProgressLabel;

  /// No description provided for @stepProgressStep1.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get stepProgressStep1;

  /// No description provided for @stepProgressStep2.
  ///
  /// In es, this message translates to:
  /// **'Fecha y precio'**
  String get stepProgressStep2;

  /// No description provided for @stepProgressStep3.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get stepProgressStep3;

  /// No description provided for @homeComercioBusinessSettingsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Mi negocio'**
  String get homeComercioBusinessSettingsTooltip;

  /// No description provided for @homeComercioBusinessUpdatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Datos del negocio actualizados'**
  String get homeComercioBusinessUpdatedSnackbar;
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
