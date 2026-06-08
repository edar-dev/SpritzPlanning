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

  /// No description provided for @homeGetStarted.
  ///
  /// In it, this message translates to:
  /// **'Inizia una sessione'**
  String get homeGetStarted;

  /// No description provided for @homeMoreOptions.
  ///
  /// In it, this message translates to:
  /// **'Gestione e strumenti'**
  String get homeMoreOptions;

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

  /// No description provided for @barVoteStatusOrdered.
  ///
  /// In it, this message translates to:
  /// **'Dose scelta'**
  String get barVoteStatusOrdered;

  /// No description provided for @barVoteStatusWaiting.
  ///
  /// In it, this message translates to:
  /// **'Attende'**
  String get barVoteStatusWaiting;

  /// No description provided for @barDeckTrayTitle.
  ///
  /// In it, this message translates to:
  /// **'Carte al bancone'**
  String get barDeckTrayTitle;

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

  /// No description provided for @eliminaOrdine.
  ///
  /// In it, this message translates to:
  /// **'Elimina ordine'**
  String get eliminaOrdine;

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

  /// No description provided for @recentRoomUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Questo locale non è più disponibile ed è stato rimosso dall\'elenco.'**
  String get recentRoomUnavailable;

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

  /// No description provided for @joinAdvancedOptions.
  ///
  /// In it, this message translates to:
  /// **'Opzioni avanzate'**
  String get joinAdvancedOptions;

  /// No description provided for @roomToolsTitle.
  ///
  /// In it, this message translates to:
  /// **'Strumenti'**
  String get roomToolsTitle;

  /// No description provided for @observerBadge.
  ///
  /// In it, this message translates to:
  /// **'Osservatore'**
  String get observerBadge;

  /// No description provided for @editorBadge.
  ///
  /// In it, this message translates to:
  /// **'Editor'**
  String get editorBadge;

  /// No description provided for @viewerBadge.
  ///
  /// In it, this message translates to:
  /// **'Solo lettura'**
  String get viewerBadge;

  /// No description provided for @setParticipantRoleEditor.
  ///
  /// In it, this message translates to:
  /// **'Assegna ruolo editor'**
  String get setParticipantRoleEditor;

  /// No description provided for @setParticipantRoleViewer.
  ///
  /// In it, this message translates to:
  /// **'Assegna ruolo solo lettura'**
  String get setParticipantRoleViewer;

  /// No description provided for @participantRoleChanged.
  ///
  /// In it, this message translates to:
  /// **'Ruolo partecipante aggiornato'**
  String get participantRoleChanged;

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

  /// No description provided for @reportVariance.
  ///
  /// In it, this message translates to:
  /// **'Dispersione stime'**
  String get reportVariance;

  /// No description provided for @reportRevisionRate.
  ///
  /// In it, this message translates to:
  /// **'Revisioni stima'**
  String get reportRevisionRate;

  /// No description provided for @reportRevisionRateValue.
  ///
  /// In it, this message translates to:
  /// **'{percent}%'**
  String reportRevisionRateValue(int percent);

  /// No description provided for @reportAvgTimePerStory.
  ///
  /// In it, this message translates to:
  /// **'Tempo medio per ordine'**
  String get reportAvgTimePerStory;

  /// No description provided for @reportAvgMinutesValue.
  ///
  /// In it, this message translates to:
  /// **'{minutes} min'**
  String reportAvgMinutesValue(int minutes);

  /// No description provided for @executiveReportTitle.
  ///
  /// In it, this message translates to:
  /// **'Report executive'**
  String get executiveReportTitle;

  /// No description provided for @executiveReportOverview.
  ///
  /// In it, this message translates to:
  /// **'Panoramica sessione'**
  String get executiveReportOverview;

  /// No description provided for @executiveReportRoomLabel.
  ///
  /// In it, this message translates to:
  /// **'Locale'**
  String get executiveReportRoomLabel;

  /// No description provided for @executiveReportCodeLabel.
  ///
  /// In it, this message translates to:
  /// **'Codice'**
  String get executiveReportCodeLabel;

  /// No description provided for @executiveReportExportedAtLabel.
  ///
  /// In it, this message translates to:
  /// **'Esportato il'**
  String get executiveReportExportedAtLabel;

  /// No description provided for @executiveReportKpi.
  ///
  /// In it, this message translates to:
  /// **'KPI principali'**
  String get executiveReportKpi;

  /// No description provided for @executiveReportUncertainStories.
  ///
  /// In it, this message translates to:
  /// **'Ordini con maggiore incertezza'**
  String get executiveReportUncertainStories;

  /// No description provided for @executiveReportUncertaintyScore.
  ///
  /// In it, this message translates to:
  /// **'Indice incertezza'**
  String get executiveReportUncertaintyScore;

  /// No description provided for @executiveReportActions.
  ///
  /// In it, this message translates to:
  /// **'Decisioni e azioni suggerite'**
  String get executiveReportActions;

  /// No description provided for @executiveReportBacklog.
  ///
  /// In it, this message translates to:
  /// **'Ordine'**
  String get executiveReportBacklog;

  /// No description provided for @executiveReportEstimateColumn.
  ///
  /// In it, this message translates to:
  /// **'Stima'**
  String get executiveReportEstimateColumn;

  /// No description provided for @executiveReportNoUncertainStories.
  ///
  /// In it, this message translates to:
  /// **'Nessun ordine con segnali di incertezza rilevanti.'**
  String get executiveReportNoUncertainStories;

  /// No description provided for @executiveReportNoSuggestedActions.
  ///
  /// In it, this message translates to:
  /// **'Nessuna azione suggerita automaticamente.'**
  String get executiveReportNoSuggestedActions;

  /// No description provided for @executiveReportActionSpike.
  ///
  /// In it, this message translates to:
  /// **'Pianificare ricerca spike per «{title}»'**
  String executiveReportActionSpike(Object title);

  /// No description provided for @executiveReportActionRevised.
  ///
  /// In it, this message translates to:
  /// **'Allineare la stima di «{title}» (revisioni: {history})'**
  String executiveReportActionRevised(Object history, Object title);

  /// No description provided for @executiveReportActionReference.
  ///
  /// In it, this message translates to:
  /// **'Usare «{title}» come riferimento relativo per le prossime stime'**
  String executiveReportActionReference(Object title);

  /// No description provided for @executiveReportActionHighVariance.
  ///
  /// In it, this message translates to:
  /// **'Ridurre la dispersione delle stime: rivedere la baseline del team'**
  String get executiveReportActionHighVariance;

  /// No description provided for @executiveReportActionFacilitatorNote.
  ///
  /// In it, this message translates to:
  /// **'«{title}»: {note}'**
  String executiveReportActionFacilitatorNote(Object note, Object title);

  /// No description provided for @executiveReportActionPublicComment.
  ///
  /// In it, this message translates to:
  /// **'«{title}» — commento team: {comment}'**
  String executiveReportActionPublicComment(Object comment, Object title);

  /// No description provided for @executiveReportExport.
  ///
  /// In it, this message translates to:
  /// **'Report executive'**
  String get executiveReportExport;

  /// No description provided for @executiveReportCopyMarkdown.
  ///
  /// In it, this message translates to:
  /// **'Copia Markdown'**
  String get executiveReportCopyMarkdown;

  /// No description provided for @executiveReportCopyCsv.
  ///
  /// In it, this message translates to:
  /// **'Copia CSV business'**
  String get executiveReportCopyCsv;

  /// No description provided for @executiveReportPrint.
  ///
  /// In it, this message translates to:
  /// **'Stampa / PDF'**
  String get executiveReportPrint;

  /// No description provided for @executiveReportPrintOpened.
  ///
  /// In it, this message translates to:
  /// **'Finestra di stampa aperta'**
  String get executiveReportPrintOpened;

  /// No description provided for @executiveReportPrintUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Stampa disponibile solo su web'**
  String get executiveReportPrintUnavailable;

  /// No description provided for @executiveReportOtherExports.
  ///
  /// In it, this message translates to:
  /// **'Altri export'**
  String get executiveReportOtherExports;

  /// No description provided for @executiveReportMinutesSuffix.
  ///
  /// In it, this message translates to:
  /// **'min'**
  String get executiveReportMinutesSuffix;

  /// No description provided for @executiveReportPercentSuffix.
  ///
  /// In it, this message translates to:
  /// **'%'**
  String get executiveReportPercentSuffix;

  /// No description provided for @roomTemplates.
  ///
  /// In it, this message translates to:
  /// **'Template locale'**
  String get roomTemplates;

  /// No description provided for @businessTemplatesTitle.
  ///
  /// In it, this message translates to:
  /// **'Template business'**
  String get businessTemplatesTitle;

  /// No description provided for @customTemplatesTitle.
  ///
  /// In it, this message translates to:
  /// **'Template personalizzati'**
  String get customTemplatesTitle;

  /// No description provided for @customTemplatesEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun template personalizzato salvato'**
  String get customTemplatesEmpty;

  /// No description provided for @createCustomTemplate.
  ///
  /// In it, this message translates to:
  /// **'Crea template personalizzato'**
  String get createCustomTemplate;

  /// No description provided for @templateBusinessDiscoveryName.
  ///
  /// In it, this message translates to:
  /// **'Product Discovery'**
  String get templateBusinessDiscoveryName;

  /// No description provided for @templateBusinessDiscoveryDescription.
  ///
  /// In it, this message translates to:
  /// **'Allineamento su problemi, ipotesi e scope MVP'**
  String get templateBusinessDiscoveryDescription;

  /// No description provided for @templateBusinessRefinementName.
  ///
  /// In it, this message translates to:
  /// **'Delivery Refinement'**
  String get templateBusinessRefinementName;

  /// No description provided for @templateBusinessRefinementDescription.
  ///
  /// In it, this message translates to:
  /// **'Rifinitura backlog con dipendenze e criteri di accettazione'**
  String get templateBusinessRefinementDescription;

  /// No description provided for @templateBusinessMaintenanceName.
  ///
  /// In it, this message translates to:
  /// **'Maintenance Fast Track'**
  String get templateBusinessMaintenanceName;

  /// No description provided for @templateBusinessMaintenanceDescription.
  ///
  /// In it, this message translates to:
  /// **'Flusso rapido per incident, fix urgenti e follow-up'**
  String get templateBusinessMaintenanceDescription;

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

  /// No description provided for @helpTitle.
  ///
  /// In it, this message translates to:
  /// **'Guida SpritzPlanning'**
  String get helpTitle;

  /// No description provided for @helpIntro.
  ///
  /// In it, this message translates to:
  /// **'Planning poker a tema spritz per team agile. Nessun account: nickname e codice stanza bastano per iniziare.'**
  String get helpIntro;

  /// No description provided for @helpRolesTitle.
  ///
  /// In it, this message translates to:
  /// **'Ruoli'**
  String get helpRolesTitle;

  /// No description provided for @helpRolesBody.
  ///
  /// In it, this message translates to:
  /// **'Il barman facilita: avvia votazioni, rivela i voti, gestisce il menu ordini. I clienti votano con le carte. Gli osservatori seguono la sessione senza votare.'**
  String get helpRolesBody;

  /// No description provided for @helpFlowTitle.
  ///
  /// In it, this message translates to:
  /// **'Flusso di una serata'**
  String get helpFlowTitle;

  /// No description provided for @helpFlowBody.
  ///
  /// In it, this message translates to:
  /// **'1. Apri o entra in un locale\n2. Aggiungi ordini al menu (backlog)\n3. Avvia la votazione per ogni story\n4. Rivelate i voti e concordate la stima\n5. Esportate il report di fine serata'**
  String get helpFlowBody;

  /// No description provided for @helpFeaturesTitle.
  ///
  /// In it, this message translates to:
  /// **'Funzionalità'**
  String get helpFeaturesTitle;

  /// No description provided for @helpFeatTemplates.
  ///
  /// In it, this message translates to:
  /// **'Template locale — Home → Crea da template'**
  String get helpFeatTemplates;

  /// No description provided for @helpFeatImport.
  ///
  /// In it, this message translates to:
  /// **'Import backlog — Lobby barman → icona upload'**
  String get helpFeatImport;

  /// No description provided for @helpFeatSpike.
  ///
  /// In it, this message translates to:
  /// **'Story spike — Icona fulmine su ordine pending'**
  String get helpFeatSpike;

  /// No description provided for @helpFeatPin.
  ///
  /// In it, this message translates to:
  /// **'PIN stanza — Impostazioni deck del barman'**
  String get helpFeatPin;

  /// No description provided for @helpFeatAutoReveal.
  ///
  /// In it, this message translates to:
  /// **'Auto-reveal — Impostazioni deck, quando tutti hanno votato'**
  String get helpFeatAutoReveal;

  /// No description provided for @helpFeatDuplicate.
  ///
  /// In it, this message translates to:
  /// **'Nuova serata — Menu ⋮ in stanza (barman)'**
  String get helpFeatDuplicate;

  /// No description provided for @helpFeatReport.
  ///
  /// In it, this message translates to:
  /// **'Report Jira/ADO — Icona riepilogo in stanza'**
  String get helpFeatReport;

  /// No description provided for @helpFeatNotify.
  ///
  /// In it, this message translates to:
  /// **'Notifiche browser — Impostazioni home'**
  String get helpFeatNotify;

  /// No description provided for @helpFeatProjector.
  ///
  /// In it, this message translates to:
  /// **'Modalità proiettore — Impostazioni home'**
  String get helpFeatProjector;

  /// No description provided for @helpFeatResume.
  ///
  /// In it, this message translates to:
  /// **'Ripresa sessione — Home, se hai già giocato'**
  String get helpFeatResume;

  /// No description provided for @helpFaqTitle.
  ///
  /// In it, this message translates to:
  /// **'Domande frequenti'**
  String get helpFaqTitle;

  /// No description provided for @helpFaqNicknameTitle.
  ///
  /// In it, this message translates to:
  /// **'Nickname già presente'**
  String get helpFaqNicknameTitle;

  /// No description provided for @helpFaqNicknameBody.
  ///
  /// In it, this message translates to:
  /// **'Significa che quel nickname è attivo in stanza. Esci dal locale prima di rientrare, oppure attendi ~2 minuti se il cliente è assente.'**
  String get helpFaqNicknameBody;

  /// No description provided for @helpFaqRejoinTitle.
  ///
  /// In it, this message translates to:
  /// **'Come rientro nella stessa stanza'**
  String get helpFaqRejoinTitle;

  /// No description provided for @helpFaqRejoinBody.
  ///
  /// In it, this message translates to:
  /// **'Usa lo stesso nickname e codice. L\'app propone di riprendere la sessione se l\'hai lasciata di recente.'**
  String get helpFaqRejoinBody;

  /// No description provided for @helpFaqPinTitle.
  ///
  /// In it, this message translates to:
  /// **'PIN non accettato'**
  String get helpFaqPinTitle;

  /// No description provided for @helpFaqPinBody.
  ///
  /// In it, this message translates to:
  /// **'Chiedi il PIN al barman. Deve essere di 4–6 cifre numeriche.'**
  String get helpFaqPinBody;

  /// No description provided for @helpFaqObserverTitle.
  ///
  /// In it, this message translates to:
  /// **'Osservatore'**
  String get helpFaqObserverTitle;

  /// No description provided for @helpFaqObserverBody.
  ///
  /// In it, this message translates to:
  /// **'Spunta «Solo osservazione» in fase di join. Non potrai votare ma vedrai reveal e report.'**
  String get helpFaqObserverBody;

  /// No description provided for @helpShortcutsTitle.
  ///
  /// In it, this message translates to:
  /// **'Scorciatoie tastiera (barman, web)'**
  String get helpShortcutsTitle;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto al bancone!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In it, this message translates to:
  /// **'SpritzPlanning è planning poker veloce per il tuo team — senza registrazione.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingCreateTitle.
  ///
  /// In it, this message translates to:
  /// **'Apri un locale'**
  String get onboardingCreateTitle;

  /// No description provided for @onboardingCreateBody.
  ///
  /// In it, this message translates to:
  /// **'Crea una stanza, condividi il codice o il QR con il team e aggiungi gli ordini da stimare.'**
  String get onboardingCreateBody;

  /// No description provided for @onboardingJoinTitle.
  ///
  /// In it, this message translates to:
  /// **'Entra al bancone'**
  String get onboardingJoinTitle;

  /// No description provided for @onboardingJoinBody.
  ///
  /// In it, this message translates to:
  /// **'Hai un codice? Inserisci nickname e codice stanza. Puoi anche usare un link con ?code=.'**
  String get onboardingJoinBody;

  /// No description provided for @onboardingHelpTitle.
  ///
  /// In it, this message translates to:
  /// **'Serve aiuto?'**
  String get onboardingHelpTitle;

  /// No description provided for @onboardingHelpBody.
  ///
  /// In it, this message translates to:
  /// **'Nella guida trovi tutte le funzioni: spike, PIN, template, export e molto altro.'**
  String get onboardingHelpBody;

  /// No description provided for @onboardingSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get onboardingNext;

  /// No description provided for @onboardingDone.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get onboardingDone;

  /// No description provided for @businessOnboardingTitle.
  ///
  /// In it, this message translates to:
  /// **'Primo valore in 5 minuti'**
  String get businessOnboardingTitle;

  /// No description provided for @businessOnboardingSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Percorso guidato per PM e team strutturati'**
  String get businessOnboardingSubtitle;

  /// No description provided for @businessOnboardingProgress.
  ///
  /// In it, this message translates to:
  /// **'Passo {current} di {total}'**
  String businessOnboardingProgress(int current, int total);

  /// No description provided for @businessOnboardingStep1Title.
  ///
  /// In it, this message translates to:
  /// **'1. Apri un locale'**
  String get businessOnboardingStep1Title;

  /// No description provided for @businessOnboardingStep1Body.
  ///
  /// In it, this message translates to:
  /// **'Crea la stanza, scegli un template business (Discovery, Refinement o Fast Track) e imposta deck e regole.'**
  String get businessOnboardingStep1Body;

  /// No description provided for @businessOnboardingStep2Title.
  ///
  /// In it, this message translates to:
  /// **'2. Importa il backlog'**
  String get businessOnboardingStep2Title;

  /// No description provided for @businessOnboardingStep2Body.
  ///
  /// In it, this message translates to:
  /// **'Inserisci gli ordini con incolla rapido o import Jira/Azure DevOps dalla schermata del bancone.'**
  String get businessOnboardingStep2Body;

  /// No description provided for @businessOnboardingStep3Title.
  ///
  /// In it, this message translates to:
  /// **'3. Invita il team'**
  String get businessOnboardingStep3Title;

  /// No description provided for @businessOnboardingStep3Body.
  ///
  /// In it, this message translates to:
  /// **'Condividi codice stanza o QR: i partecipanti entrano con nickname, senza registrazione.'**
  String get businessOnboardingStep3Body;

  /// No description provided for @businessOnboardingStep4Title.
  ///
  /// In it, this message translates to:
  /// **'4. Stima e report'**
  String get businessOnboardingStep4Title;

  /// No description provided for @businessOnboardingStep4Body.
  ///
  /// In it, this message translates to:
  /// **'Avvia il voto, conferma le stime e chiudi con il report executive (KPI, CSV, stampa) per i manager.'**
  String get businessOnboardingStep4Body;

  /// No description provided for @businessOnboardingSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta percorso'**
  String get businessOnboardingSkip;

  /// No description provided for @businessOnboardingNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get businessOnboardingNext;

  /// No description provided for @businessOnboardingStart.
  ///
  /// In it, this message translates to:
  /// **'Apri il primo locale'**
  String get businessOnboardingStart;

  /// No description provided for @businessOnboardingDoneLater.
  ///
  /// In it, this message translates to:
  /// **'Più tardi'**
  String get businessOnboardingDoneLater;

  /// No description provided for @helpReplayBusinessOnboarding.
  ///
  /// In it, this message translates to:
  /// **'Rivedi percorso guidato'**
  String get helpReplayBusinessOnboarding;

  /// No description provided for @workspaceTitle.
  ///
  /// In it, this message translates to:
  /// **'Workspace team'**
  String get workspaceTitle;

  /// No description provided for @workspaceManageSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Branding e deck predefinito'**
  String get workspaceManageSubtitle;

  /// No description provided for @workspaceEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun workspace configurato'**
  String get workspaceEmpty;

  /// No description provided for @workspaceBrandPreview.
  ///
  /// In it, this message translates to:
  /// **'Colore brand'**
  String get workspaceBrandPreview;

  /// No description provided for @workspaceAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi workspace'**
  String get workspaceAdd;

  /// No description provided for @planUpgradeTitle.
  ///
  /// In it, this message translates to:
  /// **'Piano commerciale'**
  String get planUpgradeTitle;

  /// No description provided for @planUpgradeBody.
  ///
  /// In it, this message translates to:
  /// **'Funzione richiesta: piano {tier}'**
  String planUpgradeBody(String tier);

  /// No description provided for @planTierFree.
  ///
  /// In it, this message translates to:
  /// **'Free'**
  String get planTierFree;

  /// No description provided for @planTierFreeFeatures.
  ///
  /// In it, this message translates to:
  /// **'Stanze, voto e report base'**
  String get planTierFreeFeatures;

  /// No description provided for @planTierPro.
  ///
  /// In it, this message translates to:
  /// **'Pro'**
  String get planTierPro;

  /// No description provided for @planTierProFeatures.
  ///
  /// In it, this message translates to:
  /// **'KPI avanzati, report executive, health'**
  String get planTierProFeatures;

  /// No description provided for @planTierTeam.
  ///
  /// In it, this message translates to:
  /// **'Team'**
  String get planTierTeam;

  /// No description provided for @planTierTeamFeatures.
  ///
  /// In it, this message translates to:
  /// **'Workspace multipli, audit trail, sync Jira/ADO'**
  String get planTierTeamFeatures;

  /// No description provided for @planUpgradeDemoNote.
  ///
  /// In it, this message translates to:
  /// **'Demo locale: selezione piano per testare i limiti (nessun pagamento).'**
  String get planUpgradeDemoNote;

  /// No description provided for @planManageSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Free / Pro / Team'**
  String get planManageSubtitle;

  /// No description provided for @planFeatureLocked.
  ///
  /// In it, this message translates to:
  /// **'Disponibile con piano superiore'**
  String get planFeatureLocked;

  /// No description provided for @auditTrailTitle.
  ///
  /// In it, this message translates to:
  /// **'Registro audit'**
  String get auditTrailTitle;

  /// No description provided for @opsHealthTitle.
  ///
  /// In it, this message translates to:
  /// **'Stato servizio'**
  String get opsHealthTitle;

  /// No description provided for @opsHealthSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Metriche operative (Pro+)'**
  String get opsHealthSubtitle;

  /// No description provided for @opsHealthRealtime.
  ///
  /// In it, this message translates to:
  /// **'Realtime'**
  String get opsHealthRealtime;

  /// No description provided for @opsHealthActiveRooms1h.
  ///
  /// In it, this message translates to:
  /// **'Stanze attive (1h)'**
  String get opsHealthActiveRooms1h;

  /// No description provided for @opsHealthActiveRooms24h.
  ///
  /// In it, this message translates to:
  /// **'Stanze attive (24h)'**
  String get opsHealthActiveRooms24h;

  /// No description provided for @opsHealthAudit24h.
  ///
  /// In it, this message translates to:
  /// **'Eventi audit (24h)'**
  String get opsHealthAudit24h;

  /// No description provided for @opsHealthExternalLinks.
  ///
  /// In it, this message translates to:
  /// **'Collegamenti esterni'**
  String get opsHealthExternalLinks;

  /// No description provided for @opsHealthStoriesDone24h.
  ///
  /// In it, this message translates to:
  /// **'Ordini completati (24h)'**
  String get opsHealthStoriesDone24h;

  /// No description provided for @opsHealthCheckedAt.
  ///
  /// In it, this message translates to:
  /// **'Aggiornato: {at}'**
  String opsHealthCheckedAt(String at);

  /// No description provided for @opsHealthAlertHint.
  ///
  /// In it, this message translates to:
  /// **'Soglie alert: error rate RPC elevato o latenza prolungata — monitoraggio manuale in questa release.'**
  String get opsHealthAlertHint;

  /// No description provided for @externalSyncTitle.
  ///
  /// In it, this message translates to:
  /// **'Sync Jira / ADO'**
  String get externalSyncTitle;

  /// No description provided for @externalSyncJira.
  ///
  /// In it, this message translates to:
  /// **'Jira'**
  String get externalSyncJira;

  /// No description provided for @externalSyncAdo.
  ///
  /// In it, this message translates to:
  /// **'Azure DevOps'**
  String get externalSyncAdo;

  /// No description provided for @externalSyncKeyLabel.
  ///
  /// In it, this message translates to:
  /// **'Chiave issue'**
  String get externalSyncKeyLabel;

  /// No description provided for @externalSyncKeyHint.
  ///
  /// In it, this message translates to:
  /// **'es. PROJ-123'**
  String get externalSyncKeyHint;

  /// No description provided for @externalSyncLinkAction.
  ///
  /// In it, this message translates to:
  /// **'Collega ordine'**
  String get externalSyncLinkAction;

  /// No description provided for @externalSyncPushAction.
  ///
  /// In it, this message translates to:
  /// **'Registra push stima (clipboard)'**
  String get externalSyncPushAction;

  /// No description provided for @externalSyncCopied.
  ///
  /// In it, this message translates to:
  /// **'Payload sync copiato'**
  String get externalSyncCopied;

  /// No description provided for @pastSessions.
  ///
  /// In it, this message translates to:
  /// **'Sessioni passate'**
  String get pastSessions;

  /// No description provided for @sessionArchiveTitle.
  ///
  /// In it, this message translates to:
  /// **'Archivio sessioni'**
  String get sessionArchiveTitle;

  /// No description provided for @sessionArchiveEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna sessione salvata. Completa almeno una serata con ordini stimati.'**
  String get sessionArchiveEmpty;

  /// No description provided for @sessionArchiveExported.
  ///
  /// In it, this message translates to:
  /// **'Report copiato'**
  String get sessionArchiveExported;

  /// No description provided for @sessionCloseTitle.
  ///
  /// In it, this message translates to:
  /// **'Chiudi serata'**
  String get sessionCloseTitle;

  /// No description provided for @sessionCloseRetroLabel.
  ///
  /// In it, this message translates to:
  /// **'Note retro (opzionale)'**
  String get sessionCloseRetroLabel;

  /// No description provided for @sessionCloseRetroHint.
  ///
  /// In it, this message translates to:
  /// **'Incluse nell\'export Markdown'**
  String get sessionCloseRetroHint;

  /// No description provided for @sessionCloseExport.
  ///
  /// In it, this message translates to:
  /// **'Esporta report'**
  String get sessionCloseExport;

  /// No description provided for @sessionCloseDuplicate.
  ///
  /// In it, this message translates to:
  /// **'Duplica per prossima settimana'**
  String get sessionCloseDuplicate;

  /// No description provided for @sessionCloseLeave.
  ///
  /// In it, this message translates to:
  /// **'Esci dal locale'**
  String get sessionCloseLeave;

  /// No description provided for @feedbackTitle.
  ///
  /// In it, this message translates to:
  /// **'Com\'è andata la serata?'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Un rapido feedback ci aiuta a migliorare SpritzPlanning.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackPositive.
  ///
  /// In it, this message translates to:
  /// **'Bene'**
  String get feedbackPositive;

  /// No description provided for @feedbackNegative.
  ///
  /// In it, this message translates to:
  /// **'Da migliorare'**
  String get feedbackNegative;

  /// No description provided for @feedbackSuggest.
  ///
  /// In it, this message translates to:
  /// **'Lascia un suggerimento'**
  String get feedbackSuggest;

  /// No description provided for @feedbackDismiss.
  ///
  /// In it, this message translates to:
  /// **'Non ora'**
  String get feedbackDismiss;

  /// No description provided for @roomInvitePinLine.
  ///
  /// In it, this message translates to:
  /// **'PIN: {pin}'**
  String roomInvitePinLine(String pin);

  /// No description provided for @roomInviteBody.
  ///
  /// In it, this message translates to:
  /// **'🍹 Unisciti a «{roomName}» su SpritzPlanning!\nCodice: {code}\n{pinLine}\nApri: {joinUrl}\nGuida: {helpUrl}'**
  String roomInviteBody(
    String roomName,
    String code,
    String pinLine,
    String joinUrl,
    String helpUrl,
  );

  /// No description provided for @exportLinear.
  ///
  /// In it, this message translates to:
  /// **'Linear'**
  String get exportLinear;

  /// No description provided for @exportGitHubIssues.
  ///
  /// In it, this message translates to:
  /// **'GitHub Issues'**
  String get exportGitHubIssues;

  /// No description provided for @deckPresetPowers2.
  ///
  /// In it, this message translates to:
  /// **'Powers of 2'**
  String get deckPresetPowers2;

  /// No description provided for @deckPresetSafe.
  ///
  /// In it, this message translates to:
  /// **'SAFe'**
  String get deckPresetSafe;

  /// No description provided for @hideVotersUntilRevealTitle.
  ///
  /// In it, this message translates to:
  /// **'Voto anonimo fino al reveal'**
  String get hideVotersUntilRevealTitle;

  /// No description provided for @hideVotersUntilRevealSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Nasconde chi ha già votato; resta il conteggio N/M'**
  String get hideVotersUntilRevealSubtitle;

  /// No description provided for @confidenceVoteTitle.
  ///
  /// In it, this message translates to:
  /// **'Quanto siete sicuri?'**
  String get confidenceVoteTitle;

  /// No description provided for @confidenceVoteSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Valuta da 1 (poco) a 5 (molto) — non cambia la stima.'**
  String get confidenceVoteSubtitle;

  /// No description provided for @confidenceVoteProgress.
  ///
  /// In it, this message translates to:
  /// **'{voted}/{total} hanno risposto'**
  String confidenceVoteProgress(int voted, int total);

  /// No description provided for @confidenceVoteClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi confidence'**
  String get confidenceVoteClose;

  /// No description provided for @confidenceVoteStart.
  ///
  /// In it, this message translates to:
  /// **'Confidence vote'**
  String get confidenceVoteStart;

  /// No description provided for @storyPublicCommentTitle.
  ///
  /// In it, this message translates to:
  /// **'Commento / domanda'**
  String get storyPublicCommentTitle;

  /// No description provided for @storyPublicCommentHint.
  ///
  /// In it, this message translates to:
  /// **'Visibile a tutti in sala'**
  String get storyPublicCommentHint;

  /// No description provided for @referenceStoryBadge.
  ///
  /// In it, this message translates to:
  /// **'Riferimento'**
  String get referenceStoryBadge;

  /// No description provided for @setReferenceStory.
  ///
  /// In it, this message translates to:
  /// **'Imposta come riferimento'**
  String get setReferenceStory;

  /// No description provided for @saveRoomTemplate.
  ///
  /// In it, this message translates to:
  /// **'Salva come template'**
  String get saveRoomTemplate;

  /// No description provided for @saveRoomTemplateSuccess.
  ///
  /// In it, this message translates to:
  /// **'Template salvato'**
  String get saveRoomTemplateSuccess;

  /// No description provided for @saveRoomTemplatePrompt.
  ///
  /// In it, this message translates to:
  /// **'Nome template'**
  String get saveRoomTemplatePrompt;

  /// No description provided for @importJiraAdoTab.
  ///
  /// In it, this message translates to:
  /// **'Jira / ADO'**
  String get importJiraAdoTab;

  /// No description provided for @importPasteTab.
  ///
  /// In it, this message translates to:
  /// **'Incolla titoli'**
  String get importPasteTab;

  /// No description provided for @importJiraAdoHint.
  ///
  /// In it, this message translates to:
  /// **'Incolla export CSV o tab-separated (Summary, Story Points…)'**
  String get importJiraAdoHint;

  /// No description provided for @soundEffectsTitle.
  ///
  /// In it, this message translates to:
  /// **'Effetti sonori'**
  String get soundEffectsTitle;

  /// No description provided for @soundEffectsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Suoni su reveal e timer (opt-in)'**
  String get soundEffectsSubtitle;

  /// No description provided for @hapticTitle.
  ///
  /// In it, this message translates to:
  /// **'Feedback aptico'**
  String get hapticTitle;

  /// No description provided for @hapticSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Vibrazione su eventi chiave (mobile)'**
  String get hapticSubtitle;

  /// No description provided for @pushNotificationsTitle.
  ///
  /// In it, this message translates to:
  /// **'Push PWA (beta)'**
  String get pushNotificationsTitle;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Notifiche con app in background (web, richiede VAPID)'**
  String get pushNotificationsSubtitle;

  /// No description provided for @relativeSizingHint.
  ///
  /// In it, this message translates to:
  /// **'Rispetto al riferimento ({reference} pt): ~{ratio}×'**
  String relativeSizingHint(String reference, String ratio);

  /// No description provided for @estimateHistoryLabel.
  ///
  /// In it, this message translates to:
  /// **'Revisioni stima'**
  String get estimateHistoryLabel;

  /// No description provided for @accountTitle.
  ///
  /// In it, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSignIn.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get accountSignIn;

  /// No description provided for @accountSignInSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Salva workspace e report sul tuo profilo'**
  String get accountSignInSubtitle;

  /// No description provided for @accountSignOut.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get accountSignOut;

  /// No description provided for @accountProfile.
  ///
  /// In it, this message translates to:
  /// **'Il tuo profilo'**
  String get accountProfile;

  /// No description provided for @accountEmailLabel.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get accountEmailLabel;

  /// No description provided for @accountEmailHint.
  ///
  /// In it, this message translates to:
  /// **'nome@azienda.it'**
  String get accountEmailHint;

  /// No description provided for @accountMagicLinkSend.
  ///
  /// In it, this message translates to:
  /// **'Invia link al bancone'**
  String get accountMagicLinkSend;

  /// No description provided for @accountMagicLinkSent.
  ///
  /// In it, this message translates to:
  /// **'Controlla la posta: ti abbiamo mandato il link per entrare.'**
  String get accountMagicLinkSent;

  /// No description provided for @accountOAuthGoogle.
  ///
  /// In it, this message translates to:
  /// **'Continua con Google'**
  String get accountOAuthGoogle;

  /// No description provided for @accountOAuthMicrosoft.
  ///
  /// In it, this message translates to:
  /// **'Continua con Microsoft'**
  String get accountOAuthMicrosoft;

  /// No description provided for @accountLinkParticipantTitle.
  ///
  /// In it, this message translates to:
  /// **'Collega questo tavolo'**
  String get accountLinkParticipantTitle;

  /// No description provided for @accountLinkParticipantAction.
  ///
  /// In it, this message translates to:
  /// **'Collega account a questa sessione'**
  String get accountLinkParticipantAction;

  /// No description provided for @accountLinkParticipantSuccess.
  ///
  /// In it, this message translates to:
  /// **'Account collegato al bancone'**
  String get accountLinkParticipantSuccess;

  /// No description provided for @accountLinkParticipantHint.
  ///
  /// In it, this message translates to:
  /// **'Collega un account per ritrovare workspace e report su altri dispositivi.'**
  String get accountLinkParticipantHint;

  /// No description provided for @accountDisplayNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome visualizzato'**
  String get accountDisplayNameLabel;

  /// No description provided for @accountSaveProfile.
  ///
  /// In it, this message translates to:
  /// **'Salva profilo'**
  String get accountSaveProfile;

  /// No description provided for @accountProfileSaved.
  ///
  /// In it, this message translates to:
  /// **'Profilo aggiornato'**
  String get accountProfileSaved;

  /// No description provided for @accountAuthRequired.
  ///
  /// In it, this message translates to:
  /// **'Accedi per usare questa funzione'**
  String get accountAuthRequired;

  /// No description provided for @accountCallbackLoading.
  ///
  /// In it, this message translates to:
  /// **'Accesso in corso…'**
  String get accountCallbackLoading;

  /// No description provided for @accountCallbackError.
  ///
  /// In it, this message translates to:
  /// **'Accesso non riuscito. Riprova dal bancone.'**
  String get accountCallbackError;

  /// No description provided for @orgTitle.
  ///
  /// In it, this message translates to:
  /// **'Organizzazione'**
  String get orgTitle;

  /// No description provided for @orgManageSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Team, inviti e piano'**
  String get orgManageSubtitle;

  /// No description provided for @orgEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessuna organizzazione. Creane una per il tuo team.'**
  String get orgEmpty;

  /// No description provided for @orgCreateNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome organizzazione'**
  String get orgCreateNameLabel;

  /// No description provided for @orgCreateNameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Team Delivery Alpha'**
  String get orgCreateNameHint;

  /// No description provided for @orgCreateAction.
  ///
  /// In it, this message translates to:
  /// **'Crea organizzazione'**
  String get orgCreateAction;

  /// No description provided for @orgSignInRequired.
  ///
  /// In it, this message translates to:
  /// **'Accedi per gestire un\'organizzazione.'**
  String get orgSignInRequired;

  /// No description provided for @orgInviteMember.
  ///
  /// In it, this message translates to:
  /// **'Invita collega'**
  String get orgInviteMember;

  /// No description provided for @orgInviteTitle.
  ///
  /// In it, this message translates to:
  /// **'Invito al team'**
  String get orgInviteTitle;

  /// No description provided for @orgInviteSend.
  ///
  /// In it, this message translates to:
  /// **'Genera link invito'**
  String get orgInviteSend;

  /// No description provided for @orgInviteLinkHint.
  ///
  /// In it, this message translates to:
  /// **'Condividi il link: valido 7 giorni, monouso.'**
  String get orgInviteLinkHint;

  /// No description provided for @orgInviteAccepted.
  ///
  /// In it, this message translates to:
  /// **'Sei entrato nel team.'**
  String get orgInviteAccepted;

  /// No description provided for @orgInviteAccepting.
  ///
  /// In it, this message translates to:
  /// **'Accettazione invito…'**
  String get orgInviteAccepting;

  /// No description provided for @orgInviteExpired.
  ///
  /// In it, this message translates to:
  /// **'Invito scaduto o non valido.'**
  String get orgInviteExpired;

  /// No description provided for @workspaceCloudHint.
  ///
  /// In it, this message translates to:
  /// **'Workspace salvati sul cloud dell\'organizzazione attiva.'**
  String get workspaceCloudHint;

  /// No description provided for @planUpgradeOrgNote.
  ///
  /// In it, this message translates to:
  /// **'Il piano è legato all\'organizzazione (owner). Stripe in arrivo.'**
  String get planUpgradeOrgNote;
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
