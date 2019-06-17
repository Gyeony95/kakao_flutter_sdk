import 'package:kakao_flutter_sdk/src/auth/model/access_token_response.dart';
import 'package:kakao_flutter_sdk/src/auth/model/access_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessTokenRepo {
  static const atKey = "com.kakao.token.AccessToken";
  static const atExpiresAtKey = "com.kakao.token.AccessToken.ExpiresAt";
  static const rtKey = "com.kakao.token.RefreshToken";
  static const rtExpiresAtKey = "com.kakao.token.RefreshToken.ExpiresAt";
  static const secureModeKey = "com.kakao.token.KakaoSecureMode";
  static const scopesKey = "com.kakao.token.Scopes";

  static final AccessTokenRepo instance = AccessTokenRepo();

  void clear() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(atKey);
    preferences.remove(atExpiresAtKey);
    preferences.remove(rtKey);
    preferences.remove(rtExpiresAtKey);
    preferences.remove(secureModeKey);
    preferences.remove(scopesKey);
  }

  Future<AccessToken> toCache(AccessTokenResponse response) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(atKey, response.accessToken);
    preferences.setInt(atExpiresAtKey,
        DateTime.now().millisecondsSinceEpoch + response.expiresIn * 1000);
    if (response.refreshToken != null) {
      preferences.setString(rtKey, response.refreshToken);
      preferences.setInt(
          rtExpiresAtKey,
          DateTime.now().millisecondsSinceEpoch +
              response.refreshTokenExpiresIn * 1000);
    }
    if (response.scopes != null) {
      preferences.setStringList(scopesKey, response.scopes.split(' '));
    }
    return fromCache();
  }

  Future<AccessToken> fromCache() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String accessToken = preferences.getString(atKey);
    int atExpiresAtMillis = preferences.getInt(atExpiresAtKey);

    DateTime accessTokenExpiresAt = atExpiresAtMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(atExpiresAtMillis)
        : null;
    String refreshToken = preferences.getString(rtKey);
    int rtExpiresAtMillis = preferences.getInt(rtExpiresAtKey);
    DateTime refreshTokenExpiresAt = rtExpiresAtMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(rtExpiresAtMillis)
        : null;
    List<String> scopes = preferences.getStringList(scopesKey);

    return AccessToken(accessToken, accessTokenExpiresAt, refreshToken,
        refreshTokenExpiresAt, scopes);
  }
}
