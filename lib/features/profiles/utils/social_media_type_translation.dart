import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.enums.swagger.dart';

String getSocialMediaTypeTranslation(SocialMediaEntryType type) {
  switch (type) {
    case SocialMediaEntryType.facebook:
      return t.profiles.socialMediaType.facebook;
    case SocialMediaEntryType.instagram:
      return t.profiles.socialMediaType.instagram;
    case SocialMediaEntryType.mastodon:
      return t.profiles.socialMediaType.mastodon;
    case SocialMediaEntryType.twitter:
      return t.profiles.socialMediaType.twitter;
    case SocialMediaEntryType.chatbegruenung:
      return t.profiles.socialMediaType.chatbegruenung;
    default:
      return type.value ?? '';
  }
}
