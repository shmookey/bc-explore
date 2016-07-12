# Makefile for Elm app

NAME = BlockchainExplorer
MAIN = Main

# Build configuration
VPATH = src
CWD = $(shell pwd)


# Files and directories
########################################################################

# Sources
SRC_HTML = $(shell find src/html -type f -name "*.html" | sed -e 's|src/||' | xargs echo)
SRC_SASS = $(shell find src/sass -type f -name "*.scss" | sed -e 's|src/||' | xargs echo)
SRC_ELM = $(shell find src/elm -type f -name "*.elm" | sed -e 's|src/||' | xargs echo)

# Objects (web assets)
WEB = $(HTML) $(JS) $(CSS)
HTML = $(BUILD)/
JS = $(BUILD)/app.js
CSS = $(BUILD)/style.css

# Build directories
BUILD = build


# Rules
########################################################################

# Aliases
web: $(WEB)

# Objects
$(CSS): $(SRC_SASS) | $(BUILD)
	scss -I src/sass src/sass/main.scss $(CSS)

$(JS): $(SRC_ELM) | $(BUILD)
	elm-make src/elm/$(MAIN).elm --output $(JS)

$(HTML): $(SRC_HTML) | $(BUILD)
	cp src/html/* $(HTML)

# Directories
$(BUILD):
	mkdir $(BUILD)

# Utilities
clean:
	rm -rf build/

