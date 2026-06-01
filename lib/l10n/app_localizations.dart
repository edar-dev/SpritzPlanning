import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('it'),
  ];

  /// No description provided for @appName.
  ///
  /// In it, this message translates to:
  /// **'SpritzPlanning'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In it, this message translates to:
  /// **'Stima le user story al bancone'**
  String get tagline;

  /// No description provided for @installPwa.
  ///
  /// In it, this message translates to:
  /// **'Installa SpritzPlanning sulla home'**
  String get installPwa;

  /// No description provided for @installPwaAction.
  ///
  /// In it, this message translates to:
  /// **'Installa'**
  String get installPwaAction;

  /// No description provided for @rateLimitError.
  ///
  /// In it, this message translates to:
  /// **'Troppe richieste. Attendi un momento e riprova.'**
  String get rateLimitError;

  /// No description provided for @voteCardSemantics.
  ///
  /// In it, this message translates to:
  /// **'Vota {value}'**
  String voteCardSemantics(String value);

  /// No description provided for @projectorMode.
  ///
  /// In it, this message translates to:
  /// **'Modalità sala / proiettore'**
  String get projectorMode;

  /// No description provided for @projectorModeHint.
  ///
  /// In it, this message translates to:
  /// **'Testo e card più grandi per proiettore o TV'**
  String get projectorModeHint;

  /// No description provided for @appSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get appSettings;

  /// No description provided for @nicknameLabel.
  ///
  /// In it, this message translates to:
  /// **'Il tuo nome al bancone'**
  String get nicknameLabel;

  /// No description provided for @nicknameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Marco'**
  String get nicknameHint;

  /// No description provided for @openLocale.
  ///
  /// In it, this message translates to:
  /// **'Apri un locale'**
  String get openLocale;

  /// No description provided for @enterBancone.
  ///
  /// In it, this message translates to:
  /// **'Entra al bancone'**
  String get enterBancone;

  /// No description provided for @localeNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome del locale'**
  String get localeNameLabel;

  /// No description provided for @localeNameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Bar del Team Alpha'**
  String get localeNameHint;

  /// No description provided for @roomCodeLabel.
  ///
  /// In it, this message translates to:
  /// **'Codice bancone'**
  String get roomCodeLabel;

  /// No description provided for @roomCodeHint.
  ///
  /// In it, this message translates to:
  /// **'Es. SPRT-A3K9'**
  String get roomCodeHint;

  /// No description provided for @languageLabel.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get languageLabel;

  /// No description provided for @themeLight.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @back.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get back;

  /// No description provided for @createRoomSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Crea una stanza per il tuo team'**
  String get createRoomSubtitle;

  /// No description provided for @joinRoomSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Unisciti con il codice bancone'**
  String get joinRoomSubtitle;

  /// No description provided for @codiceBancone.
  ///
  /// In it, this message translates to:
  /// **'Codice bancone'**
  String get codiceBancone;

  /// No description provided for @copyCode.
  ///
  /// In it, this message translates to:
  /// **'Copia codice'**
  String get copyCode;

  /// No description provided for @shareCode.
  ///
  /// In it, this message translates to:
  /// **'Condividi invito'**
  String get shareCode;

  /// No description provided for @shareMessage.
  ///
  /// In it, this message translates to:
  /// **'Entra al mio locale SpritzPlanning! Codice:'**
  String get shareMessage;

  /// No description provided for @showQr.
  ///
  /// In it, this message translates to:
  /// **'Mostra QR'**
  String get showQr;

  /// No description provided for @qrBanconeTitle.
  ///
  /// In it, this message translates to:
  /// **'QR bancone'**
  String get qrBanconeTitle;

  /// No description provided for @qrBanconeHint.
  ///
  /// In it, this message translates to:
  /// **'Inquadra per entrare al locale'**
  String get qrBanconeHint;

  /// No description provided for @clienti.
  ///
  /// In it, this message translates to:
  /// **'Clienti al bancone'**
  String get clienti;

  /// No description provided for @barman.
  ///
  /// In it, this message translates to:
  /// **'Barman'**
  String get barman;

  /// No description provided for @passaBancone.
  ///
  /// In it, this message translates to:
  /// **'Passa il bancone'**
  String get passaBancone;

  /// No description provided for @confermaPassaBancone.
  ///
  /// In it, this message translates to:
  /// **'Passa il ruolo di Barman a {nickname}?'**
  String confermaPassaBancone(String nickname);

  /// No description provided for @menu.
  ///
  /// In it, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @menuSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Ordini da stimare con il team'**
  String get menuSubtitle;

  /// No description provided for @menuEmpty.
  ///
  /// In it, this message translates to:
  /// **'Il menu è vuoto. Aggiungi il primo ordine!'**
  String get menuEmpty;

  /// No description provided for @addOrdine.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi ordine'**
  String get addOrdine;

  /// No description provided for @ordineTitle.
  ///
  /// In it, this message translates to:
  /// **'Titolo ordine'**
  String get ordineTitle;

  /// No description provided for @ordineDescription.
  ///
  /// In it, this message translates to:
  /// **'Descrizione (opzionale)'**
  String get ordineDescription;

  /// No description provided for @startVoting.
  ///
  /// In it, this message translates to:
  /// **'Servi l\'ordine'**
  String get startVoting;

  /// No description provided for @waitingAperitivo.
  ///
  /// In it, this message translates to:
  /// **'In attesa dell\'aperitivo...'**
  String get waitingAperitivo;

  /// No description provided for @modificaOrdine.
  ///
  /// In it, this message translates to:
  /// **'Modifica ordine'**
  String get modificaOrdine;

  /// No description provided for @salvaOrdine.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get salvaOrdine;

  /// No description provided for @modificaOrdineHint.
  ///
  /// In it, this message translates to:
  /// **'Trascina per riordinare il menu'**
  String get modificaOrdineHint;

  /// No description provided for @chooseDose.
  ///
  /// In it, this message translates to:
  /// **'Scegli la dose'**
  String get chooseDose;

  /// No description provided for @yourVote.
  ///
  /// In it, this message translates to:
  /// **'La tua dose'**
  String get yourVote;

  /// No description provided for @voteSubmitted.
  ///
  /// In it, this message translates to:
  /// **'Dose scelta! In attesa degli altri...'**
  String get voteSubmitted;

  /// No description provided for @allVoted.
  ///
  /// In it, this message translates to:
  /// **'Tutti hanno scelto!'**
  String get allVoted;

  /// No description provided for @servizio.
  ///
  /// In it, this message translates to:
  /// **'Servizio!'**
  String get servizio;

  /// No description provided for @resetRound.
  ///
  /// In it, this message translates to:
  /// **'Nuovo giro'**
  String get resetRound;

  /// No description provided for @confirmEstimate.
  ///
  /// In it, this message translates to:
  /// **'Conferma stima'**
  String get confirmEstimate;

  /// No description provided for @nextOrdine.
  ///
  /// In it, this message translates to:
  /// **'Prossimo ordine'**
  String get nextOrdine;

  /// No description provided for @finalEstimateLabel.
  ///
  /// In it, this message translates to:
  /// **'Stima finale'**
  String get finalEstimateLabel;

  /// No description provided for @votesRevealed.
  ///
  /// In it, this message translates to:
  /// **'Ecco le dosi!'**
  String get votesRevealed;

  /// No description provided for @noActiveStory.
  ///
  /// In it, this message translates to:
  /// **'Nessun ordine in votazione'**
  String get noActiveStory;

  /// No description provided for @currentStoryLabel.
  ///
  /// In it, this message translates to:
  /// **'Ordine corrente'**
  String get currentStoryLabel;

  /// No description provided for @chooseDoseSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Seleziona la dose per questo ordine'**
  String get chooseDoseSubtitle;

  /// No description provided for @consensoSuggerito.
  ///
  /// In it, this message translates to:
  /// **'Consenso suggerito'**
  String get consensoSuggerito;

  /// No description provided for @distribuzioneVoti.
  ///
  /// In it, this message translates to:
  /// **'Distribuzione voti'**
  String get distribuzioneVoti;

  /// No description provided for @dosiScelte.
  ///
  /// In it, this message translates to:
  /// **'dosi scelte'**
  String get dosiScelte;

  /// No description provided for @outlier.
  ///
  /// In it, this message translates to:
  /// **'Fuori scala'**
  String get outlier;

  /// No description provided for @timerScaduto.
  ///
  /// In it, this message translates to:
  /// **'Tempo scaduto — pronti per il servizio?'**
  String get timerScaduto;

  /// No description provided for @timerLabel.
  ///
  /// In it, this message translates to:
  /// **'Tempo rimasto'**
  String get timerLabel;

  /// No description provided for @timerNone.
  ///
  /// In it, this message translates to:
  /// **'Senza timer'**
  String get timerNone;

  /// No description provided for @timer2Min.
  ///
  /// In it, this message translates to:
  /// **'2 min'**
  String get timer2Min;

  /// No description provided for @timer5Min.
  ///
  /// In it, this message translates to:
  /// **'5 min'**
  String get timer5Min;

  /// No description provided for @timer10Min.
  ///
  /// In it, this message translates to:
  /// **'10 min'**
  String get timer10Min;

  /// No description provided for @scegliTimer.
  ///
  /// In it, this message translates to:
  /// **'Durata votazione'**
  String get scegliTimer;

  /// No description provided for @assente.
  ///
  /// In it, this message translates to:
  /// **'Assente'**
  String get assente;

  /// No description provided for @rimuoviDalBancone.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dal bancone'**
  String get rimuoviDalBancone;

  /// No description provided for @confermaRimuovi.
  ///
  /// In it, this message translates to:
  /// **'Rimuovere {nickname} dal bancone?'**
  String confermaRimuovi(String nickname);

  /// No description provided for @azioniCliente.
  ///
  /// In it, this message translates to:
  /// **'Azioni cliente'**
  String get azioniCliente;

  /// No description provided for @riepilogoSerata.
  ///
  /// In it, this message translates to:
  /// **'Riepilogo serata'**
  String get riepilogoSerata;

  /// No description provided for @exportCsv.
  ///
  /// In it, this message translates to:
  /// **'Esporta CSV'**
  String get exportCsv;

  /// No description provided for @exportMarkdown.
  ///
  /// In it, this message translates to:
  /// **'Condividi Markdown'**
  String get exportMarkdown;

  /// No description provided for @copiaReport.
  ///
  /// In it, this message translates to:
  /// **'Copia report'**
  String get copiaReport;

  /// No description provided for @reportEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna stima ancora confermata'**
  String get reportEmpty;

  /// No description provided for @reportCopied.
  ///
  /// In it, this message translates to:
  /// **'Report copiato negli appunti'**
  String get reportCopied;

  /// No description provided for @nicknameTooShort.
  ///
  /// In it, this message translates to:
  /// **'Il nickname deve avere almeno 2 caratteri'**
  String get nicknameTooShort;

  /// No description provided for @localeNameTooShort.
  ///
  /// In it, this message translates to:
  /// **'Il nome del locale deve avere almeno 2 caratteri'**
  String get localeNameTooShort;

  /// No description provided for @roomCodeRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il codice bancone'**
  String get roomCodeRequired;

  /// No description provided for @connectionLost.
  ///
  /// In it, this message translates to:
  /// **'Connessione persa al bancone'**
  String get connectionLost;

  /// No description provided for @genericError.
  ///
  /// In it, this message translates to:
  /// **'Qualcosa è andato storto al bancone'**
  String get genericError;

  /// No description provided for @leaveLocale.
  ///
  /// In it, this message translates to:
  /// **'Lascia il locale'**
  String get leaveLocale;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get add;

  /// No description provided for @deckSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni deck'**
  String get deckSettings;

  /// No description provided for @deckPresetFibonacci.
  ///
  /// In it, this message translates to:
  /// **'Fibonacci (default)'**
  String get deckPresetFibonacci;

  /// No description provided for @deckPresetNumbers.
  ///
  /// In it, this message translates to:
  /// **'Solo numeri'**
  String get deckPresetNumbers;

  /// No description provided for @deckPresetTshirt.
  ///
  /// In it, this message translates to:
  /// **'T-shirt'**
  String get deckPresetTshirt;

  /// No description provided for @deckAllowCoffee.
  ///
  /// In it, this message translates to:
  /// **'Consenti pausa caffè'**
  String get deckAllowCoffee;

  /// No description provided for @deckLabelZero.
  ///
  /// In it, this message translates to:
  /// **'Acqua'**
  String get deckLabelZero;

  /// No description provided for @deckLabelHalf.
  ///
  /// In it, this message translates to:
  /// **'Mezzo'**
  String get deckLabelHalf;

  /// No description provided for @deckLabelUnsure.
  ///
  /// In it, this message translates to:
  /// **'Non ho sete'**
  String get deckLabelUnsure;

  /// No description provided for @deckLabelCoffee.
  ///
  /// In it, this message translates to:
  /// **'Pausa caffè'**
  String get deckLabelCoffee;

  /// No description provided for @deckLabelSpritz.
  ///
  /// In it, this message translates to:
  /// **'Spritz {value}'**
  String deckLabelSpritz(String value);

  /// No description provided for @pointsSuffix.
  ///
  /// In it, this message translates to:
  /// **'{estimate} pt'**
  String pointsSuffix(String estimate);

  /// No description provided for @reconnecting.
  ///
  /// In it, this message translates to:
  /// **'Riconnessione al bancone…'**
  String get reconnecting;

  /// No description provided for @pollingFallback.
  ///
  /// In it, this message translates to:
  /// **'Aggiornamento periodico attivo'**
  String get pollingFallback;

  /// No description provided for @codeCopied.
  ///
  /// In it, this message translates to:
  /// **'Codice copiato'**
  String get codeCopied;

  /// No description provided for @refresh.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get refresh;

  /// No description provided for @supabaseNotConfigured.
  ///
  /// In it, this message translates to:
  /// **'Supabase non configurato — usa --dart-define-from-file=env.json'**
  String get supabaseNotConfigured;

  /// No description provided for @backToHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get backToHome;

  /// No description provided for @distribuzioneVotiSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Riepilogo delle dosi scelte'**
  String get distribuzioneVotiSubtitle;

  /// No description provided for @importStories.
  ///
  /// In it, this message translates to:
  /// **'Importa ordini'**
  String get importStories;

  /// No description provided for @importPasteHint.
  ///
  /// In it, this message translates to:
  /// **'Una riga per ordine (max 50). CSV: usa solo la prima colonna.'**
  String get importPasteHint;

  /// No description provided for @importStoriesAction.
  ///
  /// In it, this message translates to:
  /// **'Importa nel menu'**
  String get importStoriesAction;

  /// No description provided for @importStoriesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Incolla almeno un titolo ordine'**
  String get importStoriesEmpty;

  /// No description provided for @importStoriesSuccess.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 ordine importato} other{{count} ordini importati}}'**
  String importStoriesSuccess(int count);

  /// No description provided for @importPreview.
  ///
  /// In it, this message translates to:
  /// **'Anteprima: {count} ordini'**
  String importPreview(int count);

  /// No description provided for @recentRooms.
  ///
  /// In it, this message translates to:
  /// **'Locali recenti'**
  String get recentRooms;

  /// No description provided for @resumeSession.
  ///
  /// In it, this message translates to:
  /// **'Riprendi sessione'**
  String get resumeSession;

  /// No description provided for @resumeSessionSubtitle.
  ///
  /// In it, this message translates to:
  /// **'{roomName} · {code}'**
  String resumeSessionSubtitle(String roomName, String code);

  /// No description provided for @backlogProgress.
  ///
  /// In it, this message translates to:
  /// **'{done} di {total} ordini stimati'**
  String backlogProgress(int done, int total);

  /// No description provided for @menuEmptyImportCta.
  ///
  /// In it, this message translates to:
  /// **'Importa una lista o aggiungi il primo ordine'**
  String get menuEmptyImportCta;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In it, this message translates to:
  /// **'Scorciatoie tastiera'**
  String get keyboardShortcuts;

  /// No description provided for @keyboardShortcutReveal.
  ///
  /// In it, this message translates to:
  /// **'R — Servizio (reveal)'**
  String get keyboardShortcutReveal;

  /// No description provided for @keyboardShortcutNext.
  ///
  /// In it, this message translates to:
  /// **'N — Prossimo ordine'**
  String get keyboardShortcutNext;

  /// No description provided for @keyboardShortcutStartVote.
  ///
  /// In it, this message translates to:
  /// **'V — Servi ordine (primo in coda)'**
  String get keyboardShortcutStartVote;

  /// No description provided for @applyConsensusAndNext.
  ///
  /// In it, this message translates to:
  /// **'Applica {value} e prossimo'**
  String applyConsensusAndNext(String value);

  /// No description provided for @confirmVoteTitle.
  ///
  /// In it, this message translates to:
  /// **'Confermi la dose {value}?'**
  String confirmVoteTitle(String value);

  /// No description provided for @exportJson.
  ///
  /// In it, this message translates to:
  /// **'Esporta JSON'**
  String get exportJson;

  /// No description provided for @joinAsObserver.
  ///
  /// In it, this message translates to:
  /// **'Solo osservazione (non voto)'**
  String get joinAsObserver;

  /// No description provided for @observerBadge.
  ///
  /// In it, this message translates to:
  /// **'Osservatore'**
  String get observerBadge;

  /// No description provided for @observerCannotVote.
  ///
  /// In it, this message translates to:
  /// **'Stai osservando: non puoi votare'**
  String get observerCannotVote;

  /// No description provided for @roomPinLabel.
  ///
  /// In it, this message translates to:
  /// **'PIN locale'**
  String get roomPinLabel;

  /// No description provided for @roomPinHint.
  ///
  /// In it, this message translates to:
  /// **'4-6 cifre'**
  String get roomPinHint;

  /// No description provided for @roomPinRequired.
  ///
  /// In it, this message translates to:
  /// **'PIN richiesto per questo locale'**
  String get roomPinRequired;

  /// No description provided for @setRoomPin.
  ///
  /// In it, this message translates to:
  /// **'Imposta PIN'**
  String get setRoomPin;

  /// No description provided for @removeRoomPin.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi PIN'**
  String get removeRoomPin;

  /// No description provided for @autoRevealTitle.
  ///
  /// In it, this message translates to:
  /// **'Reveal automatico'**
  String get autoRevealTitle;

  /// No description provided for @autoRevealSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Rivela i voti quando tutti hanno scelto'**
  String get autoRevealSubtitle;

  /// No description provided for @markAsSpike.
  ///
  /// In it, this message translates to:
  /// **'Segna come spike'**
  String get markAsSpike;

  /// No description provided for @storyKindSpike.
  ///
  /// In it, this message translates to:
  /// **'Spike'**
  String get storyKindSpike;

  /// No description provided for @duplicateRoom.
  ///
  /// In it, this message translates to:
  /// **'Nuova serata (stesso menu)'**
  String get duplicateRoom;

  /// No description provided for @duplicateRoomConfirm.
  ///
  /// In it, this message translates to:
  /// **'Si crea un nuovo codice. Il backlog viene copiato. I clienti dovranno rientrare.'**
  String get duplicateRoomConfirm;

  /// No description provided for @facilitatorNote.
  ///
  /// In it, this message translates to:
  /// **'Note barman'**
  String get facilitatorNote;

  /// No description provided for @facilitatorNoteHint.
  ///
  /// In it, this message translates to:
  /// **'Solo per te, visibili in export'**
  String get facilitatorNoteHint;

  /// No description provided for @exportJira.
  ///
  /// In it, this message translates to:
  /// **'Jira'**
  String get exportJira;

  /// No description provided for @exportAzureDevOps.
  ///
  /// In it, this message translates to:
  /// **'Azure DevOps'**
  String get exportAzureDevOps;

  /// No description provided for @reportMean.
  ///
  /// In it, this message translates to:
  /// **'Media punti'**
  String get reportMean;

  /// No description provided for @reportMedian.
  ///
  /// In it, this message translates to:
  /// **'Mediana punti'**
  String get reportMedian;

  /// No description provided for @reportCompleted.
  ///
  /// In it, this message translates to:
  /// **'Ordini completati'**
  String get reportCompleted;

  /// No description provided for @reportSpikes.
  ///
  /// In it, this message translates to:
  /// **'Spike'**
  String get reportSpikes;

  /// No description provided for @roomTemplates.
  ///
  /// In it, this message translates to:
  /// **'Template locale'**
  String get roomTemplates;

  /// No description provided for @createFromTemplate.
  ///
  /// In it, this message translates to:
  /// **'Crea da template'**
  String get createFromTemplate;

  /// No description provided for @notificationsTitle.
  ///
  /// In it, this message translates to:
  /// **'Notifiche browser'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Reveal e timer quando la scheda è in background'**
  String get notificationsSubtitle;

  /// No description provided for @notificationsReveal.
  ///
  /// In it, this message translates to:
  /// **'Voti rivelati'**
  String get notificationsReveal;

  /// No description provided for @notificationsTimer.
  ///
  /// In it, this message translates to:
  /// **'Tempo quasi scaduto'**
  String get notificationsTimer;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
