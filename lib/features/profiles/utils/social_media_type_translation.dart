import 'package:gruene_app/i18n/translations.g.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.enums.swagger.dart';

String getSocialMediaTypeTranslation(SocialMediaType type) {
  switch (type) {
    case SocialMediaType.facebook:
      return t.profiles.socialMediaType.facebook;
    case SocialMediaType.instagram:
      return t.profiles.socialMediaType.instagram;
    case SocialMediaType.mastodon:
      return t.profiles.socialMediaType.mastodon;
    case SocialMediaType.twitter:
      return t.profiles.socialMediaType.twitter;
    case SocialMediaType.chatbegruenung:
      return t.profiles.socialMediaType.chatbegruenung;
    default:
      return type.value ?? '';
  }
}
