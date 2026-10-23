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
      'Invalid tax ID: numbers only (5 to 15 digits)';

  @override
  String get commerceRegisterEmailInvalidOrTaken =>
      'Enter a valid email (e.g. name@mail.com)';

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
  String get configNotificationsToggleLabel => 'Show alerts';

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
  String get addExpenseInvalidAmount => 'Enter an amount greater than 0';

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
  String get addExpenseTimeLabel => 'Time';

  @override
  String get addExpensePlaceLabel => 'Place (optional)';

  @override
  String get addExpensePlaceHint => 'E.g. El Sabor Restaurant';

  @override
  String get addExpensePaidByLabel => 'Who paid?';

  @override
  String get addExpensePaidWithTripMoney => 'Paid with trip money';

  @override
  String get addExpensePaidTripMoneyOn => 'Came from the shared trip fund';

  @override
  String get addExpensePaidTripMoneyOff => 'Came from personal pocket';

  @override
  String get addExpensePaymentSourceLabel => 'Which money are you paying with?';

  @override
  String get addExpenseSourceTrip => 'Trip money';

  @override
  String get addExpenseSourcePocket => 'My pocket';

  @override
  String addExpenseSourceBalance(String amount) {
    return 'Available: $amount';
  }

  @override
  String get addExpenseSourceNoPocket => 'No pocket yet';

  @override
  String get addExpensePocketMissing =>
      'You don\'t have a pocket for this trip yet. Create it from \"My pocket\".';

  @override
  String addExpensePocketInsufficient(String balance) {
    return 'Your pocket only has $balance available.';
  }

  @override
  String get pocketButtonLabel => 'My pocket';

  @override
  String get pocketScreenTitle => 'My personal pocket';

  @override
  String get pocketPrivateNote => 'Only you can see this pocket.';

  @override
  String get pocketEmptyTitle => 'You don\'t have a pocket for this trip yet';

  @override
  String get pocketEmptyDescription =>
      'Create your pocket to keep your own money and pay trip expenses from it.';

  @override
  String get pocketCreateButton => 'Create my pocket';

  @override
  String get pocketBalanceLabel => 'AVAILABLE BALANCE';

  @override
  String get pocketAddedLabel => 'ADDED';

  @override
  String get pocketSpentLabel => 'SPENT';

  @override
  String get pocketAddMoneyButton => 'Add money';

  @override
  String get pocketAddMoneyTitle => 'Add money to your pocket';

  @override
  String get pocketAmountLabel => 'Amount';

  @override
  String get pocketNoteLabel => 'Note (optional)';

  @override
  String get pocketNoteHint => 'E.g. Cash for shopping';

  @override
  String get pocketAddConfirmButton => 'Add';

  @override
  String get pocketMovementsTitle => 'Movements';

  @override
  String get pocketNoMovements => 'You haven\'t added any money yet.';

  @override
  String get pocketLoadError => 'Couldn\'t load your pocket.';

  @override
  String get pocketSaveError => 'Couldn\'t save. Try again.';

  @override
  String get pocketCreatedSnackbar => 'Pocket created';

  @override
  String pocketDepositAddedSnackbar(String amount) {
    return '$amount added to your pocket';
  }

  @override
  String get estimateScreenTitle => 'Estimate budget';

  @override
  String get estimateEyebrow => 'BUDGET ESTIMATOR';

  @override
  String get estimateTitleLine1 => 'How much will';

  @override
  String get estimateTitleLine2 => 'your trip cost?';

  @override
  String get estimateIntro =>
      'Tell us where you\'re going and we\'ll estimate lodging, food and transport.';

  @override
  String get estimateDestinationLabel => 'DESTINATION';

  @override
  String get estimateDestinationHint => 'Search for a city';

  @override
  String get estimateDatesLabel => 'TRIP DATES';

  @override
  String get estimateDatesPlaceholder => 'Select departure and return';

  @override
  String get estimateDatePickerHelp => 'Trip dates';

  @override
  String get estimateDatePickerSave => 'Done';

  @override
  String estimateDurationSummary(int days, int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    String _temp1 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights nights',
      one: '$nights night',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get estimateTravelersLabel => 'TRAVELERS';

  @override
  String estimateTravelersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count travelers',
      one: '$count traveler',
    );
    return '$_temp0';
  }

  @override
  String get estimateTripTypeLabel => 'TRIP TYPE';

  @override
  String get estimateStyleEconomyTitle => 'Budget';

  @override
  String get estimateStyleEconomyCaption => 'Hostels and local food';

  @override
  String get estimateStyleStandardTitle => 'Standard';

  @override
  String get estimateStyleStandardCaption => '3-4★ hotels';

  @override
  String get estimateStyleLuxuryTitle => 'Luxury';

  @override
  String get estimateStyleLuxuryCaption => '5★ hotels and experiences';

  @override
  String get estimateErrorDestinationEmpty => 'Type or choose a destination.';

  @override
  String get estimateErrorDatesEmpty => 'Select your trip dates.';

  @override
  String get estimateErrorDatesTooShort => 'The trip must be at least 1 night.';

  @override
  String get estimateErrorDatesTooLong =>
      'For now we only estimate trips of up to 30 days.';

  @override
  String get estimateErrorGeneric =>
      'We couldn\'t calculate the estimate. Please try again.';

  @override
  String get estimateButton => 'Estimate budget';

  @override
  String get estimateButtonLoading => 'Estimating…';

  @override
  String get estimateButtonNew => 'New estimate';

  @override
  String get estimateLoadingEyebrow => 'CHECKING PRICES';

  @override
  String get estimateLoadingTitle => 'Building your estimate';

  @override
  String get estimateLoadingStepLodging => 'Looking up lodging';

  @override
  String get estimateLoadingStepFlights => 'Checking flights';

  @override
  String get estimateLoadingStepLocal => 'Calculating food and local transport';

  @override
  String get estimateResultEyebrow => 'ESTIMATED BUDGET';

  @override
  String get estimateRangeBadge => 'RANGE ±15%';

  @override
  String estimateHeroSubtitle(int nights, int travelers, String style) {
    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights NIGHTS',
      one: '$nights NIGHT',
    );
    String _temp1 = intl.Intl.pluralLogic(
      travelers,
      locale: localeName,
      other: '$travelers TRAVELERS',
      one: '$travelers TRAVELER',
    );
    return '$_temp0 · $_temp1 · $style';
  }

  @override
  String get estimateBreakdownTitle => 'Breakdown';

  @override
  String get estimateLodgingTitle => 'Lodging';

  @override
  String estimateLodgingCaption(int nights) {
    String _temp0 = intl.Intl.pluralLogic(
      nights,
      locale: localeName,
      other: '$nights nights',
      one: '$nights night',
    );
    return 'Average per night × $_temp0';
  }

  @override
  String get estimateFoodTitle => 'Food';

  @override
  String estimateFoodCaption(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return 'Daily average × $_temp0';
  }

  @override
  String get estimateTransportTitle => 'Transport';

  @override
  String get estimateTransportCaption => 'Flight + local transport';

  @override
  String get estimateFlightLabel => 'Flight';

  @override
  String get estimateLocalTransportLabel => 'Local transport';

  @override
  String get estimateSourcesIntro => 'Estimate based on average prices from';

  @override
  String get estimateUpdatedLessThanHour => 'Data updated less than 1 hour ago';

  @override
  String estimateUpdatedHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return 'Data updated $_temp0 ago';
  }

  @override
  String get estimateDisclaimer =>
      'Prices may vary ±15% depending on current availability.';

  @override
  String get estimateCardSubtitle => 'Work out what a trip would cost';

  @override
  String get estimateCardDescription =>
      'Find out what a trip would cost before planning it.';

  @override
  String get estimateCardButton => 'Estimate';

  @override
  String get limitsTabTitle => 'Limits';

  @override
  String get limitsConfigureButton => 'Set limits';

  @override
  String get limitsScreenTitle => 'Set limits';

  @override
  String get limitsTripLabel => 'TRIP';

  @override
  String get limitsScreenSubtitle =>
      'Set the most you want to spend on each category of this trip. Leave it empty for no limit.';

  @override
  String get limitsFieldHint => 'No limit';

  @override
  String limitsSpentSoFar(String amount) {
    return 'Spent: $amount';
  }

  @override
  String get limitsSaveButton => 'Save limits';

  @override
  String get limitsSavedSnackbar => 'Limits saved';

  @override
  String get limitsSaveError => 'Couldn\'t save the limits. Please try again.';

  @override
  String get limitsProgressTitle => 'Progress by category';

  @override
  String limitsProgressAmount(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String limitsOverBy(String amount) {
    return 'You went over the limit by $amount';
  }

  @override
  String limitsLeft(String amount) {
    return '$amount left';
  }

  @override
  String get limitsEmptyTitle => 'No limits set yet';

  @override
  String get limitsEmptyDescription =>
      'Set a maximum per category and follow your spending in real time.';

  @override
  String get limitsReportTitle => 'Compliance report';

  @override
  String get limitsColCategory => 'CATEGORY';

  @override
  String get limitsColLimit => 'LIMIT';

  @override
  String get limitsColSpent => 'SPENT';

  @override
  String get limitsColCompliance => '% COMPLIANCE';

  @override
  String get limitsTotalRow => 'Total';

  @override
  String limitDialogTitle(String category) {
    return '$category limit';
  }

  @override
  String get limitDialogReached =>
      'You\'ve reached your limit in this category. Continue?';

  @override
  String limitDialogWillExceed(String category, String amount) {
    return 'This expense will put you over your $category limit by $amount. Continue?';
  }

  @override
  String get limitDialogContinue => 'Continue';

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
  String get createTripStep2TitleLine1 => 'What will you';

  @override
  String get createTripStep2TitleLine2 => 'spend on?';

  @override
  String get createTripStepNameDestination => 'Destination and dates';

  @override
  String get createTripStepNameLodging => 'Lodging';

  @override
  String get createTripStepNameTransport => 'Expenses';

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
      'Enter a valid amount (0 or more)';

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
  String get createTripEstimatedLabel => 'Planned expenses';

  @override
  String get createTripOverBudgetLabel => 'You\'re over by';

  @override
  String get createTripAvailableLabel => 'Available, not yet planned';

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
  String get editTripBudgetEstimatedLabel => 'Planned expenses';

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
  String get homeClientPickTripTitle => 'Which trip is this expense for?';

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
  String homeClientMapCardPlacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places nearby',
      one: '1 place nearby',
      zero: 'Explore places',
    );
    return '$_temp0';
  }

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
  String get tripDetailTabAnalisis => 'Analysis';

  @override
  String get analysisDailyTitle => 'Daily comparison';

  @override
  String get analysisInvalidTripDates => 'The trip dates are not valid.';

  @override
  String get analysisColDay => 'DAY';

  @override
  String get analysisColDailyBudget => 'DAILY BUDGET';

  @override
  String get analysisColActual => 'ACTUAL SPEND';

  @override
  String get analysisColDifference => 'DIFFERENCE';

  @override
  String get analysisColPctSpent => '% SPENT';

  @override
  String analysisDayLabelDate(int n, String date) {
    return 'Day $n · $date';
  }

  @override
  String analysisDayLabel(int n) {
    return 'Day $n';
  }

  @override
  String get analysisByCategoryTitle => 'By category';

  @override
  String get analysisNoCategoriesYet =>
      'There are no categories or expenses to compare yet.';

  @override
  String get analysisColCategory => 'CATEGORY';

  @override
  String get analysisColBudgeted => 'BUDGETED';

  @override
  String get analysisBudgetedVsActual => 'Budgeted vs actual';

  @override
  String get analysisLegendBudgeted => 'Budgeted';

  @override
  String get analysisLegendActual => 'Actual';

  @override
  String analysisCategorySaved(String category, String amount) {
    return '$category: You saved $amount in this category';
  }

  @override
  String analysisCategoryExceeded(String category, String amount) {
    return '$category: You went over by $amount in this category';
  }

  @override
  String get analysisTopCategoryTitle => 'Top spending category';

  @override
  String get analysisTopCategoryEmpty => 'Log expenses to see this analysis.';

  @override
  String analysisTopCategorySummary(String summary) {
    return 'You spent the most on: $summary';
  }

  @override
  String get analysisTopPlacesTitle => 'Top 3 places';

  @override
  String get analysisTopPlacesEmpty =>
      'Add descriptions to your expenses to see where you spend the most.';

  @override
  String get analysisPeakHoursTitle => 'Peak spending hours';

  @override
  String get analysisPeakHoursEmpty => 'No time data yet.';

  @override
  String analysisPeakHoursSummary(String ranges) {
    return 'Most spending between: $ranges';
  }

  @override
  String get analysisAnd => ' and ';

  @override
  String get analysisBetweenDaysTitle => 'Day-to-day comparison';

  @override
  String analysisAverageTrailing(String amount) {
    return 'Average $amount';
  }

  @override
  String get analysisNoExpensesYet => 'No expenses logged yet.';

  @override
  String get analysisDailyAverageLegend => 'Daily average';

  @override
  String get analysisPerPersonTitle => 'Spending per person';

  @override
  String get analysisNoParticipants => 'No participants loaded.';

  @override
  String get analysisUnassigned => 'Unassigned';

  @override
  String analysisTripMoneyAmount(String amount) {
    return 'Trip money: $amount';
  }

  @override
  String analysisPocketAmount(String amount) {
    return 'Personal pocket: $amount';
  }

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
  String configExchangeRatePreview(String code, String rate) {
    return '1 $code = $rate';
  }

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
      'Exclusive deals and alerts so your daily budget stays under control';

  @override
  String get subscriptionsBillingMonthly => 'Monthly';

  @override
  String get subscriptionsBillingAnnual => 'Annual (-20%)';

  @override
  String get subscriptionsPlanTouristName => 'Premium';

  @override
  String get subscriptionsPlanTouristSubtitle =>
      'For travelers who watch their budget';

  @override
  String get subscriptionsPeriodMonth => '/month';

  @override
  String get subscriptionsPeriodYear => '/year';

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
      'We accept Visa, Mastercard, American Express and Diners credit and debit cards, processed by Mercado Pago.';

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
      'By clicking \"Continue\" you\'ll enter your card details. The payment is processed by Mercado Pago.';

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

  @override
  String get dailyBudgetTodayTitle => 'Today\'s budget';

  @override
  String dailyBudgetOkMessage(String amount) {
    return 'On track: you still have $amount to spend today.';
  }

  @override
  String get dailyBudgetWarningTitle => 'Budget warning';

  @override
  String dailyBudgetWarningMessage(int pct, String amount) {
    return 'You\'ve used $pct% of today\'s budget. $amount left.';
  }

  @override
  String get dailyBudgetExceededTitle => 'Daily limit exceeded!';

  @override
  String dailyBudgetExceededMessage(String amount) {
    return 'You\'re $amount over today\'s budget; the coming days will have less available.';
  }

  @override
  String dailyBudgetSpentOf(String spent, String budget) {
    return '$spent OF $budget TODAY';
  }

  @override
  String get expenseReminderTitle => 'Did you spend anything today?';

  @override
  String get expenseReminderMessage =>
      'You haven\'t logged any expenses today for these ongoing trips. Add them before you forget so your daily budget stays accurate.';

  @override
  String get expenseReminderDismiss => 'I didn\'t spend today';

  @override
  String addExpenseNearDailyBudget(int pct, String amount) {
    return 'This expense brings that day to $pct% of its budget ($amount left).';
  }

  @override
  String addExpenseExceedsDailyBudget(String over, String budget) {
    return 'You\'re going to exceed your budget by $over (that day\'s budget: $budget).';
  }

  @override
  String get addExpenseOverBudgetDialogTitle => 'Over your daily budget';

  @override
  String addExpenseOverBudgetDialogContent(String budget, String over) {
    return 'That day\'s available budget is $budget. You\'re going to exceed your budget by $over. You can still log it.';
  }

  @override
  String get addExpenseOverBudgetConfirm => 'Log anyway';

  @override
  String subscriptionsActivePlanBanner(String date) {
    return 'You\'re Premium until $date. Buying another plan extends it from that date.';
  }

  @override
  String get subscriptionsCheckoutErrorSnackbar =>
      'Couldn\'t open the payment gateway. Please try again.';

  @override
  String get paymentResultChecking =>
      'Confirming your payment with Mercado Pago…';

  @override
  String get paymentResultApprovedTitle => 'Payment approved!';

  @override
  String paymentResultApprovedBody(String date) {
    return 'You\'re now Premium. Your subscription is active until $date.';
  }

  @override
  String get paymentResultApprovedBodyNoDate =>
      'You\'re now Premium. Your subscription is active.';

  @override
  String get paymentResultPendingTitle => 'Payment in progress';

  @override
  String get paymentResultPendingBody =>
      'Mercado Pago is still processing your payment. We\'ll activate Premium as soon as it\'s approved.';

  @override
  String get paymentResultRejectedTitle => 'Payment declined';

  @override
  String get paymentResultRejectedBody =>
      'Your payment method was declined and nothing was charged. You can try another one.';

  @override
  String get paymentResultCancelledTitle => 'Payment not completed';

  @override
  String get paymentResultCancelledBody =>
      'You left the checkout before paying. Nothing was charged.';

  @override
  String get paymentResultErrorTitle => 'We couldn\'t confirm the payment';

  @override
  String get paymentResultErrorBody =>
      'Check your connection and try again. If you already paid, it isn\'t lost: Premium activates once Mercado Pago confirms it.';

  @override
  String get paymentResultPlanMonthly => 'Monthly Premium plan';

  @override
  String get paymentResultPlanAnnual => 'Annual Premium plan';

  @override
  String paymentResultReference(int id) {
    return 'PAYMENT REFERENCE #$id';
  }

  @override
  String get paymentResultGoHome => 'Go home';

  @override
  String get paymentResultBackToPlans => 'Back to plans';

  @override
  String get paymentResultRetry => 'Check again';

  @override
  String get cardPaymentTitle => 'Pay by card';

  @override
  String cardPaymentSummary(String plan, String price) {
    return '$plan · $price';
  }

  @override
  String get cardPaymentTestModeHint =>
      'Mercado Pago test mode: no real money is charged. Use card 4013 5406 8274 6260, expiry 11/30, code 123. Holder APRO = approved, CONT = in progress, any other name = declined.';

  @override
  String get cardPaymentNumberLabel => 'Card number';

  @override
  String get cardPaymentNumberInvalid => 'Invalid card number';

  @override
  String get cardPaymentBrandUnsupported =>
      'We accept Visa, Mastercard, American Express and Diners';

  @override
  String get cardPaymentHolderLabel => 'Cardholder name';

  @override
  String get cardPaymentHolderHint => 'As shown on the card';

  @override
  String get cardPaymentHolderInvalid => 'Enter the cardholder name';

  @override
  String get cardPaymentExpiryLabel => 'Expiry';

  @override
  String get cardPaymentExpiryInvalid => 'Invalid or expired date';

  @override
  String get cardPaymentCvvLabel => 'Security code';

  @override
  String cardPaymentCvvInvalid(int digits) {
    return 'Must be $digits digits';
  }

  @override
  String get cardPaymentDocTypeLabel => 'Type';

  @override
  String get cardPaymentDocNumberLabel => 'Holder\'s ID number';

  @override
  String get cardPaymentDocInvalid => 'Invalid ID number';

  @override
  String cardPaymentPayButton(String price) {
    return 'Pay $price';
  }

  @override
  String get cardPaymentProcessing => 'Processing payment…';

  @override
  String get cardPaymentSecureNote =>
      'PAYMENT PROCESSED BY MERCADO PAGO · TRAVELGUARD DOESN\'T STORE YOUR CARD DETAILS';

  @override
  String get cardPaymentError =>
      'We couldn\'t process the payment. Check the card details and try again; nothing was charged.';

  @override
  String get appShellNavPromos => 'Deals';

  @override
  String get appShellNavPlans => 'Plans';

  @override
  String get subscriptionsBenefitPromos =>
      'Exclusive deals from nearby businesses';

  @override
  String get subscriptionsBenefitDailyAlerts =>
      'How much of today\'s budget you\'ve used, with alerts at 75%, 85% and 100%';

  @override
  String get subscriptionsBenefitOverspendWarning =>
      'A warning before logging an expense that exceeds the day\'s budget';

  @override
  String get subscriptionsBenefitReminder =>
      'Reminders: unlogged expenses, daily summary and closing, and a heads-up before each trip';

  @override
  String get premiumGateBadge => 'PREMIUM ONLY';

  @override
  String get premiumGateButton => 'See Premium plans';

  @override
  String get premiumGateCompactButton => 'Go Premium';

  @override
  String get dailyBudgetLockedTitle => 'Daily budget alerts';

  @override
  String get dailyBudgetLockedDescription =>
      'With Premium you see how much you\'ve spent today and get alerts at 75%, 85% and 100%.';

  @override
  String placeDetailsPromosLockedTitle(int count) {
    return 'Premium only ($count)';
  }

  @override
  String get placeDetailsPromosLockedDescription =>
      'This business has deals and activities for Premium members only.';

  @override
  String get promosEyebrow => 'PREMIUM ONLY';

  @override
  String get promosTitle => 'Deals';

  @override
  String get promosSubtitle =>
      'Deals businesses publish only for Premium travelers.';

  @override
  String get promosLockedTitle => 'Exclusive deals for Premium members';

  @override
  String get promosLockedDescription =>
      'Subscribe to see the deals nearby businesses publish only for Premium members.';

  @override
  String get promosLoadError =>
      'We couldn\'t load the deals. Please try again.';

  @override
  String get promosEmpty => 'There are no active deals yet. Check back soon.';

  @override
  String promosValidUntil(String date) {
    return 'UNTIL $date';
  }

  @override
  String get productFormRequiredFields =>
      'You must fill in the required fields';

  @override
  String get productFormRequiredField => 'Required field';

  @override
  String get productFormInvalidPrice => 'Enter a valid price greater than zero';

  @override
  String get productFormCategoryLabel => 'Product type';

  @override
  String get productFormDescriptionOptionalLabel => 'Description (optional)';

  @override
  String get productFormEditTitle => 'Edit product';

  @override
  String get productFormSaveButton => 'Save';

  @override
  String get productCategoryPlato => 'Dish';

  @override
  String get productCategoryPlatos => 'Dishes';

  @override
  String get productCategoryBebida => 'Drink';

  @override
  String get productCategoryBebidas => 'Drinks';

  @override
  String get productCategoryPostre => 'Dessert';

  @override
  String get productCategoryPostres => 'Desserts';

  @override
  String get productCategoryOtro => 'Other';

  @override
  String get productCategoryOtros => 'Others';

  @override
  String get businessSettingsNameTooShort =>
      'The name must be at least 3 characters long';

  @override
  String get businessSettingsPhoneInvalid =>
      'Enter a valid phone number (7 to 15 digits)';

  @override
  String get businessSettingsScheduleIncomplete =>
      'Set both opening and closing time, or leave both empty';

  @override
  String get businessSettingsScheduleSameTime =>
      'Closing time can\'t be the same as opening time';

  @override
  String get businessSettingsDescriptionLabel => 'Description';

  @override
  String get businessSettingsDescriptionHint => 'Tell travelers what you offer';

  @override
  String get businessSettingsLocationTitle => 'Location';

  @override
  String get businessSettingsLocationSubtitle =>
      'This is how travelers find you on the map. Search your address and adjust the marker if needed.';

  @override
  String get businessSettingsAddressNotFound =>
      'We couldn\'t find that address on the map. Fix it (add city or neighborhood) to save.';

  @override
  String get placeDetailsMenuTitle => 'Menu';

  @override
  String get businessSettingsHeaderTitle => 'Your business';

  @override
  String get businessSettingsHeaderAccent => 'details';

  @override
  String get createMenuHeaderTitle => 'New';

  @override
  String get createMenuHeaderAccent => 'menu';

  @override
  String get subscriptionsHeroTitle => 'Travel without';

  @override
  String get subscriptionsHeroAccent => 'blowing your budget';

  @override
  String get subscriptionsSubscribeButton => 'Subscribe';

  @override
  String get mySubscriptionTitle => 'My subscription';

  @override
  String get mySubscriptionHeroTitle => 'Your subscription';

  @override
  String get mySubscriptionStatusActive => 'Active';

  @override
  String get mySubscriptionStatusCancelled => 'Cancelled';

  @override
  String get mySubscriptionStatRenewal => 'Renewal';

  @override
  String get mySubscriptionStatEnds => 'Access until';

  @override
  String get mySubscriptionStatDaysLeft => 'Days left';

  @override
  String get mySubscriptionDetailsTitle => 'Plan details';

  @override
  String get mySubscriptionRowPlan => 'Current plan';

  @override
  String get mySubscriptionRowStatus => 'Status';

  @override
  String get mySubscriptionRowPeriod => 'Current period';

  @override
  String get mySubscriptionRowRenewalDate => 'Renewal date';

  @override
  String get mySubscriptionRowRenewalMode => 'Renewal';

  @override
  String get mySubscriptionRowNextPlan => 'Plan on renewal';

  @override
  String get mySubscriptionRowPrepaid => 'Prepaid periods';

  @override
  String mySubscriptionPeriodRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get mySubscriptionRenewalManual =>
      'Manual: you pay the next period whenever you want, no automatic charges';

  @override
  String mySubscriptionRenewalCancelled(String date) {
    return 'It won\'t renew. You have Premium until $date.';
  }

  @override
  String mySubscriptionRenewSoon(int days) {
    return 'Your Premium expires in $days days.';
  }

  @override
  String mySubscriptionRenewNow(String plan) {
    return 'Renew $plan';
  }

  @override
  String get mySubscriptionChangeTitle => 'Change plan';

  @override
  String get mySubscriptionChangeSubtitle =>
      'Switching to annual: you pay now and it starts when your paid time ends. Switching to monthly: nothing is charged, it applies on renewal.';

  @override
  String get mySubscriptionChangeCancelledHint =>
      'Reactivate your subscription to change plans.';

  @override
  String get mySubscriptionCurrentBadge => 'Your plan';

  @override
  String get mySubscriptionScheduledBadge => 'Scheduled on renewal';

  @override
  String get mySubscriptionUpgradeButton => 'Switch to annual';

  @override
  String get mySubscriptionDowngradeButton => 'Switch to monthly';

  @override
  String mySubscriptionKeepPlan(String plan) {
    return 'Keep $plan';
  }

  @override
  String get mySubscriptionUpgradeDialogTitle => 'Switch to the annual plan';

  @override
  String mySubscriptionUpgradeDialogBody(
    String price,
    String from,
    String until,
  ) {
    return 'You pay $price now. The annual plan runs from $from to $until: it starts when your paid time ends, so you don\'t lose any days.';
  }

  @override
  String get mySubscriptionUpgradeConfirm => 'Pay annual plan';

  @override
  String get mySubscriptionDowngradeDialogTitle => 'Switch to the monthly plan';

  @override
  String mySubscriptionDowngradeDialogBody(String date, String price) {
    return 'Nothing is charged now. You keep what you already paid until $date; on renewal you\'ll pay the monthly plan ($price).';
  }

  @override
  String get mySubscriptionDowngradeConfirm => 'Schedule change';

  @override
  String mySubscriptionChangeScheduledSnackbar(String plan) {
    return 'Change scheduled: on renewal you\'ll move to the $plan.';
  }

  @override
  String get mySubscriptionChangeUndoneSnackbar =>
      'Done, you keep your current plan.';

  @override
  String get mySubscriptionCancelTitle => 'Cancel subscription';

  @override
  String mySubscriptionCancelBody(String date) {
    return 'Your Premium stays active until $date and then won\'t renew. Paid time is not refunded.';
  }

  @override
  String get mySubscriptionCancelDialogTitle => 'Cancel your subscription?';

  @override
  String get mySubscriptionCancelConfirm => 'Yes, cancel';

  @override
  String get mySubscriptionCancelKeep => 'Keep Premium';

  @override
  String mySubscriptionCancelledSnackbar(String date) {
    return 'Subscription cancelled. You have Premium until $date.';
  }

  @override
  String get mySubscriptionCancelledTitle => 'Subscription cancelled';

  @override
  String get mySubscriptionReactivateButton => 'Reactivate subscription';

  @override
  String get mySubscriptionReactivatedSnackbar => 'Subscription reactivated.';

  @override
  String get mySubscriptionHistoryTitle => 'Payment history';

  @override
  String get mySubscriptionHistoryEmpty => 'No payments yet.';

  @override
  String get mySubscriptionHistoryError => 'We couldn\'t load your payments.';

  @override
  String get mySubscriptionEmptyTitle =>
      'You don\'t have an active subscription';

  @override
  String get mySubscriptionEmptySubtitle =>
      'Go Premium to see exclusive promotions and get daily budget alerts.';

  @override
  String get mySubscriptionSeePlans => 'See plans';

  @override
  String get mySubscriptionActionError =>
      'We couldn\'t update your subscription. Try again.';

  @override
  String get mySubscriptionManageButton => 'Manage my subscription';

  @override
  String get mySubscriptionGoTo => 'See my subscription';

  @override
  String get paymentStatusApproved => 'Approved';

  @override
  String get paymentStatusInProcess => 'In process';

  @override
  String get paymentStatusPending => 'Pending';

  @override
  String get paymentStatusRejected => 'Rejected';

  @override
  String get paymentStatusCancelled => 'Cancelled';

  @override
  String get paymentStatusRefunded => 'Refunded';

  @override
  String get budgetNoticeOpenTrip => 'See trip';

  @override
  String get configNotificationsToggleSubtitle =>
      'Daily budget alerts and reminders. When off, your expenses are still recorded.';

  @override
  String get budgetNoticeToday => 'today';

  @override
  String budgetNoticeOnDate(String date) {
    return 'on $date';
  }

  @override
  String budgetNoticeWarningTitle(int pct) {
    return 'You\'ve spent $pct% of your daily budget';
  }

  @override
  String budgetNoticeWarningMessage(String trip, String amount, String day) {
    return 'Careful! $trip: you have $amount left for $day.';
  }

  @override
  String budgetNoticeNearLimitTitle(String amount, String day) {
    return 'You have $amount of budget left for $day';
  }

  @override
  String budgetNoticeNearLimitMessage(String trip, int pct, String day) {
    return 'Careful! $trip: you\'re at $pct% of the budget for $day.';
  }

  @override
  String get budgetNoticeExceededTitle => 'You\'ve reached your daily limit';

  @override
  String budgetNoticeExceededMessage(
    String trip,
    int pct,
    String spent,
    String budget,
    String day,
  ) {
    return '$trip: you\'re at $pct% ($spent of $budget for $day). The next days will have less available.';
  }

  @override
  String get configBrowserNotificationsLabel => 'Browser notifications';

  @override
  String get configBrowserNotificationsSubtitle =>
      'Besides inside the app, get alerts as browser notifications (while the tab is open).';

  @override
  String get configBrowserNotificationsDenied =>
      'Your browser blocked notifications. Allow them in the site settings (lock icon next to the address).';

  @override
  String get configBrowserNotificationsUnsupported =>
      'This browser doesn\'t support notifications.';

  @override
  String get configBrowserNotificationsTestTitle => 'TravelGuard';

  @override
  String get configBrowserNotificationsTestBody =>
      'Done: this is how we\'ll alert you when today\'s budget reaches 75%, 85% and 100%.';

  @override
  String get reminderNoExpensesTitle =>
      'Did you have any expenses today you haven\'t logged?';

  @override
  String reminderNoExpensesMessage(String trip, int hours) {
    return '$trip: it\'s been over $hours hours since you logged an expense.';
  }

  @override
  String reminderNoExpensesEndOfDay(String trip) {
    return '$trip: you didn\'t log any expenses today. Add them so your budget stays accurate.';
  }

  @override
  String get reminderRegisterExpense => 'Log expense';

  @override
  String reminderDailySummaryTitle(String spent, String remaining) {
    return 'Today\'s spending: $spent. Remaining budget: $remaining';
  }

  @override
  String reminderDailySummaryMessage(String trip) {
    return '$trip · daily summary';
  }

  @override
  String reminderDayClosingTitle(
    int day,
    String budget,
    String spent,
    String saved,
  ) {
    return 'Day $day: Budget $budget | You spent $spent | Saved $saved';
  }

  @override
  String reminderDayClosingOverTitle(
    int day,
    String budget,
    String spent,
    String over,
  ) {
    return 'Day $day: Budget $budget | You spent $spent | Over $over';
  }

  @override
  String reminderDayClosingMessage(String trip, String date) {
    return '$trip · closing of $date';
  }

  @override
  String reminderUpcomingTripTitle(String destination, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Your trip to $destination starts in $_temp0';
  }

  @override
  String get reminderUpcomingTripMessage =>
      'Do you want to review your budget?';

  @override
  String get reminderReviewBudget => 'Review budget';

  @override
  String get configRemindersTitle => 'Reminders';

  @override
  String get configReminderHoursLabel =>
      'Remind me if I don\'t log expenses for';

  @override
  String configReminderHoursOption(int hours) {
    return '$hours h';
  }

  @override
  String get configReminderHoursHint =>
      'Only between 8 AM and 10 PM, during a trip.';

  @override
  String get configDailySummaryLabel => 'Daily summary at 11 PM';

  @override
  String get configDailySummarySubtitle =>
      'Today\'s spending and remaining budget.';

  @override
  String get configTripReminderLabel => 'Reminder before a trip';

  @override
  String get configTripReminderSubtitle =>
      '3 days and 1 day before, to review your budget.';

  @override
  String get configRemindersPremiumHint =>
      'Alerts and reminders are part of Premium.';

  @override
  String get mySubscriptionStatCost => 'Cost';

  @override
  String get mySubscriptionRowCost => 'Plan cost';

  @override
  String mySubscriptionCostValue(String price, String period) {
    return '$price $period';
  }

  @override
  String get mySubscriptionRowRenewalCost => 'Next renewal';

  @override
  String mySubscriptionRenewalCostValue(String date, String price) {
    return '$date · $price';
  }

  @override
  String get businessSettingsPhotoTitle => 'Cover photo';

  @override
  String get businessSettingsPhotoSubtitle =>
      'It\'s the image travelers see on your business card and details.';

  @override
  String get businessSettingsPhotoUpload => 'Upload photo';

  @override
  String get businessSettingsPhotoChange => 'Change photo';

  @override
  String get businessSettingsPhotoRemove => 'Remove';

  @override
  String get businessSettingsPhotoEmpty => 'No cover photo';

  @override
  String get businessSettingsPhotoHint =>
      'JPG, PNG or WebP · max 5 MB · landscape looks best';

  @override
  String get businessSettingsPhotoTooLarge =>
      'The image is over 5 MB. Choose a lighter one.';

  @override
  String get businessSettingsPhotoInvalidType =>
      'Unsupported format. Use a JPG, PNG or WebP image.';

  @override
  String get businessSettingsPhotoPickError =>
      'Couldn\'t open the image. Try another one.';

  @override
  String get homeComercioPhotoUploadError =>
      'Your changes weren\'t saved because the photo couldn\'t be uploaded. Try again.';

  @override
  String get comercioNavSectionLabel => 'BUSINESS';

  @override
  String get comercioPublicProfileLabel => 'YOUR PUBLIC PROFILE';

  @override
  String get comercioViewAsTourist => 'View as a tourist →';

  @override
  String get comercioSignOutShort => 'Sign out';

  @override
  String get comercioSearchHint => 'Search activities or dishes';

  @override
  String get comercioPanelEyebrow => 'BUSINESS DASHBOARD';

  @override
  String get comercioGreetingPrefix => 'Hello, ';

  @override
  String get comercioYourMenuTitle => 'Your menu';

  @override
  String get comercioEditLink => 'Edit';

  @override
  String get comercioEmptyActivitiesBody =>
      'Published activities show up on the map and in tourists\' list of nearby businesses.';

  @override
  String get comercioCreateFirstActivity => 'Create the first one →';

  @override
  String get comercioEmptyMenuShort => 'No dishes yet.';

  @override
  String get comercioRetry => 'Retry';

  @override
  String get comercioStatusPublished => 'Published';

  @override
  String get comercioStatusDraft => 'Draft';

  @override
  String get comercioStatusPaused => 'Paused';

  @override
  String get comercioFilterAll => 'All';

  @override
  String get comercioDatesNone => 'No date';

  @override
  String comercioDatesFrom(String date) {
    return 'From $date';
  }

  @override
  String get comercioFree => 'Free';

  @override
  String comercioActivitiesTotal(int count) {
    return '$count IN TOTAL';
  }

  @override
  String get comercioActivitiesTitle1 => 'My ';

  @override
  String get comercioActivitiesTitle2 => 'activities';

  @override
  String get comercioColActivity => 'ACTIVITY';

  @override
  String get comercioColCategory => 'CATEGORY';

  @override
  String get comercioColDates => 'DATES';

  @override
  String get comercioColPrice => 'PRICE';

  @override
  String get comercioColStatus => 'STATUS';

  @override
  String get comercioActivitiesEmptyFilter => 'No activities with this status.';

  @override
  String get comercioNoDescription => 'No description';

  @override
  String comercioMenuProductsCount(int count) {
    return '$count PRODUCTS';
  }

  @override
  String get comercioMenuTitle1 => 'Your ';

  @override
  String get comercioMenuTitle2 => 'menu';

  @override
  String get comercioMenuSubtitle =>
      'Dishes, drinks and services your business offers.';

  @override
  String get comercioAddProductButton => '+ Add product';

  @override
  String get comercioAddProductShort => '+ Product';

  @override
  String get comercioMenuEmpty =>
      'Your menu is empty. Add the first dish and it will show up on your public profile.';

  @override
  String get comercioMenuDetailLink => 'View details';

  @override
  String get comercioPickMenuTitle => 'Which menu should it go in?';

  @override
  String get comercioNewActivityEyebrow => 'NEW ACTIVITY';

  @override
  String get comercioPreviewTitle1 => 'How tourists';

  @override
  String get comercioPreviewTitle2 => 'will see it';

  @override
  String get comercioPreviewDescPlaceholder =>
      'The description will show up here.';

  @override
  String get comercioStatusNotePublished => 'Visible on the map once saved';

  @override
  String get comercioStatusNotePaused => 'Hidden from tourists';

  @override
  String get comercioStatusNoteDraft =>
      'Only you can see it while it\'s a draft';

  @override
  String get comercioNoEndToggle => 'No end';

  @override
  String get comercioEndShort => 'End';

  @override
  String get comercioPickDate => 'Pick a date';

  @override
  String get comercioSubmitPublish => 'Publish activity';

  @override
  String get comercioSubmitPaused => 'Save as paused';

  @override
  String get comercioSubmitDraft => 'Save draft';

  @override
  String get comercioNewMenuEyebrow => 'NEW MENU';

  @override
  String get comercioMenuPreviewTitle1 => 'How tourists';

  @override
  String get comercioMenuPreviewEmpty => 'Products will show up here.';

  @override
  String comercioSearchNoResults(String query) {
    return 'Nothing matches “$query”.';
  }

  @override
  String get valRequired => 'This field is required';

  @override
  String valTooShort(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String valTooLong(int max) {
    return 'Maximum $max characters';
  }

  @override
  String get valPersonName => 'Only letters and spaces are allowed';

  @override
  String get valNeedsLetter => 'Must contain at least one letter';

  @override
  String get valInvalidChars => 'Symbols like < > [ ] or \\ are not allowed';

  @override
  String get valEmail => 'Enter a valid email (e.g. name@mail.com)';

  @override
  String get valPhone => 'Enter a valid phone: numbers only, 7 to 15 digits';

  @override
  String get valPasswordMin => 'Password must be at least 8 characters';

  @override
  String get valPasswordHelper => 'At least 8 characters';

  @override
  String get valAmountPositive => 'Enter an amount greater than 0';

  @override
  String valAmountMax(String max) {
    return 'The amount can\'t exceed $max';
  }

  @override
  String valIntRange(int min, int max) {
    return 'Must be a number between $min and $max';
  }

  @override
  String get valEndBeforeStart =>
      'The end date can\'t be before the start date';

  @override
  String get valDuplicateProduct =>
      'There\'s already a product with that name in this menu';

  @override
  String get valCardHolder =>
      'Write the name as it appears on the card (letters only)';

  @override
  String get valScheduleBoth => 'Set both opening and closing time, or neither';

  @override
  String get valDocLength => 'The ID must have 5 to 12 digits';

  @override
  String get valInviteEmailRequired => 'Enter the person\'s email';

  @override
  String get valOverBudgetTitle => 'The plan exceeds the budget';

  @override
  String valOverBudgetContent(String amount) {
    return 'What you planned exceeds your maximum budget by $amount. Save anyway?';
  }

  @override
  String get valOverBudgetConfirm => 'Save anyway';

  @override
  String get valOverBudgetCancel => 'Review';

  @override
  String get valAdvanceOverBudget =>
      'Advance payments can\'t exceed the maximum budget';

  @override
  String get valPersonsRange => 'People must be between 1 and 50';

  @override
  String get valLoadTripsError =>
      'We couldn\'t load your trips. Check your connection.';

  @override
  String get valLoadPlacesError => 'We couldn\'t load nearby places.';

  @override
  String get valLoadGastosError =>
      'We couldn\'t load your expenses: bars show only what\'s planned.';

  @override
  String get valLoadMapError => 'We couldn\'t load the map places.';

  @override
  String get valNitFormat =>
      'Invalid tax ID: numbers only (5 to 15 digits), optionally -check digit';

  @override
  String get valCommerceAddress => 'Enter a valid address';

  @override
  String get placeDetailsDirectionsSoon => 'Coming soon';

  @override
  String createTripAutoMealsRow(String meals) {
    return 'Meals not included ($meals)';
  }

  @override
  String get createTripAutoTransfersRow => 'Transfers';

  @override
  String get createTripServicesHint =>
      'Mark what your lodging already covers: you don\'t need to budget for it. Whatever isn\'t included is added to the expenses in the last step so you can set an amount.';

  @override
  String get createTripEstimatedHint =>
      'Lodging + advance payments + additional expenses + emergencies';

  @override
  String createTripCoveredByLodging(String services) {
    return 'Covered by lodging: $services';
  }

  @override
  String get createTripIncompleteFieldsIntro => 'These fields are missing:';

  @override
  String get createTripIncompleteFieldsOutro =>
      'You can create the trip like this, but the budget will be less accurate. If one doesn\'t apply, enter 0.';

  @override
  String get createTripIncompleteFillButton => 'Fill them in';

  @override
  String tripDetailPaceRemaining(String amount) {
    return 'You have $amount of budget left, after what\'s planned and already spent. To stay within it, you can spend:';
  }

  @override
  String get tripDetailPacePerDayGroup => 'Per day, whole group';

  @override
  String get tripDetailPacePerDaySolo => 'Per day';

  @override
  String get tripDetailPacePerPersonDay => 'Per person, per day';

  @override
  String get tripDetailPaceNoBudgetLeft =>
      'What\'s planned and spent already covers the whole budget: there\'s no room for new expenses.';

  @override
  String get tripDetailPacePlanned => 'Planned when creating the trip';

  @override
  String get tripDetailPaceRegistered => 'Recorded expenses';

  @override
  String tripDetailPacePerPerson(int persons) {
    return 'Total per person ($persons people)';
  }

  @override
  String get appShellNavActivities => 'Activities';

  @override
  String activitiesEyebrow(int count) {
    return '$count THINGS TO DO';
  }

  @override
  String get activitiesTitle1 => 'Activities ';

  @override
  String get activitiesTitle2 => 'near you';

  @override
  String get activitiesSubtitle =>
      'Events, tours, classes and plans published by TravelGuard businesses.';

  @override
  String get activitiesAllFilter => 'All';

  @override
  String get activitiesEmpty => 'No activities published yet. Check back soon.';

  @override
  String get activitiesEmptyFilter => 'No activities in this category.';

  @override
  String get activitiesLoadError => 'We couldn\'t load the activities.';

  @override
  String get activitiesPromoBanner =>
      'Looking for deals? Exclusive promotions are in Promotions.';

  @override
  String get activitiesPromoLink => 'See promotions →';

  @override
  String get activitiesViewBusiness => 'View business →';

  @override
  String get activitiesBusinessUnavailable =>
      'This business\'s page isn\'t available yet.';

  @override
  String get homeClientViewActivitiesButton => 'See activities →';

  @override
  String get configDemoTitle => 'Test notifications';

  @override
  String get configDemoSubtitle =>
      'Shows each notice instantly with your latest trip, without waiting for it to really happen. No data is changed.';

  @override
  String get configDemoNoTrip => 'Create a trip first to test notifications.';

  @override
  String get configDemoWarning => 'Budget at 75%';

  @override
  String get configDemoNearLimit => 'Budget at 85%';

  @override
  String get configDemoExceeded => 'Budget exceeded';

  @override
  String get configDemoNoExpenses => 'No expenses recorded';

  @override
  String get configDemoSummary => 'Daily summary';

  @override
  String get configDemoClosing => 'Day closing';

  @override
  String get configDemoUpcoming => 'Upcoming trip';

  @override
  String get comercioNavPromos => 'Promotions';

  @override
  String get comercioCreatePromoTitle => 'Create promotion';

  @override
  String get comercioCreatePromoDescription =>
      'Exclusive deals and discounts for TravelGuard Premium tourists.';

  @override
  String get comercioCreatePromoButton => '+ Promotion';

  @override
  String comercioPromosTotal(int count) {
    return '$count PROMOTIONS';
  }

  @override
  String get comercioPromosTitle1 => 'My ';

  @override
  String get comercioPromosTitle2 => 'promotions';

  @override
  String get comercioPromosSubtitle =>
      'Only tourists with TravelGuard Premium see them, in their Promotions section and on your business page.';

  @override
  String get comercioPromosEmptyFilter => 'No promotions with this status.';

  @override
  String get comercioNewPromoEyebrow => 'NEW PROMOTION';

  @override
  String get comercioNewPromoHeading => 'New promotion';

  @override
  String get comercioNewPromoSubtitle =>
      'An exclusive offer for Premium tourists: a discount, combo or special perk.';

  @override
  String get comercioPromoPreviewTitle2 => 'Premium tourists';

  @override
  String get comercioPromoNameLabel => 'Promotion name';

  @override
  String get comercioPromoNameHint => 'E.g. 2-for-1 lunches';

  @override
  String get comercioSubmitPublishPromo => 'Publish promotion';

  @override
  String get comercioAudienceLabel => 'Who can see it?';

  @override
  String get comercioAudiencePublic => 'Everyone';

  @override
  String get comercioAudiencePremium => 'Premium only';

  @override
  String get comercioAudiencePremiumNote =>
      'Only Premium tourists will see it; everyone else sees it locked.';

  @override
  String get comercioPromoAudienceNote =>
      'Promotions are always exclusive to Premium tourists.';

  @override
  String get comercioPremiumBadge => 'PREMIUM';

  @override
  String comercioPromoCreatedSnackbar(String name) {
    return 'Promotion \"$name\" created';
  }

  @override
  String get activitiesPremiumLocked => 'Premium exclusive';

  @override
  String get activitiesPremiumLockedHint => 'Go Premium to see the details →';

  @override
  String get commonFixMarkedFields => 'Check the fields marked in red';

  @override
  String get comercioEditActivityHeading => 'Edit activity';

  @override
  String get comercioEditPromoHeading => 'Edit promotion';

  @override
  String get comercioEditEyebrow => 'EDITING';

  @override
  String get comercioEditSubtitle =>
      'Change whatever you need, including the status: draft, published or paused.';

  @override
  String comercioActivityUpdatedSnackbar(String name) {
    return '\"$name\" updated';
  }

  @override
  String get comercioEditSaveError => 'Couldn\'t save the changes, try again';

  @override
  String get comercioEditTooltip => 'Edit';

  @override
  String get comercioEditNotFound => 'That activity wasn\'t found';

  @override
  String get comercioDeleteButton => 'Delete';

  @override
  String comercioDeleteConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get comercioDeleteConfirmBody =>
      'It is deleted for good and tourists will stop seeing it. This can\'t be undone.';

  @override
  String comercioDeletedSnackbar(String name) {
    return '\"$name\" deleted';
  }

  @override
  String get comercioDeleteError => 'Couldn\'t delete it, try again';

  @override
  String get receiptScanTooltip => 'Scan receipt';

  @override
  String get receiptScanButton => 'Scan receipt';

  @override
  String get receiptPreviewTitle => 'Check the photo';

  @override
  String get receiptPreviewHint =>
      'Make sure the business name, date and total are readable.';

  @override
  String get receiptRetakeButton => 'Retake';

  @override
  String get receiptConfirmButton => 'Confirm';

  @override
  String get receiptAnalyzing => 'Analyzing receipt...';

  @override
  String get receiptReadError =>
      'We couldn\'t read the receipt. Try taking a clearer photo.';

  @override
  String get receiptCameraError => 'The camera couldn\'t be opened.';

  @override
  String get receiptFilledNotice =>
      'We filled in what we read from the receipt. Check the details before saving.';

  @override
  String receiptDateOutOfTrip(String date) {
    return 'The receipt date ($date) is outside the trip dates; pick the expense date.';
  }

  @override
  String get tripFinishedReadOnlyNotice =>
      'This trip has ended: expenses can\'t be added and the budget can\'t be edited.';

  @override
  String get tripFinishedBadge => 'Trip ended';

  @override
  String get homeClientNoOpenTripsSnackbar =>
      'You have no active or upcoming trips. Trips that have ended don\'t accept new expenses.';

  @override
  String get floatingNavBarAddExpenseSemanticLabel => 'Add expense';
}
