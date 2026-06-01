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
  String get createRoomSubtitle => 'Crea una stanza per il tuo team';

  @override
  String get joinRoomSubtitle => 'Unisciti con il codice bancone';

  @override
  String get codiceBancone => 'Codice bancone';

  @override
  String get copyCode => 'Copia codice';

  @override
  String get shareCode => 'Condividi invito';

  @override
  String get shareMessage => 'Entra al mio locale SpritzPlanning! Codice:';

  @override
  String get showQr => 'Mostra QR';

  @override
  String get qrBanconeTitle => 'QR bancone';

  @override
  String get qrBanconeHint => 'Inquadra per entrare al locale';

  @override
  String get clienti => 'Clienti al bancone';

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
  String get modificaOrdine => 'Modifica ordine';

  @override
  String get salvaOrdine => 'Salva';

  @override
  String get modificaOrdineHint => 'Trascina per riordinare il menu';

  @override
  String get chooseDose => 'Scegli la dose';

  @override
  String get yourVote => 'La tua dose';

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
  String get add => 'Aggiungi';

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
  String get exportJson => 'Esporta JSON';
}
