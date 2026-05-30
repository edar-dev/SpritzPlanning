/// Stringhe UI in italiano — tema bar/spritz.
abstract final class AppStrings {
  static const appName = 'SpritzPlanning';
  static const tagline = 'Stima le user story al bancone';

  // Home
  static const nicknameLabel = 'Il tuo nome al bancone';
  static const nicknameHint = 'Es. Marco';
  static const openLocale = 'Apri un locale';
  static const enterBancone = 'Entra al bancone';
  static const localeNameLabel = 'Nome del locale';
  static const localeNameHint = 'Es. Bar del Team Alpha';
  static const roomCodeLabel = 'Codice bancone';
  static const roomCodeHint = 'Es. SPRT-A3K9';

  // Lobby
  static const codiceBancone = 'Codice bancone';
  static const copyCode = 'Copia codice';
  static const shareCode = 'Condividi invito';
  static const shareMessage = 'Entra al mio locale SpritzPlanning! Codice:';
  static const clienti = 'Clienti al bancone';
  static const barman = 'Barman';
  static const menu = 'Menu';
  static const menuEmpty = 'Il menu è vuoto. Aggiungi il primo ordine!';
  static const addOrdine = 'Aggiungi ordine';
  static const ordineTitle = 'Titolo ordine';
  static const ordineDescription = 'Descrizione (opzionale)';
  static const startVoting = 'Servi l\'ordine';
  static const waitingAperitivo = 'In attesa dell\'aperitivo...';

  // Voting
  static const chooseDose = 'Scegli la dose';
  static const yourVote = 'La tua dose';
  static const voteSubmitted = 'Dose scelta! In attesa degli altri...';
  static const allVoted = 'Tutti hanno scelto!';
  static const servizio = 'Servizio!';
  static const resetRound = 'Nuovo giro';
  static const confirmEstimate = 'Conferma stima';
  static const nextOrdine = 'Prossimo ordine';
  static const finalEstimateLabel = 'Stima finale';
  static const votesRevealed = 'Ecco le dosi!';
  static const noActiveStory = 'Nessun ordine in votazione';

  // Errors
  static const nicknameTooShort = 'Il nickname deve avere almeno 2 caratteri';
  static const localeNameTooShort = 'Il nome del locale deve avere almeno 2 caratteri';
  static const roomCodeRequired = 'Inserisci il codice bancone';
  static const connectionLost = 'Connessione persa al bancone';
  static const genericError = 'Qualcosa è andato storto al bancone';

  // Deck labels
  static const deckZero = 'Acqua';
  static const deckHalf = 'Mezzo';
  static const deckUnsure = 'Non ho sete';
  static const deckCoffee = 'Pausa caffè';
}
