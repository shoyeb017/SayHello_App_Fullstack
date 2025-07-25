import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

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
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'SayHello'**
  String get appTitle;

  /// Subtitle about practicing languages
  ///
  /// In en, this message translates to:
  /// **'Practice 5+ languages'**
  String get practiceLanguages;

  /// Subtitle about meeting friends
  ///
  /// In en, this message translates to:
  /// **'Meet 50 million global friends'**
  String get meetFriends;

  /// Button text for learner login
  ///
  /// In en, this message translates to:
  /// **'I am a Learner'**
  String get iAmLearner;

  /// Button text for instructor login
  ///
  /// In en, this message translates to:
  /// **'I am an Instructor'**
  String get iAmInstructor;

  /// Terms of service link text
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Privacy policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Agreement text before terms and privacy policy links
  ///
  /// In en, this message translates to:
  /// **'Your first login creates your account, and in doing so you agree to our'**
  String get agreementText;

  /// Conjunction word
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// Hello greeting
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Language selector label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selector popup title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Learner sign in page title
  ///
  /// In en, this message translates to:
  /// **'Learner Sign In'**
  String get learnerSignIn;

  /// Instructor sign in page title
  ///
  /// In en, this message translates to:
  /// **'Instructor Sign In'**
  String get instructorSignIn;

  /// Welcome message on sign in page
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Sign in page subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue learning.'**
  String get signInToContinue;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Learner sign up page title
  ///
  /// In en, this message translates to:
  /// **'Learner Sign Up'**
  String get learnerSignUp;

  /// Instructor sign up page title
  ///
  /// In en, this message translates to:
  /// **'Instructor Sign Up'**
  String get instructorSignUp;

  /// Create account header text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Sign up page subtitle
  ///
  /// In en, this message translates to:
  /// **'Join our learning community.'**
  String get joinCommunity;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Link text to sign in page
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Welcome message for instructor
  ///
  /// In en, this message translates to:
  /// **'Welcome Instructor'**
  String get welcomeInstructor;

  /// Subtitle for instructor sign in
  ///
  /// In en, this message translates to:
  /// **'Please sign in to manage your courses.'**
  String get signInToManageCourses;

  /// Sign up page header
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Native language dropdown label
  ///
  /// In en, this message translates to:
  /// **'Native Language'**
  String get nativeLanguage;

  /// Learning language dropdown label
  ///
  /// In en, this message translates to:
  /// **'Learning Language'**
  String get learningLanguage;

  /// Gender dropdown label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Bio field label
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// Bangla language option
  ///
  /// In en, this message translates to:
  /// **'Bangla'**
  String get bangla;

  /// Korean language option
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// Profile photo section title
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// Instruction to add profile photo
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'SayHello'**
  String get home;

  /// Connect tab label
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Feed tab label
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// Learn tab label
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Settings menu label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Step 1 title for personal information (short)
  ///
  /// In en, this message translates to:
  /// **'Step 1: Personal Info'**
  String get step1PersonalInfo;

  /// Step 2 title for language and bio
  ///
  /// In en, this message translates to:
  /// **'Step 2: Language & Bio'**
  String get step2LanguageBio;

  /// Step 3 title for additional information
  ///
  /// In en, this message translates to:
  /// **'Step 3: Additional Info'**
  String get step3AdditionalInfo;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Date of birth field label
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// Choose date of birth button text
  ///
  /// In en, this message translates to:
  /// **'Choose DOB'**
  String get chooseDOB;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Teaching language dropdown label
  ///
  /// In en, this message translates to:
  /// **'Teaching Language'**
  String get teachingLanguage;

  /// Optional bio field label
  ///
  /// In en, this message translates to:
  /// **'Bio (Optional)'**
  String get bioOptional;

  /// Success message for instructor registration
  ///
  /// In en, this message translates to:
  /// **'Instructor Registered Successfully!'**
  String get instructorRegisteredSuccessfully;

  /// Success message for learner registration
  ///
  /// In en, this message translates to:
  /// **'Learner Registered Successfully!'**
  String get learnerRegisteredSuccessfully;

  /// Skill level label
  ///
  /// In en, this message translates to:
  /// **'Skill Level'**
  String get skillLevel;

  /// Beginner skill level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// Basic skill level
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// Intermediate skill level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// Advanced settings
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Fluent skill level
  ///
  /// In en, this message translates to:
  /// **'Fluent'**
  String get fluent;

  /// Select interests label
  ///
  /// In en, this message translates to:
  /// **'Select Interests'**
  String get selectInterests;

  /// Music interest
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// Travel interest
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// Books interest
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// Gaming interest
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get gaming;

  /// Cooking interest
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking;

  /// Movies interest
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// Photography interest
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get photography;

  /// Fitness interest
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// Art interest
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get art;

  /// Others option
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// Bangladesh country option
  ///
  /// In en, this message translates to:
  /// **'Bangladesh'**
  String get bangladesh;

  /// USA country option
  ///
  /// In en, this message translates to:
  /// **'USA'**
  String get usa;

  /// UK country option
  ///
  /// In en, this message translates to:
  /// **'UK'**
  String get uk;

  /// India country option
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get india;

  /// Japan country option
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get japan;

  /// Korea country option
  ///
  /// In en, this message translates to:
  /// **'Korea'**
  String get korea;

  /// Saudi Arabia country option
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get saudiArabia;

  /// Step 2 title for language information
  ///
  /// In en, this message translates to:
  /// **'Step 2: Language Info'**
  String get step2LanguageInfo;

  /// Native language dropdown label (short)
  ///
  /// In en, this message translates to:
  /// **'Native Language'**
  String get nativeLanguageShort;

  /// Learning language dropdown label (short)
  ///
  /// In en, this message translates to:
  /// **'Learning Language'**
  String get learningLanguageShort;

  /// All courses label
  ///
  /// In en, this message translates to:
  /// **'All Courses'**
  String get allCourses;

  /// Play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Translate button
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// Japanese AI label
  ///
  /// In en, this message translates to:
  /// **'Japanese AI'**
  String get japaneseAi;

  /// More options
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// How are you greeting
  ///
  /// In en, this message translates to:
  /// **'Hello, how are you?'**
  String get howAreYou;

  /// New user greeting
  ///
  /// In en, this message translates to:
  /// **'Hi, I am new here!'**
  String get hiNewHere;

  /// Waved interaction message
  ///
  /// In en, this message translates to:
  /// **'You waved at'**
  String get youWavedAt;

  /// Search button/label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search people title
  ///
  /// In en, this message translates to:
  /// **'Search People'**
  String get searchPeople;

  /// Courses label
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get courses;

  /// Chat label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Online status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Typing indicator
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// Send message placeholder
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No messages placeholder
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// Loading indicator
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Failed message
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Open button
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// View button
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Update label
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Copy button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Paste button
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// Cut button
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// Select all button
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Apply button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Receive button
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// Upload button
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// Download button
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Import button
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importData;

  /// Export button
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportData;

  /// Print button
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// Preview button
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Complete button
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Start button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Stop button
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Resume button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Mute button
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// Unmute button
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// Volume control
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// Brightness control
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// Notifications label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Privacy label
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Security label
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Account label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// General settings
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Help section
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Support section
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Feedback section
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Contact section
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Changelog label
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// License label
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// Legal section
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// Terms label
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// Disclaimer label
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// Acknowledgments section
  ///
  /// In en, this message translates to:
  /// **'Acknowledgments'**
  String get acknowledgments;
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
      <String>['bn', 'en', 'es', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
