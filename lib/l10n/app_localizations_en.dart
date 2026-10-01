// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Travel Guard';

  @override
  String get registerTypeTitle => 'How would you like to register?';

  @override
  String get registerTypeSubtitle =>
      'Choose how you want to sign up for TravelGuard.';

  @override
  String get registerTypeTouristTitle => 'Tourist';

  @override
  String get registerTypeTouristDescription =>
      'Access experiences, maps, recommendations, and more.';

  @override
  String get registerTypeCommerceTitle => 'Business';

  @override
  String get registerTypeCommerceDescription =>
      'Register your business and reach more visitors.';

  @override
  String get authBrandTagline =>
      'Your itinerary, your budget, and your safety, all in one place.';

  @override
  String get loginErrorGeneric => 'Could not sign in.';

  @override
  String get loginSuccessSnackbar => 'Signed in successfully!';

  @override
  String get loginErrorEnterEmail => 'Please enter your email';

  @override
  String get loginErrorInvalidEmail => 'Invalid email';

  @override
  String get loginErrorEnterPassword => 'Please enter your password';

  @override
  String get loginWelcome => 'Welcome';

  @override
  String get loginWelcomeBack => 'back';

  @override
  String get loginHeroSubtitle =>
      'Explore Medellín safely and stay in control of your budget.';

  @override
  String get loginStatStepsLabel => 'STEPS TO CREATE YOUR TRIP';

  @override
  String get loginStatBudgetLabel => 'BUDGET CONTROL';

  @override
  String get loginRoleTourist => 'Tourist';

  @override
  String get loginRoleCommerce => 'Business';

  @override
  String get loginFieldEmailLabel => 'EMAIL';

  @override
  String get loginFieldEmailHint => 'example@email.com';

  @override
  String get loginFieldPasswordLabel => 'PASSWORD';

  @override
  String get loginPasswordHide => 'HIDE';

  @override
  String get loginPasswordShow => 'SHOW';

  @override
  String get loginFeatureInDevelopment => 'Feature in development';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginSubmitAsCommerce => 'Sign in as business';

  @override
  String get loginSubmitAsTourist => 'Sign in as tourist';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get loginNoAccountQuestion => 'Don\'t have an account?';

  @override
  String get loginRegisterLink => 'Sign up';

  @override
  String get commonRegisterButton => 'Sign up';

  @override
  String get commonEmailLabel => 'Email';

  @override
  String get commonEmailHint => 'example@email.com';

  @override
  String get commonPasswordLabel => 'Password';

  @override
  String get commonConfirmPasswordLabel => 'Confirm password';

  @override
  String get commonTermsNotice =>
      'By signing up you accept our Terms and Conditions';

  @override
  String get commonRegisterErrorGeneric =>
      'Could not complete the registration.';

  @override
  String get commonEmailRequired => 'Please enter your email';

  @override
  String get commonEmailInvalid => 'Invalid email';

  @override
  String get commonPasswordRequired => 'Please enter your password';

  @override
  String get commonPasswordsMismatch => 'Passwords don\'t match';

  @override
  String get clientRegisterTitle => 'Sign up as a tourist';

  @override
  String get clientRegisterSubtitle =>
      'Create your account to start planning your trip';

  @override
  String get clientRegisterNameLabel => 'Full name';

  @override
  String get clientRegisterNameHint => 'Enter your name';

  @override
  String get clientRegisterNameRequired => 'Please enter your name';

  @override
  String get clientRegisterPasswordHelper => 'Minimum 6 characters';

  @override
  String get clientRegisterPasswordMin =>
      'Password must be at least 6 characters';

  @override
  String get clientRegisterConfirmPasswordRequired =>
      'Please confirm your password';

  @override
  String get clientRegisterSuccessSnackbar => 'Signed up successfully';

  @override
  String get clientRegisterOrContinueWith => 'or continue with';

  @override
  String get clientRegisterGoogleButton => 'Sign up with Google';

  @override
  String get commerceRegisterTitle => 'Register your business';

  @override
  String get commerceRegisterSubtitle =>
      'Reach more travelers with your business on TravelGuard';

  @override
  String get commerceRegisterNitLabel => 'Tax ID';

  @override
  String get commerceRegisterNitHint => 'Enter your tax ID';

  @override
  String get commerceRegisterNameLabel => 'Business name';

  @override
  String get commerceRegisterNameHint => 'Enter the business name';

  @override
  String get commerceRegisterAddressLabel => 'Address';

  @override
  String get commerceRegisterAddressHint => 'Enter the address';

  @override
  String get commerceRegisterAddressHelper =>
      'Type the address and tap the location icon (or press Enter) to see it on the map below.';

  @override
  String get commerceRegisterAddressSearchTooltip =>
      'Search this address on the map';

  @override
  String get commerceRegisterPhoneLabel => 'Phone number';

  @override
  String get commerceRegisterPhoneHint => 'Enter the phone number';

  @override
  String get commerceRegisterSedeLabel => 'Branch';

  @override
  String get commerceRegisterSedeHint => 'Enter the branch';

  @override
  String get commerceRegisterLocationLabel => 'Business location';

  @override
  String get commerceRegisterPasswordHelper => 'Minimum 8 characters';

  @override
  String get commerceRegisterSuccessSnackbar => 'Signed up successfully!';

  @override
  String get commerceRegisterOr => 'or';

  @override
  String get commerceRegisterGoogleVerified => 'Google account verified';

  @override
  String get commerceRegisterGoogleVerify => 'Verify with Google';

  @override
  String get commerceRegisterGoogleVerifiedSnackbar =>
      'Google account verified. Complete the business details and press \"Sign up\" to finish.';

  @override
  String get commerceRegisterFieldsRequired =>
      'You must complete all required fields';

  @override
  String get commerceRegisterLocationRequired =>
      'Select your business location on the map';

  @override
  String get commerceRegisterNitInvalid =>
      'Invalid or already registered tax ID';

  @override
  String get commerceRegisterEmailInvalidOrTaken =>
      'Invalid or already registered email';

  @override
  String get commerceRegisterPasswordMin =>
      'Password must be at least 8 characters';

  @override
  String get commerceRegisterGeocodeNotFound =>
      'That address wasn\'t found on the map. Set your business location manually by tapping the map below.';

  @override
  String get commerceRegisterGeocodeFound =>
      'Location found — adjust the marker if needed.';

  @override
  String get configScreenTitle => 'Settings';

  @override
  String get configSectionLanguageRegion => 'Language and region';

  @override
  String get configLanguageLabel => 'Language';

  @override
  String get configCurrencyLabel => 'Currency';

  @override
  String get configSectionNotifications => 'Notifications';

  @override
  String get configNotificationsToggleLabel => 'Enable notifications';

  @override
  String get configSectionSecurity => 'Security';

  @override
  String get configChangePasswordLabel => 'Change password';

  @override
  String get configLogoutLabel => 'Log out';

  @override
  String get configVersionLabel => 'Version 1.0.0';

  @override
  String get configCurrentPasswordLabel => 'Current password';

  @override
  String get configCurrentPasswordHint => 'Enter your current password';

  @override
  String get configNewPasswordLabel => 'New password';

  @override
  String get configNewPasswordHint => 'Enter your new password';

  @override
  String get configConfirmNewPasswordHint => 'Confirm your new password';

  @override
  String get configShowPasswordCheckbox => 'Show password';

  @override
  String get configCancelButton => 'Cancel';

  @override
  String get configSaveButton => 'Save';

  @override
  String get configPasswordUpdatedSnackbar => 'Password updated successfully';

  @override
  String configErrorChangePassword(String error) {
    return 'Could not change the password: $error';
  }

  @override
  String get configSelectLanguageTitle => 'Select language';

  @override
  String get configSelectCurrencyTitle => 'Select currency';

  @override
  String get configCurrencyCOP => 'Colombian Peso';

  @override
  String get configCurrencyUSD => 'US Dollar';

  @override
  String get configCurrencyEUR => 'Euro';

  @override
  String get configLogoutDialogTitle => 'Log out?';

  @override
  String get configLogoutDialogContent => 'You will be signed out of the app.';

  @override
  String get addExpenseInvalidAmount => 'Enter a valid amount';

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get addExpenseSubtitle => 'Record a new real expense for this trip';

  @override
  String get addExpenseCategoryLabel => 'Category';

  @override
  String get addExpenseAmountLabel => 'Amount';

  @override
  String get addExpenseAmountHint => 'E.g. 50000';

  @override
  String get addExpenseDateLabel => 'Expense date';

  @override
  String get addExpenseDescriptionLabel => 'Description (optional)';

  @override
  String get addExpenseDescriptionHint => 'E.g. Dinner downtown';

  @override
  String get addExpenseAddButton => 'Add';

  @override
  String get mapScreenUserHereLabel => 'You are here';

  @override
  String get mapScreenActionEnableGps => 'Enable GPS';

  @override
  String get mapScreenActionAllow => 'Allow';

  @override
  String get mapScreenActionSettings => 'Settings';

  @override
  String get mapScreenLocationServiceDisabled =>
      'GPS is turned off. Turn it on to see your location.';

  @override
  String get mapScreenLocationPermissionDenied =>
      'We need location permission to center the map on you.';

  @override
  String get mapScreenLocationPermissionDeniedForever =>
      'Location permission is blocked. Enable it from the app settings.';

  @override
  String get mapScreenTitle => 'Map';

  @override
  String get mapScreenSearchingNearbyPlaces => 'Searching for nearby places...';

  @override
  String mapScreenPlacesFoundCount(int count) {
    return '$count place(s) found';
  }

  @override
  String get comerciosCercanosLoadError =>
      'Could not load the businesses. Please try again.';

  @override
  String comerciosCercanosPlacesCountLabel(int count) {
    return '$count PLACE(S)';
  }

  @override
  String get comerciosCercanosHeaderTitle1 => 'Near ';

  @override
  String get comerciosCercanosHeaderTitle2 => 'you';

  @override
  String get comerciosCercanosHeaderSubtitle =>
      'Verified businesses and places near your location.';

  @override
  String get comerciosCercanosTagVerified => 'Verified';

  @override
  String get comerciosCercanosTagOpenNow => 'Open now';

  @override
  String get comerciosCercanosRetryLabel => 'Retry';

  @override
  String get comerciosCercanosEmptyAll =>
      'There are no registered businesses or places yet';

  @override
  String get comerciosCercanosEmptyCategory =>
      'There are no places in this category';

  @override
  String get comerciosCercanosEmptyHint =>
      'Try another category or check back later.';

  @override
  String get comerciosCercanosTitle => 'Nearby businesses';

  @override
  String get comerciosCercanosNearYourLocation => 'Near your current location';

  @override
  String get comerciosCercanosLocationUnavailable => 'Location unavailable';

  @override
  String comerciosCercanosPlacesFoundCount(int count) {
    return '$count place(s) found';
  }

  @override
  String get placeDetailsErrorOpenMap => 'Could not open the map.';

  @override
  String placeDetailsCategoryDistance(String category, String distance) {
    return '$category · $distance away';
  }

  @override
  String get placeDetailsDirectionsButton => 'Get directions';

  @override
  String get placeDetailsActivitiesTitle => 'Available activities';

  @override
  String get placeDetailsNoActivities => 'No activities registered yet.';

  @override
  String get locationPickerErrorSnackbar =>
      'Could not get your location. Tap the map to place your business manually.';

  @override
  String get locationPickerHintTapMap =>
      'Tap the map or use the button to place your business.';

  @override
  String locationPickerSelectedLocation(String lat, String lng) {
    return 'Selected location: $lat, $lng (you can drag the marker to adjust)';
  }

  @override
  String get appShellNavHome => 'Home';

  @override
  String get appShellNavMyTrips => 'My trips';

  @override
  String get appShellNavCommerces => 'Businesses';

  @override
  String get appShellNavMap => 'Map';

  @override
  String get appShellNavSectionLabel => 'NAVIGATION';

  @override
  String get appShellCreateTripButton => 'Create trip';

  @override
  String appShellBudgetLabel(String month) {
    return 'BUDGET $month';
  }

  @override
  String appShellBudgetPercentOf(int percent, String amount) {
    return '$percent% of $amount';
  }

  @override
  String get appShellNoActiveTrip => 'No active trip';

  @override
  String get appShellRoleTourist => 'Tourist';

  @override
  String get appShellRoleCommerce => 'Business';

  @override
  String get appShellSettingsTooltip => 'Settings';

  @override
  String get appShellSignOutTooltip => 'Sign out';

  @override
  String get appShellSignOutDialogTitle => 'Sign out';

  @override
  String get appShellSignOutDialogContent =>
      'Are you sure you want to sign out?';

  @override
  String get appShellCancelButton => 'Cancel';

  @override
  String get appShellSignOutConfirmButton => 'Sign out';

  @override
  String get appShellSearchHint => 'Search trips, businesses or cities';

  @override
  String get appShellMonthJan => 'jan';

  @override
  String get appShellMonthFeb => 'feb';

  @override
  String get appShellMonthMar => 'mar';

  @override
  String get appShellMonthApr => 'apr';

  @override
  String get appShellMonthMay => 'may';

  @override
  String get appShellMonthJun => 'jun';

  @override
  String get appShellMonthJul => 'jul';

  @override
  String get appShellMonthAug => 'aug';

  @override
  String get appShellMonthSep => 'sep';

  @override
  String get appShellMonthOct => 'oct';

  @override
  String get appShellMonthNov => 'nov';

  @override
  String get appShellMonthDec => 'dec';

  @override
  String get appShellWeekdayMonday => 'monday';

  @override
  String get appShellWeekdayTuesday => 'tuesday';

  @override
  String get appShellWeekdayWednesday => 'wednesday';

  @override
  String get appShellWeekdayThursday => 'thursday';

  @override
  String get appShellWeekdayFriday => 'friday';

  @override
  String get appShellWeekdaySaturday => 'saturday';

  @override
  String get appShellWeekdaySunday => 'sunday';

  @override
  String get floatingNavBarHome => 'Home';

  @override
  String get floatingNavBarMap => 'Map';

  @override
  String get floatingNavBarCommerces => 'Businesses';

  @override
  String get floatingNavBarCreateTripSemanticLabel => 'Create trip';

  @override
  String get createActivityDatePickerHelpText => 'Select a date';

  @override
  String get createActivityDatePickerCancel => 'Cancel';

  @override
  String get createActivityDatePickerConfirm => 'OK';

  @override
  String get createActivityStartDateSnackbar =>
      'Select the activity\'s start date.';

  @override
  String get createActivityEndDateSnackbar =>
      'Select the end date or check \"No end date\".';

  @override
  String get createActivityAppBarTitle => 'Create activity';

  @override
  String get createActivityHeading => 'New activity';

  @override
  String get createActivitySubtitle =>
      'Fill in the information to publish an activity for tourists.';

  @override
  String get createActivityNameLabel => 'Activity name';

  @override
  String get createActivityNameHint => 'E.g. Happy Hour';

  @override
  String get createActivityNameRequired => 'Enter the activity name';

  @override
  String get createActivityDescriptionLabel => 'Description';

  @override
  String get createActivityDescriptionHint =>
      'Explain what the activity is about';

  @override
  String get createActivityDescriptionRequired => 'Enter a description';

  @override
  String get createActivityDescriptionTooShort =>
      'The description must be more detailed';

  @override
  String get createActivityCategoryLabel => 'Type or category';

  @override
  String get createActivityCategoryHint => 'Select a category';

  @override
  String get createActivityCategoryRequired => 'Select a category';

  @override
  String get createActivityPriceLabel => 'Price';

  @override
  String get createActivityPriceHint => 'E.g. 25000';

  @override
  String get createActivityPriceRequired => 'Enter the price or check \"Free\"';

  @override
  String get createActivityPriceInvalid => 'Enter a valid price';

  @override
  String get createActivityFreeCheckbox => 'Free activity';

  @override
  String get createActivityStartDateLabel => 'Start date';

  @override
  String get createActivityStartDateHint => 'Select the start date';

  @override
  String get createActivityStartDateRequired => 'Select the start date';

  @override
  String get createActivityEndDateLabel => 'End date';

  @override
  String get createActivityEndDateHint => 'Select the end date';

  @override
  String get createActivityNoEndDateCheckbox => 'No end date';

  @override
  String get createActivityStatusLabel => 'Activity status';

  @override
  String get createActivityCancelButton => 'Cancel';

  @override
  String get createActivityCreateButton => 'Create';

  @override
  String get createMenuAddProductDialogTitle => 'Add product';

  @override
  String get createMenuProductNameLabel => 'Product name';

  @override
  String get createMenuProductNameHint => 'E.g. Classic burger';

  @override
  String get createMenuProductDescriptionLabel => 'Description';

  @override
  String get createMenuProductDescriptionHint => 'Describe the product';

  @override
  String get createMenuProductPriceLabel => 'Price';

  @override
  String get createMenuProductPriceHint => 'E.g. 18000';

  @override
  String get createMenuCancelButton => 'Cancel';

  @override
  String get createMenuFieldsInvalidSnackbar => 'Fill in all fields correctly.';

  @override
  String get createMenuNegativePriceSnackbar => 'The price cannot be negative.';

  @override
  String get createMenuAddProductButton => 'Add';

  @override
  String get createMenuNoProductsSnackbar =>
      'Add at least one product to the menu.';

  @override
  String get createMenuAppBarTitle => 'Create menu';

  @override
  String get createMenuHeading => 'New menu';

  @override
  String get createMenuSubtitle =>
      'Create a menu to show your products to tourists.';

  @override
  String get createMenuNameLabel => 'Menu name';

  @override
  String get createMenuNameHint => 'E.g. Fast food menu';

  @override
  String get createMenuNameRequired => 'Enter the menu name';

  @override
  String get createMenuDescriptionLabel => 'Description';

  @override
  String get createMenuDescriptionHint => 'Describe what this menu is about';

  @override
  String get createMenuDescriptionRequired => 'Enter a description';

  @override
  String get createMenuCategoryLabel => 'Category';

  @override
  String get createMenuProductsHeading => 'Menu products';

  @override
  String createMenuProductsCount(int count) {
    return '$count products';
  }

  @override
  String get createMenuEmptyProductsTitle => 'No products yet';

  @override
  String get createMenuEmptyProductsSubtitle =>
      'Add the products that will be part of this menu.';

  @override
  String get createMenuAddProductLabel => 'Add product';

  @override
  String get createMenuAvailableTitle => 'Menu available';

  @override
  String get createMenuAvailableSubtitleOn =>
      'Tourists will be able to see it.';

  @override
  String get createMenuAvailableSubtitleOff => 'The menu will be hidden.';

  @override
  String get createMenuCreateButton => 'Create menu';

  @override
  String get homeComercioSignOut => 'Sign out';

  @override
  String get homeComercioSignOutDialogContent =>
      'Are you sure you want to sign out?';

  @override
  String get homeComercioCancelButton => 'Cancel';

  @override
  String homeComercioActivityCreatedSnackbar(String name) {
    return 'Activity \"$name\" created';
  }

  @override
  String get homeComercioCreateFirstMenuSnackbar => 'Create your first menu';

  @override
  String get homeComercioAddMenuTitle => 'Add menu';

  @override
  String get homeComercioAddMenuDescription =>
      'Create and manage the dishes, drinks and services your business offers.';

  @override
  String get homeComercioAddMenuButton => '+ Menu';

  @override
  String homeComercioMenuCreatedSnackbar(String name) {
    return 'Menu \"$name\" created';
  }

  @override
  String get homeComercioCreateActivityTitle => 'Create activity';

  @override
  String get homeComercioCreateActivityDescription =>
      'Organize events, promotions and special activities for your customers.';

  @override
  String get homeComercioCreateActivityButton => '+ Activity';

  @override
  String get homeComercioMyActivitiesTitle => 'My activities';

  @override
  String get homeComercioSeeAllButton => 'See all';

  @override
  String get homeComercioNoNameFallback => 'No name';

  @override
  String homeComercioGreeting(String businessName) {
    return 'Hi, $businessName!';
  }

  @override
  String get homeComercioHeroSubtitle => 'Manage your business easily';

  @override
  String get homeComercioStatActivitiesLabel => 'Activities';

  @override
  String get homeComercioStatMenusLabel => 'Menus created';

  @override
  String get homeComercioEmptyActivitiesTitle =>
      'You don\'t have any activities yet';

  @override
  String get homeComercioEmptyActivitiesSubtitle =>
      'Create your first activity for your visitors.';

  @override
  String get homeComercioNavHome => 'Home';

  @override
  String get homeComercioNavActivities => 'Activities';

  @override
  String get homeComercioNavMenu => 'Menu';

  @override
  String get menuDetailAppBarTitle => 'Menu detail';

  @override
  String get menuDetailStatusAvailable => 'Available';

  @override
  String get menuDetailStatusUnavailable => 'Not available';

  @override
  String get menuDetailDescriptionLabel => 'Description';

  @override
  String get menuDetailStatProductsLabel => 'Products';

  @override
  String get menuDetailStatAverageLabel => 'Average';

  @override
  String get menuDetailStatTotalLabel => 'Total';

  @override
  String menuDetailProductsCount(int count) {
    return 'Products ($count)';
  }

  @override
  String get menuDetailNoProductsTitle => 'No products';

  @override
  String get menuDetailFeatureInDevelopmentSnackbar => 'Feature in development';

  @override
  String get menuDetailEditButton => 'Edit';

  @override
  String get menuDetailDeleteButton => 'Delete';

  @override
  String get menuDetailDeleteDialogTitle => 'Delete menu';

  @override
  String menuDetailDeleteDialogContent(String name) {
    return 'Are you sure you want to delete the menu \"$name\"? This action cannot be undone.';
  }

  @override
  String get menuDetailCancelButton => 'Cancel';

  @override
  String get menuDetailMenuDeletedSnackbar => 'Menu deleted';

  @override
  String get createTripBarrierLabel => 'Create trip';

  @override
  String get createTripStep0TitleLine1 => 'Where are';

  @override
  String get createTripStep0TitleLine2 => 'we going?';

  @override
  String get createTripStep1TitleLine1 => 'Where will';

  @override
  String get createTripStep1TitleLine2 => 'we sleep?';

  @override
  String get createTripStep2TitleLine1 => 'How will we';

  @override
  String get createTripStep2TitleLine2 => 'get around?';

  @override
  String get createTripStepNameDestination => 'Destination and dates';

  @override
  String get createTripStepNameLodging => 'Lodging';

  @override
  String get createTripStepNameTransport => 'Transport';

  @override
  String get createTripErrorSelectStartDateFirst =>
      'First select the start date';

  @override
  String get createTripErrorNameDestinationRequired =>
      'Enter the trip name and destination';

  @override
  String get createTripErrorInvalidDates => 'Select valid dates';

  @override
  String get createTripErrorEndDateAfterStart =>
      'The end date must be after the start date';

  @override
  String get createTripErrorMinOnePerson => 'There must be at least 1 person';

  @override
  String get createTripErrorRequiredFields =>
      'You must complete all required fields';

  @override
  String get createTripErrorBudgetMustBePositive =>
      'The budget must be greater than 0';

  @override
  String get createTripErrorInvalidDatesEntered =>
      'The entered dates are not valid';

  @override
  String get createTripErrorEndDateAfterStartFull =>
      'The end date must be after the start date';

  @override
  String get createTripErrorLodgingCostMustBePositive =>
      'The cost must be greater than 0';

  @override
  String get createTripErrorEmergencyAmountMustBePositive =>
      'The amount must be greater than 0';

  @override
  String get createTripIncompleteDataDialogTitle => 'Incomplete data';

  @override
  String get createTripIncompleteDataDialogContent =>
      'The estimate will be less accurate. Do you want to continue?';

  @override
  String get createTripCancelButton => 'Cancel';

  @override
  String get createTripConfirmCreateButton => 'Yes, create trip';

  @override
  String get createTripErrorMustBeLoggedIn =>
      'You must be signed in as a tourist to create a trip.';

  @override
  String createTripCreatedSnackbar(String amount) {
    return 'Trip created! Total budget: $amount';
  }

  @override
  String get createTripErrorSaveGeneric =>
      'The trip could not be saved. Please try again.';

  @override
  String get createTripErrorDbOutdated =>
      'The database is not up to date to save the trip (a column or table is missing). Check docs/db/hu05_viajes_costos.sql.';

  @override
  String get createTripErrorNoPermission =>
      'You don\'t have permission to save the trip (check the security policies of the viajes table in Supabase).';

  @override
  String get createTripErrorNotRegisteredAsTourist =>
      'Your user is not registered as a tourist yet.';

  @override
  String get createTripCancelDialogTitle => 'Are you sure?';

  @override
  String get createTripCancelDialogContent =>
      'The entered data will be discarded.';

  @override
  String get createTripCancelDialogNoButton => 'No';

  @override
  String get createTripCancelDialogConfirmButton => 'Yes, discard';

  @override
  String createTripStepIndicator(int current, int total) {
    return 'STEP $current OF $total';
  }

  @override
  String get createTripBackButton => 'Back';

  @override
  String createTripNextStepLabel(String stepName) {
    return 'NEXT · $stepName';
  }

  @override
  String get createTripContinueButton => 'Continue →';

  @override
  String get createTripCreateButton => 'Create trip';

  @override
  String get createTripNextLabel => 'NEXT';

  @override
  String get createTripDoneLabel => 'DONE';

  @override
  String get createTripNameLabel => 'Trip name';

  @override
  String get createTripNameHint => 'E.g.: Trip to Cartagena';

  @override
  String get createTripDestinationLabel => 'Destination';

  @override
  String get createTripDestinationHint => 'E.g.: Cartagena, Colombia';

  @override
  String get createTripStartDateLabel => 'START';

  @override
  String get createTripEndDateLabel => 'END';

  @override
  String createTripDurationLabel(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return 'Duration: $_temp0';
  }

  @override
  String get createTripTypeLabel => 'TRIP TYPE';

  @override
  String get createTripLodgingTypeLabel => 'LODGING TYPE';

  @override
  String get createTripLodgingCostLabel => 'Lodging cost';

  @override
  String get createTripLodgingCostHint => 'E.g.: 2000000';

  @override
  String get createTripAdvancePaymentLabel => 'Advance payments';

  @override
  String get createTripAdvancePaymentHint => 'E.g.: 1500000';

  @override
  String get createTripIncludedServicesLabel => 'INCLUDED SERVICES';

  @override
  String get createTripServiceBreakfast => 'Breakfast';

  @override
  String get createTripServiceLunch => 'Lunch';

  @override
  String get createTripServiceDinner => 'Dinner';

  @override
  String get createTripServiceTransfer => 'Transfer';

  @override
  String get createTripStartTransportLabel => 'STARTING TRANSPORT';

  @override
  String get createTripDuringTransportLabel => 'TRANSPORT DURING THE TRIP';

  @override
  String get createTripAdditionalExpensesLabel => 'ADDITIONAL EXPENSES';

  @override
  String get createTripAddButton => 'Add';

  @override
  String get createTripEmergencyMoneyLabel => 'Emergency money';

  @override
  String get createTripEmergencyMoneyHint => 'E.g.: 500000';

  @override
  String get createTripPersonsLabel => 'PEOPLE';

  @override
  String get createTripMaxBudgetLabel => 'MAXIMUM BUDGET';

  @override
  String get createTripCategoryLabel => 'Category';

  @override
  String get createTripCategoryHint => 'E.g.: Local transport';

  @override
  String get createTripAmountLabel => 'Amount';

  @override
  String get createTripCategoryAmountHint => 'E.g.: 500000';

  @override
  String get createTripRemoveCategoryTooltip => 'Remove category';

  @override
  String get createTripBudgetSummaryPlaceholder =>
      'Set the maximum budget in step 1 to see the summary here.';

  @override
  String get createTripBudgetSummaryTitle => 'Budget summary';

  @override
  String get createTripEstimatedLabel => 'Estimated (with entered data)';

  @override
  String get createTripOverBudgetLabel => 'You\'re over by';

  @override
  String get createTripAvailableLabel => 'Available';

  @override
  String get createTripOverBudgetWarning =>
      'The estimate exceeds your maximum budget.';

  @override
  String get createTripEnterDatesForDailyBudget =>
      'Enter the trip dates to see the budget per day.';

  @override
  String get createTripRemainingBudgetSplitLabel =>
      'Remaining budget, split into:';

  @override
  String createTripPerDayLabel(int days) {
    return 'Per day ($days days)';
  }

  @override
  String createTripPerPersonLabel(int persons) {
    return 'Per person ($persons)';
  }

  @override
  String get createTripPerPersonPerDayLabel => 'Per person, per day';

  @override
  String get editTripBudgetErrorMaxBudgetPositive =>
      'The maximum budget must be greater than 0';

  @override
  String get editTripBudgetErrorMustBeLoggedIn =>
      'You must be signed in to save changes.';

  @override
  String get editTripBudgetErrorSaveGeneric =>
      'The budget could not be saved. Please try again.';

  @override
  String get editTripBudgetTitle => 'Edit budget';

  @override
  String get editTripBudgetMaxBudgetLabel => 'Maximum budget';

  @override
  String get editTripBudgetAdvancePaymentLabel => 'Advance payments';

  @override
  String get editTripBudgetLodgingCostLabel => 'Lodging cost';

  @override
  String get editTripBudgetEmergencyMoneyLabel => 'Emergency money';

  @override
  String get editTripBudgetCategoriesTitle => 'Expense categories';

  @override
  String get editTripBudgetAddButton => 'Add';

  @override
  String get editTripBudgetEstimatedLabel => 'Estimated';

  @override
  String get editTripBudgetOverBudgetLabel => 'You\'re over by';

  @override
  String get editTripBudgetAvailableLabel => 'Available';

  @override
  String editTripBudgetPerDayLabel(int days) {
    return 'Per day (${days}d)';
  }

  @override
  String editTripBudgetPerPersonLabel(int persons) {
    return 'Per person ($persons)';
  }

  @override
  String get editTripBudgetSaveButton => 'Save changes';

  @override
  String get editTripBudgetCategoryLabel => 'Category';

  @override
  String get editTripBudgetAmountLabel => 'Amount';

  @override
  String get editTripBudgetRemoveCategoryTooltip => 'Remove category';

  @override
  String get homeClientSignOutDialogTitle => 'Sign out';

  @override
  String get homeClientSignOutDialogContent =>
      'Are you sure you want to sign out?';

  @override
  String get homeClientCancelButton => 'Cancel';

  @override
  String get homeClientSignOutConfirmButton => 'Sign out';

  @override
  String get homeClientCreateTripFirstSnackbar =>
      'Create a trip first to log an expense.';

  @override
  String get homeClientPickTripTitle => 'Which trip does this belong to?';

  @override
  String get homeClientPickTripSubtitle =>
      'Choose the trip to log the expense.';

  @override
  String get homeClientTripNotSavedSnackbar =>
      'This trip wasn\'t saved on the server; expenses can\'t be logged.';

  @override
  String get homeClientCategoriesLoadErrorSnackbar =>
      'Couldn\'t load the expense categories.';

  @override
  String homeClientExpenseAddedSnackbar(
    String amount,
    String category,
    String tripName,
  ) {
    return 'Expense of $amount in $category added to $tripName';
  }

  @override
  String get homeClientExpenseSaveErrorSnackbar =>
      'Couldn\'t save the expense. Try again.';

  @override
  String homeClientGreeting(String name) {
    return 'Hi, $name.';
  }

  @override
  String homeClientActiveTripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active trips',
      one: '1 active trip',
    );
    return '$_temp0';
  }

  @override
  String get homeClientMyTripsTitle => 'My trips';

  @override
  String get homeClientViewAllLabel => 'VIEW ALL';

  @override
  String get homeClientNoTripsTitle => 'You don\'t have any trips yet';

  @override
  String get homeClientNoTripsSubtitle =>
      'Create your first trip to start planning.';

  @override
  String get homeClientCreateTripLabel => 'Create trip';

  @override
  String get homeClientNearbyTitle => 'Near you';

  @override
  String get homeClientNoNearbyPlaces =>
      'There are no nearby businesses or places registered yet.';

  @override
  String get homeClientVerifiedTag => 'Verified';

  @override
  String homeClientViewPlacesButton(int count) {
    return 'View the $count places →';
  }

  @override
  String get homeClientExploreTagline => 'Explore, plan, and travel safely.';

  @override
  String homeClientContextLineDays(String destination, num days, int pct) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$destination starts in $_temp0. Budget is at $pct%.';
  }

  @override
  String homeClientContextLineNoDays(String destination, int pct) {
    return '$destination · budget is at $pct%.';
  }

  @override
  String get homeClientCreateTripCardTitle => 'Create a trip';

  @override
  String get homeClientCreateTripCardDescription =>
      'Organize your next adventure, set your budget, and discover the best destinations.';

  @override
  String get homeClientCreateTripButtonPlus => '+ Create trip';

  @override
  String get homeClientCreateTripCardSubtitle =>
      'Budget, lodging, and itinerary in 3 steps';

  @override
  String get homeClientMapCardTitle => 'Map';

  @override
  String get homeClientMapCardDescription =>
      'Explore destinations, find safe businesses, and plan your route.';

  @override
  String get homeClientViewMapButton => 'View map';

  @override
  String get homeClientMapCardPlacesCount => '14 places nearby';

  @override
  String get homeClientNextExpenseLabel => 'NEXT EXPENSE';

  @override
  String get homeClientLodgingFallback => 'Lodging';

  @override
  String homeClientLodgingPaymentDue(String date, String amount) {
    return 'Due before $date · $amount';
  }

  @override
  String get homeClientRegisterExpenseHint => 'Log a trip expense in seconds.';

  @override
  String get homeClientSignOutButton => 'Sign out';

  @override
  String homeClientMobileGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeClientMobileHeroSubtitle => 'Explore, plan, and travel safely';

  @override
  String get homeClientStatActiveTripsLabel => 'Active trips';

  @override
  String get homeClientStatNextTripLabel => 'Next trip';

  @override
  String get homeClientStatTotalBudgetLabel => 'Total budget';

  @override
  String get homeClientViewAllMobileLabel => 'View all';

  @override
  String get homeClientMonthAbbrJan => 'Jan';

  @override
  String get homeClientMonthAbbrFeb => 'Feb';

  @override
  String get homeClientMonthAbbrMar => 'Mar';

  @override
  String get homeClientMonthAbbrApr => 'Apr';

  @override
  String get homeClientMonthAbbrMay => 'May';

  @override
  String get homeClientMonthAbbrJun => 'Jun';

  @override
  String get homeClientMonthAbbrJul => 'Jul';

  @override
  String get homeClientMonthAbbrAug => 'Aug';

  @override
  String get homeClientMonthAbbrSep => 'Sep';

  @override
  String get homeClientMonthAbbrOct => 'Oct';

  @override
  String get homeClientMonthAbbrNov => 'Nov';

  @override
  String get homeClientMonthAbbrDec => 'Dec';

  @override
  String get tripDetailTripNotSavedSnackbar =>
      'This trip wasn\'t saved on the server; expenses can\'t be logged.';

  @override
  String get tripDetailLoadExpensesError => 'Couldn\'t load the expenses.';

  @override
  String get tripDetailLoadGroupError => 'Couldn\'t load the trip\'s group.';

  @override
  String get tripDetailInviteDialogTitle => 'Invite collaborator';

  @override
  String get tripDetailInviteEmailHint => 'email@example.com';

  @override
  String get tripDetailInviteEmailHelper =>
      'Must be registered on TravelGuard as a tourist.';

  @override
  String get tripDetailCancelButton => 'Cancel';

  @override
  String get tripDetailInviteButton => 'Invite';

  @override
  String tripDetailCollaboratorAddedSnackbar(String name) {
    return '$name can now view and edit this trip';
  }

  @override
  String get tripDetailInviteErrorSnackbar =>
      'Couldn\'t invite that person. Try again.';

  @override
  String get tripDetailRemoveCollaboratorDialogTitle => 'Remove collaborator';

  @override
  String tripDetailRemoveCollaboratorDialogContent(String name) {
    return 'Remove $name from this trip? They will no longer be able to view or edit it.';
  }

  @override
  String get tripDetailRemoveButton => 'Remove';

  @override
  String get tripDetailRemoveCollaboratorErrorSnackbar =>
      'Couldn\'t remove the collaborator.';

  @override
  String get tripDetailCategoriesLoadErrorSnackbar =>
      'Couldn\'t load the expense categories.';

  @override
  String tripDetailExpenseAddedSnackbar(String amount, String category) {
    return 'Expense of $amount in $category added';
  }

  @override
  String get tripDetailExpenseSaveErrorSnackbar =>
      'Couldn\'t save the expense. Try again.';

  @override
  String get tripDetailDeleteExpenseDialogTitle => 'Delete expense';

  @override
  String tripDetailDeleteExpenseDialogContent(String amount, String category) {
    return 'Delete the expense of $amount in $category?';
  }

  @override
  String get tripDetailDeleteButton => 'Delete';

  @override
  String get tripDetailDeleteExpenseErrorSnackbar =>
      'Couldn\'t delete the expense.';

  @override
  String get tripDetailDeleteTripDialogTitle => 'Delete trip';

  @override
  String tripDetailDeleteTripDialogContent(String name) {
    return 'Are you sure you want to delete the trip \"$name\"? This action cannot be undone.';
  }

  @override
  String get tripDetailTripDeletedSnackbar => 'Trip deleted';

  @override
  String get tripDetailDeleteTripErrorSnackbar =>
      'Couldn\'t delete the trip. Try again.';

  @override
  String get tripDetailTabResumen => 'Summary';

  @override
  String get tripDetailTabHospedaje => 'Lodging';

  @override
  String get tripDetailTabTransporte => 'Transport';

  @override
  String get tripDetailTabGastos => 'Expenses';

  @override
  String get tripDetailTabGrupo => 'Group';

  @override
  String get tripDetailBreadcrumbHome => 'HOME / MY TRIPS';

  @override
  String get tripDetailEditButton => 'Edit';

  @override
  String get tripDetailAddExpenseButton => 'Add expense';

  @override
  String get tripDetailHeaderTripToPrefix => 'Trip to ';

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
      other: '$persons PEOPLE',
      one: '$persons PERSON',
    );
    return '$startDate – $endDate · $_temp0 · $tripType';
  }

  @override
  String get tripDetailSpentLabel => 'SPENT';

  @override
  String get tripDetailCapLabel => 'CAP';

  @override
  String tripDetailOverBudgetLabel(String amount) {
    return 'You went over the cap by $amount';
  }

  @override
  String tripDetailOnTrackLabel(int pct) {
    return 'You\'re on track: $pct% of budget used';
  }

  @override
  String get tripDetailLodgingTitle => 'Lodging';

  @override
  String get tripDetailLodgingTypeLabel => 'Type';

  @override
  String get tripDetailCostLabel => 'Cost';

  @override
  String get tripDetailTransportLabel => 'TRANSPORT';

  @override
  String tripDetailDuringTransportDetail(String value) {
    return 'During: $value';
  }

  @override
  String get tripDetailPersonsLabel => 'PEOPLE';

  @override
  String get tripDetailRecentExpensesTitle => 'Recent expenses';

  @override
  String get tripDetailNoExpensesYetHint =>
      'You haven\'t logged any expenses yet. Use \"Add expense\" above to note your first one.';

  @override
  String get tripDetailAvailableBudgetTitle => 'Available budget';

  @override
  String tripDetailPerDayLabel(int days) {
    return 'Per day ($days days)';
  }

  @override
  String tripDetailPerPersonLabel(int persons) {
    return 'Per person ($persons)';
  }

  @override
  String get tripDetailExpenseBreakdownTitle => 'Expense breakdown';

  @override
  String get tripDetailNoExpensesRegistered => 'No expenses registered yet.';

  @override
  String get tripDetailAdvancePayments => 'Advance payments';

  @override
  String get tripDetailLodgingPlanned => 'Lodging (planned)';

  @override
  String get tripDetailEmergencies => 'Emergencies';

  @override
  String tripDetailCategoryRealSuffix(String category) {
    return '$category (actual)';
  }

  @override
  String get tripDetailLodgingTypeFullLabel => 'Lodging type';

  @override
  String get tripDetailIncludedServicesLabel => 'Included services';

  @override
  String get tripDetailTransportTabTitle => 'Transport';

  @override
  String get tripDetailStartTransportLabel => 'Starting transport';

  @override
  String get tripDetailDuringTransportKvLabel => 'Transport during the trip';

  @override
  String get tripDetailExpensesRegisteredTitle => 'Registered expenses';

  @override
  String get tripDetailTripNotSavedExpensesHint =>
      'This trip wasn\'t saved on the server, so real expenses can\'t be logged.';

  @override
  String get tripDetailRetryButton => 'Retry';

  @override
  String get tripDetailNoRealExpensesYet =>
      'You haven\'t logged any real expenses for this trip yet.';

  @override
  String get tripDetailDeleteExpenseTooltip => 'Delete expense';

  @override
  String get tripDetailInvalidDatesHint =>
      'Add valid dates to see your spending pace.';

  @override
  String tripDetailTripStartsIn(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return 'Your trip starts in $_temp0.';
  }

  @override
  String get tripDetailTripEnded => 'This trip has already ended.';

  @override
  String tripDetailDaysRemaining(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0 of the trip remain.';
  }

  @override
  String get tripDetailGroupDailySpendLabel => 'Group should spend/day';

  @override
  String get tripDetailPerPersonDailyLabel => 'Per person/day';

  @override
  String get tripDetailSpendingPaceTitle => 'Spending pace';

  @override
  String get tripDetailSpentPerPersonLabel => 'Spent so far per person';

  @override
  String get tripDetailForeignTouristQuestion => 'Are you a foreign tourist?';

  @override
  String tripDetailTaxRefundWithPurchases(
    String comprasTotal,
    String ivaEstimado,
  ) {
    return 'Of what you have in \"Purchases\" ($comprasTotal), approx. $ivaEstimado was VAT — in Colombia, non-resident foreign tourists can claim it back in full before leaving the country.';
  }

  @override
  String get tripDetailTaxRefundNoPurchases =>
      'When you log purchases (clothing, footwear, crafts, jewelry, appliances, etc.) with an electronic invoice, you\'ll see here how much VAT you could recover before leaving the country.';

  @override
  String tripDetailTaxRefundRequirements(String minPurchase, String maxRefund) {
    return 'Requirements: an electronic invoice of at least $minPurchase per purchase, passport or Andean Migration Card, and request it at the airport\'s DIAN office before flying. Cap: $maxRefund per request. Check the current process at dian.gov.co.';
  }

  @override
  String get tripDetailCollaboratorsTitle => 'Collaborators';

  @override
  String get tripDetailCollaboratorsSubtitle =>
      'Who can view and edit this trip';

  @override
  String get tripDetailOwnerTag => 'Owner';

  @override
  String get tripDetailYouTag => 'You';

  @override
  String get tripDetailRemoveCollaboratorTooltip => 'Remove collaborator';

  @override
  String get tripDetailHistoryTitle => 'Change history';

  @override
  String get tripDetailNoHistoryYet =>
      'No changes recorded yet. When someone edits the budget, it will show up here.';

  @override
  String get tripDetailHistoryChangedText => ' changed ';

  @override
  String get tripDetailJustNow => 'Just now';

  @override
  String tripDetailMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String tripDetailHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get tripDetailYesterday => 'Yesterday';

  @override
  String tripDetailDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get tripDetailMobileAppBarTitle => 'Trip Detail';

  @override
  String get tripDetailEditBudgetTooltip => 'Edit budget';

  @override
  String get tripDetailMoreTooltip => 'More';

  @override
  String get tripDetailBudgetTitle => 'Budget';

  @override
  String get tripDetailSpentKvLabel => 'Spent';

  @override
  String get tripDetailAvailableKvLabel => 'Available';

  @override
  String tripDetailBudgetUsedPercent(String percent) {
    return '$percent% of budget used';
  }

  @override
  String get desglosePresupuestoTitle => 'Budget Breakdown';

  @override
  String get desglosePresupuestoHospedaje => 'Lodging';

  @override
  String get desglosePresupuestoTransporte => 'Transport';

  @override
  String get desglosePresupuestoComidas => 'Meals';

  @override
  String get desglosePresupuestoActividades => 'Activities';

  @override
  String get desglosePresupuestoEmergencias => 'Emergencies';

  @override
  String get tripHistoryPresupuestoMaximo => 'Maximum budget';

  @override
  String get tripHistoryPagosAnticipados => 'Advance payments';

  @override
  String get tripHistoryCostoHospedaje => 'Lodging cost';

  @override
  String get tripHistoryDineroEmergencias => 'Emergency money';

  @override
  String get tripHistoryCategoriasPresupuesto => 'Budget categories';

  @override
  String get categoryFilterAll => 'All';

  @override
  String get placeCategoryComercio => 'Business';

  @override
  String get placeCategoryDiscoteca => 'Nightclub';

  @override
  String get placeCategoryMirador => 'Viewpoint';

  @override
  String get placeCategoryMuseo => 'Museum';

  @override
  String get placeCategoryOtro => 'Other';

  @override
  String get placeCategoryParque => 'Park';

  @override
  String get placeCategoryRestaurante => 'Restaurant';

  @override
  String get placeCategoryTour => 'Tour';

  @override
  String get placeCategoryHotel => 'Hotel';

  @override
  String get placeCategoryTienda => 'Shop';

  @override
  String get placeCategoryTransporte => 'Transport';

  @override
  String get configSectionReset => 'Reset';

  @override
  String get configResetDefaultsLabel => 'Reset to default settings';

  @override
  String get configResetDefaultsDialogTitle => 'Reset to default settings?';

  @override
  String get configResetDefaultsDialogContent =>
      'Language, currency, and notifications will be restored to their original values.';

  @override
  String get configResetDefaultsConfirmButton => 'Reset';

  @override
  String get configResetDefaultsSnackbar => 'Settings restored';

  @override
  String get configExchangeRateLabel => 'Exchange rate';

  @override
  String configExchangeRatePreview(String rate) {
    return '1 USD = $rate';
  }

  @override
  String get configExchangeRateDialogTitle => 'Exchange rate';

  @override
  String get configExchangeRateDialogHint =>
      'No connection to any service: enter yourself how many Colombian pesos equal 1 dollar and 1 euro. This only changes how amounts look in the app — what\'s saved in your trips and expenses stays the real amount in pesos.';

  @override
  String get configExchangeRateUsdLabel => '1 USD equals (COP)';

  @override
  String get configExchangeRateEurLabel => '1 EUR equals (COP)';

  @override
  String get configExchangeRateInvalid => 'Enter valid values, greater than 0';

  @override
  String get configExchangeRateSavedSnackbar => 'Exchange rate updated';

  @override
  String tripCardSpentOfBudget(String spent, String maxBudget) {
    return '$spent spent of $maxBudget';
  }

  @override
  String get forgotPasswordTitle => 'Recover your password';

  @override
  String get forgotPasswordSubtitle =>
      'We\'ll send a link to your email to create a new one';

  @override
  String get forgotPasswordSubmitButton => 'Send link';

  @override
  String get forgotPasswordBackToLogin => 'Back to sign in';

  @override
  String get forgotPasswordSuccessTitle => 'Check your email';

  @override
  String forgotPasswordSuccessBody(String email) {
    return 'If $email is registered, we sent a link to reset your password. Check your spam folder too.';
  }

  @override
  String get resetPasswordTitle => 'Create a new password';

  @override
  String get resetPasswordSubtitle =>
      'Choose a secure password for your account';

  @override
  String get resetPasswordInvalidLink =>
      'This link is no longer valid. Request a new one from the recovery screen.';

  @override
  String get resetPasswordInvalidLinkTitle => 'Invalid link';

  @override
  String get resetPasswordRequestNewLink => 'Request a new link';

  @override
  String resetPasswordForEmail(String email) {
    return 'Resetting the password for $email';
  }

  @override
  String get resetPasswordMinLength => 'Password must be at least 8 characters';

  @override
  String get resetPasswordSubmitButton => 'Change password';

  @override
  String get resetPasswordSuccessTitle => 'Password updated';

  @override
  String get resetPasswordSuccessBody =>
      'Your password was changed successfully. You can now sign in with it.';

  @override
  String get resetPasswordGoToLogin => 'Go to sign in';

  @override
  String get businessSettingsAppBarTitle => 'My business';

  @override
  String get businessSettingsNameRequiredSnackbar => 'Enter the business name';

  @override
  String get businessSettingsSectionTitle => 'General information';

  @override
  String get businessSettingsSectionSubtitle =>
      'Update the information your customers will see.';

  @override
  String get businessSettingsNameLabel => 'Business name';

  @override
  String get businessSettingsNameHint => 'E.g. El Sabor Restaurant';

  @override
  String get businessSettingsScheduleLabel => 'Hours';

  @override
  String get businessSettingsScheduleHint =>
      'E.g. Monday to Saturday 8:00 AM - 8:00 PM';

  @override
  String get businessSettingsContactLabel => 'Contact';

  @override
  String get businessSettingsContactHint => 'E.g. 300 123 4567';

  @override
  String get businessSettingsSaveButton => 'Save changes';

  @override
  String get subscriptionsAppBarTitle => 'Premium plans and subscriptions';

  @override
  String get subscriptionsHeaderTitle =>
      'Choose the perfect plan to improve your experience in the app';

  @override
  String get subscriptionsHeaderSubtitle =>
      'Access to all trip and experience features';

  @override
  String get subscriptionsBillingMonthly => 'Monthly';

  @override
  String get subscriptionsBillingAnnual => 'Annual (-20%)';

  @override
  String get subscriptionsPlanTouristName => 'Tourist';

  @override
  String get subscriptionsPlanTouristSubtitle => 'Perfect for explorers';

  @override
  String get subscriptionsPeriodMonth => '/month';

  @override
  String get subscriptionsPeriodYear => '/year';

  @override
  String get subscriptionsFeatureMobile1 => 'Search trips and experiences';

  @override
  String get subscriptionsFeatureMobile2 => 'Rate and comment';

  @override
  String get subscriptionsFeatureMobile3 => 'Save favorites';

  @override
  String get subscriptionsFeatureMobile4 => 'Full mobile access';

  @override
  String get subscriptionsFeatureMobile5 => 'Email support';

  @override
  String get subscriptionsFeatureDesktop1 => 'Save your favorite places';

  @override
  String get subscriptionsFeatureDesktop2 => 'Know where you spend the most';

  @override
  String get subscriptionsFeatureDesktop3 =>
      'Compare your budget and your expenses';

  @override
  String get subscriptionsFeatureDesktop4 => 'Scan your receipts automatically';

  @override
  String get subscriptionsPlanSelectedButton => 'Plan selected';

  @override
  String get subscriptionsPlanSelectButton => 'Select';

  @override
  String get subscriptionsFaqTitle => 'Frequently asked questions';

  @override
  String get subscriptionsFaqChangePlanQuestion =>
      'Can I change plans at any time?';

  @override
  String get subscriptionsFaqChangePlanAnswer =>
      'Yes, you can change or cancel your subscription at any time from your settings.';

  @override
  String get subscriptionsFaqFreeTrialQuestion =>
      'Is there a free trial period?';

  @override
  String get subscriptionsFaqFreeTrialAnswer =>
      'No, we don\'t currently offer a free trial period. However, you can cancel your subscription at any time.';

  @override
  String get subscriptionsFaqPaymentMethodsQuestion =>
      'What payment methods do you accept?';

  @override
  String get subscriptionsFaqPaymentMethodsAnswer =>
      'We accept credit cards, debit cards, bank transfers, and digital wallets.';

  @override
  String get subscriptionsFooterNote =>
      'Change plans at any time with no penalty';

  @override
  String subscriptionsDialogPlanTitle(String planName) {
    return '$planName Plan';
  }

  @override
  String subscriptionsDialogPriceLabel(String price) {
    return 'Price: $price';
  }

  @override
  String get subscriptionsDialogBody =>
      'By clicking \"Continue\", you\'ll be redirected to the payment gateway to complete your subscription.';

  @override
  String get subscriptionsDialogCancelButton => 'Cancel';

  @override
  String get subscriptionsDialogContinueButton => 'Continue';

  @override
  String get subscriptionsDialogRedirectingSnackbar =>
      'Redirecting to payment gateway...';

  @override
  String get stepProgressLabel => 'Step';

  @override
  String get stepProgressStep1 => 'Information';

  @override
  String get stepProgressStep2 => 'Date and price';

  @override
  String get stepProgressStep3 => 'Details';

  @override
  String get homeComercioBusinessSettingsTooltip => 'My business';

  @override
  String get homeComercioBusinessUpdatedSnackbar =>
      'Business information updated';

  @override
  String get configSectionAccount => 'Account';

  @override
  String get homeComercioLoadErrorSnackbar =>
      'Couldn\'t load the business information';

  @override
  String get homeComercioSaveErrorSnackbar =>
      'Couldn\'t save the changes, try again';

  @override
  String get createActivitySaveErrorSnackbar =>
      'Couldn\'t create the activity, try again';

  @override
  String get createMenuSaveErrorSnackbar =>
      'Couldn\'t create the menu, try again';

  @override
  String get menuDetailSaveErrorSnackbar =>
      'Couldn\'t save the change, try again';

  @override
  String get businessSettingsOpenTimeLabel => 'Opening time';

  @override
  String get businessSettingsCloseTimeLabel => 'Closing time';

  @override
  String get businessSettingsTimeNotSet => 'Not set';
}
