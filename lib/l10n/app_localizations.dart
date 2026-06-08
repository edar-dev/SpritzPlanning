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

  /// No description provided for @menuCompactHint.
  ///
  /// In it, this message translates to:
  /// **'Tocca un ordine per passare alla votazione'**
  String get menuCompactHint;

  /// No description provided for @switchOrderTitle.
  ///
  /// In it, this message translates to:
  /// **'Cambiare ordine?'**
  String get switchOrderTitle;

  /// No description provided for @switchOrderMessage.
  ///
  /// In it, this message translates to:
  /// **'La votazione su «{currentTitle}» verrà annullata e si passerà a «{targetTitle}».'**
  String switchOrderMessage(String currentTitle, String targetTitle);

  /// No description provided for @switchOrderConfirm.
  ///
  /// In it, this message translates to:
  /// **'Servi questo ordine'**
  String get switchOrderConfirm;

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

  /// No description provided for @waitingBarmanMenu.
  ///
  /// In it, this message translates to:
  /// **'Il barman prepara il menu…'**
  String get waitingBarmanMenu;

  /// No description provided for @waitingServeOrder.
  ///
  /// In it, this message translates to:
  /// **'In attesa che il barman serva un ordine'**
  String get waitingServeOrder;

  /// No description provided for @alwaysUseVotingTimer.
  ///
  /// In it, this message translates to:
  /// **'Usa sempre questa durata'**
  String get alwaysUseVotingTimer;

  /// No description provided for @autoNextOrderTitle.
  ///
  /// In it, this message translates to:
  /// **'Servi il prossimo ordine'**
  String get autoNextOrderTitle;

  /// No description provided for @autoNextOrderSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Dopo la stima, avvia subito la votazione sul successivo'**
  String get autoNextOrderSubtitle;

  /// No description provided for @skipCurrentOrder.
  ///
  /// In it, this message translates to:
  /// **'Torna al menu'**
  String get skipCurrentOrder;

  /// No description provided for @skipCurrentOrderConfirm.
  ///
  /// In it, this message translates to:
  /// **'La votazione su «{title}» verrà annullata. Tornare al menu?'**
  String skipCurrentOrderConfirm(String title);

  /// No description provided for @guidedStep1Add.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi il primo ordine'**
  String get guidedStep1Add;

  /// No description provided for @guidedStep2Share.
  ///
  /// In it, this message translates to:
  /// **'Condividi il codice bancone'**
  String get guidedStep2Share;

  /// No description provided for @guidedStep3Serve.
  ///
  /// In it, this message translates to:
  /// **'Servi l\'ordine per iniziare a votare'**
  String get guidedStep3Serve;

  /// No description provided for @resumeSessionAction.
  ///
  /// In it, this message translates to:
  /// **'Entra'**
  String get resumeSessionAction;

  /// No description provided for @resumeSessionDismiss.
  ///
  /// In it, this message translates to:
  /// **'Ignora'**
  String get resumeSessionDismiss;

  /// No description provided for @voteChanged.
  ///
  /// In it, this message translates to:
  /// **'Dose aggiornata'**
  String get voteChanged;

  /// No description provided for @shareRoomPrompt.
  ///
  /// In it, this message translates to:
  /// **'Invita il team: condividi il codice bancone'**
  String get shareRoomPrompt;

  /// No description provided for @shareRoomPromptDismiss.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get shareRoomPromptDismiss;

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

  /// No description provided for @helpFeatImport.
  ///
  /// In it, this message translates to:
  /// **'Import backlog — Lobby barman → icona upload'**
  String get helpFeatImport;

  /// No description provided for @helpFeatAutoReveal.
  ///
  /// In it, this message translates to:
  /// **'Auto-reveal — Impostazioni deck, quando tutti hanno votato'**
  String get helpFeatAutoReveal;

  /// No description provided for @helpFeatReport.
  ///
  /// In it, this message translates to:
  /// **'Report CSV/Markdown — Icona riepilogo in stanza'**
  String get helpFeatReport;

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
