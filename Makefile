AWS ?= aws
MINIFIER ?= html-minifier-terser

# Source and Build Directories
BUILD_DIR := build
SOURCE_DIR := source

# List of base names for the HTML files (without extension)
TARGETS := tiktok reddit

# Generate the full paths to the target HTML files
HTML_FILES := $(patsubst %,$(BUILD_DIR)/%.html,$(TARGETS))

# AWS Upload Configuration (overrideable via environment or command line)
# Example: make AWS_PROFILE=my_other_profile upload
AWS_PROFILE ?= cloudflare-r2
AWS_ENDPOINT_URL ?= "https://262cf8aeb384b1f034577956e3baa60a.r2.cloudflarestorage.com"
S3_BUCKET := s3://rwx-pub

# Default target: build all HTML files
all: $(HTML_FILES)

# Pattern rule to build any .html file in the BUILD_DIR
$(BUILD_DIR)/%.html: $(SOURCE_DIR)/player.html | $(BUILD_DIR)
	@echo "Generating $@"
	sed 's/%%VIDEO_BASE_DIR%%/$(*F)/g' "$<" | \
		$(MINIFIER) \
			--collapse-whitespace \
			--minify-js true \
			--minify-css true \
			--minify-urls true \
			--remove-optional-tags \
		> "$@"

# Rule to create the build directory
# This is triggered by the order-only prerequisite in the pattern rule above.
$(BUILD_DIR):
	@echo "Creating directory $@"
	mkdir -p "$@"

.PHONY: upload
upload: all
	@echo "Uploading files to $(S3_BUCKET)..."
	$(foreach target,$(TARGETS), \
		echo "Uploading $(BUILD_DIR)/$(target).html to $(S3_BUCKET)/$(target)"; \
		$(AWS) --profile "$(AWS_PROFILE)" --endpoint-url "$(AWS_ENDPOINT_URL)" s3 cp \
			"$(BUILD_DIR)/$(target).html" "$(S3_BUCKET)/$(target)" \
			--content-type "text/html" || exit 1; \
	)
	@echo "Upload complete."

.PHONY: clean
clean:
	@echo "Cleaning build directory: $(BUILD_DIR)"
	rm -rf "$(BUILD_DIR)"

# Prevent Make from deleting intermediate files and ensure recipes failing mid-way
# delete the target file to avoid corrupted output.
.SECONDARY:
.DELETE_ON_ERROR:
