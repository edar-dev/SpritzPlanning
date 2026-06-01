// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SpritzPlanning';

  @override
  String get tagline => 'Estimate user stories at the bar';

  @override
  String get installPwa => 'Install SpritzPlanning on your home screen';

  @override
  String get installPwaAction => 'Install';

  @override
  String get nicknameLabel => 'Your name at the bar';

  @override
  String get nicknameHint => 'e.g. Alex';

  @override
  String get openLocale => 'Open a room';

  @override
  String get enterBancone => 'Join the bar';

  @override
  String get localeNameLabel => 'Room name';

  @override
  String get localeNameHint => 'e.g. Team Alpha Bar';

  @override
  String get roomCodeLabel => 'Bar code';

  @override
  String get roomCodeHint => 'e.g. SPRT-A3K9';

  @override
  String get languageLabel => 'Language';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get back => 'Back';

  @override
  String get createRoomSubtitle => 'Create a room for your team';

  @override
  String get joinRoomSubtitle => 'Join with the bar code';

  @override
  String get codiceBancone => 'Bar code';

  @override
  String get copyCode => 'Copy code';

  @override
  String get shareCode => 'Share invite';

  @override
  String get shareMessage => 'Join my SpritzPlanning room! Code:';

  @override
  String get showQr => 'Show QR';

  @override
  String get qrBanconeTitle => 'Bar QR';

  @override
  String get qrBanconeHint => 'Scan to join the room';

  @override
  String get clienti => 'Guests at the bar';

  @override
  String get barman => 'Bartender';

  @override
  String get passaBancone => 'Pass the bar';

  @override
  String confermaPassaBancone(String nickname) {
    return 'Pass Bartender role to $nickname?';
  }

  @override
  String get menu => 'Menu';

  @override
  String get menuSubtitle => 'Stories to estimate with the team';

  @override
  String get menuEmpty => 'The menu is empty. Add the first story!';

  @override
  String get addOrdine => 'Add story';

  @override
  String get ordineTitle => 'Story title';

  @override
  String get ordineDescription => 'Description (optional)';

  @override
  String get startVoting => 'Serve the order';

  @override
  String get waitingAperitivo => 'Waiting for the aperitivo...';

  @override
  String get modificaOrdine => 'Edit story';

  @override
  String get salvaOrdine => 'Save';

  @override
  String get modificaOrdineHint => 'Drag to reorder the menu';

  @override
  String get chooseDose => 'Pick your dose';

  @override
  String get yourVote => 'Your dose';

  @override
  String get voteSubmitted => 'Dose chosen! Waiting for others...';

  @override
  String get allVoted => 'Everyone has voted!';

  @override
  String get servizio => 'Reveal!';

  @override
  String get resetRound => 'New round';

  @override
  String get confirmEstimate => 'Confirm estimate';

  @override
  String get nextOrdine => 'Next story';

  @override
  String get finalEstimateLabel => 'Final estimate';

  @override
  String get votesRevealed => 'Here are the doses!';

  @override
  String get noActiveStory => 'No story in voting';

  @override
  String get currentStoryLabel => 'Current story';

  @override
  String get chooseDoseSubtitle => 'Select the dose for this story';

  @override
  String get consensoSuggerito => 'Suggested consensus';

  @override
  String get distribuzioneVoti => 'Vote distribution';

  @override
  String get dosiScelte => 'doses chosen';

  @override
  String get outlier => 'Outlier';

  @override
  String get timerScaduto => 'Time\'s up — ready to reveal?';

  @override
  String get timerLabel => 'Time left';

  @override
  String get timerNone => 'No timer';

  @override
  String get timer2Min => '2 min';

  @override
  String get timer5Min => '5 min';

  @override
  String get timer10Min => '10 min';

  @override
  String get scegliTimer => 'Voting duration';

  @override
  String get assente => 'Away';

  @override
  String get rimuoviDalBancone => 'Remove from bar';

  @override
  String confermaRimuovi(String nickname) {
    return 'Remove $nickname from the bar?';
  }

  @override
  String get azioniCliente => 'Guest actions';

  @override
  String get riepilogoSerata => 'Session summary';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportMarkdown => 'Share Markdown';

  @override
  String get copiaReport => 'Copy report';

  @override
  String get reportEmpty => 'No confirmed estimates yet';

  @override
  String get reportCopied => 'Report copied to clipboard';

  @override
  String get nicknameTooShort => 'Nickname must be at least 2 characters';

  @override
  String get localeNameTooShort => 'Room name must be at least 2 characters';

  @override
  String get roomCodeRequired => 'Enter the bar code';

  @override
  String get connectionLost => 'Lost connection to the bar';

  @override
  String get genericError => 'Something went wrong at the bar';

  @override
  String get leaveLocale => 'Leave room';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get deckSettings => 'Deck settings';

  @override
  String get deckPresetFibonacci => 'Fibonacci (default)';

  @override
  String get deckPresetNumbers => 'Numbers only';

  @override
  String get deckPresetTshirt => 'T-shirt sizes';

  @override
  String get deckAllowCoffee => 'Allow coffee break vote';

  @override
  String get deckLabelZero => 'Water';

  @override
  String get deckLabelHalf => 'Half';

  @override
  String get deckLabelUnsure => 'Not thirsty';

  @override
  String get deckLabelCoffee => 'Coffee break';

  @override
  String deckLabelSpritz(String value) {
    return 'Spritz $value';
  }

  @override
  String pointsSuffix(String estimate) {
    return '$estimate pt';
  }

  @override
  String get reconnecting => 'Reconnecting to the bar…';

  @override
  String get pollingFallback => 'Periodic refresh active';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get refresh => 'Refresh';

  @override
  String get supabaseNotConfigured =>
      'Supabase not configured — use --dart-define-from-file=env.json';

  @override
  String get backToHome => 'Back to home';

  @override
  String get distribuzioneVotiSubtitle => 'Summary of chosen doses';

  @override
  String get importStories => 'Import stories';

  @override
  String get importPasteHint =>
      'One line per story (max 50). CSV: first column only.';

  @override
  String get importStoriesAction => 'Import to menu';

  @override
  String get importStoriesEmpty => 'Paste at least one story title';

  @override
  String importStoriesSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stories imported',
      one: '1 story imported',
    );
    return '$_temp0';
  }

  @override
  String importPreview(int count) {
    return 'Preview: $count stories';
  }

  @override
  String get recentRooms => 'Recent rooms';

  @override
  String get resumeSession => 'Resume session';

  @override
  String resumeSessionSubtitle(String roomName, String code) {
    return '$roomName · $code';
  }

  @override
  String backlogProgress(int done, int total) {
    return '$done of $total stories estimated';
  }

  @override
  String get menuEmptyImportCta => 'Import a list or add the first story';

  @override
  String get keyboardShortcuts => 'Keyboard shortcuts';

  @override
  String get keyboardShortcutReveal => 'R — Reveal votes';

  @override
  String get keyboardShortcutNext => 'N — Next story';

  @override
  String get keyboardShortcutStartVote => 'V — Start voting (first queued)';

  @override
  String applyConsensusAndNext(String value) {
    return 'Apply $value and next';
  }

  @override
  String confirmVoteTitle(String value) {
    return 'Confirm dose $value?';
  }

  @override
  String get exportJson => 'Export JSON';
}
