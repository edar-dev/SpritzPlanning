import '../../l10n/app_localizations.dart';
import '../constants/app_config.dart';

abstract final class RoomInviteText {
  static String build({
    required AppLocalizations l10n,
    required String roomName,
    required String code,
    String? pin,
  }) {
    final pinLine = pin != null && pin.isNotEmpty
        ? l10n.roomInvitePinLine(pin)
        : '';
    return l10n.roomInviteBody(
      roomName,
      code,
      pinLine,
      AppConfig.joinUrlForCode(code),
      AppConfig.helpUrl,
    );
  }
}
