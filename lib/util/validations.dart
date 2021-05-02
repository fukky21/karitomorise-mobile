import 'package:flutter/material.dart';

class Validations {
  static String blank({@required String text}) {
    if (text.isEmpty) {
      return '入力してください';
    }
    return null;
  }

  static String maxLength({@required String text, @required int maxLength}) {
    if (text.length > maxLength) {
      return '$maxLength文字以内で入力してください';
    }
    return null;
  }

  static String rangeLength({
    @required String text,
    @required int minLength,
    @required int maxLength,
  }) {
    if (text.length < minLength || text.length > maxLength) {
      return '$minLength文字以上$maxLength文字以内で入力してください';
    }
    return null;
  }

  static String emailFormat({@required String email}) {
    /// メールアドレスの正規表現
    /// https://techacademy.jp/magazine/33601
    const format =
        r'^[A-Za-z0-9]{1}[A-Za-z0-9_.-]*@{1}[A-Za-z0-9_.-]{1,}\.[A-Za-z0-9]{1,}$';
    if (!RegExp(format).hasMatch(email)) {
      return 'メールアドレスの形式が正しくありません';
    }
    return null;
  }

  static String passwordFormat({@required String password}) {
    /// 半角英小文字大文字数字をそれぞれ1種類以上含む8文字以上20文字以下の正規表現
    /// https://qiita.com/mpyw/items/886218e7b418dfed254b
    const format = r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]{8,20}$';
    if (!RegExp(format).hasMatch(password)) {
      return 'パスワードの形式が正しくありません';
    }
    return null;
  }

  static String confirmPassword({
    @required String password,
    @required String confirmPassword,
  }) {
    if (password != confirmPassword) {
      return 'パスワードとパスワード(確認)が一致しません';
    }
    return null;
  }
}
