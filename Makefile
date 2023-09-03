CC = gcc
BUILD_DIR = ./build
SOURCE_DIR = src
INCLUDES = ./include

PKG_CONFIG_LIBINFO_DIR = /usr/local/lib/pkgconfig
STATIC_ARCHIVE_NAME = libglad.a

# TODO: Shared library install setup
# NOTE: This is largely incomplete, presently in the "it works on my system" phase. PRs welcome.
# TODO: Clean and organize the order of variables/macros here maybe

# Library pkg-config
PREFIX = /usr/local
LIB_NAME = glad
MAJOR_VERSION = 2
MINOR_VERSION = 0

# Funny workaround to check if KHR exists.
# If a more intuitive solution exists please PR.
LIB_INCLUDES = $(addprefix $(PREFIX)/include/, $(shell ls include))

define PKG_CONFIG
prefix=$(PREFIX)
exec_prefix=$${prefix}
includedir=$(PREFIX)/include
libdir=$(PREFIX)/lib

Name: $(LIB_NAME)
Description: Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specifications for multiple languages.
Version: $(MAJOR_VERSION).$(MINOR_VERSION)
Cflags: -I$${includedir}
Libs: -L$${libdir}
endef

LIBINFO_FILENAME = $(LIB_NAME).pc

define MAKE_INSTALL
.PHONY: install uninstall
install:
	@printf 'Installing library files to $(PREFIX)...\n'
	@cp -r ./include/* $(PREFIX)/include;\
		cp ./$(STATIC_ARCHIVE_NAME) $(PREFIX)/lib;\
		cp ./$(LIBINFO_FILENAME) $(PKG_CONFIG_LIBINFO_DIR)
	@printf 'Installation complete.\n'
uninstall:
	@printf 'Uninstalling library files from $(PREFIX)...\n'
	@rm -rf $(LIB_INCLUDES)\
		$(PREFIX)/lib/$(STATIC_ARCHIVE_NAME)\
		$(PKG_CONFIG_LIBINFO_DIR)/$(LIBINFO_FILENAME)
	@printf 'Uninstallation complete.\n'
endef

# NOTE: Possible antipattern; relative include directory is copied into ./build although a manual include directory is defined at the top of the file.

default: $(BUILD_DIR)
	@printf '$(LIB_INCLUDES)\n'
	@printf 'Compiling glad.c...\n'
	@$(CC) -c -o $(BUILD_DIR)/glad.o $(SOURCE_DIR)/glad.c \
		$(addprefix -I, $(INCLUDES))
	@printf 'Archiving glad.o...\n'
	@cd $(BUILD_DIR);\
		ar rcs $(STATIC_ARCHIVE_NAME) glad.o;\
		rm ./glad.o;\
		cp -r ../include .;
	@printf '$(STATIC_ARCHIVE_NAME) created.\n'
	$(file > $(BUILD_DIR)/$(LIBINFO_FILENAME),$(PKG_CONFIG))
	@printf '$(BUILD_DIR)/$(LIBINFO_FILENAME) created.\n'
	$(file > $(BUILD_DIR)/Makefile,$(MAKE_INSTALL))
	@printf '$(BUILD_DIR)/Makefile generated.\n'
	@printf 'Run `sudo make install` in $(BUILD_DIR) to install $(LIB_NAME).\n'

$(BUILD_DIR):
	@mkdir $(BUILD_DIR)

.PHONY = clean
clean:
	@rm -rf $(BUILD_DIR)

