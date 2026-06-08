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
  String get rateLimitError =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String voteCardSemantics(String value) {
    return 'Vote $value';
  }

  @override
  String get projectorMode => 'Room / projector mode';

  @override
  String get projectorModeHint => 'Larger text and cards for projector or TV';

  @override
  String get appSettings => 'Settings';

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
  String get codiceBancone => 'Bar code';

  @override
  String get copyCode => 'Copy code';

  @override
  String get shareCode => 'Share invite';

  @override
  String get showQr => 'Show QR';

  @override
  String get qrBanconeTitle => 'Bar QR';

  @override
  String get qrBanconeHint => 'Scan to join the room';

  @override
  String get clienti => 'Guests at the bar';

  @override
  String get barVoteStatusOrdered => 'Dose chosen';

  @override
  String get barVoteStatusWaiting => 'Waiting';

  @override
  String get barDeckTrayTitle => 'Cards on the counter';

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
  String get menuCompactHint => 'Tap an order to switch voting';

  @override
  String get switchOrderTitle => 'Switch order?';

  @override
  String switchOrderMessage(String currentTitle, String targetTitle) {
    return 'Voting on \"$currentTitle\" will be cancelled and the team will move to \"$targetTitle\".';
  }

  @override
  String get switchOrderConfirm => 'Serve this order';

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
  String get waitingBarmanMenu => 'The bartender is preparing the menu…';

  @override
  String get waitingServeOrder => 'Waiting for the bartender to serve an order';

  @override
  String get alwaysUseVotingTimer => 'Always use this duration';

  @override
  String get autoNextOrderTitle => 'Serve next order automatically';

  @override
  String get autoNextOrderSubtitle =>
      'After confirming an estimate, start voting on the next item';

  @override
  String get skipCurrentOrder => 'Back to menu';

  @override
  String skipCurrentOrderConfirm(String title) {
    return 'Voting on \"$title\" will be cancelled. Return to the menu?';
  }

  @override
  String get guidedStep1Add => 'Add the first order';

  @override
  String get guidedStep2Share => 'Share the bar code';

  @override
  String get guidedStep3Serve => 'Serve an order to start voting';

  @override
  String get resumeSessionAction => 'Enter';

  @override
  String get resumeSessionDismiss => 'Dismiss';

  @override
  String get voteChanged => 'Dose updated';

  @override
  String get shareRoomPrompt => 'Invite the team — share the bar code';

  @override
  String get shareRoomPromptDismiss => 'Dismiss';

  @override
  String get modificaOrdine => 'Edit story';

  @override
  String get eliminaOrdine => 'Remove story';

  @override
  String get salvaOrdine => 'Save';

  @override
  String get modificaOrdineHint => 'Drag to reorder the menu';

  @override
  String get chooseDose => 'Pick your dose';

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
  String get recentRoomUnavailable =>
      'This room is no longer available and was removed from your list.';

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
  String get joinAsObserver => 'Observe only (no voting)';

  @override
  String get joinAdvancedOptions => 'Advanced options';

  @override
  String get roomToolsTitle => 'Tools';

  @override
  String get observerBadge => 'Observer';

  @override
  String get editorBadge => 'Editor';

  @override
  String get viewerBadge => 'View only';

  @override
  String get setParticipantRoleEditor => 'Assign editor role';

  @override
  String get setParticipantRoleViewer => 'Assign view-only role';

  @override
  String get participantRoleChanged => 'Participant role updated';

  @override
  String get observerCannotVote => 'You are observing — voting is disabled';

  @override
  String get roomPinLabel => 'Room PIN';

  @override
  String get roomPinHint => '4-6 digits';

  @override
  String get roomPinRequired => 'PIN required for this room';

  @override
  String get setRoomPin => 'Set PIN';

  @override
  String get removeRoomPin => 'Remove PIN';

  @override
  String get autoRevealTitle => 'Auto-reveal';

  @override
  String get autoRevealSubtitle => 'Reveal when everyone has voted';

  @override
  String get markAsSpike => 'Mark as spike';

  @override
  String get storyKindSpike => 'Spike';

  @override
  String get duplicateRoom => 'New session (same menu)';

  @override
  String get duplicateRoomConfirm =>
      'A new code will be created. The backlog is copied. Guests must re-join.';

  @override
  String get facilitatorNote => 'Facilitator note';

  @override
  String get facilitatorNoteHint => 'Private; included in export';

  @override
  String get reportMedian => 'Median points';

  @override
  String get reportCompleted => 'Completed stories';

  @override
  String get roomTemplates => 'Room templates';

  @override
  String get businessTemplatesTitle => 'Business templates';

  @override
  String get customTemplatesTitle => 'Custom templates';

  @override
  String get customTemplatesEmpty => 'No custom templates saved yet';

  @override
  String get createCustomTemplate => 'Create custom template';

  @override
  String get templateBusinessDiscoveryName => 'Product Discovery';

  @override
  String get templateBusinessDiscoveryDescription =>
      'Align on problem framing, hypotheses, and MVP scope';

  @override
  String get templateBusinessRefinementName => 'Delivery Refinement';

  @override
  String get templateBusinessRefinementDescription =>
      'Refine backlog with dependencies and acceptance criteria';

  @override
  String get templateBusinessMaintenanceName => 'Maintenance Fast Track';

  @override
  String get templateBusinessMaintenanceDescription =>
      'Fast flow for incidents, urgent fixes, and follow-up';

  @override
  String get createFromTemplate => 'Create from template';

  @override
  String get notificationsTitle => 'Browser notifications';

  @override
  String get notificationsSubtitle =>
      'Reveal and timer when tab is in background';

  @override
  String get notificationsReveal => 'Votes revealed';

  @override
  String get notificationsTimer => 'Time almost up';

  @override
  String get helpTitle => 'SpritzPlanning guide';

  @override
  String get helpIntro =>
      'Spritz-themed planning poker for agile teams. No account needed — just a nickname and room code.';

  @override
  String get helpRolesTitle => 'Roles';

  @override
  String get helpRolesBody =>
      'The facilitator runs the session: start voting, reveal votes, manage the backlog. Participants vote with cards. Observers watch without voting.';

  @override
  String get helpFlowTitle => 'Typical session flow';

  @override
  String get helpFlowBody =>
      '1. Create or join a room\n2. Add stories to the backlog\n3. Start voting for each story\n4. Reveal votes and agree on the estimate\n5. Export the session report';

  @override
  String get helpFeaturesTitle => 'Features';

  @override
  String get helpFeatImport =>
      'Import backlog — Facilitator lobby → upload icon';

  @override
  String get helpFeatAutoReveal =>
      'Auto-reveal — Deck settings, when everyone voted';

  @override
  String get helpFeatReport => 'CSV/Markdown report — Summary icon in room';

  @override
  String get helpFeatResume => 'Resume session — Home, if you played recently';

  @override
  String get helpFaqTitle => 'FAQ';

  @override
  String get helpFaqNicknameTitle => 'Nickname already taken';

  @override
  String get helpFaqNicknameBody =>
      'That nickname is active in the room. Leave the room first, or wait ~2 minutes if they appear away.';

  @override
  String get helpFaqRejoinTitle => 'Rejoining the same room';

  @override
  String get helpFaqRejoinBody =>
      'Use the same nickname and code. The app offers to resume if you left recently.';

  @override
  String get helpFaqPinTitle => 'PIN not accepted';

  @override
  String get helpFaqPinBody =>
      'Ask the facilitator for the PIN. It must be 4–6 digits.';

  @override
  String get helpFaqObserverTitle => 'Observer role';

  @override
  String get helpFaqObserverBody =>
      'Check «Observe only» when joining. You can watch reveals and reports but cannot vote.';

  @override
  String get onboardingWelcomeTitle => 'Welcome to the bar!';

  @override
  String get onboardingWelcomeBody =>
      'SpritzPlanning is fast planning poker for your team — no sign-up required.';

  @override
  String get onboardingCreateTitle => 'Open a room';

  @override
  String get onboardingCreateBody =>
      'Create a session, share the code or QR with your team, and add stories to estimate.';

  @override
  String get onboardingJoinTitle => 'Join the bar';

  @override
  String get onboardingJoinBody =>
      'Have a code? Enter nickname and room code. You can also use a link with ?code=.';

  @override
  String get onboardingHelpTitle => 'Need help?';

  @override
  String get onboardingHelpBody =>
      'The guide covers every feature: spikes, PIN, templates, exports, and more.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Get started';

  @override
  String get pastSessions => 'Past sessions';

  @override
  String get sessionArchiveTitle => 'Session archive';

  @override
  String get sessionArchiveEmpty =>
      'No saved sessions yet. Complete a session with estimated stories.';

  @override
  String get sessionArchiveExported => 'Report copied';

  @override
  String get sessionCloseTitle => 'Close session';

  @override
  String get sessionCloseRetroLabel => 'Retro notes (optional)';

  @override
  String get sessionCloseRetroHint => 'Included in Markdown export';

  @override
  String get sessionCloseExport => 'Export report';

  @override
  String get sessionCloseDuplicate => 'Duplicate for next week';

  @override
  String get sessionCloseLeave => 'Leave room';

  @override
  String get feedbackDismiss => 'Not now';

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
    return '🍹 Join «$roomName» on SpritzPlanning!\nCode: $code\n$pinLine\nOpen: $joinUrl\nGuide: $helpUrl';
  }

  @override
  String get deckPresetPowers2 => 'Powers of 2';

  @override
  String get deckPresetSafe => 'SAFe';

  @override
  String get hideVotersUntilRevealTitle => 'Anonymous vote until reveal';

  @override
  String get hideVotersUntilRevealSubtitle =>
      'Hide who voted; show N/M count only';

  @override
  String get saveRoomTemplate => 'Save as template';

  @override
  String get saveRoomTemplateSuccess => 'Template saved';

  @override
  String get saveRoomTemplatePrompt => 'Template name';

  @override
  String get importJiraAdoTab => 'Jira / ADO';

  @override
  String get importPasteTab => 'Paste titles';

  @override
  String get importJiraAdoHint =>
      'Paste CSV or tab-separated export (Summary, Story Points…)';

  @override
  String get soundEffectsTitle => 'Sound effects';

  @override
  String get soundEffectsSubtitle => 'Sounds on reveal and timer (opt-in)';

  @override
  String get hapticTitle => 'Haptic feedback';

  @override
  String get hapticSubtitle => 'Vibration on key events (mobile)';
}
