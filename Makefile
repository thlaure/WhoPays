SHELL := /bin/zsh

PROJECT := TabTaker.xcodeproj
SCHEME := TabTaker
DESTINATION ?= platform=iOS Simulator,name=iPhone 17 Pro,OS=latest
BUILD_ROOT := .build
DERIVED_DATA := $(BUILD_ROOT)/DerivedData
RESULT_BUNDLE := $(BUILD_ROOT)/TestResults.xcresult
SWIFT_SOURCE_DIRECTORIES := TabTaker TabTakerTests GameCore/Sources GameCore/Tests
CORE_PACKAGE := GameCore

.PHONY: format lint core-test core-coverage fast-quality ios-analyze ios-test ios-quality quality clean

format:
	xcrun swift-format format --in-place --recursive $(SWIFT_SOURCE_DIRECTORIES)

lint:
	xcrun swift-format lint --strict --recursive $(SWIFT_SOURCE_DIRECTORIES)
	PYTHONPYCACHEPREFIX="$(BUILD_ROOT)/PythonCache" python3 -m py_compile scripts/check_coverage.py

core-test:
	swift test --package-path "$(CORE_PACKAGE)" --enable-code-coverage

core-coverage:
	python3 scripts/check_coverage.py "$(CORE_PACKAGE)"

fast-quality: lint core-test core-coverage

ios-analyze:
	xcodebuild analyze -quiet \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-destination "$(DESTINATION)" \
		-derivedDataPath "$(DERIVED_DATA)" \
		CODE_SIGNING_ALLOWED=NO

ios-test:
	mkdir -p "$(BUILD_ROOT)"
	rm -rf "$(RESULT_BUNDLE)"
	xcodebuild test -quiet \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-destination "$(DESTINATION)" \
		-derivedDataPath "$(DERIVED_DATA)" \
		-resultBundlePath "$(RESULT_BUNDLE)" \
		-enableCodeCoverage YES \
		CODE_SIGNING_ALLOWED=NO

ios-quality: ios-analyze ios-test

quality: fast-quality ios-quality

clean:
	rm -rf "$(BUILD_ROOT)"
