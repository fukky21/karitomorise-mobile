String blankValidator(String text) {
  if (text.isEmpty) {
    return '入力してください';
  }
  return null;
}

String maxLengthValidator(String text, int maxLength) {
  if (text.length > maxLength) {
    return '$maxLength文字以内で入力してください';
  }
  return null;
}

String rangeLengthValidator(String text, int minLength, int maxLength) {
  if (text.length < minLength || text.length > maxLength) {
    return '$minLength文字以上$maxLength文字以内で入力してください';
  }
  return null;
}

String emailFormatValidator(String email) {
  /// メールアドレスの正規表現
  /// https://techacademy.jp/magazine/33601
  const format =
      r'^[A-Za-z0-9]{1}[A-Za-z0-9_.-]*@{1}[A-Za-z0-9_.-]{1,}\.[A-Za-z0-9]{1,}$';
  if (!RegExp(format).hasMatch(email)) {
    return 'メールアドレスの形式が正しくありません';
  }
  return null;
}

String passwordFormatValidator(String password) {
  /// 半角英小文字大文字数字をそれぞれ1種類以上含む8文字以上20文字以下の正規表現
  /// https://qiita.com/mpyw/items/886218e7b418dfed254b
  const format = r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]{8,20}$';
  if (!RegExp(format).hasMatch(password)) {
    return 'パスワードの形式が正しくありません';
  }
  return null;
}

String confirmPasswordValidator(String password, String confirmPassword) {
  if (password != confirmPassword) {
    return 'パスワードとパスワード(確認)が一致しません';
  }
  return null;
}
