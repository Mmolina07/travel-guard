// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Travel Guard';

  @override
  String get registerTypeTitle => '¿Cómo te quieres registrar?';

  @override
  String get registerTypeSubtitle =>
      'Selecciona cómo quieres registrarte en TravelGuard.';

  @override
  String get registerTypeTouristTitle => 'Turista';

  @override
  String get registerTypeTouristDescription =>
      'Accede a experiencias, mapas, recomendaciones y más.';

  @override
  String get registerTypeCommerceTitle => 'Comercio';

  @override
  String get registerTypeCommerceDescription =>
      'Registra tu negocio y llega a más visitantes.';

  @override
  String get authBrandTagline =>
      'Tu itinerario, tu presupuesto y tu seguridad, en un solo lugar.';

  @override
  String get loginErrorGeneric => 'No se pudo iniciar sesión.';

  @override
  String get loginSuccessSnackbar => '¡Ingreso exitoso!';

  @override
  String get loginErrorEnterEmail => 'Por favor ingresa tu correo';

  @override
  String get loginErrorInvalidEmail => 'Correo inválido';

  @override
  String get loginErrorEnterPassword => 'Por favor ingresa tu contraseña';

  @override
  String get loginWelcome => 'Bienvenido';

  @override
  String get loginWelcomeBack => 'de nuevo';

  @override
  String get loginHeroSubtitle =>
      'Explora Medellín con seguridad y control de tu presupuesto.';

  @override
  String get loginStatStepsLabel => 'PASOS PARA CREAR TU VIAJE';

  @override
  String get loginStatBudgetLabel => 'CONTROL DE TU PRESUPUESTO';

  @override
  String get loginRoleTourist => 'Turista';

  @override
  String get loginRoleCommerce => 'Comercio';

  @override
  String get loginFieldEmailLabel => 'CORREO';

  @override
  String get loginFieldEmailHint => 'ejemplo@correo.com';

  @override
  String get loginFieldPasswordLabel => 'CONTRASEÑA';

  @override
  String get loginPasswordHide => 'OCULTAR';

  @override
  String get loginPasswordShow => 'VER';

  @override
  String get loginFeatureInDevelopment => 'Función en desarrollo';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginSubmitAsCommerce => 'Ingresar como comercio';

  @override
  String get loginSubmitAsTourist => 'Ingresar como turista';

  @override
  String get loginContinueWithGoogle => 'Continuar con Google';

  @override
  String get loginNoAccountQuestion => '¿No tienes cuenta?';

  @override
  String get loginRegisterLink => 'Regístrate';

  @override
  String get commonRegisterButton => 'Registrarse';

  @override
  String get commonEmailLabel => 'Correo electrónico';

  @override
  String get commonEmailHint => 'ejemplo@correo.com';

  @override
  String get commonPasswordLabel => 'Contraseña';

  @override
  String get commonConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get commonTermsNotice =>
      'Al registrarte aceptas nuestros Términos y Condiciones';

  @override
  String get commonRegisterErrorGeneric => 'No se pudo completar el registro.';

  @override
  String get commonEmailRequired => 'Por favor ingresa tu correo';

  @override
  String get commonEmailInvalid => 'Correo inválido';

  @override
  String get commonPasswordRequired => 'Por favor ingresa tu contraseña';

  @override
  String get commonPasswordsMismatch => 'Las contraseñas no coinciden';

  @override
  String get clientRegisterTitle => 'Regístrate como turista';

  @override
  String get clientRegisterSubtitle =>
      'Crea tu cuenta para empezar a planificar tu viaje';

  @override
  String get clientRegisterNameLabel => 'Nombre completo';

  @override
  String get clientRegisterNameHint => 'Ingresa tu nombre';

  @override
  String get clientRegisterNameRequired => 'Por favor ingresa tu nombre';

  @override
  String get clientRegisterPasswordHelper => 'Mínimo 6 caracteres';

  @override
  String get clientRegisterPasswordMin =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get clientRegisterConfirmPasswordRequired =>
      'Por favor confirma tu contraseña';

  @override
  String get clientRegisterSuccessSnackbar => 'Registro exitoso';

  @override
  String get clientRegisterOrContinueWith => 'o continúa con';

  @override
  String get clientRegisterGoogleButton => 'Registrarse con Google';

  @override
  String get commerceRegisterTitle => 'Registra tu comercio';

  @override
  String get commerceRegisterSubtitle =>
      'Llega a más viajeros con tu negocio en TravelGuard';

  @override
  String get commerceRegisterNitLabel => 'NIT';

  @override
  String get commerceRegisterNitHint => 'Ingresa el NIT';

  @override
  String get commerceRegisterNameLabel => 'Nombre del negocio';

  @override
  String get commerceRegisterNameHint => 'Ingresa el nombre del negocio';

  @override
  String get commerceRegisterAddressLabel => 'Dirección';

  @override
  String get commerceRegisterAddressHint => 'Ingresa la dirección';

  @override
  String get commerceRegisterAddressHelper =>
      'Escribe la dirección y toca el ícono de ubicación (o presiona Enter) para verla en el mapa de abajo.';

  @override
  String get commerceRegisterAddressSearchTooltip =>
      'Buscar esta dirección en el mapa';

  @override
  String get commerceRegisterPhoneLabel => 'Número telefónico';

  @override
  String get commerceRegisterPhoneHint => 'Ingresa el número';

  @override
  String get commerceRegisterSedeLabel => 'Sede';

  @override
  String get commerceRegisterSedeHint => 'Ingresa la sede';

  @override
  String get commerceRegisterLocationLabel => 'Ubicación del negocio';

  @override
  String get commerceRegisterPasswordHelper => 'Mínimo 8 caracteres';

  @override
  String get commerceRegisterSuccessSnackbar => '¡Registro exitoso!';

  @override
  String get commerceRegisterOr => 'o';

  @override
  String get commerceRegisterGoogleVerified => 'Cuenta de Google verificada';

  @override
  String get commerceRegisterGoogleVerify => 'Verificar con Google';

  @override
  String get commerceRegisterGoogleVerifiedSnackbar =>
      'Cuenta de Google verificada. Completa los datos del negocio y presiona \"Registrarse\" para terminar.';

  @override
  String get commerceRegisterFieldsRequired =>
      'Debe completar todos los campos obligatorios';

  @override
  String get commerceRegisterLocationRequired =>
      'Selecciona la ubicación de tu negocio en el mapa';

  @override
  String get commerceRegisterNitInvalid => 'NIT inválido o ya registrado';

  @override
  String get commerceRegisterEmailInvalidOrTaken =>
      'Email inválido o ya registrado';

  @override
  String get commerceRegisterPasswordMin =>
      'La contraseña debe tener mínimo 8 caracteres';

  @override
  String get commerceRegisterGeocodeNotFound =>
      'No se encontró esa dirección en el mapa. Ubica tu negocio manualmente tocando el mapa de abajo.';

  @override
  String get commerceRegisterGeocodeFound =>
      'Ubicación encontrada — ajusta el marcador si hace falta.';

  @override
  String get configScreenTitle => 'Configuración';

  @override
  String get configSectionLanguageRegion => 'Idioma y región';

  @override
  String get configLanguageLabel => 'Idioma';

  @override
  String get configCurrencyLabel => 'Moneda';

  @override
  String get configSectionNotifications => 'Notificaciones';

  @override
  String get configNotificationsToggleLabel => 'Activar notificaciones';

  @override
  String get configSectionSecurity => 'Seguridad';

  @override
  String get configChangePasswordLabel => 'Cambiar contraseña';

  @override
  String get configLogoutLabel => 'Cerrar sesión';

  @override
  String get configVersionLabel => 'Versión 1.0.0';

  @override
  String get configCurrentPasswordLabel => 'Contraseña actual';

  @override
  String get configCurrentPasswordHint => 'Ingresa tu contraseña actual';

  @override
  String get configNewPasswordLabel => 'Nueva contraseña';

  @override
  String get configNewPasswordHint => 'Ingresa tu nueva contraseña';

  @override
  String get configConfirmNewPasswordHint => 'Confirma tu nueva contraseña';

  @override
  String get configShowPasswordCheckbox => 'Mostrar contraseña';

  @override
  String get configCancelButton => 'Cancelar';

  @override
  String get configSaveButton => 'Guardar';

  @override
  String get configPasswordUpdatedSnackbar =>
      'Contraseña actualizada correctamente';

  @override
  String configErrorChangePassword(String error) {
    return 'Error al cambiar la contraseña: $error';
  }

  @override
  String get configSelectLanguageTitle => 'Selecciona idioma';

  @override
  String get configSelectCurrencyTitle => 'Selecciona moneda';

  @override
  String get configCurrencyCOP => 'Peso Colombiano';

  @override
  String get configCurrencyUSD => 'Dólar estadounidense';

  @override
  String get configCurrencyEUR => 'Euro';

  @override
  String get configLogoutDialogTitle => '¿Cerrar sesión?';

  @override
  String get configLogoutDialogContent =>
      'Se cerrará tu sesión en la aplicación.';

  @override
  String get addExpenseInvalidAmount => 'Ingresa un monto válido';

  @override
  String get addExpenseTitle => 'Agregar gasto';

  @override
  String get addExpenseSubtitle => 'Registra un nuevo gasto real de este viaje';

  @override
  String get addExpenseCategoryLabel => 'Categoría';

  @override
  String get addExpenseAmountLabel => 'Monto';

  @override
  String get addExpenseAmountHint => 'Ej. 50000';

  @override
  String get addExpenseDateLabel => 'Fecha del gasto';

  @override
  String get addExpenseDescriptionLabel => 'Descripción (opcional)';

  @override
  String get addExpenseDescriptionHint => 'Ej. Cena en el centro';

  @override
  String get addExpenseAddButton => 'Agregar';

  @override
  String get mapScreenUserHereLabel => 'Tú estás aquí';

  @override
  String get mapScreenActionEnableGps => 'Activar GPS';

  @override
  String get mapScreenActionAllow => 'Permitir';

  @override
  String get mapScreenActionSettings => 'Ajustes';

  @override
  String get mapScreenLocationServiceDisabled =>
      'El GPS está desactivado. Actívalo para ver tu ubicación.';

  @override
  String get mapScreenLocationPermissionDenied =>
      'Necesitamos permiso de ubicación para centrar el mapa en ti.';

  @override
  String get mapScreenLocationPermissionDeniedForever =>
      'El permiso de ubicación está bloqueado. Actívalo desde los ajustes de la app.';

  @override
  String get mapScreenTitle => 'Mapa';

  @override
  String get mapScreenSearchingNearbyPlaces => 'Buscando lugares cercanos...';

  @override
  String mapScreenPlacesFoundCount(int count) {
    return '$count lugar(es) encontrados';
  }

  @override
  String get comerciosCercanosLoadError =>
      'No se pudieron cargar los comercios. Intenta de nuevo.';

  @override
  String comerciosCercanosPlacesCountLabel(int count) {
    return '$count LUGAR(ES)';
  }

  @override
  String get comerciosCercanosHeaderTitle1 => 'Cerca ';

  @override
  String get comerciosCercanosHeaderTitle2 => 'de ti';

  @override
  String get comerciosCercanosHeaderSubtitle =>
      'Comercios y lugares verificados cerca de tu ubicación.';

  @override
  String get comerciosCercanosTagVerified => 'Verificado';

  @override
  String get comerciosCercanosTagOpenNow => 'Abierto ahora';

  @override
  String get comerciosCercanosRetryLabel => 'Reintentar';

  @override
  String get comerciosCercanosEmptyAll =>
      'Todavía no hay comercios ni lugares registrados';

  @override
  String get comerciosCercanosEmptyCategory =>
      'No hay lugares en esta categoría';

  @override
  String get comerciosCercanosEmptyHint =>
      'Prueba con otra categoría o vuelve más tarde.';

  @override
  String get comerciosCercanosTitle => 'Comercios cercanos';

  @override
  String get comerciosCercanosNearYourLocation =>
      'Cerca de tu ubicación actual';

  @override
  String get comerciosCercanosLocationUnavailable => 'Ubicación no disponible';

  @override
  String comerciosCercanosPlacesFoundCount(int count) {
    return '$count lugar(es) encontrados';
  }

  @override
  String get placeDetailsErrorOpenMap => 'No se pudo abrir el mapa.';

  @override
  String placeDetailsCategoryDistance(String category, String distance) {
    return '$category · a $distance de ti';
  }

  @override
  String get placeDetailsDirectionsButton => 'Cómo llegar';

  @override
  String get placeDetailsActivitiesTitle => 'Actividades disponibles';

  @override
  String get placeDetailsNoActivities => 'Sin actividades registradas todavía.';

  @override
  String get locationPickerErrorSnackbar =>
      'No se pudo obtener tu ubicación. Toca el mapa para ubicar tu negocio manualmente.';

  @override
  String get locationPickerHintTapMap =>
      'Toca el mapa o usa el botón para ubicar tu negocio.';

  @override
  String locationPickerSelectedLocation(String lat, String lng) {
    return 'Ubicación seleccionada: $lat, $lng (puedes arrastrar el marcador para ajustar)';
  }

  @override
  String get appShellNavHome => 'Inicio';

  @override
  String get appShellNavMyTrips => 'Mis viajes';

  @override
  String get appShellNavCommerces => 'Comercios';

  @override
  String get appShellNavMap => 'Mapa';

  @override
  String get appShellNavSectionLabel => 'NAVEGACIÓN';

  @override
  String get appShellCreateTripButton => 'Crear viaje';

  @override
  String appShellBudgetLabel(String month) {
    return 'PRESUPUESTO $month';
  }

  @override
  String appShellBudgetPercentOf(int percent, String amount) {
    return '$percent% de $amount';
  }

  @override
  String get appShellNoActiveTrip => 'Sin viaje activo';

  @override
  String get appShellRoleTourist => 'Turista';

  @override
  String get appShellRoleCommerce => 'Comercio';

  @override
  String get appShellSettingsTooltip => 'Configuración';

  @override
  String get appShellSignOutTooltip => 'Cerrar sesión';

  @override
  String get appShellSignOutDialogTitle => 'Cerrar sesión';

  @override
  String get appShellSignOutDialogContent =>
      '¿Seguro que quieres cerrar tu sesión?';

  @override
  String get appShellCancelButton => 'Cancelar';

  @override
  String get appShellSignOutConfirmButton => 'Cerrar sesión';

  @override
  String get appShellSearchHint => 'Buscar viajes, comercios o ciudades';

  @override
  String get appShellMonthJan => 'ene';

  @override
  String get appShellMonthFeb => 'feb';

  @override
  String get appShellMonthMar => 'mar';

  @override
  String get appShellMonthApr => 'abr';

  @override
  String get appShellMonthMay => 'may';

  @override
  String get appShellMonthJun => 'jun';

  @override
  String get appShellMonthJul => 'jul';

  @override
  String get appShellMonthAug => 'ago';

  @override
  String get appShellMonthSep => 'sep';

  @override
  String get appShellMonthOct => 'oct';

  @override
  String get appShellMonthNov => 'nov';

  @override
  String get appShellMonthDec => 'dic';

  @override
  String get appShellWeekdayMonday => 'lunes';

  @override
  String get appShellWeekdayTuesday => 'martes';

  @override
  String get appShellWeekdayWednesday => 'miércoles';

  @override
  String get appShellWeekdayThursday => 'jueves';

  @override
  String get appShellWeekdayFriday => 'viernes';

  @override
  String get appShellWeekdaySaturday => 'sábado';

  @override
  String get appShellWeekdaySunday => 'domingo';

  @override
  String get floatingNavBarHome => 'Inicio';

  @override
  String get floatingNavBarMap => 'Mapa';

  @override
  String get floatingNavBarCommerces => 'Comercios';

  @override
  String get floatingNavBarCreateTripSemanticLabel => 'Crear viaje';

  @override
  String get createActivityDatePickerHelpText => 'Selecciona una fecha';

  @override
  String get createActivityDatePickerCancel => 'Cancelar';

  @override
  String get createActivityDatePickerConfirm => 'Aceptar';

  @override
  String get createActivityStartDateSnackbar =>
      'Selecciona la fecha de inicio de la actividad.';

  @override
  String get createActivityEndDateSnackbar =>
      'Selecciona la fecha de finalización o marca \"Sin fecha de fin\".';

  @override
  String get createActivityAppBarTitle => 'Crear actividad';

  @override
  String get createActivityHeading => 'Nueva actividad';

  @override
  String get createActivitySubtitle =>
      'Completa la información para publicar una actividad para los turistas.';

  @override
  String get createActivityNameLabel => 'Nombre de la actividad';

  @override
  String get createActivityNameHint => 'Ej. Happy Hour';

  @override
  String get createActivityNameRequired => 'Ingresa el nombre de la actividad';

  @override
  String get createActivityDescriptionLabel => 'Descripción';

  @override
  String get createActivityDescriptionHint =>
      'Explica de qué trata la actividad';

  @override
  String get createActivityDescriptionRequired => 'Ingresa una descripción';

  @override
  String get createActivityDescriptionTooShort =>
      'La descripción debe ser más detallada';

  @override
  String get createActivityCategoryLabel => 'Tipo o categoría';

  @override
  String get createActivityCategoryHint => 'Selecciona una categoría';

  @override
  String get createActivityCategoryRequired => 'Selecciona una categoría';

  @override
  String get createActivityPriceLabel => 'Precio';

  @override
  String get createActivityPriceHint => 'Ej. 25000';

  @override
  String get createActivityPriceRequired =>
      'Ingresa el precio o marca \"Gratis\"';

  @override
  String get createActivityPriceInvalid => 'Ingresa un precio válido';

  @override
  String get createActivityFreeCheckbox => 'Actividad gratuita';

  @override
  String get createActivityStartDateLabel => 'Fecha de inicio';

  @override
  String get createActivityStartDateHint => 'Selecciona la fecha de inicio';

  @override
  String get createActivityStartDateRequired => 'Selecciona la fecha de inicio';

  @override
  String get createActivityEndDateLabel => 'Fecha de finalización';

  @override
  String get createActivityEndDateHint => 'Selecciona la fecha de finalización';

  @override
  String get createActivityNoEndDateCheckbox => 'Sin fecha de fin';

  @override
  String get createActivityStatusLabel => 'Estado de la actividad';

  @override
  String get createActivityCancelButton => 'Cancelar';

  @override
  String get createActivityCreateButton => 'Crear';

  @override
  String get createMenuAddProductDialogTitle => 'Agregar producto';

  @override
  String get createMenuProductNameLabel => 'Nombre del producto';

  @override
  String get createMenuProductNameHint => 'Ej. Hamburguesa clásica';

  @override
  String get createMenuProductDescriptionLabel => 'Descripción';

  @override
  String get createMenuProductDescriptionHint => 'Describe el producto';

  @override
  String get createMenuProductPriceLabel => 'Precio';

  @override
  String get createMenuProductPriceHint => 'Ej. 18000';

  @override
  String get createMenuCancelButton => 'Cancelar';

  @override
  String get createMenuFieldsInvalidSnackbar =>
      'Completa correctamente todos los campos.';

  @override
  String get createMenuNegativePriceSnackbar =>
      'El precio no puede ser negativo.';

  @override
  String get createMenuAddProductButton => 'Agregar';

  @override
  String get createMenuNoProductsSnackbar =>
      'Agrega al menos un producto al menú.';

  @override
  String get createMenuAppBarTitle => 'Crear menú';

  @override
  String get createMenuHeading => 'Nuevo menú';

  @override
  String get createMenuSubtitle =>
      'Crea un menú para mostrar tus productos a los turistas.';

  @override
  String get createMenuNameLabel => 'Nombre del menú';

  @override
  String get createMenuNameHint => 'Ej. Menú de comidas rápidas';

  @override
  String get createMenuNameRequired => 'Ingresa el nombre del menú';

  @override
  String get createMenuDescriptionLabel => 'Descripción';

  @override
  String get createMenuDescriptionHint => 'Describe de qué trata este menú';

  @override
  String get createMenuDescriptionRequired => 'Ingresa una descripción';

  @override
  String get createMenuCategoryLabel => 'Categoría';

  @override
  String get createMenuProductsHeading => 'Productos del menú';

  @override
  String createMenuProductsCount(int count) {
    return '$count productos';
  }

  @override
  String get createMenuEmptyProductsTitle => 'Todavía no hay productos';

  @override
  String get createMenuEmptyProductsSubtitle =>
      'Agrega los productos que formarán parte de este menú.';

  @override
  String get createMenuAddProductLabel => 'Agregar producto';

  @override
  String get createMenuAvailableTitle => 'Menú disponible';

  @override
  String get createMenuAvailableSubtitleOn => 'Los turistas podrán verlo.';

  @override
  String get createMenuAvailableSubtitleOff => 'El menú estará oculto.';

  @override
  String get createMenuCreateButton => 'Crear menú';

  @override
  String get homeComercioSignOut => 'Cerrar sesión';

  @override
  String get homeComercioSignOutDialogContent =>
      '¿Seguro que quieres cerrar tu sesión?';

  @override
  String get homeComercioCancelButton => 'Cancelar';

  @override
  String homeComercioActivityCreatedSnackbar(String name) {
    return 'Actividad \"$name\" creada';
  }

  @override
  String get homeComercioCreateFirstMenuSnackbar => 'Crea tu primer menú';

  @override
  String get homeComercioAddMenuTitle => 'Agregar menú';

  @override
  String get homeComercioAddMenuDescription =>
      'Crea y gestiona los platos, bebidas y servicios que ofrece tu negocio.';

  @override
  String get homeComercioAddMenuButton => '+ Menú';

  @override
  String homeComercioMenuCreatedSnackbar(String name) {
    return 'Menú \"$name\" creado';
  }

  @override
  String get homeComercioCreateActivityTitle => 'Crear actividad';

  @override
  String get homeComercioCreateActivityDescription =>
      'Organiza eventos, promociones y actividades especiales para tus clientes.';

  @override
  String get homeComercioCreateActivityButton => '+ Actividad';

  @override
  String get homeComercioMyActivitiesTitle => 'Mis actividades';

  @override
  String get homeComercioSeeAllButton => 'Ver todas';

  @override
  String get homeComercioNoNameFallback => 'Sin nombre';

  @override
  String homeComercioGreeting(String businessName) {
    return '¡Hola, $businessName!';
  }

  @override
  String get homeComercioHeroSubtitle => 'Gestiona tu negocio fácilmente';

  @override
  String get homeComercioStatActivitiesLabel => 'Actividades';

  @override
  String get homeComercioStatMenusLabel => 'Menús creados';

  @override
  String get homeComercioEmptyActivitiesTitle => 'Aún no tienes actividades';

  @override
  String get homeComercioEmptyActivitiesSubtitle =>
      'Crea tu primera actividad para tus visitantes.';

  @override
  String get homeComercioNavHome => 'Inicio';

  @override
  String get homeComercioNavActivities => 'Actividades';

  @override
  String get homeComercioNavMenu => 'Menú';

  @override
  String get menuDetailAppBarTitle => 'Detalle del Menú';

  @override
  String get menuDetailStatusAvailable => 'Disponible';

  @override
  String get menuDetailStatusUnavailable => 'No disponible';

  @override
  String get menuDetailDescriptionLabel => 'Descripción';

  @override
  String get menuDetailStatProductsLabel => 'Productos';

  @override
  String get menuDetailStatAverageLabel => 'Promedio';

  @override
  String get menuDetailStatTotalLabel => 'Total';

  @override
  String menuDetailProductsCount(int count) {
    return 'Productos ($count)';
  }

  @override
  String get menuDetailNoProductsTitle => 'No hay productos';

  @override
  String get menuDetailFeatureInDevelopmentSnackbar => 'Función en desarrollo';

  @override
  String get menuDetailEditButton => 'Editar';

  @override
  String get menuDetailDeleteButton => 'Eliminar';

  @override
  String get menuDetailDeleteDialogTitle => 'Eliminar menú';

  @override
  String menuDetailDeleteDialogContent(String name) {
    return '¿Estás seguro de que deseas eliminar el menú \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get menuDetailCancelButton => 'Cancelar';

  @override
  String get menuDetailMenuDeletedSnackbar => 'Menú eliminado';

  @override
  String get createTripBarrierLabel => 'Crear viaje';

  @override
  String get createTripStep0TitleLine1 => '¿A dónde';

  @override
  String get createTripStep0TitleLine2 => 'vamos?';

  @override
  String get createTripStep1TitleLine1 => '¿Dónde';

  @override
  String get createTripStep1TitleLine2 => 'dormimos?';

  @override
  String get createTripStep2TitleLine1 => '¿Cómo nos';

  @override
  String get createTripStep2TitleLine2 => 'movemos?';

  @override
  String get createTripStepNameDestination => 'Destino y fechas';

  @override
  String get createTripStepNameLodging => 'Hospedaje';

  @override
  String get createTripStepNameTransport => 'Transporte';

  @override
  String get createTripErrorSelectStartDateFirst =>
      'Primero selecciona la fecha de inicio';

  @override
  String get createTripErrorNameDestinationRequired =>
      'Ingresa el nombre y el destino del viaje';

  @override
  String get createTripErrorInvalidDates => 'Selecciona fechas válidas';

  @override
  String get createTripErrorEndDateAfterStart =>
      'La fecha de fin debe ser posterior a la de inicio';

  @override
  String get createTripErrorMinOnePerson => 'Debe haber mínimo 1 persona';

  @override
  String get createTripErrorRequiredFields =>
      'Debe completar todos los campos obligatorios';

  @override
  String get createTripErrorBudgetMustBePositive =>
      'El presupuesto debe ser mayor a 0';

  @override
  String get createTripErrorInvalidDatesEntered =>
      'Las fechas ingresadas no son válidas';

  @override
  String get createTripErrorEndDateAfterStartFull =>
      'La fecha de fin debe ser posterior a la fecha de inicio';

  @override
  String get createTripErrorLodgingCostMustBePositive =>
      'El costo debe ser mayor a 0';

  @override
  String get createTripErrorEmergencyAmountMustBePositive =>
      'El monto debe ser mayor a 0';

  @override
  String get createTripIncompleteDataDialogTitle => 'Datos incompletos';

  @override
  String get createTripIncompleteDataDialogContent =>
      'La estimación será menos precisa. ¿Deseas continuar?';

  @override
  String get createTripCancelButton => 'Cancelar';

  @override
  String get createTripConfirmCreateButton => 'Sí, crear viaje';

  @override
  String get createTripErrorMustBeLoggedIn =>
      'Debes iniciar sesión como turista para crear un viaje.';

  @override
  String createTripCreatedSnackbar(String amount) {
    return '¡Viaje creado! Presupuesto total: $amount';
  }

  @override
  String get createTripErrorSaveGeneric =>
      'No se pudo guardar el viaje. Intenta nuevamente.';

  @override
  String get createTripErrorDbOutdated =>
      'La base de datos no está actualizada para guardar el viaje (falta una columna o tabla). Revisa docs/db/hu05_viajes_costos.sql.';

  @override
  String get createTripErrorNoPermission =>
      'No tienes permiso para guardar el viaje (revisa las políticas de seguridad de la tabla viajes en Supabase).';

  @override
  String get createTripErrorNotRegisteredAsTourist =>
      'Tu usuario no está registrado como turista todavía.';

  @override
  String get createTripCancelDialogTitle => '¿Estás seguro?';

  @override
  String get createTripCancelDialogContent =>
      'Se descartarán los datos ingresados.';

  @override
  String get createTripCancelDialogNoButton => 'No';

  @override
  String get createTripCancelDialogConfirmButton => 'Sí, descartar';

  @override
  String createTripStepIndicator(int current, int total) {
    return 'PASO $current DE $total';
  }

  @override
  String get createTripBackButton => 'Atrás';

  @override
  String createTripNextStepLabel(String stepName) {
    return 'SIGUIENTE · $stepName';
  }

  @override
  String get createTripContinueButton => 'Continuar →';

  @override
  String get createTripCreateButton => 'Crear viaje';

  @override
  String get createTripNextLabel => 'SIGUIENTE';

  @override
  String get createTripDoneLabel => 'LISTO';

  @override
  String get createTripNameLabel => 'Nombre del viaje';

  @override
  String get createTripNameHint => 'Ej: Viaje a Cartagena';

  @override
  String get createTripDestinationLabel => 'Destino';

  @override
  String get createTripDestinationHint => 'Ej: Cartagena, Colombia';

  @override
  String get createTripStartDateLabel => 'INICIO';

  @override
  String get createTripEndDateLabel => 'FIN';

  @override
  String createTripDurationLabel(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    return 'Duración: $_temp0';
  }

  @override
  String get createTripTypeLabel => 'TIPO DE VIAJE';

  @override
  String get createTripLodgingTypeLabel => 'TIPO DE HOSPEDAJE';

  @override
  String get createTripLodgingCostLabel => 'Costo hospedaje';

  @override
  String get createTripLodgingCostHint => 'Ej: 2000000';

  @override
  String get createTripAdvancePaymentLabel => 'Pagos anticipados';

  @override
  String get createTripAdvancePaymentHint => 'Ej: 1500000';

  @override
  String get createTripIncludedServicesLabel => 'SERVICIOS INCLUIDOS';

  @override
  String get createTripServiceBreakfast => 'Desayuno';

  @override
  String get createTripServiceLunch => 'Almuerzo';

  @override
  String get createTripServiceDinner => 'Cena';

  @override
  String get createTripServiceTransfer => 'Traslado';

  @override
  String get createTripStartTransportLabel => 'TRANSPORTE DE INICIO';

  @override
  String get createTripDuringTransportLabel => 'TRANSPORTE DURANTE EL VIAJE';

  @override
  String get createTripAdditionalExpensesLabel => 'GASTOS ADICIONALES';

  @override
  String get createTripAddButton => 'Agregar';

  @override
  String get createTripEmergencyMoneyLabel => 'Dinero emergencias';

  @override
  String get createTripEmergencyMoneyHint => 'Ej: 500000';

  @override
  String get createTripPersonsLabel => 'PERSONAS';

  @override
  String get createTripMaxBudgetLabel => 'PRESUPUESTO MÁXIMO';

  @override
  String get createTripCategoryLabel => 'Categoría';

  @override
  String get createTripCategoryHint => 'Ej: Transporte interno';

  @override
  String get createTripAmountLabel => 'Monto';

  @override
  String get createTripCategoryAmountHint => 'Ej: 500000';

  @override
  String get createTripRemoveCategoryTooltip => 'Quitar categoría';

  @override
  String get createTripBudgetSummaryPlaceholder =>
      'Define el presupuesto máximo en el paso 1 para ver aquí el resumen.';

  @override
  String get createTripBudgetSummaryTitle => 'Resumen de presupuesto';

  @override
  String get createTripEstimatedLabel => 'Estimado (con lo ingresado)';

  @override
  String get createTripOverBudgetLabel => 'Te excedes por';

  @override
  String get createTripAvailableLabel => 'Disponible';

  @override
  String get createTripOverBudgetWarning =>
      'Lo estimado supera tu presupuesto máximo.';

  @override
  String get createTripEnterDatesForDailyBudget =>
      'Ingresa las fechas del viaje para ver el presupuesto por día.';

  @override
  String get createTripRemainingBudgetSplitLabel =>
      'Presupuesto restante, repartido en:';

  @override
  String createTripPerDayLabel(int days) {
    return 'Por día ($days días)';
  }

  @override
  String createTripPerPersonLabel(int persons) {
    return 'Por persona ($persons)';
  }

  @override
  String get createTripPerPersonPerDayLabel => 'Por persona, por día';

  @override
  String get editTripBudgetErrorMaxBudgetPositive =>
      'El presupuesto máximo debe ser mayor a 0';

  @override
  String get editTripBudgetErrorMustBeLoggedIn =>
      'Debes iniciar sesión para guardar cambios.';

  @override
  String get editTripBudgetErrorSaveGeneric =>
      'No se pudo guardar el presupuesto. Intenta de nuevo.';

  @override
  String get editTripBudgetTitle => 'Editar presupuesto';

  @override
  String get editTripBudgetMaxBudgetLabel => 'Presupuesto máximo';

  @override
  String get editTripBudgetAdvancePaymentLabel => 'Pagos anticipados';

  @override
  String get editTripBudgetLodgingCostLabel => 'Costo hospedaje';

  @override
  String get editTripBudgetEmergencyMoneyLabel => 'Dinero emergencias';

  @override
  String get editTripBudgetCategoriesTitle => 'Categorías de gasto';

  @override
  String get editTripBudgetAddButton => 'Agregar';

  @override
  String get editTripBudgetEstimatedLabel => 'Estimado';

  @override
  String get editTripBudgetOverBudgetLabel => 'Te excedes por';

  @override
  String get editTripBudgetAvailableLabel => 'Disponible';

  @override
  String editTripBudgetPerDayLabel(int days) {
    return 'Por día (${days}d)';
  }

  @override
  String editTripBudgetPerPersonLabel(int persons) {
    return 'Por persona ($persons)';
  }

  @override
  String get editTripBudgetSaveButton => 'Guardar cambios';

  @override
  String get editTripBudgetCategoryLabel => 'Categoría';

  @override
  String get editTripBudgetAmountLabel => 'Monto';

  @override
  String get editTripBudgetRemoveCategoryTooltip => 'Quitar categoría';

  @override
  String get homeClientSignOutDialogTitle => 'Cerrar sesión';

  @override
  String get homeClientSignOutDialogContent =>
      '¿Seguro que quieres cerrar tu sesión?';

  @override
  String get homeClientCancelButton => 'Cancelar';

  @override
  String get homeClientSignOutConfirmButton => 'Cerrar sesión';

  @override
  String get homeClientCreateTripFirstSnackbar =>
      'Crea un viaje primero para poder registrar un gasto.';

  @override
  String get homeClientPickTripTitle => '¿A qué viaje pertenece?';

  @override
  String get homeClientPickTripSubtitle =>
      'Elige el viaje para registrar el gasto.';

  @override
  String get homeClientTripNotSavedSnackbar =>
      'Este viaje no quedó guardado en el servidor; no se pueden registrar gastos.';

  @override
  String get homeClientCategoriesLoadErrorSnackbar =>
      'No se pudieron cargar las categorías de gasto.';

  @override
  String homeClientExpenseAddedSnackbar(
    String amount,
    String category,
    String tripName,
  ) {
    return 'Gasto de $amount en $category agregado a $tripName';
  }

  @override
  String get homeClientExpenseSaveErrorSnackbar =>
      'No se pudo guardar el gasto. Intenta de nuevo.';

  @override
  String homeClientGreeting(String name) {
    return 'Hola, $name.';
  }

  @override
  String homeClientActiveTripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viajes activos',
      one: '1 viaje activo',
    );
    return '$_temp0';
  }

  @override
  String get homeClientMyTripsTitle => 'Mis viajes';

  @override
  String get homeClientViewAllLabel => 'VER TODOS';

  @override
  String get homeClientNoTripsTitle => 'Aún no tienes viajes';

  @override
  String get homeClientNoTripsSubtitle =>
      'Crea tu primer viaje para comenzar a planificar.';

  @override
  String get homeClientCreateTripLabel => 'Crear viaje';

  @override
  String get homeClientNearbyTitle => 'Cerca de ti';

  @override
  String get homeClientNoNearbyPlaces =>
      'Todavía no hay comercios ni lugares cerca registrados.';

  @override
  String get homeClientVerifiedTag => 'Verificado';

  @override
  String homeClientViewPlacesButton(int count) {
    return 'Ver los $count lugares →';
  }

  @override
  String get homeClientExploreTagline => 'Explora, planifica y viaja seguro.';

  @override
  String homeClientContextLineDays(String destination, num days, int pct) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    return '$destination empieza en $_temp0. El presupuesto va al $pct%.';
  }

  @override
  String homeClientContextLineNoDays(String destination, int pct) {
    return '$destination · el presupuesto va al $pct%.';
  }

  @override
  String get homeClientCreateTripCardTitle => 'Crear un viaje';

  @override
  String get homeClientCreateTripCardDescription =>
      'Organiza tu próxima aventura, establece tu presupuesto y descubre los mejores destinos.';

  @override
  String get homeClientCreateTripButtonPlus => '+ Crear viaje';

  @override
  String get homeClientCreateTripCardSubtitle =>
      'Presupuesto, hospedaje e itinerario en 3 pasos';

  @override
  String get homeClientMapCardTitle => 'Mapa';

  @override
  String get homeClientMapCardDescription =>
      'Explora destinos, encuentra comercios seguros y planifica tu ruta.';

  @override
  String get homeClientViewMapButton => 'Ver mapa';

  @override
  String get homeClientMapCardPlacesCount => '14 lugares cerca';

  @override
  String get homeClientNextExpenseLabel => 'PRÓXIMO GASTO';

  @override
  String get homeClientLodgingFallback => 'Hospedaje';

  @override
  String homeClientLodgingPaymentDue(String date, String amount) {
    return 'Se paga antes del $date · $amount';
  }

  @override
  String get homeClientRegisterExpenseHint =>
      'Registra un gasto de tu viaje en segundos.';

  @override
  String get homeClientSignOutButton => 'Cerrar sesión';

  @override
  String homeClientMobileGreeting(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get homeClientMobileHeroSubtitle =>
      'Explora, planifica y viaja seguro';

  @override
  String get homeClientStatActiveTripsLabel => 'Viajes activos';

  @override
  String get homeClientStatNextTripLabel => 'Próximo viaje';

  @override
  String get homeClientStatTotalBudgetLabel => 'Presupuesto total';

  @override
  String get homeClientViewAllMobileLabel => 'Ver todos';

  @override
  String get homeClientMonthAbbrJan => 'Ene';

  @override
  String get homeClientMonthAbbrFeb => 'Feb';

  @override
  String get homeClientMonthAbbrMar => 'Mar';

  @override
  String get homeClientMonthAbbrApr => 'Abr';

  @override
  String get homeClientMonthAbbrMay => 'May';

  @override
  String get homeClientMonthAbbrJun => 'Jun';

  @override
  String get homeClientMonthAbbrJul => 'Jul';

  @override
  String get homeClientMonthAbbrAug => 'Ago';

  @override
  String get homeClientMonthAbbrSep => 'Sep';

  @override
  String get homeClientMonthAbbrOct => 'Oct';

  @override
  String get homeClientMonthAbbrNov => 'Nov';

  @override
  String get homeClientMonthAbbrDec => 'Dic';

  @override
  String get tripDetailTripNotSavedSnackbar =>
      'Este viaje no quedó guardado en el servidor; no se pueden registrar gastos.';

  @override
  String get tripDetailLoadExpensesError => 'No se pudieron cargar los gastos.';

  @override
  String get tripDetailLoadGroupError =>
      'No se pudo cargar el grupo del viaje.';

  @override
  String get tripDetailInviteDialogTitle => 'Invitar colaborador';

  @override
  String get tripDetailInviteEmailHint => 'correo@ejemplo.com';

  @override
  String get tripDetailInviteEmailHelper =>
      'Debe estar registrado en TravelGuard como turista.';

  @override
  String get tripDetailCancelButton => 'Cancelar';

  @override
  String get tripDetailInviteButton => 'Invitar';

  @override
  String tripDetailCollaboratorAddedSnackbar(String name) {
    return '$name ahora puede ver y editar este viaje';
  }

  @override
  String get tripDetailInviteErrorSnackbar =>
      'No se pudo invitar a esa persona. Intenta de nuevo.';

  @override
  String get tripDetailRemoveCollaboratorDialogTitle => 'Quitar colaborador';

  @override
  String tripDetailRemoveCollaboratorDialogContent(String name) {
    return '¿Quitar a $name de este viaje? Dejará de poder verlo y editarlo.';
  }

  @override
  String get tripDetailRemoveButton => 'Quitar';

  @override
  String get tripDetailRemoveCollaboratorErrorSnackbar =>
      'No se pudo quitar al colaborador.';

  @override
  String get tripDetailCategoriesLoadErrorSnackbar =>
      'No se pudieron cargar las categorías de gasto.';

  @override
  String tripDetailExpenseAddedSnackbar(String amount, String category) {
    return 'Gasto de $amount en $category agregado';
  }

  @override
  String get tripDetailExpenseSaveErrorSnackbar =>
      'No se pudo guardar el gasto. Intenta de nuevo.';

  @override
  String get tripDetailDeleteExpenseDialogTitle => 'Eliminar gasto';

  @override
  String tripDetailDeleteExpenseDialogContent(String amount, String category) {
    return '¿Eliminar el gasto de $amount en $category?';
  }

  @override
  String get tripDetailDeleteButton => 'Eliminar';

  @override
  String get tripDetailDeleteExpenseErrorSnackbar =>
      'No se pudo eliminar el gasto.';

  @override
  String get tripDetailDeleteTripDialogTitle => 'Eliminar viaje';

  @override
  String tripDetailDeleteTripDialogContent(String name) {
    return '¿Estás seguro de que deseas eliminar el viaje \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get tripDetailTripDeletedSnackbar => 'Viaje eliminado';

  @override
  String get tripDetailDeleteTripErrorSnackbar =>
      'No se pudo eliminar el viaje. Intenta de nuevo.';

  @override
  String get tripDetailTabResumen => 'Resumen';

  @override
  String get tripDetailTabHospedaje => 'Hospedaje';

  @override
  String get tripDetailTabTransporte => 'Transporte';

  @override
  String get tripDetailTabGastos => 'Gastos';

  @override
  String get tripDetailTabGrupo => 'Grupo';

  @override
  String get tripDetailBreadcrumbHome => 'INICIO / MIS VIAJES';

  @override
  String get tripDetailEditButton => 'Editar';

  @override
  String get tripDetailAddExpenseButton => 'Añadir gasto';

  @override
  String get tripDetailHeaderTripToPrefix => 'Viaje a ';

  @override
  String tripDetailHeaderSubtitle(
    String startDate,
    String endDate,
    num persons,
    String tripType,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      persons,
      locale: localeName,
      other: '$persons PERSONAS',
      one: '$persons PERSONA',
    );
    return '$startDate – $endDate · $_temp0 · $tripType';
  }

  @override
  String get tripDetailSpentLabel => 'GASTADO';

  @override
  String get tripDetailCapLabel => 'TOPE';

  @override
  String tripDetailOverBudgetLabel(String amount) {
    return 'Te pasaste del tope por $amount';
  }

  @override
  String tripDetailOnTrackLabel(int pct) {
    return 'Vas bien: $pct% del presupuesto usado';
  }

  @override
  String get tripDetailLodgingTitle => 'Hospedaje';

  @override
  String get tripDetailLodgingTypeLabel => 'Tipo';

  @override
  String get tripDetailCostLabel => 'Costo';

  @override
  String get tripDetailTransportLabel => 'TRANSPORTE';

  @override
  String tripDetailDuringTransportDetail(String value) {
    return 'Durante: $value';
  }

  @override
  String get tripDetailPersonsLabel => 'PERSONAS';

  @override
  String get tripDetailRecentExpensesTitle => 'Últimos gastos';

  @override
  String get tripDetailNoExpensesYetHint =>
      'Aún no has registrado gastos. Usa \"Añadir gasto\" arriba para anotar el primero.';

  @override
  String get tripDetailAvailableBudgetTitle => 'Presupuesto disponible';

  @override
  String tripDetailPerDayLabel(int days) {
    return 'Por día ($days días)';
  }

  @override
  String tripDetailPerPersonLabel(int persons) {
    return 'Por persona ($persons)';
  }

  @override
  String get tripDetailExpenseBreakdownTitle => 'Desglose de gastos';

  @override
  String get tripDetailNoExpensesRegistered => 'No hay gastos registrados aún.';

  @override
  String get tripDetailAdvancePayments => 'Pagos anticipados';

  @override
  String get tripDetailLodgingPlanned => 'Hospedaje (planeado)';

  @override
  String get tripDetailEmergencies => 'Emergencias';

  @override
  String tripDetailCategoryRealSuffix(String category) {
    return '$category (real)';
  }

  @override
  String get tripDetailLodgingTypeFullLabel => 'Tipo de hospedaje';

  @override
  String get tripDetailIncludedServicesLabel => 'Servicios incluidos';

  @override
  String get tripDetailTransportTabTitle => 'Transporte';

  @override
  String get tripDetailStartTransportLabel => 'Transporte de inicio';

  @override
  String get tripDetailDuringTransportKvLabel => 'Transporte durante el viaje';

  @override
  String get tripDetailExpensesRegisteredTitle => 'Gastos registrados';

  @override
  String get tripDetailTripNotSavedExpensesHint =>
      'Este viaje no quedó guardado en el servidor, así que no se pueden registrar gastos reales.';

  @override
  String get tripDetailRetryButton => 'Reintentar';

  @override
  String get tripDetailNoRealExpensesYet =>
      'Aún no has registrado gastos reales para este viaje.';

  @override
  String get tripDetailDeleteExpenseTooltip => 'Eliminar gasto';

  @override
  String get tripDetailInvalidDatesHint =>
      'Agrega fechas válidas para ver tu ritmo de gasto.';

  @override
  String tripDetailTripStartsIn(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    return 'Tu viaje empieza en $_temp0.';
  }

  @override
  String get tripDetailTripEnded => 'Este viaje ya terminó.';

  @override
  String tripDetailDaysRemaining(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    return 'Quedan $_temp0 de viaje.';
  }

  @override
  String get tripDetailGroupDailySpendLabel => 'Grupo debería gastar/día';

  @override
  String get tripDetailPerPersonDailyLabel => 'Por persona/día';

  @override
  String get tripDetailSpendingPaceTitle => 'Ritmo de gasto';

  @override
  String get tripDetailSpentPerPersonLabel => 'Llevas gastado por persona';

  @override
  String get tripDetailForeignTouristQuestion => '¿Eres turista extranjero?';

  @override
  String tripDetailTaxRefundWithPurchases(
    String comprasTotal,
    String ivaEstimado,
  ) {
    return 'De lo que llevas en \"Compras\" ($comprasTotal), aprox. $ivaEstimado fue IVA — en Colombia los turistas extranjeros no residentes pueden pedirlo de vuelta completo antes de salir del país.';
  }

  @override
  String get tripDetailTaxRefundNoPurchases =>
      'Cuando registres compras (ropa, calzado, artesanías, joyería, electrodomésticos, etc.) con factura electrónica, aquí verás cuánto IVA podrías recuperar antes de salir del país.';

  @override
  String tripDetailTaxRefundRequirements(String minPurchase, String maxRefund) {
    return 'Requisitos: factura electrónica de mínimo $minPurchase por compra, pasaporte o Tarjeta Andina Migratoria, y solicitarlo en la DIAN del aeropuerto antes de viajar. Tope: $maxRefund por solicitud. Verifica el trámite vigente en dian.gov.co.';
  }

  @override
  String get tripDetailCollaboratorsTitle => 'Colaboradores';

  @override
  String get tripDetailCollaboratorsSubtitle =>
      'Quiénes pueden ver y editar este viaje';

  @override
  String get tripDetailOwnerTag => 'Dueño';

  @override
  String get tripDetailYouTag => 'Tú';

  @override
  String get tripDetailRemoveCollaboratorTooltip => 'Quitar colaborador';

  @override
  String get tripDetailHistoryTitle => 'Historial de cambios';

  @override
  String get tripDetailNoHistoryYet =>
      'Todavía no hay cambios registrados. Cuando alguien edite el presupuesto, quedará aquí.';

  @override
  String get tripDetailHistoryChangedText => ' cambió ';

  @override
  String get tripDetailJustNow => 'Justo ahora';

  @override
  String tripDetailMinutesAgo(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String tripDetailHoursAgo(int hours) {
    return 'Hace $hours h';
  }

  @override
  String get tripDetailYesterday => 'Ayer';

  @override
  String tripDetailDaysAgo(int days) {
    return 'Hace $days días';
  }

  @override
  String get tripDetailMobileAppBarTitle => 'Detalle del Viaje';

  @override
  String get tripDetailEditBudgetTooltip => 'Editar presupuesto';

  @override
  String get tripDetailMoreTooltip => 'Más';

  @override
  String get tripDetailBudgetTitle => 'Presupuesto';

  @override
  String get tripDetailSpentKvLabel => 'Gastado';

  @override
  String get tripDetailAvailableKvLabel => 'Disponible';

  @override
  String tripDetailBudgetUsedPercent(String percent) {
    return '$percent% del presupuesto utilizado';
  }

  @override
  String get desglosePresupuestoTitle => 'Desglose de Presupuesto';

  @override
  String get desglosePresupuestoHospedaje => 'Hospedaje';

  @override
  String get desglosePresupuestoTransporte => 'Transporte';

  @override
  String get desglosePresupuestoComidas => 'Comidas';

  @override
  String get desglosePresupuestoActividades => 'Actividades';

  @override
  String get desglosePresupuestoEmergencias => 'Emergencias';

  @override
  String get tripHistoryPresupuestoMaximo => 'Presupuesto máximo';

  @override
  String get tripHistoryPagosAnticipados => 'Pagos anticipados';

  @override
  String get tripHistoryCostoHospedaje => 'Costo hospedaje';

  @override
  String get tripHistoryDineroEmergencias => 'Dinero emergencias';

  @override
  String get tripHistoryCategoriasPresupuesto => 'Categorías de presupuesto';

  @override
  String get categoryFilterAll => 'Todos';

  @override
  String get placeCategoryComercio => 'Comercio';

  @override
  String get placeCategoryDiscoteca => 'Discoteca';

  @override
  String get placeCategoryMirador => 'Mirador';

  @override
  String get placeCategoryMuseo => 'Museo';

  @override
  String get placeCategoryOtro => 'Otro';

  @override
  String get placeCategoryParque => 'Parque';

  @override
  String get placeCategoryRestaurante => 'Restaurante';

  @override
  String get placeCategoryTour => 'Tour';

  @override
  String get placeCategoryHotel => 'Hotel';

  @override
  String get placeCategoryTienda => 'Tienda';

  @override
  String get placeCategoryTransporte => 'Transporte';

  @override
  String get configSectionReset => 'Restablecer';

  @override
  String get configResetDefaultsLabel => 'Restaurar valores predeterminados';

  @override
  String get configResetDefaultsDialogTitle =>
      '¿Restaurar valores predeterminados?';

  @override
  String get configResetDefaultsDialogContent =>
      'Se restablecerán el idioma, la moneda y las notificaciones a sus valores originales.';

  @override
  String get configResetDefaultsConfirmButton => 'Restaurar';

  @override
  String get configResetDefaultsSnackbar => 'Configuración restaurada';

  @override
  String get configExchangeRateLabel => 'Tasa de cambio';

  @override
  String configExchangeRatePreview(String rate) {
    return '1 USD = $rate';
  }

  @override
  String get configExchangeRateDialogTitle => 'Tasa de cambio';

  @override
  String get configExchangeRateDialogHint =>
      'Sin conexión a ningún servicio: ingresa tú mismo cuántos pesos colombianos equivalen a 1 dólar y a 1 euro. Solo cambia cómo se ven los montos en la app — lo guardado en tus viajes y gastos sigue siendo el valor real en pesos.';

  @override
  String get configExchangeRateUsdLabel => '1 USD equivale a (COP)';

  @override
  String get configExchangeRateEurLabel => '1 EUR equivale a (COP)';

  @override
  String get configExchangeRateInvalid =>
      'Ingresa valores válidos, mayores a 0';

  @override
  String get configExchangeRateSavedSnackbar => 'Tasa de cambio actualizada';

  @override
  String tripCardSpentOfBudget(String spent, String maxBudget) {
    return '$spent gastado de $maxBudget';
  }

  @override
  String get forgotPasswordTitle => 'Recupera tu contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Te enviaremos un enlace a tu correo para crear una nueva';

  @override
  String get forgotPasswordSubmitButton => 'Enviar enlace';

  @override
  String get forgotPasswordBackToLogin => 'Volver a iniciar sesión';

  @override
  String get forgotPasswordSuccessTitle => 'Revisa tu correo';

  @override
  String forgotPasswordSuccessBody(String email) {
    return 'Si $email está registrado, te enviamos un enlace para restablecer tu contraseña. Revisa también la carpeta de spam.';
  }

  @override
  String get resetPasswordTitle => 'Crea una nueva contraseña';

  @override
  String get resetPasswordSubtitle =>
      'Elige una contraseña segura para tu cuenta';

  @override
  String get resetPasswordInvalidLink =>
      'Este enlace ya no es válido. Solicita uno nuevo desde la pantalla de recuperación.';

  @override
  String get resetPasswordInvalidLinkTitle => 'Enlace no válido';

  @override
  String get resetPasswordRequestNewLink => 'Solicitar un nuevo enlace';

  @override
  String resetPasswordForEmail(String email) {
    return 'Restableciendo la contraseña de $email';
  }

  @override
  String get resetPasswordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get resetPasswordSubmitButton => 'Cambiar contraseña';

  @override
  String get resetPasswordSuccessTitle => 'Contraseña actualizada';

  @override
  String get resetPasswordSuccessBody =>
      'Tu contraseña se cambió correctamente. Ya puedes iniciar sesión con ella.';

  @override
  String get resetPasswordGoToLogin => 'Ir a iniciar sesión';

  @override
  String get businessSettingsAppBarTitle => 'Mi negocio';

  @override
  String get businessSettingsNameRequiredSnackbar =>
      'Ingresa el nombre del negocio';

  @override
  String get businessSettingsSectionTitle => 'Datos generales';

  @override
  String get businessSettingsSectionSubtitle =>
      'Actualiza la información que verán tus clientes.';

  @override
  String get businessSettingsNameLabel => 'Nombre del negocio';

  @override
  String get businessSettingsNameHint => 'Ej. Restaurante El Sabor';

  @override
  String get businessSettingsScheduleLabel => 'Horario';

  @override
  String get businessSettingsScheduleHint =>
      'Ej. Lunes a sábado 8:00 AM - 8:00 PM';

  @override
  String get businessSettingsContactLabel => 'Contacto';

  @override
  String get businessSettingsContactHint => 'Ej. 300 123 4567';

  @override
  String get businessSettingsSaveButton => 'Guardar cambios';

  @override
  String get subscriptionsAppBarTitle => 'Planes y suscripciones premium';

  @override
  String get subscriptionsHeaderTitle =>
      'Elige tu plan perfecto para mejorar tu experiencia en la aplicación';

  @override
  String get subscriptionsHeaderSubtitle =>
      'Promociones exclusivas y alertas para que tu presupuesto diario no se salga de control';

  @override
  String get subscriptionsBillingMonthly => 'Mensual';

  @override
  String get subscriptionsBillingAnnual => 'Anual (-20%)';

  @override
  String get subscriptionsPlanTouristName => 'Premium';

  @override
  String get subscriptionsPlanTouristSubtitle =>
      'Para viajeros que cuidan su presupuesto';

  @override
  String get subscriptionsPeriodMonth => '/mes';

  @override
  String get subscriptionsPeriodYear => '/año';

  @override
  String get subscriptionsPlanSelectedButton => 'Plan seleccionado';

  @override
  String get subscriptionsPlanSelectButton => 'Seleccionar';

  @override
  String get subscriptionsFaqTitle => 'Preguntas frecuentes';

  @override
  String get subscriptionsFaqChangePlanQuestion =>
      '¿Puedo cambiar de plan en cualquier momento?';

  @override
  String get subscriptionsFaqChangePlanAnswer =>
      'Sí, puedes cambiar o cancelar tu suscripción en cualquier momento desde tu configuración.';

  @override
  String get subscriptionsFaqFreeTrialQuestion =>
      '¿Hay período de prueba gratuita?';

  @override
  String get subscriptionsFaqFreeTrialAnswer =>
      'No, actualmente no ofrecemos un período de prueba gratuita. Sin embargo, puedes cancelar tu suscripción en cualquier momento.';

  @override
  String get subscriptionsFaqPaymentMethodsQuestion =>
      '¿Qué métodos de pago aceptan?';

  @override
  String get subscriptionsFaqPaymentMethodsAnswer =>
      'Aceptamos tarjetas de crédito y débito Visa, Mastercard, American Express y Diners, procesadas por Mercado Pago.';

  @override
  String get subscriptionsFooterNote =>
      'Cambiar de plan en cualquier momento sin penalización';

  @override
  String subscriptionsDialogPlanTitle(String planName) {
    return 'Plan $planName';
  }

  @override
  String subscriptionsDialogPriceLabel(String price) {
    return 'Precio: $price';
  }

  @override
  String get subscriptionsDialogBody =>
      'Al hacer clic en \"Continuar\" ingresarás los datos de tu tarjeta. El pago lo procesa Mercado Pago.';

  @override
  String get subscriptionsDialogCancelButton => 'Cancelar';

  @override
  String get subscriptionsDialogContinueButton => 'Continuar';

  @override
  String get subscriptionsDialogRedirectingSnackbar =>
      'Redirigiendo a pasarela de pago...';

  @override
  String get stepProgressLabel => 'Paso';

  @override
  String get stepProgressStep1 => 'Información';

  @override
  String get stepProgressStep2 => 'Fecha y precio';

  @override
  String get stepProgressStep3 => 'Detalles';

  @override
  String get homeComercioBusinessSettingsTooltip => 'Mi negocio';

  @override
  String get homeComercioBusinessUpdatedSnackbar =>
      'Datos del negocio actualizados';

  @override
  String get configSectionAccount => 'Cuenta';

  @override
  String get homeComercioLoadErrorSnackbar =>
      'No se pudo cargar la información del negocio';

  @override
  String get homeComercioSaveErrorSnackbar =>
      'No se pudieron guardar los cambios, intenta de nuevo';

  @override
  String get createActivitySaveErrorSnackbar =>
      'No se pudo crear la actividad, intenta de nuevo';

  @override
  String get createMenuSaveErrorSnackbar =>
      'No se pudo crear el menú, intenta de nuevo';

  @override
  String get menuDetailSaveErrorSnackbar =>
      'No se pudo guardar el cambio, intenta de nuevo';

  @override
  String get businessSettingsOpenTimeLabel => 'Hora de apertura';

  @override
  String get businessSettingsCloseTimeLabel => 'Hora de cierre';

  @override
  String get businessSettingsTimeNotSet => 'Sin definir';

  @override
  String get dailyBudgetTodayTitle => 'Presupuesto de hoy';

  @override
  String dailyBudgetOkMessage(String amount) {
    return 'Vas bien: aún tienes $amount para gastar hoy.';
  }

  @override
  String get dailyBudgetWarningTitle => 'Advertencia de presupuesto';

  @override
  String dailyBudgetWarningMessage(int pct, String amount) {
    return 'Ya usaste el $pct% del presupuesto de hoy. Te quedan $amount.';
  }

  @override
  String get dailyBudgetExceededTitle => '¡Límite diario superado!';

  @override
  String dailyBudgetExceededMessage(String amount) {
    return 'Hoy te pasaste $amount del presupuesto diario; los próximos días tendrán menos disponible.';
  }

  @override
  String dailyBudgetSpentOf(String spent, String budget) {
    return '$spent DE $budget HOY';
  }

  @override
  String get expenseReminderTitle => '¿Tuviste gastos hoy?';

  @override
  String get expenseReminderMessage =>
      'No registraste ningún gasto hoy en estos viajes en curso. Anótalos antes de que se te olviden para que tu presupuesto diario siga siendo real.';

  @override
  String get expenseReminderDismiss => 'Hoy no gasté';

  @override
  String addExpenseNearDailyBudget(int pct, String amount) {
    return 'Con este gasto llegas al $pct% del presupuesto de ese día (quedarían $amount).';
  }

  @override
  String addExpenseExceedsDailyBudget(String over, String budget) {
    return 'Este gasto supera el presupuesto de ese día por $over (presupuesto diario: $budget).';
  }

  @override
  String get addExpenseOverBudgetDialogTitle => 'Supera tu presupuesto diario';

  @override
  String addExpenseOverBudgetDialogContent(String budget, String over) {
    return 'El presupuesto disponible para ese día es $budget y con este gasto te pasarías $over. ¿Quieres registrarlo de todas formas?';
  }

  @override
  String get addExpenseOverBudgetConfirm => 'Registrar igual';

  @override
  String subscriptionsActivePlanBanner(String date) {
    return 'Eres Premium hasta el $date. Si pagas otro plan, se suma a partir de esa fecha.';
  }

  @override
  String get subscriptionsCheckoutErrorSnackbar =>
      'No se pudo abrir la pasarela de pago. Intenta de nuevo.';

  @override
  String get paymentResultChecking => 'Confirmando tu pago con Mercado Pago…';

  @override
  String get paymentResultApprovedTitle => '¡Pago aprobado!';

  @override
  String paymentResultApprovedBody(String date) {
    return 'Ya eres Premium. Tu suscripción está activa hasta el $date.';
  }

  @override
  String get paymentResultApprovedBodyNoDate =>
      'Ya eres Premium. Tu suscripción quedó activa.';

  @override
  String get paymentResultPendingTitle => 'Pago en proceso';

  @override
  String get paymentResultPendingBody =>
      'Mercado Pago todavía está procesando tu pago. Te activamos Premium apenas se apruebe.';

  @override
  String get paymentResultRejectedTitle => 'Pago rechazado';

  @override
  String get paymentResultRejectedBody =>
      'Tu medio de pago fue rechazado y no se hizo ningún cobro. Puedes intentarlo con otro.';

  @override
  String get paymentResultCancelledTitle => 'No se completó el pago';

  @override
  String get paymentResultCancelledBody =>
      'Saliste del checkout antes de pagar. No se hizo ningún cobro.';

  @override
  String get paymentResultErrorTitle => 'No pudimos confirmar el pago';

  @override
  String get paymentResultErrorBody =>
      'Revisa tu conexión e intenta de nuevo. Si ya pagaste, el cobro no se pierde: Premium se activa en cuanto Mercado Pago nos confirme.';

  @override
  String get paymentResultPlanMonthly => 'Plan Premium mensual';

  @override
  String get paymentResultPlanAnnual => 'Plan Premium anual';

  @override
  String paymentResultReference(int id) {
    return 'REFERENCIA DE PAGO #$id';
  }

  @override
  String get paymentResultGoHome => 'Ir al inicio';

  @override
  String get paymentResultBackToPlans => 'Volver a los planes';

  @override
  String get paymentResultRetry => 'Volver a consultar';

  @override
  String get cardPaymentTitle => 'Pago con tarjeta';

  @override
  String cardPaymentSummary(String plan, String price) {
    return '$plan · $price';
  }

  @override
  String get cardPaymentTestModeHint =>
      'Modo de prueba de Mercado Pago: no se cobra dinero real. Usa la tarjeta 4013 5406 8274 6260, vencimiento 11/30, código 123. Titular APRO = aprobado, CONT = en proceso, cualquier otro nombre = rechazado.';

  @override
  String get cardPaymentNumberLabel => 'Número de tarjeta';

  @override
  String get cardPaymentNumberInvalid => 'Número de tarjeta inválido';

  @override
  String get cardPaymentBrandUnsupported =>
      'Aceptamos Visa, Mastercard, American Express y Diners';

  @override
  String get cardPaymentHolderLabel => 'Nombre del titular';

  @override
  String get cardPaymentHolderHint => 'Como aparece en la tarjeta';

  @override
  String get cardPaymentHolderInvalid => 'Escribe el nombre del titular';

  @override
  String get cardPaymentExpiryLabel => 'Vencimiento';

  @override
  String get cardPaymentExpiryInvalid => 'Fecha inválida o vencida';

  @override
  String get cardPaymentCvvLabel => 'Código de seguridad';

  @override
  String cardPaymentCvvInvalid(int digits) {
    return 'Debe tener $digits dígitos';
  }

  @override
  String get cardPaymentDocTypeLabel => 'Tipo';

  @override
  String get cardPaymentDocNumberLabel => 'Documento del titular';

  @override
  String get cardPaymentDocInvalid => 'Documento inválido';

  @override
  String cardPaymentPayButton(String price) {
    return 'Pagar $price';
  }

  @override
  String get cardPaymentProcessing => 'Procesando pago…';

  @override
  String get cardPaymentSecureNote =>
      'PAGO PROCESADO POR MERCADO PAGO · TRAVELGUARD NO GUARDA LOS DATOS DE TU TARJETA';

  @override
  String get cardPaymentError =>
      'No pudimos procesar el pago. Revisa los datos de la tarjeta e intenta de nuevo; no se hizo ningún cobro.';

  @override
  String get appShellNavPromos => 'Promociones';

  @override
  String get appShellNavPlans => 'Planes';

  @override
  String get subscriptionsBenefitPromos =>
      'Promociones exclusivas de comercios cercanos';

  @override
  String get subscriptionsBenefitDailyAlerts =>
      'Cuánto llevas del presupuesto de hoy, con alertas al 75% y al 100%';

  @override
  String get subscriptionsBenefitOverspendWarning =>
      'Aviso antes de registrar un gasto que supera el presupuesto del día';

  @override
  String get subscriptionsBenefitReminder =>
      'Recordatorio a las 11 PM si no registraste gastos';

  @override
  String get premiumGateBadge => 'EXCLUSIVO PREMIUM';

  @override
  String get premiumGateButton => 'Ver planes Premium';

  @override
  String get premiumGateCompactButton => 'Hazte Premium';

  @override
  String get dailyBudgetLockedTitle => 'Alertas del presupuesto diario';

  @override
  String get dailyBudgetLockedDescription =>
      'Con Premium ves cuánto llevas hoy y te avisamos al 75% y al 100%.';

  @override
  String placeDetailsPromosLockedTitle(int count) {
    return 'Promociones exclusivas ($count)';
  }

  @override
  String get placeDetailsPromosLockedDescription =>
      'Este comercio tiene ofertas solo para usuarios Premium.';

  @override
  String get promosEyebrow => 'EXCLUSIVO PREMIUM';

  @override
  String get promosTitle => 'Promociones';

  @override
  String get promosSubtitle =>
      'Ofertas que los comercios publican solo para viajeros Premium.';

  @override
  String get promosLockedTitle => 'Promociones exclusivas para Premium';

  @override
  String get promosLockedDescription =>
      'Suscríbete para ver las ofertas que los comercios cercanos publican solo para miembros Premium.';

  @override
  String get promosLoadError =>
      'No pudimos cargar las promociones. Intenta de nuevo.';

  @override
  String get promosEmpty =>
      'Todavía no hay promociones vigentes. Vuelve pronto.';

  @override
  String promosValidUntil(String date) {
    return 'HASTA $date';
  }
}
