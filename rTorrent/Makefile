BIN_NAME := script/magnet_to_torrent.bash
SERVER_JSON := server/package.json
SERVER_JS := server/server.js
DESTDIR = /
INSTALL_PREFIX = usr/local 
.SUFFIXES:
INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 664
INSTALL_DIR = $(INSTALL) -m 774
RM = -rm

.PHONY: install
install:
	@echo "Installing to $(DESTDIR)$(INSTALL_PREFIX)/"
	@$(INSTALL_DIR) -d $(DESTDIR)$(INSTALL_PREFIX)/magnet/script
	@$(INSTALL_PROGRAM) $(BIN_NAME) $(DESTDIR)$(INSTALL_PREFIX)/magnet/script
	@$(INSTALL_DIR) -d $(DESTDIR)$(INSTALL_PREFIX)/magnet/server
	@$(INSTALL_DATA) $(SERVER_JSON) $(DESTDIR)$(INSTALL_PREFIX)/magnet/server
	@$(INSTALL_DATA) $(SERVER_JS) $(DESTDIR)$(INSTALL_PREFIX)/magnet/server
	

.PHONY: deinstall
deinstall:
	@echo "Removing $(DESTDIR)$(INSTALL_PREFIX)/$(BIN_NAME)"
	@$(RM) -rf $(DESTDIR)$(INSTALL_PREFIX)/magnet

.PHONY config
config:
	@echo "Installing rtorrent.rc"
	sed -e s/\\\$DATA_PATH\\\$/GG/g rtorrent/.rtorrent.rc.source	
