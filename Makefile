.DEFAULT_GOAL := usage

setup:
	cp ios/Flutter/Development.xcconfig.example ios/Flutter/Development.xcconfig
	cp ios/Flutter/Staging.xcconfig.example ios/Flutter/Staging.xcconfig
	cp ios/Flutter/Production.xcconfig.example ios/Flutter/Production.xcconfig

clean:
	flutter clean

run:
	flutter run --debug --flavor development --dart-define=FLAVOR=development

usage:
	@echo usage: [setup, clean, run]