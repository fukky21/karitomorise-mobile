# karitomorise-mobile

## Firebase Projects
- [karitomorise-dev](https://console.firebase.google.com/u/0/project/karitomorise-dev/overview)
- [karitomorise-stg](https://console.firebase.google.com/u/0/project/karitomorise-stg/overview)
- [karitomorise](https://console.firebase.google.com/u/0/project/karitomorise/overview)

## Setup
### 環境変数ファイルを生成
```
$ cp .env.sample .env
```

### xcconfigを設定
以下のコマンドで`ios/Flutter`ディレクトリに`Development.xcconfig`, `Staging.xcconfig`, `Production.xcconfig`を作成する
```
$ make setup
```

### Firebaseを設定
#### iOS
各Firebase Projectから`GoogleService-Info.plist`をダウンロードして`ios/Runner/Firebase`ディレクトリに

- `GoogleService-Info-Development.plist`
- `GoogleService-Info-Staging.plist`
- `GoogleService-Info-Production.plist`

と名前を変更して配置する

#### Android
各Firebase Projectから`google-services.json`をダウンロードして

- `android/app/src/development`
- `android/app/src/staging`
- `android/app/src/production`

にそれぞれ配置する

## Development
エミュレータでアプリをビルド&インストール&実行
```
$ make run
```

実機でアプリをビルド&インストール&実行
```
$ flutter run --release --flavor development --dart-define=FLAVOR=development
```

## Staging
実機でアプリをビルド&インストール&実行
```
$ flutter run --release --flavor staging --dart-define=FLAVOR=staging
```

## Production
実機でアプリをビルド&インストール&実行
```
$ flutter run --release --flavor production --dart-define=FLAVOR=production
```
