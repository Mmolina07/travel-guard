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
  /// **'NIT inválido: usa solo números (5 a 15 dígitos)'**
  String get commerceRegisterNitInvalid;

  /// No description provided for @commerceRegisterEmailInvalidOrTaken.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido (ej. nombre@correo.com)'**
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
  /// **'Mostrar alertas'**
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
  /// **'Ingresa un monto mayor a 0'**
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

  /// No description provided for @addExpenseTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get addExpenseTimeLabel;

  /// No description provided for @addExpensePlaceLabel.
  ///
  /// In es, this message translates to:
  /// **'Establecimiento (opcional)'**
  String get addExpensePlaceLabel;

  /// No description provided for @addExpensePlaceHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Restaurante El Sabor'**
  String get addExpensePlaceHint;

  /// No description provided for @addExpensePaidByLabel.
  ///
  /// In es, this message translates to:
  /// **'¿Quién pagó?'**
  String get addExpensePaidByLabel;

  /// No description provided for @addExpensePaidWithTripMoney.
  ///
  /// In es, this message translates to:
  /// **'Pagado con dinero del viaje'**
  String get addExpensePaidWithTripMoney;

  /// No description provided for @addExpensePaidTripMoneyOn.
  ///
  /// In es, this message translates to:
  /// **'Salió del fondo común del viaje'**
  String get addExpensePaidTripMoneyOn;

  /// No description provided for @addExpensePaidTripMoneyOff.
  ///
  /// In es, this message translates to:
  /// **'Salió del bolsillo personal'**
  String get addExpensePaidTripMoneyOff;

  /// No description provided for @addExpensePaymentSourceLabel.
  ///
  /// In es, this message translates to:
  /// **'¿Con qué dinero pagas?'**
  String get addExpensePaymentSourceLabel;

  /// No description provided for @addExpenseSourceTrip.
  ///
  /// In es, this message translates to:
  /// **'Dinero del viaje'**
  String get addExpenseSourceTrip;

  /// No description provided for @addExpenseSourcePocket.
  ///
  /// In es, this message translates to:
  /// **'Mi bolsillo'**
  String get addExpenseSourcePocket;

  /// No description provided for @addExpenseSourceBalance.
  ///
  /// In es, this message translates to:
  /// **'Disponible: {amount}'**
  String addExpenseSourceBalance(String amount);

  /// No description provided for @addExpenseSourceNoPocket.
  ///
  /// In es, this message translates to:
  /// **'Aún sin bolsillo'**
  String get addExpenseSourceNoPocket;

  /// No description provided for @addExpensePocketMissing.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes bolsillo en este viaje. Créalo desde \"Mi bolsillo\".'**
  String get addExpensePocketMissing;

  /// No description provided for @addExpensePocketInsufficient.
  ///
  /// In es, this message translates to:
  /// **'Tu bolsillo solo tiene {balance} disponible.'**
  String addExpensePocketInsufficient(String balance);

  /// No description provided for @pocketButtonLabel.
  ///
  /// In es, this message translates to:
  /// **'Mi bolsillo'**
  String get pocketButtonLabel;

  /// No description provided for @pocketScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi bolsillo personal'**
  String get pocketScreenTitle;

  /// No description provided for @pocketPrivateNote.
  ///
  /// In es, this message translates to:
  /// **'Solo tú puedes ver este bolsillo.'**
  String get pocketPrivateNote;

  /// No description provided for @pocketEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes bolsillo en este viaje'**
  String get pocketEmptyTitle;

  /// No description provided for @pocketEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Crea tu bolsillo para guardar dinero propio y pagar gastos del viaje desde él.'**
  String get pocketEmptyDescription;

  /// No description provided for @pocketCreateButton.
  ///
  /// In es, this message translates to:
  /// **'Crear mi bolsillo'**
  String get pocketCreateButton;

  /// No description provided for @pocketBalanceLabel.
  ///
  /// In es, this message translates to:
  /// **'SALDO DISPONIBLE'**
  String get pocketBalanceLabel;

  /// No description provided for @pocketAddedLabel.
  ///
  /// In es, this message translates to:
  /// **'AGREGADO'**
  String get pocketAddedLabel;

  /// No description provided for @pocketSpentLabel.
  ///
  /// In es, this message translates to:
  /// **'GASTADO'**
  String get pocketSpentLabel;

  /// No description provided for @pocketAddMoneyButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar dinero'**
  String get pocketAddMoneyButton;

  /// No description provided for @pocketAddMoneyTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar dinero al bolsillo'**
  String get pocketAddMoneyTitle;

  /// No description provided for @pocketAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get pocketAmountLabel;

  /// No description provided for @pocketNoteLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota (opcional)'**
  String get pocketNoteLabel;

  /// No description provided for @pocketNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Efectivo para compras'**
  String get pocketNoteHint;

  /// No description provided for @pocketAddConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get pocketAddConfirmButton;

  /// No description provided for @pocketMovementsTitle.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get pocketMovementsTitle;

  /// No description provided for @pocketNoMovements.
  ///
  /// In es, this message translates to:
  /// **'Aún no has agregado dinero.'**
  String get pocketNoMovements;

  /// No description provided for @pocketLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar tu bolsillo.'**
  String get pocketLoadError;

  /// No description provided for @pocketSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar. Intenta de nuevo.'**
  String get pocketSaveError;

  /// No description provided for @pocketCreatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Bolsillo creado'**
  String get pocketCreatedSnackbar;

  /// No description provided for @pocketDepositAddedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Se agregó {amount} a tu bolsillo'**
  String pocketDepositAddedSnackbar(String amount);

  /// No description provided for @estimateScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Estimar presupuesto'**
  String get estimateScreenTitle;

  /// No description provided for @estimateEyebrow.
  ///
  /// In es, this message translates to:
  /// **'ESTIMADOR DE PRESUPUESTO'**
  String get estimateEyebrow;

  /// No description provided for @estimateTitleLine1.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto costará'**
  String get estimateTitleLine1;

  /// No description provided for @estimateTitleLine2.
  ///
  /// In es, this message translates to:
  /// **'tu viaje?'**
  String get estimateTitleLine2;

  /// No description provided for @estimateIntro.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos a dónde vas y te damos un estimado del alojamiento, la comida y el transporte.'**
  String get estimateIntro;

  /// No description provided for @estimateDestinationLabel.
  ///
  /// In es, this message translates to:
  /// **'DESTINO'**
  String get estimateDestinationLabel;

  /// No description provided for @estimateDestinationHint.
  ///
  /// In es, this message translates to:
  /// **'Busca una ciudad'**
  String get estimateDestinationHint;

  /// No description provided for @estimateDatesLabel.
  ///
  /// In es, this message translates to:
  /// **'FECHAS DEL VIAJE'**
  String get estimateDatesLabel;

  /// No description provided for @estimateDatesPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Selecciona ida y vuelta'**
  String get estimateDatesPlaceholder;

  /// No description provided for @estimateDatePickerHelp.
  ///
  /// In es, this message translates to:
  /// **'Fechas del viaje'**
  String get estimateDatePickerHelp;

  /// No description provided for @estimateDatePickerSave.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get estimateDatePickerSave;

  /// No description provided for @estimateDurationSummary.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, one{{days} día} other{{days} días}} · {nights, plural, one{{nights} noche} other{{nights} noches}}'**
  String estimateDurationSummary(int days, int nights);

  /// No description provided for @estimateTravelersLabel.
  ///
  /// In es, this message translates to:
  /// **'VIAJEROS'**
  String get estimateTravelersLabel;

  /// No description provided for @estimateTravelersCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{{count} viajero} other{{count} viajeros}}'**
  String estimateTravelersCount(int count);

  /// No description provided for @estimateTripTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'TIPO DE VIAJE'**
  String get estimateTripTypeLabel;

  /// No description provided for @estimateStyleEconomyTitle.
  ///
  /// In es, this message translates to:
  /// **'Económico'**
  String get estimateStyleEconomyTitle;

  /// No description provided for @estimateStyleEconomyCaption.
  ///
  /// In es, this message translates to:
  /// **'Hostales y comida local'**
  String get estimateStyleEconomyCaption;

  /// No description provided for @estimateStyleStandardTitle.
  ///
  /// In es, this message translates to:
  /// **'Estándar'**
  String get estimateStyleStandardTitle;

  /// No description provided for @estimateStyleStandardCaption.
  ///
  /// In es, this message translates to:
  /// **'Hoteles 3-4★'**
  String get estimateStyleStandardCaption;

  /// No description provided for @estimateStyleLuxuryTitle.
  ///
  /// In es, this message translates to:
  /// **'Lujo'**
  String get estimateStyleLuxuryTitle;

  /// No description provided for @estimateStyleLuxuryCaption.
  ///
  /// In es, this message translates to:
  /// **'Hoteles 5★ y experiencias'**
  String get estimateStyleLuxuryCaption;

  /// No description provided for @estimateErrorDestinationEmpty.
  ///
  /// In es, this message translates to:
  /// **'Escribe o elige un destino.'**
  String get estimateErrorDestinationEmpty;

  /// No description provided for @estimateErrorDatesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Selecciona las fechas de tu viaje.'**
  String get estimateErrorDatesEmpty;

  /// No description provided for @estimateErrorDatesTooShort.
  ///
  /// In es, this message translates to:
  /// **'El viaje debe tener al menos 1 noche.'**
  String get estimateErrorDatesTooShort;

  /// No description provided for @estimateErrorDatesTooLong.
  ///
  /// In es, this message translates to:
  /// **'Por ahora solo estimamos viajes de hasta 30 días.'**
  String get estimateErrorDatesTooLong;

  /// No description provided for @estimateErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'No pudimos calcular la estimación. Intenta de nuevo.'**
  String get estimateErrorGeneric;

  /// No description provided for @estimateButton.
  ///
  /// In es, this message translates to:
  /// **'Estimar presupuesto'**
  String get estimateButton;

  /// No description provided for @estimateButtonLoading.
  ///
  /// In es, this message translates to:
  /// **'Estimando…'**
  String get estimateButtonLoading;

  /// No description provided for @estimateButtonNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva estimación'**
  String get estimateButtonNew;

  /// No description provided for @estimateLoadingEyebrow.
  ///
  /// In es, this message translates to:
  /// **'CONSULTANDO PRECIOS'**
  String get estimateLoadingEyebrow;

  /// No description provided for @estimateLoadingTitle.
  ///
  /// In es, this message translates to:
  /// **'Armando tu estimación'**
  String get estimateLoadingTitle;

  /// No description provided for @estimateLoadingStepLodging.
  ///
  /// In es, this message translates to:
  /// **'Buscando alojamiento'**
  String get estimateLoadingStepLodging;

  /// No description provided for @estimateLoadingStepFlights.
  ///
  /// In es, this message translates to:
  /// **'Consultando vuelos'**
  String get estimateLoadingStepFlights;

  /// No description provided for @estimateLoadingStepLocal.
  ///
  /// In es, this message translates to:
  /// **'Calculando alimentación y transporte local'**
  String get estimateLoadingStepLocal;

  /// No description provided for @estimateResultEyebrow.
  ///
  /// In es, this message translates to:
  /// **'PRESUPUESTO ESTIMADO'**
  String get estimateResultEyebrow;

  /// No description provided for @estimateRangeBadge.
  ///
  /// In es, this message translates to:
  /// **'RANGO ±15%'**
  String get estimateRangeBadge;

  /// No description provided for @estimateHeroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{nights, plural, one{{nights} NOCHE} other{{nights} NOCHES}} · {travelers, plural, one{{travelers} VIAJERO} other{{travelers} VIAJEROS}} · {style}'**
  String estimateHeroSubtitle(int nights, int travelers, String style);

  /// No description provided for @estimateBreakdownTitle.
  ///
  /// In es, this message translates to:
  /// **'Desglose'**
  String get estimateBreakdownTitle;

  /// No description provided for @estimateLodgingTitle.
  ///
  /// In es, this message translates to:
  /// **'Alojamiento'**
  String get estimateLodgingTitle;

  /// No description provided for @estimateLodgingCaption.
  ///
  /// In es, this message translates to:
  /// **'Promedio por noche × {nights, plural, one{{nights} noche} other{{nights} noches}}'**
  String estimateLodgingCaption(int nights);

  /// No description provided for @estimateFoodTitle.
  ///
  /// In es, this message translates to:
  /// **'Alimentación'**
  String get estimateFoodTitle;

  /// No description provided for @estimateFoodCaption.
  ///
  /// In es, this message translates to:
  /// **'Promedio diario × {days, plural, one{{days} día} other{{days} días}}'**
  String estimateFoodCaption(int days);

  /// No description provided for @estimateTransportTitle.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get estimateTransportTitle;

  /// No description provided for @estimateTransportCaption.
  ///
  /// In es, this message translates to:
  /// **'Vuelo + transporte local'**
  String get estimateTransportCaption;

  /// No description provided for @estimateFlightLabel.
  ///
  /// In es, this message translates to:
  /// **'Vuelo'**
  String get estimateFlightLabel;

  /// No description provided for @estimateLocalTransportLabel.
  ///
  /// In es, this message translates to:
  /// **'Transporte local'**
  String get estimateLocalTransportLabel;

  /// No description provided for @estimateSourcesIntro.
  ///
  /// In es, this message translates to:
  /// **'Estimación basada en precios promedio de'**
  String get estimateSourcesIntro;

  /// No description provided for @estimateUpdatedLessThanHour.
  ///
  /// In es, this message translates to:
  /// **'Datos actualizados hace menos de 1 hora'**
  String get estimateUpdatedLessThanHour;

  /// No description provided for @estimateUpdatedHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Datos actualizados hace {hours, plural, one{1 hora} other{{hours} horas}}'**
  String estimateUpdatedHoursAgo(int hours);

  /// No description provided for @estimateDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'Los precios pueden variar ±15% según disponibilidad actual.'**
  String get estimateDisclaimer;

  /// No description provided for @estimateCardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Calcula el costo de un viaje'**
  String get estimateCardSubtitle;

  /// No description provided for @estimateCardDescription.
  ///
  /// In es, this message translates to:
  /// **'Descubre cuánto costaría un viaje antes de planearlo.'**
  String get estimateCardDescription;

  /// No description provided for @estimateCardButton.
  ///
  /// In es, this message translates to:
  /// **'Estimar'**
  String get estimateCardButton;

  /// No description provided for @limitsTabTitle.
  ///
  /// In es, this message translates to:
  /// **'Límites'**
  String get limitsTabTitle;

  /// No description provided for @limitsConfigureButton.
  ///
  /// In es, this message translates to:
  /// **'Configurar límites'**
  String get limitsConfigureButton;

  /// No description provided for @limitsScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Configurar límites'**
  String get limitsScreenTitle;

  /// No description provided for @limitsTripLabel.
  ///
  /// In es, this message translates to:
  /// **'VIAJE'**
  String get limitsTripLabel;

  /// No description provided for @limitsScreenSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Define el máximo que quieres gastar en cada categoría de este viaje. Déjalo vacío si no quieres límite.'**
  String get limitsScreenSubtitle;

  /// No description provided for @limitsFieldHint.
  ///
  /// In es, this message translates to:
  /// **'Sin límite'**
  String get limitsFieldHint;

  /// No description provided for @limitsSpentSoFar.
  ///
  /// In es, this message translates to:
  /// **'Gastado: {amount}'**
  String limitsSpentSoFar(String amount);

  /// No description provided for @limitsSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar límites'**
  String get limitsSaveButton;

  /// No description provided for @limitsSavedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Límites guardados'**
  String get limitsSavedSnackbar;

  /// No description provided for @limitsSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los límites. Intenta de nuevo.'**
  String get limitsSaveError;

  /// No description provided for @limitsProgressTitle.
  ///
  /// In es, this message translates to:
  /// **'Progreso por categoría'**
  String get limitsProgressTitle;

  /// No description provided for @limitsProgressAmount.
  ///
  /// In es, this message translates to:
  /// **'{spent} de {limit}'**
  String limitsProgressAmount(String spent, String limit);

  /// No description provided for @limitsOverBy.
  ///
  /// In es, this message translates to:
  /// **'Superaste el límite por {amount}'**
  String limitsOverBy(String amount);

  /// No description provided for @limitsLeft.
  ///
  /// In es, this message translates to:
  /// **'Te quedan {amount}'**
  String limitsLeft(String amount);

  /// No description provided for @limitsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no defines límites'**
  String get limitsEmptyTitle;

  /// No description provided for @limitsEmptyDescription.
  ///
  /// In es, this message translates to:
  /// **'Configura un máximo por categoría y sigue tu gasto en tiempo real.'**
  String get limitsEmptyDescription;

  /// No description provided for @limitsReportTitle.
  ///
  /// In es, this message translates to:
  /// **'Reporte de cumplimiento'**
  String get limitsReportTitle;

  /// No description provided for @limitsColCategory.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get limitsColCategory;

  /// No description provided for @limitsColLimit.
  ///
  /// In es, this message translates to:
  /// **'LÍMITE'**
  String get limitsColLimit;

  /// No description provided for @limitsColSpent.
  ///
  /// In es, this message translates to:
  /// **'GASTO'**
  String get limitsColSpent;

  /// No description provided for @limitsColCompliance.
  ///
  /// In es, this message translates to:
  /// **'% CUMPLIMIENTO'**
  String get limitsColCompliance;

  /// No description provided for @limitsTotalRow.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get limitsTotalRow;

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
  /// **'¿En qué lo'**
  String get createTripStep2TitleLine1;

  /// No description provided for @createTripStep2TitleLine2.
  ///
  /// In es, this message translates to:
  /// **'vas a gastar?'**
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
  /// **'Gastos'**
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
  /// **'Ingresa un monto válido (0 o más)'**
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
  /// **'Gastos planeados'**
  String get createTripEstimatedLabel;

  /// No description provided for @createTripOverBudgetLabel.
  ///
  /// In es, this message translates to:
  /// **'Te excedes por'**
  String get createTripOverBudgetLabel;

  /// No description provided for @createTripAvailableLabel.
  ///
  /// In es, this message translates to:
  /// **'Disponible sin planear'**
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
  /// **'Gastos planeados'**
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
  /// **'¿A qué viaje quieres agregar el gasto?'**
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
  /// **'{count, plural, =0{Explora lugares} one{1 lugar cerca} other{{count} lugares cerca}}'**
  String homeClientMapCardPlacesCount(int count);

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

  /// No description provided for @tripDetailTabAnalisis.
  ///
  /// In es, this message translates to:
  /// **'Análisis'**
  String get tripDetailTabAnalisis;

  /// No description provided for @analysisDailyTitle.
  ///
  /// In es, this message translates to:
  /// **'Comparativa diaria'**
  String get analysisDailyTitle;

  /// No description provided for @analysisInvalidTripDates.
  ///
  /// In es, this message translates to:
  /// **'Las fechas del viaje no son válidas.'**
  String get analysisInvalidTripDates;

  /// No description provided for @analysisColDay.
  ///
  /// In es, this message translates to:
  /// **'DÍA'**
  String get analysisColDay;

  /// No description provided for @analysisColDailyBudget.
  ///
  /// In es, this message translates to:
  /// **'PRESUPUESTO DIARIO'**
  String get analysisColDailyBudget;

  /// No description provided for @analysisColActual.
  ///
  /// In es, this message translates to:
  /// **'GASTO REAL'**
  String get analysisColActual;

  /// No description provided for @analysisColDifference.
  ///
  /// In es, this message translates to:
  /// **'DIFERENCIA'**
  String get analysisColDifference;

  /// No description provided for @analysisColPctSpent.
  ///
  /// In es, this message translates to:
  /// **'% GASTADO'**
  String get analysisColPctSpent;

  /// No description provided for @analysisDayLabelDate.
  ///
  /// In es, this message translates to:
  /// **'Día {n} · {date}'**
  String analysisDayLabelDate(int n, String date);

  /// No description provided for @analysisDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Día {n}'**
  String analysisDayLabel(int n);

  /// No description provided for @analysisByCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Por categoría'**
  String get analysisByCategoryTitle;

  /// No description provided for @analysisNoCategoriesYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay categorías ni gastos para comparar.'**
  String get analysisNoCategoriesYet;

  /// No description provided for @analysisColCategory.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get analysisColCategory;

  /// No description provided for @analysisColBudgeted.
  ///
  /// In es, this message translates to:
  /// **'PRESUPUESTADO'**
  String get analysisColBudgeted;

  /// No description provided for @analysisBudgetedVsActual.
  ///
  /// In es, this message translates to:
  /// **'Presupuestado vs real'**
  String get analysisBudgetedVsActual;

  /// No description provided for @analysisLegendBudgeted.
  ///
  /// In es, this message translates to:
  /// **'Presupuestado'**
  String get analysisLegendBudgeted;

  /// No description provided for @analysisLegendActual.
  ///
  /// In es, this message translates to:
  /// **'Real'**
  String get analysisLegendActual;

  /// No description provided for @analysisCategorySaved.
  ///
  /// In es, this message translates to:
  /// **'{category}: Ahorraste {amount} en esta categoría'**
  String analysisCategorySaved(String category, String amount);

  /// No description provided for @analysisCategoryExceeded.
  ///
  /// In es, this message translates to:
  /// **'{category}: Excediste por {amount} en esta categoría'**
  String analysisCategoryExceeded(String category, String amount);

  /// No description provided for @analysisTopCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Categoría con más gasto'**
  String get analysisTopCategoryTitle;

  /// No description provided for @analysisTopCategoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Registra gastos para ver este análisis.'**
  String get analysisTopCategoryEmpty;

  /// No description provided for @analysisTopCategorySummary.
  ///
  /// In es, this message translates to:
  /// **'Gastaste más en: {summary}'**
  String analysisTopCategorySummary(String summary);

  /// No description provided for @analysisTopPlacesTitle.
  ///
  /// In es, this message translates to:
  /// **'Top 3 establecimientos'**
  String get analysisTopPlacesTitle;

  /// No description provided for @analysisTopPlacesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Agrega descripciones a tus gastos para ver dónde gastas más.'**
  String get analysisTopPlacesEmpty;

  /// No description provided for @analysisPeakHoursTitle.
  ///
  /// In es, this message translates to:
  /// **'Horarios de mayor gasto'**
  String get analysisPeakHoursTitle;

  /// No description provided for @analysisPeakHoursEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de horario todavía.'**
  String get analysisPeakHoursEmpty;

  /// No description provided for @analysisPeakHoursSummary.
  ///
  /// In es, this message translates to:
  /// **'Más gasto entre: {ranges}'**
  String analysisPeakHoursSummary(String ranges);

  /// No description provided for @analysisAnd.
  ///
  /// In es, this message translates to:
  /// **' y '**
  String get analysisAnd;

  /// No description provided for @analysisBetweenDaysTitle.
  ///
  /// In es, this message translates to:
  /// **'Comparativa entre días'**
  String get analysisBetweenDaysTitle;

  /// No description provided for @analysisAverageTrailing.
  ///
  /// In es, this message translates to:
  /// **'Promedio {amount}'**
  String analysisAverageTrailing(String amount);

  /// No description provided for @analysisNoExpensesYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay gastos registrados.'**
  String get analysisNoExpensesYet;

  /// No description provided for @analysisDailyAverageLegend.
  ///
  /// In es, this message translates to:
  /// **'Promedio diario'**
  String get analysisDailyAverageLegend;

  /// No description provided for @analysisPerPersonTitle.
  ///
  /// In es, this message translates to:
  /// **'Gasto por persona'**
  String get analysisPerPersonTitle;

  /// No description provided for @analysisNoParticipants.
  ///
  /// In es, this message translates to:
  /// **'No hay participantes cargados.'**
  String get analysisNoParticipants;

  /// No description provided for @analysisUnassigned.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get analysisUnassigned;

  /// No description provided for @analysisTripMoneyAmount.
  ///
  /// In es, this message translates to:
  /// **'Dinero del viaje: {amount}'**
  String analysisTripMoneyAmount(String amount);

  /// No description provided for @analysisPocketAmount.
  ///
  /// In es, this message translates to:
  /// **'Bolsillo personal: {amount}'**
  String analysisPocketAmount(String amount);

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
  /// **'1 {code} = {rate}'**
  String configExchangeRatePreview(String code, String rate);

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
  /// **'Promociones exclusivas y alertas para que tu presupuesto diario no se salga de control'**
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
  /// **'Premium'**
  String get subscriptionsPlanTouristName;

  /// No description provided for @subscriptionsPlanTouristSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Para viajeros que cuidan su presupuesto'**
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
  /// **'Aceptamos tarjetas de crédito y débito Visa, Mastercard, American Express y Diners, procesadas por Mercado Pago.'**
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
  /// **'Al hacer clic en \"Continuar\" ingresarás los datos de tu tarjeta. El pago lo procesa Mercado Pago.'**
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

  /// No description provided for @configSectionAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get configSectionAccount;

  /// No description provided for @homeComercioLoadErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la información del negocio'**
  String get homeComercioLoadErrorSnackbar;

  /// No description provided for @homeComercioSaveErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los cambios, intenta de nuevo'**
  String get homeComercioSaveErrorSnackbar;

  /// No description provided for @createActivitySaveErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear la actividad, intenta de nuevo'**
  String get createActivitySaveErrorSnackbar;

  /// No description provided for @createMenuSaveErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el menú, intenta de nuevo'**
  String get createMenuSaveErrorSnackbar;

  /// No description provided for @menuDetailSaveErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el cambio, intenta de nuevo'**
  String get menuDetailSaveErrorSnackbar;

  /// No description provided for @businessSettingsOpenTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora de apertura'**
  String get businessSettingsOpenTimeLabel;

  /// No description provided for @businessSettingsCloseTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora de cierre'**
  String get businessSettingsCloseTimeLabel;

  /// No description provided for @businessSettingsTimeNotSet.
  ///
  /// In es, this message translates to:
  /// **'Sin definir'**
  String get businessSettingsTimeNotSet;

  /// No description provided for @dailyBudgetTodayTitle.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto de hoy'**
  String get dailyBudgetTodayTitle;

  /// No description provided for @dailyBudgetOkMessage.
  ///
  /// In es, this message translates to:
  /// **'Vas bien: aún tienes {amount} para gastar hoy.'**
  String dailyBudgetOkMessage(String amount);

  /// No description provided for @dailyBudgetWarningTitle.
  ///
  /// In es, this message translates to:
  /// **'Advertencia de presupuesto'**
  String get dailyBudgetWarningTitle;

  /// No description provided for @dailyBudgetWarningMessage.
  ///
  /// In es, this message translates to:
  /// **'Ya usaste el {pct}% del presupuesto de hoy. Te quedan {amount}.'**
  String dailyBudgetWarningMessage(int pct, String amount);

  /// No description provided for @dailyBudgetExceededTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Límite diario superado!'**
  String get dailyBudgetExceededTitle;

  /// No description provided for @dailyBudgetExceededMessage.
  ///
  /// In es, this message translates to:
  /// **'Hoy te pasaste {amount} del presupuesto diario; los próximos días tendrán menos disponible.'**
  String dailyBudgetExceededMessage(String amount);

  /// No description provided for @dailyBudgetSpentOf.
  ///
  /// In es, this message translates to:
  /// **'{spent} DE {budget} HOY'**
  String dailyBudgetSpentOf(String spent, String budget);

  /// No description provided for @expenseReminderTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Tuviste gastos hoy?'**
  String get expenseReminderTitle;

  /// No description provided for @expenseReminderMessage.
  ///
  /// In es, this message translates to:
  /// **'No registraste ningún gasto hoy en estos viajes en curso. Anótalos antes de que se te olviden para que tu presupuesto diario siga siendo real.'**
  String get expenseReminderMessage;

  /// No description provided for @expenseReminderDismiss.
  ///
  /// In es, this message translates to:
  /// **'Hoy no gasté'**
  String get expenseReminderDismiss;

  /// No description provided for @addExpenseNearDailyBudget.
  ///
  /// In es, this message translates to:
  /// **'Con este gasto llegas al {pct}% del presupuesto de ese día (quedarían {amount}).'**
  String addExpenseNearDailyBudget(int pct, String amount);

  /// No description provided for @addExpenseExceedsDailyBudget.
  ///
  /// In es, this message translates to:
  /// **'Vas a exceder tu presupuesto en {over} (presupuesto de ese día: {budget}).'**
  String addExpenseExceedsDailyBudget(String over, String budget);

  /// No description provided for @addExpenseOverBudgetDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Supera tu presupuesto diario'**
  String get addExpenseOverBudgetDialogTitle;

  /// No description provided for @addExpenseOverBudgetDialogContent.
  ///
  /// In es, this message translates to:
  /// **'El presupuesto disponible para ese día es {budget}. Vas a exceder tu presupuesto en {over}. Puedes registrarlo de todas formas.'**
  String addExpenseOverBudgetDialogContent(String budget, String over);

  /// No description provided for @addExpenseOverBudgetConfirm.
  ///
  /// In es, this message translates to:
  /// **'Registrar igual'**
  String get addExpenseOverBudgetConfirm;

  /// No description provided for @subscriptionsActivePlanBanner.
  ///
  /// In es, this message translates to:
  /// **'Eres Premium hasta el {date}. Si pagas otro plan, se suma a partir de esa fecha.'**
  String subscriptionsActivePlanBanner(String date);

  /// No description provided for @subscriptionsCheckoutErrorSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la pasarela de pago. Intenta de nuevo.'**
  String get subscriptionsCheckoutErrorSnackbar;

  /// No description provided for @paymentResultChecking.
  ///
  /// In es, this message translates to:
  /// **'Confirmando tu pago con Mercado Pago…'**
  String get paymentResultChecking;

  /// No description provided for @paymentResultApprovedTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Pago aprobado!'**
  String get paymentResultApprovedTitle;

  /// No description provided for @paymentResultApprovedBody.
  ///
  /// In es, this message translates to:
  /// **'Ya eres Premium. Tu suscripción está activa hasta el {date}.'**
  String paymentResultApprovedBody(String date);

  /// No description provided for @paymentResultApprovedBodyNoDate.
  ///
  /// In es, this message translates to:
  /// **'Ya eres Premium. Tu suscripción quedó activa.'**
  String get paymentResultApprovedBodyNoDate;

  /// No description provided for @paymentResultPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago en proceso'**
  String get paymentResultPendingTitle;

  /// No description provided for @paymentResultPendingBody.
  ///
  /// In es, this message translates to:
  /// **'Mercado Pago todavía está procesando tu pago. Te activamos Premium apenas se apruebe.'**
  String get paymentResultPendingBody;

  /// No description provided for @paymentResultRejectedTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago rechazado'**
  String get paymentResultRejectedTitle;

  /// No description provided for @paymentResultRejectedBody.
  ///
  /// In es, this message translates to:
  /// **'Tu medio de pago fue rechazado y no se hizo ningún cobro. Puedes intentarlo con otro.'**
  String get paymentResultRejectedBody;

  /// No description provided for @paymentResultCancelledTitle.
  ///
  /// In es, this message translates to:
  /// **'No se completó el pago'**
  String get paymentResultCancelledTitle;

  /// No description provided for @paymentResultCancelledBody.
  ///
  /// In es, this message translates to:
  /// **'Saliste del checkout antes de pagar. No se hizo ningún cobro.'**
  String get paymentResultCancelledBody;

  /// No description provided for @paymentResultErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar el pago'**
  String get paymentResultErrorTitle;

  /// No description provided for @paymentResultErrorBody.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e intenta de nuevo. Si ya pagaste, el cobro no se pierde: Premium se activa en cuanto Mercado Pago nos confirme.'**
  String get paymentResultErrorBody;

  /// No description provided for @paymentResultPlanMonthly.
  ///
  /// In es, this message translates to:
  /// **'Plan Premium mensual'**
  String get paymentResultPlanMonthly;

  /// No description provided for @paymentResultPlanAnnual.
  ///
  /// In es, this message translates to:
  /// **'Plan Premium anual'**
  String get paymentResultPlanAnnual;

  /// No description provided for @paymentResultReference.
  ///
  /// In es, this message translates to:
  /// **'REFERENCIA DE PAGO #{id}'**
  String paymentResultReference(int id);

  /// No description provided for @paymentResultGoHome.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get paymentResultGoHome;

  /// No description provided for @paymentResultBackToPlans.
  ///
  /// In es, this message translates to:
  /// **'Volver a los planes'**
  String get paymentResultBackToPlans;

  /// No description provided for @paymentResultRetry.
  ///
  /// In es, this message translates to:
  /// **'Volver a consultar'**
  String get paymentResultRetry;

  /// No description provided for @cardPaymentTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago con tarjeta'**
  String get cardPaymentTitle;

  /// No description provided for @cardPaymentSummary.
  ///
  /// In es, this message translates to:
  /// **'{plan} · {price}'**
  String cardPaymentSummary(String plan, String price);

  /// No description provided for @cardPaymentTestModeHint.
  ///
  /// In es, this message translates to:
  /// **'Modo de prueba de Mercado Pago: no se cobra dinero real. Usa la tarjeta 4013 5406 8274 6260, vencimiento 11/30, código 123. Titular APRO = aprobado, CONT = en proceso, cualquier otro nombre = rechazado.'**
  String get cardPaymentTestModeHint;

  /// No description provided for @cardPaymentNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de tarjeta'**
  String get cardPaymentNumberLabel;

  /// No description provided for @cardPaymentNumberInvalid.
  ///
  /// In es, this message translates to:
  /// **'Número de tarjeta inválido'**
  String get cardPaymentNumberInvalid;

  /// No description provided for @cardPaymentBrandUnsupported.
  ///
  /// In es, this message translates to:
  /// **'Aceptamos Visa, Mastercard, American Express y Diners'**
  String get cardPaymentBrandUnsupported;

  /// No description provided for @cardPaymentHolderLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del titular'**
  String get cardPaymentHolderLabel;

  /// No description provided for @cardPaymentHolderHint.
  ///
  /// In es, this message translates to:
  /// **'Como aparece en la tarjeta'**
  String get cardPaymentHolderHint;

  /// No description provided for @cardPaymentHolderInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del titular'**
  String get cardPaymentHolderInvalid;

  /// No description provided for @cardPaymentExpiryLabel.
  ///
  /// In es, this message translates to:
  /// **'Vencimiento'**
  String get cardPaymentExpiryLabel;

  /// No description provided for @cardPaymentExpiryInvalid.
  ///
  /// In es, this message translates to:
  /// **'Fecha inválida o vencida'**
  String get cardPaymentExpiryInvalid;

  /// No description provided for @cardPaymentCvvLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de seguridad'**
  String get cardPaymentCvvLabel;

  /// No description provided for @cardPaymentCvvInvalid.
  ///
  /// In es, this message translates to:
  /// **'Debe tener {digits} dígitos'**
  String cardPaymentCvvInvalid(int digits);

  /// No description provided for @cardPaymentDocTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get cardPaymentDocTypeLabel;

  /// No description provided for @cardPaymentDocNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Documento del titular'**
  String get cardPaymentDocNumberLabel;

  /// No description provided for @cardPaymentDocInvalid.
  ///
  /// In es, this message translates to:
  /// **'Documento inválido'**
  String get cardPaymentDocInvalid;

  /// No description provided for @cardPaymentPayButton.
  ///
  /// In es, this message translates to:
  /// **'Pagar {price}'**
  String cardPaymentPayButton(String price);

  /// No description provided for @cardPaymentProcessing.
  ///
  /// In es, this message translates to:
  /// **'Procesando pago…'**
  String get cardPaymentProcessing;

  /// No description provided for @cardPaymentSecureNote.
  ///
  /// In es, this message translates to:
  /// **'PAGO PROCESADO POR MERCADO PAGO · TRAVELGUARD NO GUARDA LOS DATOS DE TU TARJETA'**
  String get cardPaymentSecureNote;

  /// No description provided for @cardPaymentError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos procesar el pago. Revisa los datos de la tarjeta e intenta de nuevo; no se hizo ningún cobro.'**
  String get cardPaymentError;

  /// No description provided for @appShellNavPromos.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get appShellNavPromos;

  /// No description provided for @appShellNavPlans.
  ///
  /// In es, this message translates to:
  /// **'Planes'**
  String get appShellNavPlans;

  /// No description provided for @subscriptionsBenefitPromos.
  ///
  /// In es, this message translates to:
  /// **'Promociones exclusivas de comercios cercanos'**
  String get subscriptionsBenefitPromos;

  /// No description provided for @subscriptionsBenefitDailyAlerts.
  ///
  /// In es, this message translates to:
  /// **'Cuánto llevas del presupuesto de hoy, con alertas al 75%, 85% y 100%'**
  String get subscriptionsBenefitDailyAlerts;

  /// No description provided for @subscriptionsBenefitOverspendWarning.
  ///
  /// In es, this message translates to:
  /// **'Aviso antes de registrar un gasto que supera el presupuesto del día'**
  String get subscriptionsBenefitOverspendWarning;

  /// No description provided for @subscriptionsBenefitReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios: gastos sin registrar, resumen y cierre del día, y aviso antes de cada viaje'**
  String get subscriptionsBenefitReminder;

  /// No description provided for @premiumGateBadge.
  ///
  /// In es, this message translates to:
  /// **'EXCLUSIVO PREMIUM'**
  String get premiumGateBadge;

  /// No description provided for @premiumGateButton.
  ///
  /// In es, this message translates to:
  /// **'Ver planes Premium'**
  String get premiumGateButton;

  /// No description provided for @premiumGateCompactButton.
  ///
  /// In es, this message translates to:
  /// **'Hazte Premium'**
  String get premiumGateCompactButton;

  /// No description provided for @dailyBudgetLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas del presupuesto diario'**
  String get dailyBudgetLockedTitle;

  /// No description provided for @dailyBudgetLockedDescription.
  ///
  /// In es, this message translates to:
  /// **'Con Premium ves cuánto llevas hoy y te avisamos al 75%, 85% y 100%.'**
  String get dailyBudgetLockedDescription;

  /// No description provided for @placeDetailsPromosLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Exclusivo Premium ({count})'**
  String placeDetailsPromosLockedTitle(int count);

  /// No description provided for @placeDetailsPromosLockedDescription.
  ///
  /// In es, this message translates to:
  /// **'Este comercio tiene promociones y actividades solo para usuarios Premium.'**
  String get placeDetailsPromosLockedDescription;

  /// No description provided for @promosEyebrow.
  ///
  /// In es, this message translates to:
  /// **'EXCLUSIVO PREMIUM'**
  String get promosEyebrow;

  /// No description provided for @promosTitle.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get promosTitle;

  /// No description provided for @promosSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ofertas que los comercios publican solo para viajeros Premium.'**
  String get promosSubtitle;

  /// No description provided for @promosLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'Promociones exclusivas para Premium'**
  String get promosLockedTitle;

  /// No description provided for @promosLockedDescription.
  ///
  /// In es, this message translates to:
  /// **'Suscríbete para ver las ofertas que los comercios cercanos publican solo para miembros Premium.'**
  String get promosLockedDescription;

  /// No description provided for @promosLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las promociones. Intenta de nuevo.'**
  String get promosLoadError;

  /// No description provided for @promosEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay promociones vigentes. Vuelve pronto.'**
  String get promosEmpty;

  /// No description provided for @promosValidUntil.
  ///
  /// In es, this message translates to:
  /// **'HASTA {date}'**
  String promosValidUntil(String date);

  /// No description provided for @productFormRequiredFields.
  ///
  /// In es, this message translates to:
  /// **'Debe completar los campos obligatorios'**
  String get productFormRequiredFields;

  /// No description provided for @productFormRequiredField.
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get productFormRequiredField;

  /// No description provided for @productFormInvalidPrice.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un precio válido mayor a cero'**
  String get productFormInvalidPrice;

  /// No description provided for @productFormCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de producto'**
  String get productFormCategoryLabel;

  /// No description provided for @productFormDescriptionOptionalLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get productFormDescriptionOptionalLabel;

  /// No description provided for @productFormEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get productFormEditTitle;

  /// No description provided for @productFormSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get productFormSaveButton;

  /// No description provided for @productCategoryPlato.
  ///
  /// In es, this message translates to:
  /// **'Plato'**
  String get productCategoryPlato;

  /// No description provided for @productCategoryPlatos.
  ///
  /// In es, this message translates to:
  /// **'Platos'**
  String get productCategoryPlatos;

  /// No description provided for @productCategoryBebida.
  ///
  /// In es, this message translates to:
  /// **'Bebida'**
  String get productCategoryBebida;

  /// No description provided for @productCategoryBebidas.
  ///
  /// In es, this message translates to:
  /// **'Bebidas'**
  String get productCategoryBebidas;

  /// No description provided for @productCategoryPostre.
  ///
  /// In es, this message translates to:
  /// **'Postre'**
  String get productCategoryPostre;

  /// No description provided for @productCategoryPostres.
  ///
  /// In es, this message translates to:
  /// **'Postres'**
  String get productCategoryPostres;

  /// No description provided for @productCategoryOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get productCategoryOtro;

  /// No description provided for @productCategoryOtros.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get productCategoryOtros;

  /// No description provided for @businessSettingsNameTooShort.
  ///
  /// In es, this message translates to:
  /// **'El nombre debe tener al menos 3 caracteres'**
  String get businessSettingsNameTooShort;

  /// No description provided for @businessSettingsPhoneInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un teléfono válido (7 a 15 dígitos)'**
  String get businessSettingsPhoneInvalid;

  /// No description provided for @businessSettingsScheduleIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Define la hora de apertura y la de cierre, o deja las dos sin definir'**
  String get businessSettingsScheduleIncomplete;

  /// No description provided for @businessSettingsScheduleSameTime.
  ///
  /// In es, this message translates to:
  /// **'La hora de cierre no puede ser igual a la de apertura'**
  String get businessSettingsScheduleSameTime;

  /// No description provided for @businessSettingsDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get businessSettingsDescriptionLabel;

  /// No description provided for @businessSettingsDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntales a los viajeros qué ofreces'**
  String get businessSettingsDescriptionHint;

  /// No description provided for @businessSettingsLocationTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get businessSettingsLocationTitle;

  /// No description provided for @businessSettingsLocationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Así te encuentran los viajeros en el mapa. Busca tu dirección y ajusta el marcador si hace falta.'**
  String get businessSettingsLocationSubtitle;

  /// No description provided for @businessSettingsAddressNotFound.
  ///
  /// In es, this message translates to:
  /// **'No pudimos ubicar esa dirección en el mapa. Corrígela (agrega ciudad o barrio) para poder guardar.'**
  String get businessSettingsAddressNotFound;

  /// No description provided for @placeDetailsMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get placeDetailsMenuTitle;

  /// No description provided for @businessSettingsHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos de'**
  String get businessSettingsHeaderTitle;

  /// No description provided for @businessSettingsHeaderAccent.
  ///
  /// In es, this message translates to:
  /// **'tu negocio'**
  String get businessSettingsHeaderAccent;

  /// No description provided for @createMenuHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get createMenuHeaderTitle;

  /// No description provided for @createMenuHeaderAccent.
  ///
  /// In es, this message translates to:
  /// **'menú'**
  String get createMenuHeaderAccent;

  /// No description provided for @subscriptionsHeroTitle.
  ///
  /// In es, this message translates to:
  /// **'Viaja sin salirte'**
  String get subscriptionsHeroTitle;

  /// No description provided for @subscriptionsHeroAccent.
  ///
  /// In es, this message translates to:
  /// **'de tu presupuesto'**
  String get subscriptionsHeroAccent;

  /// No description provided for @subscriptionsSubscribeButton.
  ///
  /// In es, this message translates to:
  /// **'Suscribirme'**
  String get subscriptionsSubscribeButton;

  /// No description provided for @mySubscriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi suscripción'**
  String get mySubscriptionTitle;

  /// No description provided for @mySubscriptionHeroTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu suscripción'**
  String get mySubscriptionHeroTitle;

  /// No description provided for @mySubscriptionStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get mySubscriptionStatusActive;

  /// No description provided for @mySubscriptionStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get mySubscriptionStatusCancelled;

  /// No description provided for @mySubscriptionStatRenewal.
  ///
  /// In es, this message translates to:
  /// **'Renovación'**
  String get mySubscriptionStatRenewal;

  /// No description provided for @mySubscriptionStatEnds.
  ///
  /// In es, this message translates to:
  /// **'Acceso hasta'**
  String get mySubscriptionStatEnds;

  /// No description provided for @mySubscriptionStatDaysLeft.
  ///
  /// In es, this message translates to:
  /// **'Días restantes'**
  String get mySubscriptionStatDaysLeft;

  /// No description provided for @mySubscriptionDetailsTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalles del plan'**
  String get mySubscriptionDetailsTitle;

  /// No description provided for @mySubscriptionRowPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan actual'**
  String get mySubscriptionRowPlan;

  /// No description provided for @mySubscriptionRowStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get mySubscriptionRowStatus;

  /// No description provided for @mySubscriptionRowPeriod.
  ///
  /// In es, this message translates to:
  /// **'Periodo actual'**
  String get mySubscriptionRowPeriod;

  /// No description provided for @mySubscriptionRowRenewalDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de renovación'**
  String get mySubscriptionRowRenewalDate;

  /// No description provided for @mySubscriptionRowRenewalMode.
  ///
  /// In es, this message translates to:
  /// **'Renovación'**
  String get mySubscriptionRowRenewalMode;

  /// No description provided for @mySubscriptionRowNextPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan al renovar'**
  String get mySubscriptionRowNextPlan;

  /// No description provided for @mySubscriptionRowPrepaid.
  ///
  /// In es, this message translates to:
  /// **'Periodos ya pagados'**
  String get mySubscriptionRowPrepaid;

  /// No description provided for @mySubscriptionPeriodRange.
  ///
  /// In es, this message translates to:
  /// **'{from} – {to}'**
  String mySubscriptionPeriodRange(String from, String to);

  /// No description provided for @mySubscriptionRenewalManual.
  ///
  /// In es, this message translates to:
  /// **'Manual: pagas el siguiente periodo cuando quieras, sin cobros automáticos'**
  String get mySubscriptionRenewalManual;

  /// No description provided for @mySubscriptionRenewalCancelled.
  ///
  /// In es, this message translates to:
  /// **'No se renovará. Tienes Premium hasta el {date}.'**
  String mySubscriptionRenewalCancelled(String date);

  /// No description provided for @mySubscriptionRenewSoon.
  ///
  /// In es, this message translates to:
  /// **'Tu Premium vence en {days} días.'**
  String mySubscriptionRenewSoon(int days);

  /// No description provided for @mySubscriptionRenewNow.
  ///
  /// In es, this message translates to:
  /// **'Renovar {plan}'**
  String mySubscriptionRenewNow(String plan);

  /// No description provided for @mySubscriptionChangeTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de plan'**
  String get mySubscriptionChangeTitle;

  /// No description provided for @mySubscriptionChangeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Al pasar a anual pagas ahora y empieza cuando termina lo que ya pagaste. Al pasar a mensual no se cobra nada: aplica al renovar.'**
  String get mySubscriptionChangeSubtitle;

  /// No description provided for @mySubscriptionChangeCancelledHint.
  ///
  /// In es, this message translates to:
  /// **'Reactiva tu suscripción para poder cambiar de plan.'**
  String get mySubscriptionChangeCancelledHint;

  /// No description provided for @mySubscriptionCurrentBadge.
  ///
  /// In es, this message translates to:
  /// **'Tu plan'**
  String get mySubscriptionCurrentBadge;

  /// No description provided for @mySubscriptionScheduledBadge.
  ///
  /// In es, this message translates to:
  /// **'Programado al renovar'**
  String get mySubscriptionScheduledBadge;

  /// No description provided for @mySubscriptionUpgradeButton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar a anual'**
  String get mySubscriptionUpgradeButton;

  /// No description provided for @mySubscriptionDowngradeButton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar a mensual'**
  String get mySubscriptionDowngradeButton;

  /// No description provided for @mySubscriptionKeepPlan.
  ///
  /// In es, this message translates to:
  /// **'Mantener {plan}'**
  String mySubscriptionKeepPlan(String plan);

  /// No description provided for @mySubscriptionUpgradeDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar al plan anual'**
  String get mySubscriptionUpgradeDialogTitle;

  /// No description provided for @mySubscriptionUpgradeDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Pagas {price} ahora. El plan anual va del {from} al {until}: empieza cuando termina lo que ya pagaste, así no pierdes ningún día.'**
  String mySubscriptionUpgradeDialogBody(
    String price,
    String from,
    String until,
  );

  /// No description provided for @mySubscriptionUpgradeConfirm.
  ///
  /// In es, this message translates to:
  /// **'Pagar plan anual'**
  String get mySubscriptionUpgradeConfirm;

  /// No description provided for @mySubscriptionDowngradeDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar al plan mensual'**
  String get mySubscriptionDowngradeDialogTitle;

  /// No description provided for @mySubscriptionDowngradeDialogBody.
  ///
  /// In es, this message translates to:
  /// **'No se cobra nada ahora. Conservas lo que ya pagaste hasta el {date}; al renovar pagarás el plan mensual ({price}).'**
  String mySubscriptionDowngradeDialogBody(String date, String price);

  /// No description provided for @mySubscriptionDowngradeConfirm.
  ///
  /// In es, this message translates to:
  /// **'Programar cambio'**
  String get mySubscriptionDowngradeConfirm;

  /// No description provided for @mySubscriptionChangeScheduledSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Cambio programado: al renovar pasarás al {plan}.'**
  String mySubscriptionChangeScheduledSnackbar(String plan);

  /// No description provided for @mySubscriptionChangeUndoneSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Listo, conservas tu plan actual.'**
  String get mySubscriptionChangeUndoneSnackbar;

  /// No description provided for @mySubscriptionCancelTitle.
  ///
  /// In es, this message translates to:
  /// **'Cancelar suscripción'**
  String get mySubscriptionCancelTitle;

  /// No description provided for @mySubscriptionCancelBody.
  ///
  /// In es, this message translates to:
  /// **'Tu Premium sigue activo hasta el {date} y después no se renueva. No hay reembolso de lo ya pagado.'**
  String mySubscriptionCancelBody(String date);

  /// No description provided for @mySubscriptionCancelDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar tu suscripción?'**
  String get mySubscriptionCancelDialogTitle;

  /// No description provided for @mySubscriptionCancelConfirm.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get mySubscriptionCancelConfirm;

  /// No description provided for @mySubscriptionCancelKeep.
  ///
  /// In es, this message translates to:
  /// **'Mantener Premium'**
  String get mySubscriptionCancelKeep;

  /// No description provided for @mySubscriptionCancelledSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Suscripción cancelada. Tienes Premium hasta el {date}.'**
  String mySubscriptionCancelledSnackbar(String date);

  /// No description provided for @mySubscriptionCancelledTitle.
  ///
  /// In es, this message translates to:
  /// **'Suscripción cancelada'**
  String get mySubscriptionCancelledTitle;

  /// No description provided for @mySubscriptionReactivateButton.
  ///
  /// In es, this message translates to:
  /// **'Reactivar suscripción'**
  String get mySubscriptionReactivateButton;

  /// No description provided for @mySubscriptionReactivatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Suscripción reactivada.'**
  String get mySubscriptionReactivatedSnackbar;

  /// No description provided for @mySubscriptionHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de pagos'**
  String get mySubscriptionHistoryTitle;

  /// No description provided for @mySubscriptionHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay pagos.'**
  String get mySubscriptionHistoryEmpty;

  /// No description provided for @mySubscriptionHistoryError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus pagos.'**
  String get mySubscriptionHistoryError;

  /// No description provided for @mySubscriptionEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes una suscripción activa'**
  String get mySubscriptionEmptyTitle;

  /// No description provided for @mySubscriptionEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Hazte Premium para ver promociones exclusivas y recibir alertas de tu presupuesto diario.'**
  String get mySubscriptionEmptySubtitle;

  /// No description provided for @mySubscriptionSeePlans.
  ///
  /// In es, this message translates to:
  /// **'Ver planes'**
  String get mySubscriptionSeePlans;

  /// No description provided for @mySubscriptionActionError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar tu suscripción. Intenta de nuevo.'**
  String get mySubscriptionActionError;

  /// No description provided for @mySubscriptionManageButton.
  ///
  /// In es, this message translates to:
  /// **'Gestionar mi suscripción'**
  String get mySubscriptionManageButton;

  /// No description provided for @mySubscriptionGoTo.
  ///
  /// In es, this message translates to:
  /// **'Ver mi suscripción'**
  String get mySubscriptionGoTo;

  /// No description provided for @paymentStatusApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobado'**
  String get paymentStatusApproved;

  /// No description provided for @paymentStatusInProcess.
  ///
  /// In es, this message translates to:
  /// **'En proceso'**
  String get paymentStatusInProcess;

  /// No description provided for @paymentStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazado'**
  String get paymentStatusRejected;

  /// No description provided for @paymentStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get paymentStatusCancelled;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In es, this message translates to:
  /// **'Reembolsado'**
  String get paymentStatusRefunded;

  /// No description provided for @budgetNoticeOpenTrip.
  ///
  /// In es, this message translates to:
  /// **'Ver viaje'**
  String get budgetNoticeOpenTrip;

  /// No description provided for @configNotificationsToggleSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Alertas del presupuesto diario y recordatorios. Apagado, tus gastos se siguen registrando.'**
  String get configNotificationsToggleSubtitle;

  /// No description provided for @budgetNoticeToday.
  ///
  /// In es, this message translates to:
  /// **'hoy'**
  String get budgetNoticeToday;

  /// No description provided for @budgetNoticeOnDate.
  ///
  /// In es, this message translates to:
  /// **'el {date}'**
  String budgetNoticeOnDate(String date);

  /// No description provided for @budgetNoticeWarningTitle.
  ///
  /// In es, this message translates to:
  /// **'Has gastado el {pct}% de tu presupuesto diario'**
  String budgetNoticeWarningTitle(int pct);

  /// No description provided for @budgetNoticeWarningMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Cuidado! {trip}: te quedan {amount} para {day}.'**
  String budgetNoticeWarningMessage(String trip, String amount, String day);

  /// No description provided for @budgetNoticeNearLimitTitle.
  ///
  /// In es, this message translates to:
  /// **'Te quedan {amount} de presupuesto para {day}'**
  String budgetNoticeNearLimitTitle(String amount, String day);

  /// No description provided for @budgetNoticeNearLimitMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Cuidado! {trip}: ya vas en el {pct}% del presupuesto de {day}.'**
  String budgetNoticeNearLimitMessage(String trip, int pct, String day);

  /// No description provided for @budgetNoticeExceededTitle.
  ///
  /// In es, this message translates to:
  /// **'Has alcanzado tu límite diario'**
  String get budgetNoticeExceededTitle;

  /// No description provided for @budgetNoticeExceededMessage.
  ///
  /// In es, this message translates to:
  /// **'{trip}: vas en el {pct}% ({spent} de {budget} para {day}). Los próximos días tendrán menos disponible.'**
  String budgetNoticeExceededMessage(
    String trip,
    int pct,
    String spent,
    String budget,
    String day,
  );

  /// No description provided for @configBrowserNotificationsLabel.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones del navegador'**
  String get configBrowserNotificationsLabel;

  /// No description provided for @configBrowserNotificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Además de dentro de la app, recibe las alertas como notificación de tu navegador (con la pestaña abierta).'**
  String get configBrowserNotificationsSubtitle;

  /// No description provided for @configBrowserNotificationsDenied.
  ///
  /// In es, this message translates to:
  /// **'El navegador bloqueó las notificaciones. Permítelas en la configuración del sitio (ícono del candado junto a la dirección).'**
  String get configBrowserNotificationsDenied;

  /// No description provided for @configBrowserNotificationsUnsupported.
  ///
  /// In es, this message translates to:
  /// **'Este navegador no admite notificaciones.'**
  String get configBrowserNotificationsUnsupported;

  /// No description provided for @configBrowserNotificationsTestTitle.
  ///
  /// In es, this message translates to:
  /// **'TravelGuard'**
  String get configBrowserNotificationsTestTitle;

  /// No description provided for @configBrowserNotificationsTestBody.
  ///
  /// In es, this message translates to:
  /// **'Listo: así te avisaremos cuando tu presupuesto del día llegue al 75%, 85% y 100%.'**
  String get configBrowserNotificationsTestBody;

  /// No description provided for @reminderNoExpensesTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Tuviste gastos hoy que no hayas registrado?'**
  String get reminderNoExpensesTitle;

  /// No description provided for @reminderNoExpensesMessage.
  ///
  /// In es, this message translates to:
  /// **'{trip}: llevas más de {hours} horas sin registrar gastos.'**
  String reminderNoExpensesMessage(String trip, int hours);

  /// No description provided for @reminderNoExpensesEndOfDay.
  ///
  /// In es, this message translates to:
  /// **'{trip}: hoy no registraste ningún gasto. Anótalos para que tu presupuesto siga siendo real.'**
  String reminderNoExpensesEndOfDay(String trip);

  /// No description provided for @reminderRegisterExpense.
  ///
  /// In es, this message translates to:
  /// **'Registrar gasto'**
  String get reminderRegisterExpense;

  /// No description provided for @reminderDailySummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Gasto de hoy: {spent}. Presupuesto restante: {remaining}'**
  String reminderDailySummaryTitle(String spent, String remaining);

  /// No description provided for @reminderDailySummaryMessage.
  ///
  /// In es, this message translates to:
  /// **'{trip} · resumen del día'**
  String reminderDailySummaryMessage(String trip);

  /// No description provided for @reminderDayClosingTitle.
  ///
  /// In es, this message translates to:
  /// **'Día {day}: Presupuesto {budget} | Gastaste {spent} | Ahorro {saved}'**
  String reminderDayClosingTitle(
    int day,
    String budget,
    String spent,
    String saved,
  );

  /// No description provided for @reminderDayClosingOverTitle.
  ///
  /// In es, this message translates to:
  /// **'Día {day}: Presupuesto {budget} | Gastaste {spent} | Exceso {over}'**
  String reminderDayClosingOverTitle(
    int day,
    String budget,
    String spent,
    String over,
  );

  /// No description provided for @reminderDayClosingMessage.
  ///
  /// In es, this message translates to:
  /// **'{trip} · cierre del {date}'**
  String reminderDayClosingMessage(String trip, String date);

  /// No description provided for @reminderUpcomingTripTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu viaje a {destination} inicia en {days, plural, =1{1 día} other{{days} días}}'**
  String reminderUpcomingTripTitle(String destination, int days);

  /// No description provided for @reminderUpcomingTripMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres revisar tu presupuesto?'**
  String get reminderUpcomingTripMessage;

  /// No description provided for @reminderReviewBudget.
  ///
  /// In es, this message translates to:
  /// **'Revisar presupuesto'**
  String get reminderReviewBudget;

  /// No description provided for @configRemindersTitle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios'**
  String get configRemindersTitle;

  /// No description provided for @configReminderHoursLabel.
  ///
  /// In es, this message translates to:
  /// **'Recordarme si no registro gastos en'**
  String get configReminderHoursLabel;

  /// No description provided for @configReminderHoursOption.
  ///
  /// In es, this message translates to:
  /// **'{hours} h'**
  String configReminderHoursOption(int hours);

  /// No description provided for @configReminderHoursHint.
  ///
  /// In es, this message translates to:
  /// **'Solo entre las 8 AM y las 10 PM, durante un viaje.'**
  String get configReminderHoursHint;

  /// No description provided for @configDailySummaryLabel.
  ///
  /// In es, this message translates to:
  /// **'Resumen diario a las 11 PM'**
  String get configDailySummaryLabel;

  /// No description provided for @configDailySummarySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gasto de hoy y presupuesto restante.'**
  String get configDailySummarySubtitle;

  /// No description provided for @configTripReminderLabel.
  ///
  /// In es, this message translates to:
  /// **'Aviso antes de un viaje'**
  String get configTripReminderLabel;

  /// No description provided for @configTripReminderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'3 días y 1 día antes, para revisar tu presupuesto.'**
  String get configTripReminderSubtitle;

  /// No description provided for @configRemindersPremiumHint.
  ///
  /// In es, this message translates to:
  /// **'Las alertas y recordatorios son parte de Premium.'**
  String get configRemindersPremiumHint;

  /// No description provided for @mySubscriptionStatCost.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get mySubscriptionStatCost;

  /// No description provided for @mySubscriptionRowCost.
  ///
  /// In es, this message translates to:
  /// **'Costo del plan'**
  String get mySubscriptionRowCost;

  /// No description provided for @mySubscriptionCostValue.
  ///
  /// In es, this message translates to:
  /// **'{price} {period}'**
  String mySubscriptionCostValue(String price, String period);

  /// No description provided for @mySubscriptionRowRenewalCost.
  ///
  /// In es, this message translates to:
  /// **'Próxima renovación'**
  String get mySubscriptionRowRenewalCost;

  /// No description provided for @mySubscriptionRenewalCostValue.
  ///
  /// In es, this message translates to:
  /// **'{date} · {price}'**
  String mySubscriptionRenewalCostValue(String date, String price);

  /// No description provided for @businessSettingsPhotoTitle.
  ///
  /// In es, this message translates to:
  /// **'Foto de portada'**
  String get businessSettingsPhotoTitle;

  /// No description provided for @businessSettingsPhotoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Es la imagen que ven los viajeros en la tarjeta de tu comercio y en su ficha.'**
  String get businessSettingsPhotoSubtitle;

  /// No description provided for @businessSettingsPhotoUpload.
  ///
  /// In es, this message translates to:
  /// **'Subir foto'**
  String get businessSettingsPhotoUpload;

  /// No description provided for @businessSettingsPhotoChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get businessSettingsPhotoChange;

  /// No description provided for @businessSettingsPhotoRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get businessSettingsPhotoRemove;

  /// No description provided for @businessSettingsPhotoEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin foto de portada'**
  String get businessSettingsPhotoEmpty;

  /// No description provided for @businessSettingsPhotoHint.
  ///
  /// In es, this message translates to:
  /// **'JPG, PNG o WebP · máx. 5 MB · horizontal se ve mejor'**
  String get businessSettingsPhotoHint;

  /// No description provided for @businessSettingsPhotoTooLarge.
  ///
  /// In es, this message translates to:
  /// **'La imagen pesa más de 5 MB. Elige una más liviana.'**
  String get businessSettingsPhotoTooLarge;

  /// No description provided for @businessSettingsPhotoInvalidType.
  ///
  /// In es, this message translates to:
  /// **'Formato no admitido. Usa una imagen JPG, PNG o WebP.'**
  String get businessSettingsPhotoInvalidType;

  /// No description provided for @businessSettingsPhotoPickError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la imagen. Intenta con otra.'**
  String get businessSettingsPhotoPickError;

  /// No description provided for @homeComercioPhotoUploadError.
  ///
  /// In es, this message translates to:
  /// **'Tus datos no se guardaron porque la foto no se pudo subir. Intenta de nuevo.'**
  String get homeComercioPhotoUploadError;

  /// No description provided for @comercioNavSectionLabel.
  ///
  /// In es, this message translates to:
  /// **'NEGOCIO'**
  String get comercioNavSectionLabel;

  /// No description provided for @comercioPublicProfileLabel.
  ///
  /// In es, this message translates to:
  /// **'TU PERFIL PÚBLICO'**
  String get comercioPublicProfileLabel;

  /// No description provided for @comercioViewAsTourist.
  ///
  /// In es, this message translates to:
  /// **'Ver como turista →'**
  String get comercioViewAsTourist;

  /// No description provided for @comercioSignOutShort.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get comercioSignOutShort;

  /// No description provided for @comercioSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar actividades o platos'**
  String get comercioSearchHint;

  /// No description provided for @comercioPanelEyebrow.
  ///
  /// In es, this message translates to:
  /// **'PANEL DEL NEGOCIO'**
  String get comercioPanelEyebrow;

  /// No description provided for @comercioGreetingPrefix.
  ///
  /// In es, this message translates to:
  /// **'¡Hola, '**
  String get comercioGreetingPrefix;

  /// No description provided for @comercioYourMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu menú'**
  String get comercioYourMenuTitle;

  /// No description provided for @comercioEditLink.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get comercioEditLink;

  /// No description provided for @comercioEmptyActivitiesBody.
  ///
  /// In es, this message translates to:
  /// **'Las actividades publicadas aparecen en el mapa y en la lista de comercios cercanos de los turistas.'**
  String get comercioEmptyActivitiesBody;

  /// No description provided for @comercioCreateFirstActivity.
  ///
  /// In es, this message translates to:
  /// **'Crear la primera →'**
  String get comercioCreateFirstActivity;

  /// No description provided for @comercioEmptyMenuShort.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay platos.'**
  String get comercioEmptyMenuShort;

  /// No description provided for @comercioRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get comercioRetry;

  /// No description provided for @comercioStatusPublished.
  ///
  /// In es, this message translates to:
  /// **'Publicada'**
  String get comercioStatusPublished;

  /// No description provided for @comercioStatusDraft.
  ///
  /// In es, this message translates to:
  /// **'Borrador'**
  String get comercioStatusDraft;

  /// No description provided for @comercioStatusPaused.
  ///
  /// In es, this message translates to:
  /// **'Pausada'**
  String get comercioStatusPaused;

  /// No description provided for @comercioFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get comercioFilterAll;

  /// No description provided for @comercioDatesNone.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get comercioDatesNone;

  /// No description provided for @comercioDatesFrom.
  ///
  /// In es, this message translates to:
  /// **'Desde {date}'**
  String comercioDatesFrom(String date);

  /// No description provided for @comercioFree.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get comercioFree;

  /// No description provided for @comercioActivitiesTotal.
  ///
  /// In es, this message translates to:
  /// **'{count} EN TOTAL'**
  String comercioActivitiesTotal(int count);

  /// No description provided for @comercioActivitiesTitle1.
  ///
  /// In es, this message translates to:
  /// **'Mis '**
  String get comercioActivitiesTitle1;

  /// No description provided for @comercioActivitiesTitle2.
  ///
  /// In es, this message translates to:
  /// **'actividades'**
  String get comercioActivitiesTitle2;

  /// No description provided for @comercioColActivity.
  ///
  /// In es, this message translates to:
  /// **'ACTIVIDAD'**
  String get comercioColActivity;

  /// No description provided for @comercioColCategory.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA'**
  String get comercioColCategory;

  /// No description provided for @comercioColDates.
  ///
  /// In es, this message translates to:
  /// **'FECHAS'**
  String get comercioColDates;

  /// No description provided for @comercioColPrice.
  ///
  /// In es, this message translates to:
  /// **'PRECIO'**
  String get comercioColPrice;

  /// No description provided for @comercioColStatus.
  ///
  /// In es, this message translates to:
  /// **'ESTADO'**
  String get comercioColStatus;

  /// No description provided for @comercioActivitiesEmptyFilter.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades con este estado.'**
  String get comercioActivitiesEmptyFilter;

  /// No description provided for @comercioNoDescription.
  ///
  /// In es, this message translates to:
  /// **'Sin descripción'**
  String get comercioNoDescription;

  /// No description provided for @comercioMenuProductsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} PRODUCTOS'**
  String comercioMenuProductsCount(int count);

  /// No description provided for @comercioMenuTitle1.
  ///
  /// In es, this message translates to:
  /// **'Tu '**
  String get comercioMenuTitle1;

  /// No description provided for @comercioMenuTitle2.
  ///
  /// In es, this message translates to:
  /// **'menú'**
  String get comercioMenuTitle2;

  /// No description provided for @comercioMenuSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Platos, bebidas y servicios que ofrece tu negocio.'**
  String get comercioMenuSubtitle;

  /// No description provided for @comercioAddProductButton.
  ///
  /// In es, this message translates to:
  /// **'+ Agregar producto'**
  String get comercioAddProductButton;

  /// No description provided for @comercioAddProductShort.
  ///
  /// In es, this message translates to:
  /// **'+ Producto'**
  String get comercioAddProductShort;

  /// No description provided for @comercioMenuEmpty.
  ///
  /// In es, this message translates to:
  /// **'Tu menú está vacío. Agrega el primer plato y aparecerá en tu perfil público.'**
  String get comercioMenuEmpty;

  /// No description provided for @comercioMenuDetailLink.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get comercioMenuDetailLink;

  /// No description provided for @comercioPickMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'¿A qué menú lo agregas?'**
  String get comercioPickMenuTitle;

  /// No description provided for @comercioNewActivityEyebrow.
  ///
  /// In es, this message translates to:
  /// **'NUEVA ACTIVIDAD'**
  String get comercioNewActivityEyebrow;

  /// No description provided for @comercioPreviewTitle1.
  ///
  /// In es, this message translates to:
  /// **'Así la verán'**
  String get comercioPreviewTitle1;

  /// No description provided for @comercioPreviewTitle2.
  ///
  /// In es, this message translates to:
  /// **'los turistas'**
  String get comercioPreviewTitle2;

  /// No description provided for @comercioPreviewDescPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'La descripción aparecerá aquí.'**
  String get comercioPreviewDescPlaceholder;

  /// No description provided for @comercioStatusNotePublished.
  ///
  /// In es, this message translates to:
  /// **'Visible en el mapa al guardar'**
  String get comercioStatusNotePublished;

  /// No description provided for @comercioStatusNotePaused.
  ///
  /// In es, this message translates to:
  /// **'Oculta para los turistas'**
  String get comercioStatusNotePaused;

  /// No description provided for @comercioStatusNoteDraft.
  ///
  /// In es, this message translates to:
  /// **'Solo tú la ves mientras sea borrador'**
  String get comercioStatusNoteDraft;

  /// No description provided for @comercioNoEndToggle.
  ///
  /// In es, this message translates to:
  /// **'Sin fin'**
  String get comercioNoEndToggle;

  /// No description provided for @comercioEndShort.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get comercioEndShort;

  /// No description provided for @comercioPickDate.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha'**
  String get comercioPickDate;

  /// No description provided for @comercioSubmitPublish.
  ///
  /// In es, this message translates to:
  /// **'Publicar actividad'**
  String get comercioSubmitPublish;

  /// No description provided for @comercioSubmitPaused.
  ///
  /// In es, this message translates to:
  /// **'Guardar pausada'**
  String get comercioSubmitPaused;

  /// No description provided for @comercioSubmitDraft.
  ///
  /// In es, this message translates to:
  /// **'Guardar borrador'**
  String get comercioSubmitDraft;

  /// No description provided for @comercioNewMenuEyebrow.
  ///
  /// In es, this message translates to:
  /// **'NUEVO MENÚ'**
  String get comercioNewMenuEyebrow;

  /// No description provided for @comercioMenuPreviewTitle1.
  ///
  /// In es, this message translates to:
  /// **'Así lo verán'**
  String get comercioMenuPreviewTitle1;

  /// No description provided for @comercioMenuPreviewEmpty.
  ///
  /// In es, this message translates to:
  /// **'Los productos aparecerán aquí.'**
  String get comercioMenuPreviewEmpty;

  /// No description provided for @comercioSearchNoResults.
  ///
  /// In es, this message translates to:
  /// **'Nada coincide con «{query}».'**
  String comercioSearchNoResults(String query);

  /// No description provided for @valRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get valRequired;

  /// No description provided for @valTooShort.
  ///
  /// In es, this message translates to:
  /// **'Debe tener al menos {min} caracteres'**
  String valTooShort(int min);

  /// No description provided for @valTooLong.
  ///
  /// In es, this message translates to:
  /// **'Máximo {max} caracteres'**
  String valTooLong(int max);

  /// No description provided for @valPersonName.
  ///
  /// In es, this message translates to:
  /// **'Solo se permiten letras y espacios'**
  String get valPersonName;

  /// No description provided for @valNeedsLetter.
  ///
  /// In es, this message translates to:
  /// **'Debe contener al menos una letra'**
  String get valNeedsLetter;

  /// No description provided for @valInvalidChars.
  ///
  /// In es, this message translates to:
  /// **'No se permiten símbolos como < > [ ] o \\'**
  String get valInvalidChars;

  /// No description provided for @valEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido (ej. nombre@correo.com)'**
  String get valEmail;

  /// No description provided for @valPhone.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un teléfono válido: solo números, de 7 a 15 dígitos'**
  String get valPhone;

  /// No description provided for @valPasswordMin.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get valPasswordMin;

  /// No description provided for @valPasswordHelper.
  ///
  /// In es, this message translates to:
  /// **'Al menos 8 caracteres'**
  String get valPasswordHelper;

  /// No description provided for @valAmountPositive.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto mayor a 0'**
  String get valAmountPositive;

  /// No description provided for @valAmountMax.
  ///
  /// In es, this message translates to:
  /// **'El monto no puede superar {max}'**
  String valAmountMax(String max);

  /// No description provided for @valIntRange.
  ///
  /// In es, this message translates to:
  /// **'Debe ser un número entre {min} y {max}'**
  String valIntRange(int min, int max);

  /// No description provided for @valEndBeforeStart.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin no puede ser anterior a la de inicio'**
  String get valEndBeforeStart;

  /// No description provided for @valDuplicateProduct.
  ///
  /// In es, this message translates to:
  /// **'Ya hay un producto con ese nombre en este menú'**
  String get valDuplicateProduct;

  /// No description provided for @valCardHolder.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre como aparece en la tarjeta (solo letras)'**
  String get valCardHolder;

  /// No description provided for @valScheduleBoth.
  ///
  /// In es, this message translates to:
  /// **'Indica la hora de apertura y la de cierre, o ninguna'**
  String get valScheduleBoth;

  /// No description provided for @valDocLength.
  ///
  /// In es, this message translates to:
  /// **'El documento debe tener entre 5 y 12 dígitos'**
  String get valDocLength;

  /// No description provided for @valInviteEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe el correo de la persona'**
  String get valInviteEmailRequired;

  /// No description provided for @valOverBudgetTitle.
  ///
  /// In es, this message translates to:
  /// **'Lo planeado supera el presupuesto'**
  String get valOverBudgetTitle;

  /// No description provided for @valOverBudgetContent.
  ///
  /// In es, this message translates to:
  /// **'Lo que planeaste supera tu presupuesto máximo por {amount}. ¿Quieres guardar igual?'**
  String valOverBudgetContent(String amount);

  /// No description provided for @valOverBudgetConfirm.
  ///
  /// In es, this message translates to:
  /// **'Guardar igual'**
  String get valOverBudgetConfirm;

  /// No description provided for @valOverBudgetCancel.
  ///
  /// In es, this message translates to:
  /// **'Revisar'**
  String get valOverBudgetCancel;

  /// No description provided for @valAdvanceOverBudget.
  ///
  /// In es, this message translates to:
  /// **'Los pagos anticipados no pueden superar el presupuesto máximo'**
  String get valAdvanceOverBudget;

  /// No description provided for @valPersonsRange.
  ///
  /// In es, this message translates to:
  /// **'Las personas deben ser entre 1 y 50'**
  String get valPersonsRange;

  /// No description provided for @valLoadTripsError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus viajes. Revisa tu conexión.'**
  String get valLoadTripsError;

  /// No description provided for @valLoadPlacesError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los lugares cercanos.'**
  String get valLoadPlacesError;

  /// No description provided for @valLoadGastosError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tus gastos: las barras muestran solo lo planeado.'**
  String get valLoadGastosError;

  /// No description provided for @valLoadMapError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los lugares del mapa.'**
  String get valLoadMapError;

  /// No description provided for @valNitFormat.
  ///
  /// In es, this message translates to:
  /// **'NIT inválido: usa solo números (5 a 15 dígitos) y, si quieres, -dígito de verificación'**
  String get valNitFormat;

  /// No description provided for @valCommerceAddress.
  ///
  /// In es, this message translates to:
  /// **'Escribe una dirección válida'**
  String get valCommerceAddress;

  /// No description provided for @placeDetailsDirectionsSoon.
  ///
  /// In es, this message translates to:
  /// **'Disponible próximamente'**
  String get placeDetailsDirectionsSoon;

  /// No description provided for @createTripAutoMealsRow.
  ///
  /// In es, this message translates to:
  /// **'Comidas no incluidas ({meals})'**
  String createTripAutoMealsRow(String meals);

  /// No description provided for @createTripAutoTransfersRow.
  ///
  /// In es, this message translates to:
  /// **'Traslados'**
  String get createTripAutoTransfersRow;

  /// No description provided for @createTripServicesHint.
  ///
  /// In es, this message translates to:
  /// **'Marca lo que ya cubre tu hospedaje: eso no lo tienes que presupuestar. Lo que no esté incluido lo agregamos a los gastos del último paso para que le pongas un monto.'**
  String get createTripServicesHint;

  /// No description provided for @createTripEstimatedHint.
  ///
  /// In es, this message translates to:
  /// **'Hospedaje + pagos anticipados + gastos adicionales + emergencias'**
  String get createTripEstimatedHint;

  /// No description provided for @createTripCoveredByLodging.
  ///
  /// In es, this message translates to:
  /// **'Cubierto por el hospedaje: {services}'**
  String createTripCoveredByLodging(String services);

  /// No description provided for @createTripIncompleteFieldsIntro.
  ///
  /// In es, this message translates to:
  /// **'Te faltan estos campos:'**
  String get createTripIncompleteFieldsIntro;

  /// No description provided for @createTripIncompleteFieldsOutro.
  ///
  /// In es, this message translates to:
  /// **'Puedes crear el viaje así, pero el presupuesto será menos preciso. Si alguno no aplica, escribe 0.'**
  String get createTripIncompleteFieldsOutro;

  /// No description provided for @createTripIncompleteFillButton.
  ///
  /// In es, this message translates to:
  /// **'Completarlos'**
  String get createTripIncompleteFillButton;

  /// No description provided for @tripDetailPaceRemaining.
  ///
  /// In es, this message translates to:
  /// **'Te quedan {amount} del presupuesto, ya descontando lo planeado y lo gastado. Para no pasarte, puedes gastar:'**
  String tripDetailPaceRemaining(String amount);

  /// No description provided for @tripDetailPacePerDayGroup.
  ///
  /// In es, this message translates to:
  /// **'Por día, todo el grupo'**
  String get tripDetailPacePerDayGroup;

  /// No description provided for @tripDetailPacePerDaySolo.
  ///
  /// In es, this message translates to:
  /// **'Por día'**
  String get tripDetailPacePerDaySolo;

  /// No description provided for @tripDetailPacePerPersonDay.
  ///
  /// In es, this message translates to:
  /// **'Por persona, por día'**
  String get tripDetailPacePerPersonDay;

  /// No description provided for @tripDetailPaceNoBudgetLeft.
  ///
  /// In es, this message translates to:
  /// **'Lo planeado y lo gastado ya cubren todo el presupuesto: no queda margen para gastos nuevos.'**
  String get tripDetailPaceNoBudgetLeft;

  /// No description provided for @tripDetailPacePlanned.
  ///
  /// In es, this message translates to:
  /// **'Planeado al crear el viaje'**
  String get tripDetailPacePlanned;

  /// No description provided for @tripDetailPaceRegistered.
  ///
  /// In es, this message translates to:
  /// **'Gastos registrados'**
  String get tripDetailPaceRegistered;

  /// No description provided for @tripDetailPacePerPerson.
  ///
  /// In es, this message translates to:
  /// **'Total por persona ({persons} personas)'**
  String tripDetailPacePerPerson(int persons);

  /// No description provided for @appShellNavActivities.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get appShellNavActivities;

  /// No description provided for @activitiesEyebrow.
  ///
  /// In es, this message translates to:
  /// **'{count} PARA HACER'**
  String activitiesEyebrow(int count);

  /// No description provided for @activitiesTitle1.
  ///
  /// In es, this message translates to:
  /// **'Actividades '**
  String get activitiesTitle1;

  /// No description provided for @activitiesTitle2.
  ///
  /// In es, this message translates to:
  /// **'cerca de ti'**
  String get activitiesTitle2;

  /// No description provided for @activitiesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Eventos, tours, clases y planes que publican los comercios de TravelGuard.'**
  String get activitiesSubtitle;

  /// No description provided for @activitiesAllFilter.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get activitiesAllFilter;

  /// No description provided for @activitiesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay actividades publicadas. Vuelve pronto.'**
  String get activitiesEmpty;

  /// No description provided for @activitiesEmptyFilter.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades de esta categoría.'**
  String get activitiesEmptyFilter;

  /// No description provided for @activitiesLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las actividades.'**
  String get activitiesLoadError;

  /// No description provided for @activitiesPromoBanner.
  ///
  /// In es, this message translates to:
  /// **'¿Buscas descuentos? Las promociones exclusivas están en Promociones.'**
  String get activitiesPromoBanner;

  /// No description provided for @activitiesPromoLink.
  ///
  /// In es, this message translates to:
  /// **'Ver promociones →'**
  String get activitiesPromoLink;

  /// No description provided for @activitiesViewBusiness.
  ///
  /// In es, this message translates to:
  /// **'Ver comercio →'**
  String get activitiesViewBusiness;

  /// No description provided for @activitiesBusinessUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Este comercio todavía no tiene su ficha disponible.'**
  String get activitiesBusinessUnavailable;

  /// No description provided for @homeClientViewActivitiesButton.
  ///
  /// In es, this message translates to:
  /// **'Ver actividades →'**
  String get homeClientViewActivitiesButton;

  /// No description provided for @configDemoTitle.
  ///
  /// In es, this message translates to:
  /// **'Probar notificaciones'**
  String get configDemoTitle;

  /// No description provided for @configDemoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Muestra cada aviso al instante con tu viaje más reciente, sin esperar a que pase de verdad. No cambia ningún dato.'**
  String get configDemoSubtitle;

  /// No description provided for @configDemoNoTrip.
  ///
  /// In es, this message translates to:
  /// **'Crea un viaje primero para probar las notificaciones.'**
  String get configDemoNoTrip;

  /// No description provided for @configDemoWarning.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto al 75%'**
  String get configDemoWarning;

  /// No description provided for @configDemoNearLimit.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto al 85%'**
  String get configDemoNearLimit;

  /// No description provided for @configDemoExceeded.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto superado'**
  String get configDemoExceeded;

  /// No description provided for @configDemoNoExpenses.
  ///
  /// In es, this message translates to:
  /// **'Sin gastos registrados'**
  String get configDemoNoExpenses;

  /// No description provided for @configDemoSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen del día'**
  String get configDemoSummary;

  /// No description provided for @configDemoClosing.
  ///
  /// In es, this message translates to:
  /// **'Cierre del día'**
  String get configDemoClosing;

  /// No description provided for @configDemoUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Viaje próximo'**
  String get configDemoUpcoming;

  /// No description provided for @comercioNavPromos.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get comercioNavPromos;

  /// No description provided for @comercioCreatePromoTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear promoción'**
  String get comercioCreatePromoTitle;

  /// No description provided for @comercioCreatePromoDescription.
  ///
  /// In es, this message translates to:
  /// **'Ofertas y descuentos exclusivos para los turistas Premium de TravelGuard.'**
  String get comercioCreatePromoDescription;

  /// No description provided for @comercioCreatePromoButton.
  ///
  /// In es, this message translates to:
  /// **'+ Promoción'**
  String get comercioCreatePromoButton;

  /// No description provided for @comercioPromosTotal.
  ///
  /// In es, this message translates to:
  /// **'{count} PROMOCIONES'**
  String comercioPromosTotal(int count);

  /// No description provided for @comercioPromosTitle1.
  ///
  /// In es, this message translates to:
  /// **'Mis '**
  String get comercioPromosTitle1;

  /// No description provided for @comercioPromosTitle2.
  ///
  /// In es, this message translates to:
  /// **'promociones'**
  String get comercioPromosTitle2;

  /// No description provided for @comercioPromosSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Solo las ven los turistas con TravelGuard Premium, en su sección de Promociones y en la ficha de tu negocio.'**
  String get comercioPromosSubtitle;

  /// No description provided for @comercioPromosEmptyFilter.
  ///
  /// In es, this message translates to:
  /// **'No hay promociones con este estado.'**
  String get comercioPromosEmptyFilter;

  /// No description provided for @comercioNewPromoEyebrow.
  ///
  /// In es, this message translates to:
  /// **'NUEVA PROMOCIÓN'**
  String get comercioNewPromoEyebrow;

  /// No description provided for @comercioNewPromoHeading.
  ///
  /// In es, this message translates to:
  /// **'Nueva promoción'**
  String get comercioNewPromoHeading;

  /// No description provided for @comercioNewPromoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Una oferta exclusiva para turistas Premium: descuento, combo o beneficio especial.'**
  String get comercioNewPromoSubtitle;

  /// No description provided for @comercioPromoPreviewTitle2.
  ///
  /// In es, this message translates to:
  /// **'los turistas Premium'**
  String get comercioPromoPreviewTitle2;

  /// No description provided for @comercioPromoNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la promoción'**
  String get comercioPromoNameLabel;

  /// No description provided for @comercioPromoNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 2x1 en almuerzos'**
  String get comercioPromoNameHint;

  /// No description provided for @comercioSubmitPublishPromo.
  ///
  /// In es, this message translates to:
  /// **'Publicar promoción'**
  String get comercioSubmitPublishPromo;

  /// No description provided for @comercioAudienceLabel.
  ///
  /// In es, this message translates to:
  /// **'¿Quién la puede ver?'**
  String get comercioAudienceLabel;

  /// No description provided for @comercioAudiencePublic.
  ///
  /// In es, this message translates to:
  /// **'Todo el público'**
  String get comercioAudiencePublic;

  /// No description provided for @comercioAudiencePremium.
  ///
  /// In es, this message translates to:
  /// **'Solo Premium'**
  String get comercioAudiencePremium;

  /// No description provided for @comercioAudiencePremiumNote.
  ///
  /// In es, this message translates to:
  /// **'Solo la verán los turistas con Premium; los demás la ven con candado.'**
  String get comercioAudiencePremiumNote;

  /// No description provided for @comercioPromoAudienceNote.
  ///
  /// In es, this message translates to:
  /// **'Las promociones son siempre exclusivas para turistas Premium.'**
  String get comercioPromoAudienceNote;

  /// No description provided for @comercioPremiumBadge.
  ///
  /// In es, this message translates to:
  /// **'PREMIUM'**
  String get comercioPremiumBadge;

  /// No description provided for @comercioPromoCreatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Promoción \"{name}\" creada'**
  String comercioPromoCreatedSnackbar(String name);

  /// No description provided for @activitiesPremiumLocked.
  ///
  /// In es, this message translates to:
  /// **'Exclusiva Premium'**
  String get activitiesPremiumLocked;

  /// No description provided for @activitiesPremiumLockedHint.
  ///
  /// In es, this message translates to:
  /// **'Hazte Premium para ver los detalles →'**
  String get activitiesPremiumLockedHint;

  /// No description provided for @commonFixMarkedFields.
  ///
  /// In es, this message translates to:
  /// **'Revisa los campos marcados en rojo'**
  String get commonFixMarkedFields;

  /// No description provided for @comercioEditActivityHeading.
  ///
  /// In es, this message translates to:
  /// **'Editar actividad'**
  String get comercioEditActivityHeading;

  /// No description provided for @comercioEditPromoHeading.
  ///
  /// In es, this message translates to:
  /// **'Editar promoción'**
  String get comercioEditPromoHeading;

  /// No description provided for @comercioEditEyebrow.
  ///
  /// In es, this message translates to:
  /// **'EDITANDO'**
  String get comercioEditEyebrow;

  /// No description provided for @comercioEditSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cambia lo que necesites, incluido el estado: borrador, publicada o pausada.'**
  String get comercioEditSubtitle;

  /// No description provided for @comercioActivityUpdatedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" actualizada'**
  String comercioActivityUpdatedSnackbar(String name);

  /// No description provided for @comercioEditSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron guardar los cambios, intenta de nuevo'**
  String get comercioEditSaveError;

  /// No description provided for @comercioEditTooltip.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get comercioEditTooltip;

  /// No description provided for @comercioEditNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró esa actividad'**
  String get comercioEditNotFound;

  /// No description provided for @comercioDeleteButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get comercioDeleteButton;

  /// No description provided for @comercioDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String comercioDeleteConfirmTitle(String name);

  /// No description provided for @comercioDeleteConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Se borra para siempre y los turistas dejarán de verla. No se puede deshacer.'**
  String get comercioDeleteConfirmBody;

  /// No description provided for @comercioDeletedSnackbar.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" eliminada'**
  String comercioDeletedSnackbar(String name);

  /// No description provided for @comercioDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar, intenta de nuevo'**
  String get comercioDeleteError;

  /// No description provided for @receiptScanTooltip.
  ///
  /// In es, this message translates to:
  /// **'Escanear recibo'**
  String get receiptScanTooltip;

  /// No description provided for @receiptScanButton.
  ///
  /// In es, this message translates to:
  /// **'Escanear recibo'**
  String get receiptScanButton;

  /// No description provided for @receiptPreviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa la foto'**
  String get receiptPreviewTitle;

  /// No description provided for @receiptPreviewHint.
  ///
  /// In es, this message translates to:
  /// **'Que se lean bien el nombre del negocio, la fecha y el total.'**
  String get receiptPreviewHint;

  /// No description provided for @receiptRetakeButton.
  ///
  /// In es, this message translates to:
  /// **'Retomar'**
  String get receiptRetakeButton;

  /// No description provided for @receiptConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get receiptConfirmButton;

  /// No description provided for @receiptAnalyzing.
  ///
  /// In es, this message translates to:
  /// **'Analizando recibo...'**
  String get receiptAnalyzing;

  /// No description provided for @receiptReadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer el recibo. Intenta tomar una fotografía más clara.'**
  String get receiptReadError;

  /// No description provided for @receiptCameraError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la cámara.'**
  String get receiptCameraError;

  /// No description provided for @receiptFilledNotice.
  ///
  /// In es, this message translates to:
  /// **'Llenamos lo que leímos del recibo. Revisa los datos antes de guardar.'**
  String get receiptFilledNotice;

  /// No description provided for @receiptDateOutOfTrip.
  ///
  /// In es, this message translates to:
  /// **'La fecha del recibo ({date}) está fuera de las fechas del viaje; elige la fecha del gasto.'**
  String receiptDateOutOfTrip(String date);

  /// No description provided for @tripFinishedReadOnlyNotice.
  ///
  /// In es, this message translates to:
  /// **'Este viaje ya terminó: no se pueden agregar gastos ni editar el presupuesto.'**
  String get tripFinishedReadOnlyNotice;

  /// No description provided for @tripFinishedBadge.
  ///
  /// In es, this message translates to:
  /// **'Viaje terminado'**
  String get tripFinishedBadge;

  /// No description provided for @homeClientNoOpenTripsSnackbar.
  ///
  /// In es, this message translates to:
  /// **'No tienes viajes activos o próximos. Los viajes que ya terminaron no admiten gastos nuevos.'**
  String get homeClientNoOpenTripsSnackbar;

  /// No description provided for @floatingNavBarAddExpenseSemanticLabel.
  ///
  /// In es, this message translates to:
  /// **'Agregar gasto'**
  String get floatingNavBarAddExpenseSemanticLabel;
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
