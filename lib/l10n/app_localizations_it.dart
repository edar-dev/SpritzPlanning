// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'SpritzPlanning';

  @override
  String get tagline => 'Stima le user story al bancone';

  @override
  String get installPwa => 'Installa SpritzPlanning sulla home';

  @override
  String get installPwaAction => 'Installa';

  @override
  String get rateLimitError =>
      'Troppe richieste. Attendi un momento e riprova.';

  @override
  String voteCardSemantics(String value) {
    return 'Vota $value';
  }

  @override
  String get projectorMode => 'Modalità sala / proiettore';

  @override
  String get projectorModeHint => 'Testo e card più grandi per proiettore o TV';

  @override
  String get appSettings => 'Impostazioni';

  @override
  String get nicknameLabel => 'Il tuo nome al bancone';

  @override
  String get nicknameHint => 'Es. Marco';

  @override
  String get openLocale => 'Apri un locale';

  @override
  String get enterBancone => 'Entra al bancone';

  @override
  String get localeNameLabel => 'Nome del locale';

  @override
  String get localeNameHint => 'Es. Bar del Team Alpha';

  @override
  String get roomCodeLabel => 'Codice bancone';

  @override
  String get roomCodeHint => 'Es. SPRT-A3K9';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get back => 'Indietro';

  @override
  String get codiceBancone => 'Codice bancone';

  @override
  String get copyCode => 'Copia codice';

  @override
  String get shareCode => 'Condividi invito';

  @override
  String get showQr => 'Mostra QR';

  @override
  String get qrBanconeTitle => 'QR bancone';

  @override
  String get qrBanconeHint => 'Inquadra per entrare al locale';

  @override
  String get clienti => 'Clienti al bancone';

  @override
  String get barVoteStatusOrdered => 'Dose scelta';

  @override
  String get barVoteStatusWaiting => 'Attende';

  @override
  String get barDeckTrayTitle => 'Carte al bancone';

  @override
  String get barman => 'Barman';

  @override
  String get passaBancone => 'Passa il bancone';

  @override
  String confermaPassaBancone(String nickname) {
    return 'Passa il ruolo di Barman a $nickname?';
  }

  @override
  String get menu => 'Menu';

  @override
  String get menuSubtitle => 'Ordini da stimare con il team';

  @override
  String get menuCompactHint => 'Tocca un ordine per passare alla votazione';

  @override
  String get switchOrderTitle => 'Cambiare ordine?';

  @override
  String switchOrderMessage(String currentTitle, String targetTitle) {
    return 'La votazione su «$currentTitle» verrà annullata e si passerà a «$targetTitle».';
  }

  @override
  String get switchOrderConfirm => 'Servi questo ordine';

  @override
  String get menuEmpty => 'Il menu è vuoto. Aggiungi il primo ordine!';

  @override
  String get addOrdine => 'Aggiungi ordine';

  @override
  String get ordineTitle => 'Titolo ordine';

  @override
  String get ordineDescription => 'Descrizione (opzionale)';

  @override
  String get startVoting => 'Servi l\'ordine';

  @override
  String get waitingAperitivo => 'In attesa dell\'aperitivo...';

  @override
  String get waitingBarmanMenu => 'Il barman prepara il menu…';

  @override
  String get waitingServeOrder => 'In attesa che il barman serva un ordine';

  @override
  String get alwaysUseVotingTimer => 'Usa sempre questa durata';

  @override
  String get shareRoomPrompt => 'Invita il team: condividi il codice bancone';

  @override
  String get shareRoomPromptDismiss => 'Chiudi';

  @override
  String get modificaOrdine => 'Modifica ordine';

  @override
  String get eliminaOrdine => 'Elimina ordine';

  @override
  String get salvaOrdine => 'Salva';

  @override
  String get modificaOrdineHint => 'Trascina per riordinare il menu';

  @override
  String get chooseDose => 'Scegli la dose';

  @override
  String get voteSubmitted => 'Dose scelta! In attesa degli altri...';

  @override
  String get allVoted => 'Tutti hanno scelto!';

  @override
  String get servizio => 'Servizio!';

  @override
  String get resetRound => 'Nuovo giro';

  @override
  String get confirmEstimate => 'Conferma stima';

  @override
  String get nextOrdine => 'Prossimo ordine';

  @override
  String get finalEstimateLabel => 'Stima finale';

  @override
  String get votesRevealed => 'Ecco le dosi!';

  @override
  String get noActiveStory => 'Nessun ordine in votazione';

  @override
  String get currentStoryLabel => 'Ordine corrente';

  @override
  String get chooseDoseSubtitle => 'Seleziona la dose per questo ordine';

  @override
  String get consensoSuggerito => 'Consenso suggerito';

  @override
  String get distribuzioneVoti => 'Distribuzione voti';

  @override
  String get dosiScelte => 'dosi scelte';

  @override
  String get outlier => 'Fuori scala';

  @override
  String get timerScaduto => 'Tempo scaduto — pronti per il servizio?';

  @override
  String get timerLabel => 'Tempo rimasto';

  @override
  String get timerNone => 'Senza timer';

  @override
  String get timer2Min => '2 min';

  @override
  String get timer5Min => '5 min';

  @override
  String get timer10Min => '10 min';

  @override
  String get scegliTimer => 'Durata votazione';

  @override
  String get assente => 'Assente';

  @override
  String get rimuoviDalBancone => 'Rimuovi dal bancone';

  @override
  String confermaRimuovi(String nickname) {
    return 'Rimuovere $nickname dal bancone?';
  }

  @override
  String get azioniCliente => 'Azioni cliente';

  @override
  String get riepilogoSerata => 'Riepilogo serata';

  @override
  String get exportCsv => 'Esporta CSV';

  @override
  String get exportMarkdown => 'Condividi Markdown';

  @override
  String get copiaReport => 'Copia report';

  @override
  String get reportEmpty => 'Nessuna stima ancora confermata';

  @override
  String get reportCopied => 'Report copiato negli appunti';

  @override
  String get nicknameTooShort => 'Il nickname deve avere almeno 2 caratteri';

  @override
  String get localeNameTooShort =>
      'Il nome del locale deve avere almeno 2 caratteri';

  @override
  String get roomCodeRequired => 'Inserisci il codice bancone';

  @override
  String get connectionLost => 'Connessione persa al bancone';

  @override
  String get genericError => 'Qualcosa è andato storto al bancone';

  @override
  String get leaveLocale => 'Lascia il locale';

  @override
  String get cancel => 'Annulla';

  @override
  String get deckSettings => 'Impostazioni deck';

  @override
  String get deckPresetFibonacci => 'Fibonacci (default)';

  @override
  String get deckPresetNumbers => 'Solo numeri';

  @override
  String get deckPresetTshirt => 'T-shirt';

  @override
  String get deckAllowCoffee => 'Consenti pausa caffè';

  @override
  String get deckLabelZero => 'Acqua';

  @override
  String get deckLabelHalf => 'Mezzo';

  @override
  String get deckLabelUnsure => 'Non ho sete';

  @override
  String get deckLabelCoffee => 'Pausa caffè';

  @override
  String deckLabelSpritz(String value) {
    return 'Spritz $value';
  }

  @override
  String pointsSuffix(String estimate) {
    return '$estimate pt';
  }

  @override
  String get reconnecting => 'Riconnessione al bancone…';

  @override
  String get pollingFallback => 'Aggiornamento periodico attivo';

  @override
  String get codeCopied => 'Codice copiato';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get supabaseNotConfigured =>
      'Supabase non configurato — usa --dart-define-from-file=env.json';

  @override
  String get backToHome => 'Torna alla home';

  @override
  String get distribuzioneVotiSubtitle => 'Riepilogo delle dosi scelte';

  @override
  String get importStories => 'Importa ordini';

  @override
  String get importPasteHint =>
      'Una riga per ordine (max 50). CSV: usa solo la prima colonna.';

  @override
  String get importStoriesAction => 'Importa nel menu';

  @override
  String get importStoriesEmpty => 'Incolla almeno un titolo ordine';

  @override
  String importStoriesSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ordini importati',
      one: '1 ordine importato',
    );
    return '$_temp0';
  }

  @override
  String importPreview(int count) {
    return 'Anteprima: $count ordini';
  }

  @override
  String get recentRooms => 'Locali recenti';

  @override
  String get recentRoomUnavailable =>
      'Questo locale non è più disponibile ed è stato rimosso dall\'elenco.';

  @override
  String get resumeSession => 'Riprendi sessione';

  @override
  String resumeSessionSubtitle(String roomName, String code) {
    return '$roomName · $code';
  }

  @override
  String backlogProgress(int done, int total) {
    return '$done di $total ordini stimati';
  }

  @override
  String get menuEmptyImportCta =>
      'Importa una lista o aggiungi il primo ordine';

  @override
  String get keyboardShortcuts => 'Scorciatoie tastiera';

  @override
  String get keyboardShortcutReveal => 'R — Servizio (reveal)';

  @override
  String get keyboardShortcutNext => 'N — Prossimo ordine';

  @override
  String get keyboardShortcutStartVote => 'V — Servi ordine (primo in coda)';

  @override
  String applyConsensusAndNext(String value) {
    return 'Applica $value e prossimo';
  }

  @override
  String confirmVoteTitle(String value) {
    return 'Confermi la dose $value?';
  }

  @override
  String get joinAsObserver => 'Solo osservazione (non voto)';

  @override
  String get joinAdvancedOptions => 'Opzioni avanzate';

  @override
  String get roomToolsTitle => 'Strumenti';

  @override
  String get observerBadge => 'Osservatore';

  @override
  String get editorBadge => 'Editor';

  @override
  String get viewerBadge => 'Solo lettura';

  @override
  String get setParticipantRoleEditor => 'Assegna ruolo editor';

  @override
  String get setParticipantRoleViewer => 'Assegna ruolo solo lettura';

  @override
  String get participantRoleChanged => 'Ruolo partecipante aggiornato';

  @override
  String get observerCannotVote => 'Stai osservando: non puoi votare';

  @override
  String get roomPinLabel => 'PIN locale';

  @override
  String get roomPinHint => '4-6 cifre';

  @override
  String get roomPinRequired => 'PIN richiesto per questo locale';

  @override
  String get setRoomPin => 'Imposta PIN';

  @override
  String get removeRoomPin => 'Rimuovi PIN';

  @override
  String get autoRevealTitle => 'Reveal automatico';

  @override
  String get autoRevealSubtitle => 'Rivela i voti quando tutti hanno scelto';

  @override
  String get markAsSpike => 'Segna come spike';

  @override
  String get storyKindSpike => 'Spike';

  @override
  String get duplicateRoom => 'Nuova serata (stesso menu)';

  @override
  String get duplicateRoomConfirm =>
      'Si crea un nuovo codice. Il backlog viene copiato. I clienti dovranno rientrare.';

  @override
  String get facilitatorNote => 'Note barman';

  @override
  String get facilitatorNoteHint => 'Solo per te, visibili in export';

  @override
  String get reportMedian => 'Mediana punti';

  @override
  String get reportCompleted => 'Ordini completati';

  @override
  String get roomTemplates => 'Template locale';

  @override
  String get businessTemplatesTitle => 'Template business';

  @override
  String get customTemplatesTitle => 'Template personalizzati';

  @override
  String get customTemplatesEmpty => 'Nessun template personalizzato salvato';

  @override
  String get createCustomTemplate => 'Crea template personalizzato';

  @override
  String get templateBusinessDiscoveryName => 'Product Discovery';

  @override
  String get templateBusinessDiscoveryDescription =>
      'Allineamento su problemi, ipotesi e scope MVP';

  @override
  String get templateBusinessRefinementName => 'Delivery Refinement';

  @override
  String get templateBusinessRefinementDescription =>
      'Rifinitura backlog con dipendenze e criteri di accettazione';

  @override
  String get templateBusinessMaintenanceName => 'Maintenance Fast Track';

  @override
  String get templateBusinessMaintenanceDescription =>
      'Flusso rapido per incident, fix urgenti e follow-up';

  @override
  String get createFromTemplate => 'Crea da template';

  @override
  String get notificationsTitle => 'Notifiche browser';

  @override
  String get notificationsSubtitle =>
      'Reveal e timer quando la scheda è in background';

  @override
  String get notificationsReveal => 'Voti rivelati';

  @override
  String get notificationsTimer => 'Tempo quasi scaduto';

  @override
  String get helpTitle => 'Guida SpritzPlanning';

  @override
  String get helpIntro =>
      'Planning poker a tema spritz per team agile. Nessun account: nickname e codice stanza bastano per iniziare.';

  @override
  String get helpRolesTitle => 'Ruoli';

  @override
  String get helpRolesBody =>
      'Il barman facilita: avvia votazioni, rivela i voti, gestisce il menu ordini. I clienti votano con le carte. Gli osservatori seguono la sessione senza votare.';

  @override
  String get helpFlowTitle => 'Flusso di una serata';

  @override
  String get helpFlowBody =>
      '1. Apri o entra in un locale\n2. Aggiungi ordini al menu (backlog)\n3. Avvia la votazione per ogni story\n4. Rivelate i voti e concordate la stima\n5. Esportate il report di fine serata';

  @override
  String get helpFeaturesTitle => 'Funzionalità';

  @override
  String get helpFeatImport => 'Import backlog — Lobby barman → icona upload';

  @override
  String get helpFeatAutoReveal =>
      'Auto-reveal — Impostazioni deck, quando tutti hanno votato';

  @override
  String get helpFeatReport =>
      'Report CSV/Markdown — Icona riepilogo in stanza';

  @override
  String get helpFeatResume => 'Ripresa sessione — Home, se hai già giocato';

  @override
  String get helpFaqTitle => 'Domande frequenti';

  @override
  String get helpFaqNicknameTitle => 'Nickname già presente';

  @override
  String get helpFaqNicknameBody =>
      'Significa che quel nickname è attivo in stanza. Esci dal locale prima di rientrare, oppure attendi ~2 minuti se il cliente è assente.';

  @override
  String get helpFaqRejoinTitle => 'Come rientro nella stessa stanza';

  @override
  String get helpFaqRejoinBody =>
      'Usa lo stesso nickname e codice. L\'app propone di riprendere la sessione se l\'hai lasciata di recente.';

  @override
  String get helpFaqPinTitle => 'PIN non accettato';

  @override
  String get helpFaqPinBody =>
      'Chiedi il PIN al barman. Deve essere di 4–6 cifre numeriche.';

  @override
  String get helpFaqObserverTitle => 'Osservatore';

  @override
  String get helpFaqObserverBody =>
      'Spunta «Solo osservazione» in fase di join. Non potrai votare ma vedrai reveal e report.';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto al bancone!';

  @override
  String get onboardingWelcomeBody =>
      'SpritzPlanning è planning poker veloce per il tuo team — senza registrazione.';

  @override
  String get onboardingCreateTitle => 'Apri un locale';

  @override
  String get onboardingCreateBody =>
      'Crea una stanza, condividi il codice o il QR con il team e aggiungi gli ordini da stimare.';

  @override
  String get onboardingJoinTitle => 'Entra al bancone';

  @override
  String get onboardingJoinBody =>
      'Hai un codice? Inserisci nickname e codice stanza. Puoi anche usare un link con ?code=.';

  @override
  String get onboardingHelpTitle => 'Serve aiuto?';

  @override
  String get onboardingHelpBody =>
      'Nella guida trovi tutte le funzioni: spike, PIN, template, export e molto altro.';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingDone => 'Inizia';

  @override
  String get pastSessions => 'Sessioni passate';

  @override
  String get sessionArchiveTitle => 'Archivio sessioni';

  @override
  String get sessionArchiveEmpty =>
      'Nessuna sessione salvata. Completa almeno una serata con ordini stimati.';

  @override
  String get sessionArchiveExported => 'Report copiato';

  @override
  String get sessionCloseTitle => 'Chiudi serata';

  @override
  String get sessionCloseRetroLabel => 'Note retro (opzionale)';

  @override
  String get sessionCloseRetroHint => 'Incluse nell\'export Markdown';

  @override
  String get sessionCloseExport => 'Esporta report';

  @override
  String get sessionCloseDuplicate => 'Duplica per prossima settimana';

  @override
  String get sessionCloseLeave => 'Esci dal locale';

  @override
  String get feedbackDismiss => 'Non ora';

  @override
  String roomInvitePinLine(String pin) {
    return 'PIN: $pin';
  }

  @override
  String roomInviteBody(
    String roomName,
    String code,
    String pinLine,
    String joinUrl,
    String helpUrl,
  ) {
    return '🍹 Unisciti a «$roomName» su SpritzPlanning!\nCodice: $code\n$pinLine\nApri: $joinUrl\nGuida: $helpUrl';
  }

  @override
  String get deckPresetPowers2 => 'Powers of 2';

  @override
  String get deckPresetSafe => 'SAFe';

  @override
  String get hideVotersUntilRevealTitle => 'Voto anonimo fino al reveal';

  @override
  String get hideVotersUntilRevealSubtitle =>
      'Nasconde chi ha già votato; resta il conteggio N/M';

  @override
  String get saveRoomTemplate => 'Salva come template';

  @override
  String get saveRoomTemplateSuccess => 'Template salvato';

  @override
  String get saveRoomTemplatePrompt => 'Nome template';

  @override
  String get importJiraAdoTab => 'Jira / ADO';

  @override
  String get importPasteTab => 'Incolla titoli';

  @override
  String get importJiraAdoHint =>
      'Incolla export CSV o tab-separated (Summary, Story Points…)';

  @override
  String get soundEffectsTitle => 'Effetti sonori';

  @override
  String get soundEffectsSubtitle => 'Suoni su reveal e timer (opt-in)';

  @override
  String get hapticTitle => 'Feedback aptico';

  @override
  String get hapticSubtitle => 'Vibrazione su eventi chiave (mobile)';
}
