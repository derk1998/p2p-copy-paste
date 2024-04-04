# Makefile for deploying the Flutter web projects to GitHub
# Taken from https://codewithandrea.com/articles/flutter-web-github-pages/

GITHUB_USER = derk1998
GITHUB_REPO = git@github.com:$(GITHUB_USER)/$(OUTPUT)
BUILD_VERSION := $(shell grep 'version:' pubspec.yaml | awk '{print $$2}' | cut -d+ -f1)

build_android:
	@echo "Clean existing repository"
	flutter clean

	@echo "Getting packages..."
	flutter pub get

	@echo "Building appbundle..."
	flutter build appbundle --obfuscate --split-debug-info=debug_symbols/$(BUILD_VERSION)

# Deploy the Flutter web project to GitHub
deploy_web:
ifndef OUTPUT
	$(error OUTPUT is not set. Usage: make deploy OUTPUT=<output_repo_name>)
endif
	@echo "Clean existing repository"
	flutter clean

	@echo "Getting packages..."
	flutter pub get

	mkdir -p build
	git clone $(GITHUB_REPO) build/web

	@echo "Building for web with canvaskit..."
	flutter build web --release --web-renderer canvaskit

	@echo "Deploying to git repository"
	cd build/web && \
	git add . && \
	git commit -m "Deploy Version $(BUILD_VERSION)" && \
	git push origin HEAD

	@echo "✅ Finished deploy: $(GITHUB_REPO)"
	@echo "🚀 Flutter web URL: https://$(GITHUB_USER).github.io/$(OUTPUT)/"

.PHONY: deploy_web build_android