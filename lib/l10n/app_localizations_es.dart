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
  String get commerceRegisterNitInvalid =>
      'NIT inválido: usa solo números (5 a 15 dígitos)';

  @override
  String get commerceRegisterEmailInvalidOrTaken =>
      'Ingresa un correo válido (ej. nombre@correo.com)';

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
  String get configNotificationsToggleLabel => 'Mostrar alertas';

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
  String get addExpenseInvalidAmount => 'Ingresa un monto mayor a 0';

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
  String get addExpenseTimeLabel => 'Hora';

  @override
  String get addExpensePlaceLabel => 'Establecimiento (opcional)';

  @override
  String get addExpensePlaceHint => 'Ej. Restaurante El Sabor';

  @override
  String get addExpensePaidByLabel => '¿Quién pagó?';

  @override
  String get addExpensePaidWithTripMoney => 'Pagado con dinero del viaje';

  @override
  String get addExpensePaidTripMoneyOn => 'Salió del fondo común del viaje';

  @override
  String get addExpensePaidTripMoneyOff => 'Salió del bolsillo personal';

  @override
  String get addExpensePaymentSourceLabel => '¿Con qué dinero pagas?';

  @override
  String get addExpenseSourceTrip => 'Dinero del viaje';

  @override
  String get addExpenseSourcePocket => 'Mi bolsillo';

  @override
  String addExpenseSourceBalance(String amount) {
    return 'Disponible: $amount';
  }

  @override
  String get addExpenseSourceNoPocket => 'Aún sin bolsillo';

  @override
  String get addExpensePocketMissing =>
      'Aún no tienes bolsillo en este viaje. Créalo desde \"Mi bolsillo\".';

  @override
  String addExpensePocketInsufficient(String balance) {
    return 'Tu bolsillo solo tiene $balance disponible.';
  }

  @override
  String get pocketButtonLabel => 'Mi bolsillo';

  @override
  String get pocketScreenTitle => 'Mi bolsillo personal';

  @override
  String get pocketPrivateNote => 'Solo tú puedes ver este bolsillo.';

  @override
  String get pocketEmptyTitle => 'Aún no tienes bolsillo en este viaje';

  @override
  String get pocketEmptyDescription =>
      'Crea tu bolsillo para guardar dinero propio y pagar gastos del viaje desde él.';

  @override
  String get pocketCreateButton => 'Crear mi bolsillo';

  @override
  String get pocketBalanceLabel => 'SALDO DISPONIBLE';

  @override
  String get pocketAddedLabel => 'AGREGADO';

  @override
  String get pocketSpentLabel => 'GASTADO';

  @override
  String get pocketAddMoneyButton => 'Agregar dinero';

  @override
  String get pocketAddMoneyTitle => 'Agregar dinero al bolsillo';

  @override
  String get pocketAmountLabel => 'Monto';

  @override
  String get pocketNoteLabel => 'Nota (opcional)';

  @override
  String get pocketNoteHint => 'Ej. Efectivo para compras';

  @override
  String get pocketAddConfirmButton => 'Agregar';

  @override
  String get pocketMovementsTitle => 'Movimientos';

  @override
  String get pocketNoMovements => 'Aún no has agregado dinero.';

  @override
  String get pocketLoadError => 'No se pudo cargar tu bolsillo.';

  @override
  String get pocketSaveError => 'No se pudo guardar. Intenta de nuevo.';

  @override
  String get pocketCreatedSnackbar => 'Bolsillo creado';

  @override
  String pocketDepositAddedSnackbar(String amount) {
    return 'Se agregó $amount a tu bolsillo';
  }

  @override
  String get estimateScreenTitle => 'Estimar presupuesto';

  @override
  String get estimateEyebrow => 'ESTIMADOR DE PRESUPUESTO';

  @override
  String get estimateTitleLine1 => '¿Cuánto costará';

  @override
  String get estimateTitleLine2 => 'tu viaje?';

  @override
  String get estimateIntro =>
      'Cuéntanos a dónde vas, desde dónde sales y cómo viajas: te damos un estimado del hospedaje, la comida, el transporte y los extras.';

  @override
  String get estimateDestinationLabel => 'DESTINO';

  @override
  String get estimateOriginLabel => '¿DESDE DÓNDE SALES?';

  @override
  String get estimateOriginHint => 'Busca tu ciudad';

  @override
  String get estimateDatesLabel => 'FECHAS DEL VIAJE';

  @override
  String get estimateDatesPlaceholder => 'Selecciona ida y vuelta';

  @override
  String get estimateDatePickerHelp => 'Fechas del viaje';

  @override
  String get estimateDatePickerSave => 'Listo';

  @override
  String estimateDurationSummary(int days, int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    String _temp1 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights noches',
      one: '$nights noche',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get estimateTravelersLabel => 'VIAJEROS';

  @override
  String estimateTravelersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viajeros',
      one: '$count viajero',
    );
    return '$_temp0';
  }

  @override
  String get estimateModeLabel => '¿CÓMO VIAJAS?';

  @override
  String get estimateModePlane => 'Avión';

  @override
  String get estimateModeBus => 'Bus';

  @override
  String get estimateModeCar => 'Carro';

  @override
  String estimateModeHours(String hours) {
    return '~$hours h';
  }

  @override
  String get estimateModeUnavailable => 'No disponible';

  @override
  String get estimateModeNotRecommended => 'No recomendado';

  @override
  String get estimateModePickCities =>
      'Elige destino y origen para ver cómo puedes llegar.';

  @override
  String get estimateModeApproximate =>
      'Esta ruta se calcula con la distancia entre las ciudades: el resultado es más aproximado.';

  @override
  String get estimateTripTypeLabel => 'TIPO DE VIAJE';

  @override
  String get estimateStyleEconomyTitle => 'Económico';

  @override
  String get estimateStyleEconomyCaption => 'Hostales y comida local';

  @override
  String get estimateStyleStandardTitle => 'Estándar';

  @override
  String get estimateStyleStandardCaption => 'Hoteles 3★';

  @override
  String get estimateStyleLuxuryTitle => 'Lujo';

  @override
  String get estimateStyleLuxuryCaption => 'Hoteles 4-5★ y experiencias';

  @override
  String get estimateExtrasLabel => 'EXTRAS (OPCIONAL)';

  @override
  String get estimateExtraTours => 'Tours y actividades';

  @override
  String get estimateExtraNightlife => 'Rumba';

  @override
  String get estimateExtraSouvenirs => 'Souvenirs';

  @override
  String get estimateErrorDestinationEmpty => 'Elige un destino de la lista.';

  @override
  String get estimateErrorOriginEmpty => 'Elige desde dónde sales.';

  @override
  String get estimateErrorOriginSame =>
      'El origen debe ser distinto al destino.';

  @override
  String get estimateErrorModeEmpty => 'Elige cómo vas a viajar.';

  @override
  String get estimateErrorDatesEmpty => 'Selecciona las fechas de tu viaje.';

  @override
  String get estimateErrorDatesTooShort =>
      'El viaje debe tener al menos 1 noche.';

  @override
  String get estimateErrorDatesTooLong =>
      'Por ahora solo estimamos viajes de hasta 30 días.';

  @override
  String get estimateErrorGeneric =>
      'No pudimos calcular la estimación. Intenta de nuevo.';

  @override
  String get estimateDataError =>
      'No pudimos cargar los precios de referencia. Revisa tu conexión.';

  @override
  String get estimateRetry => 'Reintentar';

  @override
  String get estimateButton => 'Estimar presupuesto';

  @override
  String get estimateButtonLoading => 'Estimando…';

  @override
  String get estimateButtonNew => 'Nueva estimación';

  @override
  String get estimateLoadingEyebrow => 'CONSULTANDO PRECIOS';

  @override
  String get estimateLoadingTitle => 'Armando tu estimación';

  @override
  String get estimateLoadingStepLodging => 'Cargando precios de referencia';

  @override
  String get estimateLoadingStepFlights => 'Calculando transporte y temporadas';

  @override
  String get estimateLoadingStepLocal =>
      'Sumando comida, transporte local y extras';

  @override
  String get estimateResultEyebrow => 'PRESUPUESTO ESTIMADO';

  @override
  String estimateRangeBadge(int percent) {
    return 'RANGO ±$percent%';
  }

  @override
  String estimateHeroSubtitle(int nights, int travelers, String style) {
    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights NOCHES',
      one: '$nights NOCHE',
    );
    String _temp1 = intl.Intl.pluralLogic(
      travelers,
      locale: localeName,
      other: '$travelers VIAJEROS',
      one: '$travelers VIAJERO',
    );
    return '$_temp0 · $_temp1 · $style';
  }

  @override
  String estimateHeroFrom(String origin, String mode) {
    return 'Saliendo de $origin en $mode';
  }

  @override
  String get estimateBreakdownTitle => 'Desglose';

  @override
  String get estimateLodgingTitle => 'Hospedaje';

  @override
  String estimateLodgingCaption(int rooms, int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      rooms,
      locale: localeName,
      other: '$rooms habitaciones',
      one: '1 habitación',
    );
    String _temp1 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights noches',
      one: '$nights noche',
    );
    return '$_temp0 × $_temp1';
  }

  @override
  String get estimateFoodTitle => 'Alimentación';

  @override
  String estimateFoodCaption(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '$days día',
    );
    return 'Promedio diario × $_temp0';
  }

  @override
  String get estimateTransportTitle => 'Transporte';

  @override
  String get estimateTransportCaption => 'Ida y vuelta + transporte local';

  @override
  String estimateIntercityLabel(String mode) {
    return 'Ida y vuelta en $mode';
  }

  @override
  String estimateIntercityCarLabel(int vehicles) {
    String _temp0 = intl.Intl.pluralLogic(
      vehicles,
      locale: localeName,
      other: '$vehicles carros',
      one: '1 carro',
    );
    return 'Gasolina y peajes ($_temp0)';
  }

  @override
  String get estimateLocalTransportLabel => 'Transporte local';

  @override
  String get estimateExtrasTitle => 'Extras';

  @override
  String get estimateExtrasCaption => 'Lo que elegiste agregar';

  @override
  String get estimateSourcesIntro => 'Estimación basada en:';

  @override
  String estimateVerifiedOn(String date) {
    return 'Precios verificados el $date';
  }

  @override
  String estimateDisclaimer(int percent) {
    return 'Los precios pueden variar ±$percent% según la temporada y la disponibilidad.';
  }

  @override
  String get estimateDetailTitle => 'Estimación detallada';

  @override
  String get estimateDetailGateDescription =>
      'Compara los 3 estilos, mira cuánto suma la temporada y el costo por persona y por día.';

  @override
  String get estimatePerPerson => 'POR PERSONA';

  @override
  String get estimatePerDay => 'POR DÍA';

  @override
  String get estimatePerPersonPerDay => 'PERSONA / DÍA';

  @override
  String get estimateSeasonTitle => 'Temporada alta';

  @override
  String estimateSeasonBody(String seasons, String amount) {
    return 'Tus fechas caen en $seasons. Eso suma $amount al total (ya incluido).';
  }

  @override
  String get estimateSeasonNoneTitle => 'Temporada normal';

  @override
  String get estimateSeasonNone =>
      'Tus fechas no caen en temporada alta: buen momento para viajar.';

  @override
  String get estimateCompareTitle => 'Compara estilos';

  @override
  String get estimateCompareCurrent => 'TU ELECCIÓN';

  @override
  String get estimateCreateTrip => 'Crear viaje con esta estimación';

  @override
  String estimateTripName(String destination) {
    return 'Viaje a $destination';
  }

  @override
  String estimateRealSeal(int count, String city) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viajes reales',
      one: '1 viaje real',
    );
    return 'Ajustado con $_temp0 de TravelGuard a $city';
  }

  @override
  String estimateRealNone(String city) {
    return 'Aún no hay suficientes viajes reales de TravelGuard a $city: usamos solo los precios de referencia.';
  }

  @override
  String get estimateCoveredLabel => 'YA TENGO CUBIERTO';

  @override
  String get estimateCoveredHint =>
      'Marca lo que no vas a pagar; por ejemplo, si te quedas donde un familiar o un amigo.';

  @override
  String get estimateCoveredLodging => 'Hospedaje';

  @override
  String get estimateCoveredFood => 'Alimentación';

  @override
  String get estimateCoveredIntercity => 'Ida y vuelta';

  @override
  String get estimateCoveredLocal => 'Transporte local';

  @override
  String get estimateCoveredTag => 'Cubierto';

  @override
  String get estimateCoveredCaption => 'Ya lo tienes cubierto';

  @override
  String get estimateModeCovered =>
      'Ya tienes la ida y vuelta cubierta: no la sumamos.';

  @override
  String get estimateErrorAllCovered =>
      'Deja al menos un gasto por estimar o agrega un extra.';

  @override
  String get limitsHeaderTitle => 'Límites';

  @override
  String get limitsHeaderAccent => 'de gasto';

  @override
  String get pocketHeaderTitle => 'Mi bolsillo';

  @override
  String get pocketHeaderAccent => 'personal';

  @override
  String get estimateCardSubtitle => 'Calcula el costo de un viaje';

  @override
  String get estimateCardDescription =>
      'Descubre cuánto costaría un viaje antes de planearlo.';

  @override
  String get estimateCardButton => 'Estimar';

  @override
  String get limitsTabTitle => 'Límites';

  @override
  String get limitsConfigureButton => 'Configurar límites';

  @override
  String get limitsScreenTitle => 'Configurar límites';

  @override
  String get limitsTripLabel => 'VIAJE';

  @override
  String get limitsScreenSubtitle =>
      'Define el máximo que quieres gastar en cada categoría de este viaje. Déjalo vacío si no quieres límite.';

  @override
  String get limitsFieldHint => 'Sin límite';

  @override
  String limitsSpentSoFar(String amount) {
    return 'Gastado: $amount';
  }

  @override
  String get limitsSaveButton => 'Guardar límites';

  @override
  String get limitsSavedSnackbar => 'Límites guardados';

  @override
  String get limitsSaveError =>
      'No se pudieron guardar los límites. Intenta de nuevo.';

  @override
  String get limitsProgressTitle => 'Progreso por categoría';

  @override
  String limitsProgressAmount(String spent, String limit) {
    return '$spent de $limit';
  }

  @override
  String limitsOverBy(String amount) {
    return 'Superaste el límite por $amount';
  }

  @override
  String limitsLeft(String amount) {
    return 'Te quedan $amount';
  }

  @override
  String get limitsEmptyTitle => 'Aún no defines límites';

  @override
  String get limitsEmptyDescription =>
      'Configura un máximo por categoría y sigue tu gasto en tiempo real.';

  @override
  String get limitsReportTitle => 'Reporte de cumplimiento';

  @override
  String get limitsColCategory => 'CATEGORÍA';

  @override
  String get limitsColLimit => 'LÍMITE';

  @override
  String get limitsColSpent => 'GASTO';

  @override
  String get limitsColCompliance => '% CUMPLIMIENTO';

  @override
  String get limitsTotalRow => 'Total';

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
  String get createTripStep2TitleLine1 => '¿En qué lo';

  @override
  String get createTripStep2TitleLine2 => 'vas a gastar?';

  @override
  String get createTripStepNameDestination => 'Destino y fechas';

  @override
  String get createTripStepNameLodging => 'Hospedaje';

  @override
  String get createTripStepNameTransport => 'Gastos';

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
      'Ingresa un monto válido (0 o más)';

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
  String get createTripEstimatedLabel => 'Gastos planeados';

  @override
  String get createTripOverBudgetLabel => 'Te excedes por';

  @override
  String get createTripAvailableLabel => 'Disponible sin planear';

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
  String get editTripBudgetEstimatedLabel => 'Gastos planeados';

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
  String get homeClientPickTripTitle =>
      '¿A qué viaje quieres agregar el gasto?';

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
  String homeClientMapCardPlacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugares cerca',
      one: '1 lugar cerca',
      zero: 'Explora lugares',
    );
    return '$_temp0';
  }

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
  String get tripDetailTabAnalisis => 'Análisis';

  @override
  String get analysisDailyTitle => 'Comparativa diaria';

  @override
  String get analysisInvalidTripDates => 'Las fechas del viaje no son válidas.';

  @override
  String get analysisColDay => 'DÍA';

  @override
  String get analysisColDailyBudget => 'PRESUPUESTO DIARIO';

  @override
  String get analysisColActual => 'GASTO REAL';

  @override
  String get analysisColDifference => 'DIFERENCIA';

  @override
  String get analysisColPctSpent => '% GASTADO';

  @override
  String analysisDayLabelDate(int n, String date) {
    return 'Día $n · $date';
  }

  @override
  String analysisDayLabel(int n) {
    return 'Día $n';
  }

  @override
  String get analysisByCategoryTitle => 'Por categoría';

  @override
  String get analysisNoCategoriesYet =>
      'Aún no hay categorías ni gastos para comparar.';

  @override
  String get analysisColCategory => 'CATEGORÍA';

  @override
  String get analysisColBudgeted => 'PRESUPUESTADO';

  @override
  String get analysisBudgetedVsActual => 'Presupuestado vs real';

  @override
  String get analysisLegendBudgeted => 'Presupuestado';

  @override
  String get analysisLegendActual => 'Real';

  @override
  String analysisCategorySaved(String category, String amount) {
    return '$category: Ahorraste $amount en esta categoría';
  }

  @override
  String analysisCategoryExceeded(String category, String amount) {
    return '$category: Excediste por $amount en esta categoría';
  }

  @override
  String get analysisTopCategoryTitle => 'Categoría con más gasto';

  @override
  String get analysisTopCategoryEmpty =>
      'Registra gastos para ver este análisis.';

  @override
  String analysisTopCategorySummary(String summary) {
    return 'Gastaste más en: $summary';
  }

  @override
  String get analysisTopPlacesTitle => 'Top 3 establecimientos';

  @override
  String get analysisTopPlacesEmpty =>
      'Agrega descripciones a tus gastos para ver dónde gastas más.';

  @override
  String get analysisPeakHoursTitle => 'Horarios de mayor gasto';

  @override
  String get analysisPeakHoursEmpty => 'Sin datos de horario todavía.';

  @override
  String analysisPeakHoursSummary(String ranges) {
    return 'Más gasto entre: $ranges';
  }

  @override
  String get analysisAnd => ' y ';

  @override
  String get analysisBetweenDaysTitle => 'Comparativa entre días';

  @override
  String analysisAverageTrailing(String amount) {
    return 'Promedio $amount';
  }

  @override
  String get analysisNoExpensesYet => 'Aún no hay gastos registrados.';

  @override
  String get analysisDailyAverageLegend => 'Promedio diario';

  @override
  String get analysisPerPersonTitle => 'Gasto por persona';

  @override
  String get analysisNoParticipants => 'No hay participantes cargados.';

  @override
  String get analysisUnassigned => 'Sin asignar';

  @override
  String analysisTripMoneyAmount(String amount) {
    return 'Dinero del viaje: $amount';
  }

  @override
  String analysisPocketAmount(String amount) {
    return 'Bolsillo personal: $amount';
  }

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
  String configExchangeRatePreview(String code, String rate) {
    return '1 $code = $rate';
  }

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
    return 'Vas a exceder tu presupuesto en $over (presupuesto de ese día: $budget).';
  }

  @override
  String get addExpenseOverBudgetDialogTitle => 'Supera tu presupuesto diario';

  @override
  String addExpenseOverBudgetDialogContent(String budget, String over) {
    return 'El presupuesto disponible para ese día es $budget. Vas a exceder tu presupuesto en $over. Puedes registrarlo de todas formas.';
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
      'Cuánto llevas del presupuesto de hoy, con alertas al 75%, 85% y 100%';

  @override
  String get subscriptionsBenefitOverspendWarning =>
      'Aviso antes de registrar un gasto que supera el presupuesto del día';

  @override
  String get subscriptionsBenefitReminder =>
      'Recordatorios: gastos sin registrar, resumen y cierre del día, y aviso antes de cada viaje';

  @override
  String get subscriptionsBenefitEstimate =>
      'Estimación detallada de viajes: compara estilos, temporada y costo por persona';

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
      'Con Premium ves cuánto llevas hoy y te avisamos al 75%, 85% y 100%.';

  @override
  String placeDetailsPromosLockedTitle(int count) {
    return 'Exclusivo Premium ($count)';
  }

  @override
  String get placeDetailsPromosLockedDescription =>
      'Este comercio tiene promociones y actividades solo para usuarios Premium.';

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

  @override
  String get productFormRequiredFields =>
      'Debe completar los campos obligatorios';

  @override
  String get productFormRequiredField => 'Campo obligatorio';

  @override
  String get productFormInvalidPrice => 'Ingresa un precio válido mayor a cero';

  @override
  String get productFormCategoryLabel => 'Tipo de producto';

  @override
  String get productFormDescriptionOptionalLabel => 'Descripción (opcional)';

  @override
  String get productFormEditTitle => 'Editar producto';

  @override
  String get productFormSaveButton => 'Guardar';

  @override
  String get productCategoryPlato => 'Plato';

  @override
  String get productCategoryPlatos => 'Platos';

  @override
  String get productCategoryBebida => 'Bebida';

  @override
  String get productCategoryBebidas => 'Bebidas';

  @override
  String get productCategoryPostre => 'Postre';

  @override
  String get productCategoryPostres => 'Postres';

  @override
  String get productCategoryOtro => 'Otro';

  @override
  String get productCategoryOtros => 'Otros';

  @override
  String get businessSettingsNameTooShort =>
      'El nombre debe tener al menos 3 caracteres';

  @override
  String get businessSettingsPhoneInvalid =>
      'Ingresa un teléfono válido (7 a 15 dígitos)';

  @override
  String get businessSettingsScheduleIncomplete =>
      'Define la hora de apertura y la de cierre, o deja las dos sin definir';

  @override
  String get businessSettingsScheduleSameTime =>
      'La hora de cierre no puede ser igual a la de apertura';

  @override
  String get businessSettingsDescriptionLabel => 'Descripción';

  @override
  String get businessSettingsDescriptionHint =>
      'Cuéntales a los viajeros qué ofreces';

  @override
  String get businessSettingsLocationTitle => 'Ubicación';

  @override
  String get businessSettingsLocationSubtitle =>
      'Así te encuentran los viajeros en el mapa. Busca tu dirección y ajusta el marcador si hace falta.';

  @override
  String get businessSettingsAddressNotFound =>
      'No pudimos ubicar esa dirección en el mapa. Corrígela (agrega ciudad o barrio) para poder guardar.';

  @override
  String get placeDetailsMenuTitle => 'Menú';

  @override
  String get businessSettingsHeaderTitle => 'Datos de';

  @override
  String get businessSettingsHeaderAccent => 'tu negocio';

  @override
  String get createMenuHeaderTitle => 'Nuevo';

  @override
  String get createMenuHeaderAccent => 'menú';

  @override
  String get subscriptionsHeroTitle => 'Viaja sin salirte';

  @override
  String get subscriptionsHeroAccent => 'de tu presupuesto';

  @override
  String get subscriptionsSubscribeButton => 'Suscribirme';

  @override
  String get mySubscriptionTitle => 'Mi suscripción';

  @override
  String get mySubscriptionHeroTitle => 'Tu suscripción';

  @override
  String get mySubscriptionStatusActive => 'Activa';

  @override
  String get mySubscriptionStatusCancelled => 'Cancelada';

  @override
  String get mySubscriptionStatRenewal => 'Renovación';

  @override
  String get mySubscriptionStatEnds => 'Acceso hasta';

  @override
  String get mySubscriptionStatDaysLeft => 'Días restantes';

  @override
  String get mySubscriptionDetailsTitle => 'Detalles del plan';

  @override
  String get mySubscriptionRowPlan => 'Plan actual';

  @override
  String get mySubscriptionRowStatus => 'Estado';

  @override
  String get mySubscriptionRowPeriod => 'Periodo actual';

  @override
  String get mySubscriptionRowRenewalDate => 'Fecha de renovación';

  @override
  String get mySubscriptionRowRenewalMode => 'Renovación';

  @override
  String get mySubscriptionRowNextPlan => 'Plan al renovar';

  @override
  String get mySubscriptionRowPrepaid => 'Periodos ya pagados';

  @override
  String mySubscriptionPeriodRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get mySubscriptionRenewalManual =>
      'Manual: pagas el siguiente periodo cuando quieras, sin cobros automáticos';

  @override
  String mySubscriptionRenewalCancelled(String date) {
    return 'No se renovará. Tienes Premium hasta el $date.';
  }

  @override
  String mySubscriptionRenewSoon(int days) {
    return 'Tu Premium vence en $days días.';
  }

  @override
  String mySubscriptionRenewNow(String plan) {
    return 'Renovar $plan';
  }

  @override
  String get mySubscriptionChangeTitle => 'Cambiar de plan';

  @override
  String get mySubscriptionChangeSubtitle =>
      'Al pasar a anual pagas ahora y empieza cuando termina lo que ya pagaste. Al pasar a mensual no se cobra nada: aplica al renovar.';

  @override
  String get mySubscriptionChangeCancelledHint =>
      'Reactiva tu suscripción para poder cambiar de plan.';

  @override
  String get mySubscriptionCurrentBadge => 'Tu plan';

  @override
  String get mySubscriptionScheduledBadge => 'Programado al renovar';

  @override
  String get mySubscriptionUpgradeButton => 'Cambiar a anual';

  @override
  String get mySubscriptionDowngradeButton => 'Cambiar a mensual';

  @override
  String mySubscriptionKeepPlan(String plan) {
    return 'Mantener $plan';
  }

  @override
  String get mySubscriptionUpgradeDialogTitle => 'Cambiar al plan anual';

  @override
  String mySubscriptionUpgradeDialogBody(
    String price,
    String from,
    String until,
  ) {
    return 'Pagas $price ahora. El plan anual va del $from al $until: empieza cuando termina lo que ya pagaste, así no pierdes ningún día.';
  }

  @override
  String get mySubscriptionUpgradeConfirm => 'Pagar plan anual';

  @override
  String get mySubscriptionDowngradeDialogTitle => 'Cambiar al plan mensual';

  @override
  String mySubscriptionDowngradeDialogBody(String date, String price) {
    return 'No se cobra nada ahora. Conservas lo que ya pagaste hasta el $date; al renovar pagarás el plan mensual ($price).';
  }

  @override
  String get mySubscriptionDowngradeConfirm => 'Programar cambio';

  @override
  String mySubscriptionChangeScheduledSnackbar(String plan) {
    return 'Cambio programado: al renovar pasarás al $plan.';
  }

  @override
  String get mySubscriptionChangeUndoneSnackbar =>
      'Listo, conservas tu plan actual.';

  @override
  String get mySubscriptionCancelTitle => 'Cancelar suscripción';

  @override
  String mySubscriptionCancelBody(String date) {
    return 'Tu Premium sigue activo hasta el $date y después no se renueva. No hay reembolso de lo ya pagado.';
  }

  @override
  String get mySubscriptionCancelDialogTitle => '¿Cancelar tu suscripción?';

  @override
  String get mySubscriptionCancelConfirm => 'Sí, cancelar';

  @override
  String get mySubscriptionCancelKeep => 'Mantener Premium';

  @override
  String mySubscriptionCancelledSnackbar(String date) {
    return 'Suscripción cancelada. Tienes Premium hasta el $date.';
  }

  @override
  String get mySubscriptionCancelledTitle => 'Suscripción cancelada';

  @override
  String get mySubscriptionReactivateButton => 'Reactivar suscripción';

  @override
  String get mySubscriptionReactivatedSnackbar => 'Suscripción reactivada.';

  @override
  String get mySubscriptionHistoryTitle => 'Historial de pagos';

  @override
  String get mySubscriptionHistoryEmpty => 'Aún no hay pagos.';

  @override
  String get mySubscriptionHistoryError => 'No pudimos cargar tus pagos.';

  @override
  String get mySubscriptionEmptyTitle => 'No tienes una suscripción activa';

  @override
  String get mySubscriptionEmptySubtitle =>
      'Hazte Premium para ver promociones exclusivas y recibir alertas de tu presupuesto diario.';

  @override
  String get mySubscriptionSeePlans => 'Ver planes';

  @override
  String get mySubscriptionActionError =>
      'No se pudo actualizar tu suscripción. Intenta de nuevo.';

  @override
  String get mySubscriptionManageButton => 'Gestionar mi suscripción';

  @override
  String get mySubscriptionGoTo => 'Ver mi suscripción';

  @override
  String get paymentStatusApproved => 'Aprobado';

  @override
  String get paymentStatusInProcess => 'En proceso';

  @override
  String get paymentStatusPending => 'Pendiente';

  @override
  String get paymentStatusRejected => 'Rechazado';

  @override
  String get paymentStatusCancelled => 'Cancelado';

  @override
  String get paymentStatusRefunded => 'Reembolsado';

  @override
  String get budgetNoticeOpenTrip => 'Ver viaje';

  @override
  String get configNotificationsToggleSubtitle =>
      'Alertas del presupuesto diario y recordatorios. Apagado, tus gastos se siguen registrando.';

  @override
  String get budgetNoticeToday => 'hoy';

  @override
  String budgetNoticeOnDate(String date) {
    return 'el $date';
  }

  @override
  String budgetNoticeWarningTitle(int pct) {
    return 'Has gastado el $pct% de tu presupuesto diario';
  }

  @override
  String budgetNoticeWarningMessage(String trip, String amount, String day) {
    return '¡Cuidado! $trip: te quedan $amount para $day.';
  }

  @override
  String budgetNoticeNearLimitTitle(String amount, String day) {
    return 'Te quedan $amount de presupuesto para $day';
  }

  @override
  String budgetNoticeNearLimitMessage(String trip, int pct, String day) {
    return '¡Cuidado! $trip: ya vas en el $pct% del presupuesto de $day.';
  }

  @override
  String get budgetNoticeExceededTitle => 'Has alcanzado tu límite diario';

  @override
  String budgetNoticeExceededMessage(
    String trip,
    int pct,
    String spent,
    String budget,
    String day,
  ) {
    return '$trip: vas en el $pct% ($spent de $budget para $day). Los próximos días tendrán menos disponible.';
  }

  @override
  String get configBrowserNotificationsLabel => 'Notificaciones del navegador';

  @override
  String get configBrowserNotificationsSubtitle =>
      'Además de dentro de la app, recibe las alertas como notificación de tu navegador (con la pestaña abierta).';

  @override
  String get configBrowserNotificationsDenied =>
      'El navegador bloqueó las notificaciones. Permítelas en la configuración del sitio (ícono del candado junto a la dirección).';

  @override
  String get configBrowserNotificationsUnsupported =>
      'Este navegador no admite notificaciones.';

  @override
  String get configBrowserNotificationsTestTitle => 'TravelGuard';

  @override
  String get configBrowserNotificationsTestBody =>
      'Listo: así te avisaremos cuando tu presupuesto del día llegue al 75%, 85% y 100%.';

  @override
  String get reminderNoExpensesTitle =>
      '¿Tuviste gastos hoy que no hayas registrado?';

  @override
  String reminderNoExpensesMessage(String trip, int hours) {
    return '$trip: llevas más de $hours horas sin registrar gastos.';
  }

  @override
  String reminderNoExpensesEndOfDay(String trip) {
    return '$trip: hoy no registraste ningún gasto. Anótalos para que tu presupuesto siga siendo real.';
  }

  @override
  String get reminderRegisterExpense => 'Registrar gasto';

  @override
  String reminderDailySummaryTitle(String spent, String remaining) {
    return 'Gasto de hoy: $spent. Presupuesto restante: $remaining';
  }

  @override
  String reminderDailySummaryMessage(String trip) {
    return '$trip · resumen del día';
  }

  @override
  String reminderDayClosingTitle(
    int day,
    String budget,
    String spent,
    String saved,
  ) {
    return 'Día $day: Presupuesto $budget | Gastaste $spent | Ahorro $saved';
  }

  @override
  String reminderDayClosingOverTitle(
    int day,
    String budget,
    String spent,
    String over,
  ) {
    return 'Día $day: Presupuesto $budget | Gastaste $spent | Exceso $over';
  }

  @override
  String reminderDayClosingMessage(String trip, String date) {
    return '$trip · cierre del $date';
  }

  @override
  String reminderUpcomingTripTitle(String destination, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return 'Tu viaje a $destination inicia en $_temp0';
  }

  @override
  String get reminderUpcomingTripMessage => '¿Quieres revisar tu presupuesto?';

  @override
  String get reminderReviewBudget => 'Revisar presupuesto';

  @override
  String get configRemindersTitle => 'Recordatorios';

  @override
  String get configReminderHoursLabel => 'Recordarme si no registro gastos en';

  @override
  String configReminderHoursOption(int hours) {
    return '$hours h';
  }

  @override
  String get configReminderHoursHint =>
      'Solo entre las 8 AM y las 10 PM, durante un viaje.';

  @override
  String get configDailySummaryLabel => 'Resumen diario a las 11 PM';

  @override
  String get configDailySummarySubtitle =>
      'Gasto de hoy y presupuesto restante.';

  @override
  String get configTripReminderLabel => 'Aviso antes de un viaje';

  @override
  String get configTripReminderSubtitle =>
      '3 días y 1 día antes, para revisar tu presupuesto.';

  @override
  String get configRemindersPremiumHint =>
      'Las alertas y recordatorios son parte de Premium.';

  @override
  String get mySubscriptionStatCost => 'Costo';

  @override
  String get mySubscriptionRowCost => 'Costo del plan';

  @override
  String mySubscriptionCostValue(String price, String period) {
    return '$price $period';
  }

  @override
  String get mySubscriptionRowRenewalCost => 'Próxima renovación';

  @override
  String mySubscriptionRenewalCostValue(String date, String price) {
    return '$date · $price';
  }

  @override
  String get businessSettingsPhotoTitle => 'Foto de portada';

  @override
  String get businessSettingsPhotoSubtitle =>
      'Es la imagen que ven los viajeros en la tarjeta de tu comercio y en su ficha.';

  @override
  String get businessSettingsPhotoUpload => 'Subir foto';

  @override
  String get businessSettingsPhotoChange => 'Cambiar foto';

  @override
  String get businessSettingsPhotoRemove => 'Quitar';

  @override
  String get businessSettingsPhotoEmpty => 'Sin foto de portada';

  @override
  String get businessSettingsPhotoHint =>
      'JPG, PNG o WebP · máx. 5 MB · horizontal se ve mejor';

  @override
  String get businessSettingsPhotoTooLarge =>
      'La imagen pesa más de 5 MB. Elige una más liviana.';

  @override
  String get businessSettingsPhotoInvalidType =>
      'Formato no admitido. Usa una imagen JPG, PNG o WebP.';

  @override
  String get businessSettingsPhotoPickError =>
      'No se pudo abrir la imagen. Intenta con otra.';

  @override
  String get homeComercioPhotoUploadError =>
      'Tus datos no se guardaron porque la foto no se pudo subir. Intenta de nuevo.';

  @override
  String get comercioNavSectionLabel => 'NEGOCIO';

  @override
  String get comercioPublicProfileLabel => 'TU PERFIL PÚBLICO';

  @override
  String get comercioViewAsTourist => 'Ver como turista →';

  @override
  String get comercioSignOutShort => 'Salir';

  @override
  String get comercioSearchHint => 'Buscar actividades o platos';

  @override
  String get comercioPanelEyebrow => 'PANEL DEL NEGOCIO';

  @override
  String get comercioGreetingPrefix => '¡Hola, ';

  @override
  String get comercioYourMenuTitle => 'Tu menú';

  @override
  String get comercioEditLink => 'Editar';

  @override
  String get comercioEmptyActivitiesBody =>
      'Las actividades publicadas aparecen en el mapa y en la lista de comercios cercanos de los turistas.';

  @override
  String get comercioCreateFirstActivity => 'Crear la primera →';

  @override
  String get comercioEmptyMenuShort => 'Todavía no hay platos.';

  @override
  String get comercioRetry => 'Reintentar';

  @override
  String get comercioStatusPublished => 'Publicada';

  @override
  String get comercioStatusDraft => 'Borrador';

  @override
  String get comercioStatusPaused => 'Pausada';

  @override
  String get comercioFilterAll => 'Todas';

  @override
  String get comercioDatesNone => 'Sin fecha';

  @override
  String comercioDatesFrom(String date) {
    return 'Desde $date';
  }

  @override
  String get comercioFree => 'Gratis';

  @override
  String comercioActivitiesTotal(int count) {
    return '$count EN TOTAL';
  }

  @override
  String get comercioActivitiesTitle1 => 'Mis ';

  @override
  String get comercioActivitiesTitle2 => 'actividades';

  @override
  String get comercioColActivity => 'ACTIVIDAD';

  @override
  String get comercioColCategory => 'CATEGORÍA';

  @override
  String get comercioColDates => 'FECHAS';

  @override
  String get comercioColPrice => 'PRECIO';

  @override
  String get comercioColStatus => 'ESTADO';

  @override
  String get comercioActivitiesEmptyFilter =>
      'No hay actividades con este estado.';

  @override
  String get comercioNoDescription => 'Sin descripción';

  @override
  String comercioMenuProductsCount(int count) {
    return '$count PRODUCTOS';
  }

  @override
  String get comercioMenuTitle1 => 'Tu ';

  @override
  String get comercioMenuTitle2 => 'menú';

  @override
  String get comercioMenuSubtitle =>
      'Platos, bebidas y servicios que ofrece tu negocio.';

  @override
  String get comercioAddProductButton => '+ Agregar producto';

  @override
  String get comercioAddProductShort => '+ Producto';

  @override
  String get comercioMenuEmpty =>
      'Tu menú está vacío. Agrega el primer plato y aparecerá en tu perfil público.';

  @override
  String get comercioMenuDetailLink => 'Ver detalle';

  @override
  String get comercioPickMenuTitle => '¿A qué menú lo agregas?';

  @override
  String get comercioNewActivityEyebrow => 'NUEVA ACTIVIDAD';

  @override
  String get comercioPreviewTitle1 => 'Así la verán';

  @override
  String get comercioPreviewTitle2 => 'los turistas';

  @override
  String get comercioPreviewDescPlaceholder => 'La descripción aparecerá aquí.';

  @override
  String get comercioStatusNotePublished => 'Visible en el mapa al guardar';

  @override
  String get comercioStatusNotePaused => 'Oculta para los turistas';

  @override
  String get comercioStatusNoteDraft => 'Solo tú la ves mientras sea borrador';

  @override
  String get comercioNoEndToggle => 'Sin fin';

  @override
  String get comercioEndShort => 'Fin';

  @override
  String get comercioPickDate => 'Elegir fecha';

  @override
  String get comercioSubmitPublish => 'Publicar actividad';

  @override
  String get comercioSubmitPaused => 'Guardar pausada';

  @override
  String get comercioSubmitDraft => 'Guardar borrador';

  @override
  String get comercioNewMenuEyebrow => 'NUEVO MENÚ';

  @override
  String get comercioMenuPreviewTitle1 => 'Así lo verán';

  @override
  String get comercioMenuPreviewEmpty => 'Los productos aparecerán aquí.';

  @override
  String comercioSearchNoResults(String query) {
    return 'Nada coincide con «$query».';
  }

  @override
  String get valRequired => 'Este campo es obligatorio';

  @override
  String valTooShort(int min) {
    return 'Debe tener al menos $min caracteres';
  }

  @override
  String valTooLong(int max) {
    return 'Máximo $max caracteres';
  }

  @override
  String get valPersonName => 'Solo se permiten letras y espacios';

  @override
  String get valNeedsLetter => 'Debe contener al menos una letra';

  @override
  String get valInvalidChars => 'No se permiten símbolos como < > [ ] o \\';

  @override
  String get valEmail => 'Ingresa un correo válido (ej. nombre@correo.com)';

  @override
  String get valPhone =>
      'Ingresa un teléfono válido: solo números, de 7 a 15 dígitos';

  @override
  String get valPasswordMin => 'La contraseña debe tener al menos 8 caracteres';

  @override
  String get valPasswordHelper => 'Al menos 8 caracteres';

  @override
  String get valAmountPositive => 'Ingresa un monto mayor a 0';

  @override
  String valAmountMax(String max) {
    return 'El monto no puede superar $max';
  }

  @override
  String valIntRange(int min, int max) {
    return 'Debe ser un número entre $min y $max';
  }

  @override
  String get valEndBeforeStart =>
      'La fecha de fin no puede ser anterior a la de inicio';

  @override
  String get valDuplicateProduct =>
      'Ya hay un producto con ese nombre en este menú';

  @override
  String get valCardHolder =>
      'Escribe el nombre como aparece en la tarjeta (solo letras)';

  @override
  String get valScheduleBoth =>
      'Indica la hora de apertura y la de cierre, o ninguna';

  @override
  String get valDocLength => 'El documento debe tener entre 5 y 12 dígitos';

  @override
  String get valInviteEmailRequired => 'Escribe el correo de la persona';

  @override
  String get valOverBudgetTitle => 'Lo planeado supera el presupuesto';

  @override
  String valOverBudgetContent(String amount) {
    return 'Lo que planeaste supera tu presupuesto máximo por $amount. ¿Quieres guardar igual?';
  }

  @override
  String get valOverBudgetConfirm => 'Guardar igual';

  @override
  String get valOverBudgetCancel => 'Revisar';

  @override
  String get valAdvanceOverBudget =>
      'Los pagos anticipados no pueden superar el presupuesto máximo';

  @override
  String get valPersonsRange => 'Las personas deben ser entre 1 y 50';

  @override
  String get valLoadTripsError =>
      'No pudimos cargar tus viajes. Revisa tu conexión.';

  @override
  String get valLoadPlacesError => 'No pudimos cargar los lugares cercanos.';

  @override
  String get valLoadGastosError =>
      'No pudimos cargar tus gastos: las barras muestran solo lo planeado.';

  @override
  String get valLoadMapError => 'No pudimos cargar los lugares del mapa.';

  @override
  String get valNitFormat =>
      'NIT inválido: usa solo números (5 a 15 dígitos) y, si quieres, -dígito de verificación';

  @override
  String get valCommerceAddress => 'Escribe una dirección válida';

  @override
  String get placeDetailsDirectionsSoon => 'Disponible próximamente';

  @override
  String createTripAutoMealsRow(String meals) {
    return 'Comidas no incluidas ($meals)';
  }

  @override
  String get createTripAutoTransfersRow => 'Traslados';

  @override
  String get createTripServicesHint =>
      'Marca lo que ya cubre tu hospedaje: eso no lo tienes que presupuestar. Lo que no esté incluido lo agregamos a los gastos del último paso para que le pongas un monto.';

  @override
  String get createTripEstimatedHint =>
      'Hospedaje + pagos anticipados + gastos adicionales + emergencias';

  @override
  String createTripCoveredByLodging(String services) {
    return 'Cubierto por el hospedaje: $services';
  }

  @override
  String get createTripIncompleteFieldsIntro => 'Te faltan estos campos:';

  @override
  String get createTripIncompleteFieldsOutro =>
      'Puedes crear el viaje así, pero el presupuesto será menos preciso. Si alguno no aplica, escribe 0.';

  @override
  String get createTripIncompleteFillButton => 'Completarlos';

  @override
  String tripDetailPaceRemaining(String amount) {
    return 'Te quedan $amount del presupuesto, ya descontando lo planeado y lo gastado. Para no pasarte, puedes gastar:';
  }

  @override
  String get tripDetailPacePerDayGroup => 'Por día, todo el grupo';

  @override
  String get tripDetailPacePerDaySolo => 'Por día';

  @override
  String get tripDetailPacePerPersonDay => 'Por persona, por día';

  @override
  String get tripDetailPaceNoBudgetLeft =>
      'Lo planeado y lo gastado ya cubren todo el presupuesto: no queda margen para gastos nuevos.';

  @override
  String get tripDetailPacePlanned => 'Planeado al crear el viaje';

  @override
  String get tripDetailPaceRegistered => 'Gastos registrados';

  @override
  String tripDetailPacePerPerson(int persons) {
    return 'Total por persona ($persons personas)';
  }

  @override
  String get appShellNavActivities => 'Actividades';

  @override
  String activitiesEyebrow(int count) {
    return '$count PARA HACER';
  }

  @override
  String get activitiesTitle1 => 'Actividades ';

  @override
  String get activitiesTitle2 => 'cerca de ti';

  @override
  String get activitiesSubtitle =>
      'Eventos, tours, clases y planes que publican los comercios de TravelGuard.';

  @override
  String get activitiesAllFilter => 'Todas';

  @override
  String get activitiesEmpty =>
      'Todavía no hay actividades publicadas. Vuelve pronto.';

  @override
  String get activitiesEmptyFilter => 'No hay actividades de esta categoría.';

  @override
  String get activitiesLoadError => 'No pudimos cargar las actividades.';

  @override
  String get activitiesPromoBanner =>
      '¿Buscas descuentos? Las promociones exclusivas están en Promociones.';

  @override
  String get activitiesPromoLink => 'Ver promociones →';

  @override
  String get activitiesViewBusiness => 'Ver comercio →';

  @override
  String get activitiesBusinessUnavailable =>
      'Este comercio todavía no tiene su ficha disponible.';

  @override
  String get homeClientViewActivitiesButton => 'Ver actividades →';

  @override
  String get configDemoTitle => 'Probar notificaciones';

  @override
  String get configDemoSubtitle =>
      'Muestra cada aviso al instante con tu viaje más reciente, sin esperar a que pase de verdad. No cambia ningún dato.';

  @override
  String get configDemoNoTrip =>
      'Crea un viaje primero para probar las notificaciones.';

  @override
  String get configDemoWarning => 'Presupuesto al 75%';

  @override
  String get configDemoNearLimit => 'Presupuesto al 85%';

  @override
  String get configDemoExceeded => 'Presupuesto superado';

  @override
  String get configDemoNoExpenses => 'Sin gastos registrados';

  @override
  String get configDemoSummary => 'Resumen del día';

  @override
  String get configDemoClosing => 'Cierre del día';

  @override
  String get configDemoUpcoming => 'Viaje próximo';

  @override
  String get comercioNavPromos => 'Promociones';

  @override
  String get comercioCreatePromoTitle => 'Crear promoción';

  @override
  String get comercioCreatePromoDescription =>
      'Ofertas y descuentos exclusivos para los turistas Premium de TravelGuard.';

  @override
  String get comercioCreatePromoButton => '+ Promoción';

  @override
  String comercioPromosTotal(int count) {
    return '$count PROMOCIONES';
  }

  @override
  String get comercioPromosTitle1 => 'Mis ';

  @override
  String get comercioPromosTitle2 => 'promociones';

  @override
  String get comercioPromosSubtitle =>
      'Solo las ven los turistas con TravelGuard Premium, en su sección de Promociones y en la ficha de tu negocio.';

  @override
  String get comercioPromosEmptyFilter => 'No hay promociones con este estado.';

  @override
  String get comercioNewPromoEyebrow => 'NUEVA PROMOCIÓN';

  @override
  String get comercioNewPromoHeading => 'Nueva promoción';

  @override
  String get comercioNewPromoSubtitle =>
      'Una oferta exclusiva para turistas Premium: descuento, combo o beneficio especial.';

  @override
  String get comercioPromoPreviewTitle2 => 'los turistas Premium';

  @override
  String get comercioPromoNameLabel => 'Nombre de la promoción';

  @override
  String get comercioPromoNameHint => 'Ej. 2x1 en almuerzos';

  @override
  String get comercioSubmitPublishPromo => 'Publicar promoción';

  @override
  String get comercioAudienceLabel => '¿Quién la puede ver?';

  @override
  String get comercioAudiencePublic => 'Todo el público';

  @override
  String get comercioAudiencePremium => 'Solo Premium';

  @override
  String get comercioAudiencePremiumNote =>
      'Solo la verán los turistas con Premium; los demás la ven con candado.';

  @override
  String get comercioPromoAudienceNote =>
      'Las promociones son siempre exclusivas para turistas Premium.';

  @override
  String get comercioPremiumBadge => 'PREMIUM';

  @override
  String comercioPromoCreatedSnackbar(String name) {
    return 'Promoción \"$name\" creada';
  }

  @override
  String get activitiesPremiumLocked => 'Exclusiva Premium';

  @override
  String get activitiesPremiumLockedHint =>
      'Hazte Premium para ver los detalles →';

  @override
  String get commonFixMarkedFields => 'Revisa los campos marcados en rojo';

  @override
  String get comercioEditActivityHeading => 'Editar actividad';

  @override
  String get comercioEditPromoHeading => 'Editar promoción';

  @override
  String get comercioEditEyebrow => 'EDITANDO';

  @override
  String get comercioEditSubtitle =>
      'Cambia lo que necesites, incluido el estado: borrador, publicada o pausada.';

  @override
  String comercioActivityUpdatedSnackbar(String name) {
    return '\"$name\" actualizada';
  }

  @override
  String get comercioEditSaveError =>
      'No se pudieron guardar los cambios, intenta de nuevo';

  @override
  String get comercioEditTooltip => 'Editar';

  @override
  String get comercioEditNotFound => 'No se encontró esa actividad';

  @override
  String get comercioDeleteButton => 'Eliminar';

  @override
  String comercioDeleteConfirmTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get comercioDeleteConfirmBody =>
      'Se borra para siempre y los turistas dejarán de verla. No se puede deshacer.';

  @override
  String comercioDeletedSnackbar(String name) {
    return '\"$name\" eliminada';
  }

  @override
  String get comercioDeleteError => 'No se pudo eliminar, intenta de nuevo';

  @override
  String get receiptScanTooltip => 'Escanear recibo';

  @override
  String get receiptScanButton => 'Escanear recibo';

  @override
  String get receiptPreviewTitle => 'Revisa la foto';

  @override
  String get receiptPreviewHint =>
      'Que se lean bien el nombre del negocio, la fecha y el total.';

  @override
  String get receiptRetakeButton => 'Retomar';

  @override
  String get receiptConfirmButton => 'Confirmar';

  @override
  String get receiptAnalyzing => 'Analizando recibo...';

  @override
  String get receiptReadError =>
      'No pudimos leer el recibo. Intenta tomar una fotografía más clara.';

  @override
  String get receiptCameraError => 'No se pudo abrir la cámara.';

  @override
  String get receiptFilledNotice =>
      'Llenamos lo que leímos del recibo. Revisa los datos antes de guardar.';

  @override
  String receiptDateOutOfTrip(String date) {
    return 'La fecha del recibo ($date) está fuera de las fechas del viaje; elige la fecha del gasto.';
  }

  @override
  String get tripFinishedReadOnlyNotice =>
      'Este viaje ya terminó: no se pueden agregar gastos ni editar el presupuesto.';

  @override
  String get tripFinishedBadge => 'Viaje terminado';

  @override
  String get homeClientNoOpenTripsSnackbar =>
      'No tienes viajes activos o próximos. Los viajes que ya terminaron no admiten gastos nuevos.';

  @override
  String get floatingNavBarAddExpenseSemanticLabel => 'Agregar gasto';

  @override
  String get securityLayerToggle => 'Incidencia delictiva';

  @override
  String get securityIndexTitle => 'Índice histórico de incidencia delictiva';

  @override
  String securityLegendSubtitle(String period) {
    return 'Hurtos a persona · $period';
  }

  @override
  String get securityLevelLow => 'Bajo';

  @override
  String get securityLevelMedium => 'Medio';

  @override
  String get securityLevelHigh => 'Alto';

  @override
  String get securityLevelVeryHigh => 'Muy alto';

  @override
  String get securityNoData => 'Todavía no hay datos de seguridad cargados.';

  @override
  String get securityLoadError =>
      'No se pudo cargar la capa de incidencia delictiva.';

  @override
  String securityComunaLabel(String code) {
    return 'Comuna $code';
  }

  @override
  String securityCorregimientoLabel(String code) {
    return 'Corregimiento $code';
  }

  @override
  String securityLevelBadge(String level) {
    return 'Nivel $level';
  }

  @override
  String securityRecordsCount(String count) {
    return '$count hurtos a persona registrados';
  }

  @override
  String securityRankComunas(int position, int total) {
    return 'Puesto $position de $total comunas';
  }

  @override
  String securityRankCorregimientos(int position, int total) {
    return 'Puesto $position de $total corregimientos';
  }

  @override
  String securityGroupShare(String percent) {
    return '$percent % de los registros de su grupo';
  }

  @override
  String get securityTopModalities => 'Principales modalidades';

  @override
  String get securityModalitiesError =>
      'No se pudieron cargar las modalidades.';

  @override
  String get securityPeriodLabel => 'Período analizado';

  @override
  String get securitySourceLabel => 'Fuente';

  @override
  String get securityDisclaimer =>
      'Basado en registros históricos de la Policía: no mide el riesgo actual de un lugar. Las zonas con más gente circulando acumulan más registros.';

  @override
  String get securityHistoryTitle => 'Histórico';

  @override
  String get securityHistoryButton => 'Ver histórico';

  @override
  String get securityHistoryLoadError => 'No se pudo cargar el histórico.';

  @override
  String get securityIndexShort => 'Índice';

  @override
  String get securityRecordsInPeriod => 'Registros en el período';

  @override
  String get securityAnnualTitle => 'Registros por año';

  @override
  String securityAnnualNote(String year, String month) {
    return '$year incluye datos hasta $month. La fuente tiene muchos menos registros antes de 2015: compara esos años con cautela.';
  }

  @override
  String get securityMonthlyTitle => 'Registros por mes';

  @override
  String get securityYearTableTitle => 'Comparación por año';

  @override
  String get securityYearColumn => 'Año';

  @override
  String get securityRecordsColumn => 'Registros';

  @override
  String get securityChangeColumn => 'Variación';

  @override
  String get securityPartialYear => 'parcial';

  @override
  String get securityByModality => 'Por modalidad';

  @override
  String get securityOtherModalities => 'Otras';

  @override
  String get securityDayHourTitle => 'Registros por día y hora';

  @override
  String securityDayHourSubtitle(String years) {
    return 'Hora reportada · $years';
  }

  @override
  String get securityDayHourNote =>
      'La hora es la que reportó la víctima: la mayoría de los registros quedan en la hora en punto o y media, por eso se agrupan en franjas de una hora. Incluye los años completos del período.';

  @override
  String get securityDayHourUnavailable =>
      'La fuente no reporta la hora de los hechos, así que este análisis no está disponible.';

  @override
  String get securityDayHourFewer => 'Menos';

  @override
  String get securityDayHourMore => 'Más';

  @override
  String get securityTopSlots => 'Franjas con más registros';

  @override
  String get securityByWeekday => 'Por día de la semana';

  @override
  String securityCellTooltip(String day, String hour, String count) {
    return '$day $hour: $count registros';
  }

  @override
  String get mapScreenLocationUnavailable =>
      'No pudimos obtener tu ubicación. Revisa que el navegador o el teléfono tengan permiso de ubicación (en Mac también en Ajustes del Sistema → Privacidad → Localización) e inténtalo de nuevo.';

  @override
  String get securityWhenTitle => 'Cuándo hay más registros';

  @override
  String get checklistTabTitle => 'Pendientes';

  @override
  String get checklistTitle => 'Lista de pendientes';

  @override
  String checklistProgress(int done, int total) {
    return '$done de $total listos';
  }

  @override
  String get checklistAllDone => '¡Todo listo para tu viaje!';

  @override
  String checklistRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te faltan $count pendientes',
      one: 'Te falta 1 pendiente',
    );
    return '$_temp0';
  }

  @override
  String get checklistEmptyTitle => 'Tu lista está vacía';

  @override
  String get checklistEmptySubtitle =>
      'Agrega las sugerencias que te sirvan o escribe tus propios pendientes.';

  @override
  String get checklistAddHint => 'Algo que no se te puede olvidar…';

  @override
  String get checklistAddButton => 'Agregar';

  @override
  String get checklistTitleRequired => 'Escribe el pendiente';

  @override
  String get checklistTitleTooLong => 'Máximo 120 caracteres';

  @override
  String get checklistSuggestionsTitle => 'Sugeridos para tu viaje';

  @override
  String get checklistSuggestionsSubtitle =>
      'Según tu destino, transporte, fechas y hospedaje.';

  @override
  String checklistAddAll(int count) {
    return 'Agregar todas ($count)';
  }

  @override
  String get checklistSuggestionsDone => 'Ya revisaste todas las sugerencias.';

  @override
  String checklistShowDismissed(int count) {
    return 'Volver a mostrar descartadas ($count)';
  }

  @override
  String get checklistDismissTooltip => 'No aplica';

  @override
  String get checklistAddSuggestionTooltip => 'Agregar a mi lista';

  @override
  String get checklistEdit => 'Editar';

  @override
  String get checklistDelete => 'Eliminar';

  @override
  String get checklistEditTitle => 'Editar pendiente';

  @override
  String get checklistSave => 'Guardar';

  @override
  String get checklistCancel => 'Cancelar';

  @override
  String get checklistMoreTooltip => 'Más opciones';

  @override
  String get checklistLoadError => 'No se pudo cargar la lista de pendientes.';

  @override
  String get checklistSaveError =>
      'No se pudo guardar el cambio. Intenta de nuevo.';

  @override
  String get checklistRetry => 'Reintentar';

  @override
  String get checklistReadOnly =>
      'El viaje terminó: la lista es de solo lectura.';

  @override
  String get checklistReminderInfo =>
      'Te recordaremos 3 días antes, 1 día antes y la mañana de salida si te quedan pendientes.';

  @override
  String get checklistReminderOff =>
      'Los recordatorios de pendientes están apagados en Configuración.';

  @override
  String get checklistReminderGateTitle => 'Recordatorios de pendientes';

  @override
  String get checklistReminderGateDescription =>
      'Con Premium te avisamos antes del viaje si te falta algo por empacar o hacer.';

  @override
  String get checklistSummaryEmpty =>
      'Arma tu lista: te sugerimos qué llevar y qué hacer antes de salir.';

  @override
  String get checklistSummaryOpen => 'Ver lista';

  @override
  String get checklistCategoryDocumentos => 'Documentos';

  @override
  String get checklistCategoryDinero => 'Dinero';

  @override
  String get checklistCategoryEquipaje => 'Equipaje';

  @override
  String get checklistCategorySalud => 'Salud';

  @override
  String get checklistCategoryTecnologia => 'Tecnología';

  @override
  String get checklistCategoryReservas => 'Reservas';

  @override
  String get checklistCategoryCasa => 'Casa';

  @override
  String get checklistCategoryOtro => 'Otro';

  @override
  String get checklistSugDocId => 'Documento de identidad (cédula o pasaporte)';

  @override
  String get checklistSugDocLicense => 'Licencia de conducción';

  @override
  String get checklistSugDocSoat => 'SOAT y tecnomecánica al día';

  @override
  String get checklistSugDocWork => 'Documentos de la empresa';

  @override
  String get checklistSugMoneyCash => 'Efectivo para gastos pequeños';

  @override
  String get checklistSugMoneyCards => 'Tarjetas débito y crédito';

  @override
  String get checklistSugMoneyBankNotice => 'Avisar al banco que vas a viajar';

  @override
  String get checklistSugMoneyTolls => 'Efectivo para peajes';

  @override
  String get checklistSugBagPack => 'Empacar la maleta';

  @override
  String get checklistSugBagExtraClothes => 'Ropa extra o plan de lavandería';

  @override
  String get checklistSugBagLiquids => 'Líquidos en envases de 100 ml';

  @override
  String get checklistSugBagSwimsuit => 'Vestido de baño';

  @override
  String get checklistSugBagSunglasses => 'Gafas de sol y gorra';

  @override
  String get checklistSugBagJacket => 'Chaqueta o ropa abrigada';

  @override
  String get checklistSugBagUmbrella => 'Paraguas o impermeable';

  @override
  String get checklistSugHealthMeds => 'Medicamentos personales';

  @override
  String get checklistSugHealthSunscreen => 'Bloqueador solar';

  @override
  String get checklistSugHealthRepellent => 'Repelente de insectos';

  @override
  String get checklistSugTechCharger => 'Cargador del celular';

  @override
  String get checklistSugTechPowerbank => 'Batería portátil cargada';

  @override
  String get checklistSugTechLaptop => 'Portátil y su cargador';

  @override
  String get checklistSugBookLodging => 'Confirmar la reserva del hospedaje';

  @override
  String get checklistSugBookCheckin => 'Hacer el check-in en línea';

  @override
  String get checklistSugBookBoardingPass => 'Descargar el pasabordo';

  @override
  String get checklistSugBookAirportEarly =>
      'Llegar 2 horas antes al aeropuerto';

  @override
  String get checklistSugBookBusTickets => 'Comprar los tiquetes de bus';

  @override
  String get checklistSugHomeUnplug =>
      'Desconectar aparatos y cerrar las llaves';

  @override
  String get checklistSugHomeCare => 'Dejar quién cuide mascotas y plantas';

  @override
  String get checklistSugOtherCarCheck =>
      'Revisar llantas, aceite y frenos del carro';

  @override
  String get checklistSugOtherGroup => 'Acordar con el grupo quién lleva qué';

  @override
  String get checklistSugOtherItinerary =>
      'Compartir el itinerario con alguien de confianza';

  @override
  String reminderChecklistTitle(int count, String destination) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te faltan $count pendientes para tu viaje a $destination',
      one: 'Te falta 1 pendiente para tu viaje a $destination',
    );
    return '$_temp0';
  }

  @override
  String reminderChecklistMessage(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltan $days días: aprovecha para ir alistando todo.',
      one: 'Mañana sales de viaje: revisa tu lista.',
      zero: 'Hoy sales de viaje: revisa que no se te olvide nada.',
    );
    return '$_temp0';
  }

  @override
  String get reminderChecklistAction => 'Ver pendientes';

  @override
  String get configChecklistReminderLabel => 'Recordatorio de pendientes';

  @override
  String get configChecklistReminderSubtitle =>
      '3 días antes, 1 día antes y la mañana de salida, si te quedan pendientes.';

  @override
  String get subscriptionsBenefitChecklist =>
      'Recordatorios de tu lista de pendientes antes de cada viaje';
}
