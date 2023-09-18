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

define PKG_CONFIG_SRC
prefix=$(PREFIX)
exec_prefix=$${prefix}
includedir=$(PREFIX)/include
libdir=$(PREFIX)/lib

Name: $(LIB_NAME)
Description: Vulkan/GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specifications for multiple languages.
Version: $(MAJOR_VERSION).$(MINOR_VERSION)
Cflags: -I$${includedir}
Libs: -L$${libdir} -l$(LIB_NAME)
endef

LIBINFO_FILENAME = $(LIB_NAME).pc

define MAKE_INSTALL_SRC
.PHONY: install uninstall
install:
	@printf 'Installing library files to $(PREFIX)...\n'
	@cp -r ./include/* $(PREFIX)/include;\
		cp ./$(STATIC_ARCHIVE_NAME) $(PREFIX)/lib;\
		cp ./$(LIBINFO_FILENAME) $(PKG_CONFIG_LIBINFO_DIR)
	@printf 'Installation complete.\n'
	@printf 'To uninstall $(LIB_NAME), run `sudo make uninstall`.\n'
uninstall:
	@printf 'Uninstalling library files from $(PREFIX)...\n'
	@rm -rf $(LIB_INCLUDES)\
		$(PREFIX)/lib/$(STATIC_ARCHIVE_NAME)\
		$(PKG_CONFIG_LIBINFO_DIR)/$(LIBINFO_FILENAME)
	@printf 'Uninstallation complete.\n'
endef

# NOTE: Possible antipattern; relative include directory is copied into ./build although a manual include directory is defined at the top of the file.

SRCS = $(wildcard src/*.c)
_OBJS = $(subst src/,$(BUILD_DIR)/,$(SRCS))
OBJS = $(_OBJS:.c=.o)

LIB_OUT = $(BUILD_DIR)/$(STATIC_ARCHIVE_NAME)
PKG_CONFIG_FILE = $(BUILD_DIR)/$(LIBINFO_FILENAME)
INSTALL_MAKEFILE = $(BUILD_DIR)/Makefile
GENERATED_INCLUDES = $(BUILD_DIR)/include

default: $(PKG_CONFIG_LIBINFO_DIR) $(LIB_OUT) $(PKG_CONFIG_FILE) $(INSTALL_MAKEFILE) $(GENERATED_INCLUDES)
	@printf 'Library files generated.\n'
	@printf 'Run `sudo make install` in $(BUILD_DIR) to install $(LIB_NAME)\n'

$(PKG_CONFIG_LIBINFO_DIR):
	$(error PKG_CONFIG_LIBINFO_DIR ($(PKG_CONFIG_LIBINFO_DIR))\
		is not a directory)

$(PKG_CONFIG_FILE):
	$(file > $@,$(PKG_CONFIG_SRC))

$(INSTALL_MAKEFILE):
	$(file > $@,$(MAKE_INSTALL_SRC))

$(GENERATED_INCLUDES):
	@cp -r $(INCLUDES) $(BUILD_DIR)

$(LIB_OUT): $(BUILD_DIR) $(OBJS)
	@printf 'Building library archive...\n'
	@ar rvcs $(LIB_OUT) $(OBJS)
	@printf 'Archive written to $(LIB_OUT)\n'

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

# TODO: Read up on static pattern rules https://www.gnu.org/software/make/manual/make.html#Static-Pattern
$(OBJS): build/%.o : src/%.c | $(BUILD_DIR)
	@printf '$< → $@... '
	@$(CC) -c -o $@ $(addprefix -I,$(INCLUDES)) $<
	@printf '✓\n'

#$(LIB_OUT): $(BUILD_DIR) $(OBJS):
#	@printf 'Building library archive...\n'
#	@ar rvcs $(LIB_OUT) $(OBJS)
#	@printf 'Archive written to $(LIB_OUT)\n'

#$(OBJS): $(SRCS)
#	@printf '$< → $@... '
#	@$(CC) -c -o $@ $<
#	@printf '✓\n'

#$(BUILD_DIR):
#	@mkdir $(BUILD_DIR)

.PHONY = clean
clean:
	@rm -rf $(BUILD_DIR)

