SHELL := /bin/zsh

PROJECT := WhoPays.xcodeproj
SCHEME := WhoPays
DESTINATION ?= platform=iOS Simulator,name=iPhone 17 Pro,OS=latest
BUILD_ROOT := .build
DERIVED_DATA := $(BUILD_ROOT)/DerivedData
RESULT_BUNDLE := $(BUILD_ROOT)/TestResults.xcresult
SWIFT_SOURCE_DIRECTORIES := WhoPays WhoPaysTests

.PHONY: format lint analyze test coverage quality clean

format:
	xcrun swift-format format --in-place --recursive $(SWIFT_SOURCE_DIRECTORIES)

lint:
	xcrun swift-format lint --strict --recursive $(SWIFT_SOURCE_DIRECTORIES)
	PYTHONPYCACHEPREFIX="$(BUILD_ROOT)/PythonCache" python3 -m py_compile scripts/check_coverage.py

analyze:
	xcodebuild analyze -quiet \
		-project "$(PROJECT)" \
		-scheme "$(SCHEME)" \
		-destination "$(DESTINATION)" \
		-derivedDataPath "$(DERIVED_DATA)" \
		CODE_SIGNING_ALLOWED=NO

test:
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

coverage:
	python3 scripts/check_coverage.py "$(RESULT_BUNDLE)"

quality: lint analyze test coverage

clean:
	rm -rf "$(BUILD_ROOT)"
