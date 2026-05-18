# Makefile para kchangelog — monitor de changelogs del kernel Ubuntu
# Autor: Iván Ezequiel Rodriguez
# https://github.com/IRodriguez13/kchangelog

# Variables de configuración
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SCRIPT = kchangelog
MANDIR ?= $(PREFIX)/share/man/man1
BASH_COMP_DIR ?= /usr/share/bash-completion/completions
ZSH_COMP_DIR ?= $(PREFIX)/share/zsh/site-functions
FISH_COMP_DIR ?= $(PREFIX)/share/fish/vendor_completions.d

# Rutas de Systemd del usuario
SYSTEMD_USER_DIR = $(HOME)/.config/systemd/user

.PHONY: all install install-script install-service uninstall uninstall-script uninstall-service check-flags test-notify help

all: help

help:
	@echo "Opciones disponibles en el Makefile:"
	@echo "  make check-flags       - Verifica que el script y sus flags esenciales funcionen correctamente"
	@echo "  make test-notify       - Envía una notificación de prueba para verificar la integración visual"
	@echo "  make install           - Instala el script (requiere sudo) y configura el servicio systemd del usuario"
	@echo "  make install-script    - Instala únicamente el script en $(BINDIR) (suele requerir sudo)"
	@echo "  make install-service   - Instala únicamente el servicio systemd y el timer para el usuario actual"
	@echo "  make uninstall         - Elimina por completo el script y el servicio systemd"
	@echo "  make uninstall-script  - Desinstala únicamente el script de $(BINDIR)"
	@echo "  make uninstall-service - Desinstala y limpia el servicio systemd y el timer"

# 1. Verificación de flags funcionales
check-flags:
	@echo "Verificando el correcto funcionamiento de las flags de kchangelog..."
	@bash ./$(SCRIPT) --version > /dev/null || (echo "Error: La flag --version no está funcional" && exit 1)
	@bash ./$(SCRIPT) --help > /dev/null || (echo "Error: La flag --help no está funcional" && exit 1)
	@bash ./$(SCRIPT) --list-subs > /dev/null || (echo "Error: La flag --list-subs no está funcional" && exit 1)
	@bash ./$(SCRIPT) --list-available > /dev/null || (echo "Error: La flag --list-available no está funcional" && exit 1)
	@bash ./$(SCRIPT) --color=never --version > /dev/null || (echo "Error: La flag --color no está funcional" && exit 1)
	@bash ./$(SCRIPT) --grep="test" --version > /dev/null || (echo "Error: La flag --grep no está funcional" && exit 1)
	@bash ./$(SCRIPT) --json --version > /dev/null || (echo "Error: La flag --json no está funcional" && exit 1)
	@echo "✓ Todas las flags se verificaron y están 100% funcionales."

# 2. Prueba de notificaciones de escritorio
test-notify:
	@echo "Probando sistema de notificaciones de kchangelog..."
	@if command -v notify-send > /dev/null; then \
		echo "Enviando notificación de prueba..."; \
		DISPLAY="$${DISPLAY:-:0}" \
		DBUS_SESSION_BUS_ADDRESS="$${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$$(id -u)/bus}" \
		notify-send \
			--urgency=normal \
			--icon=system-software-update \
			--app-name="kchangelog" \
			"kchangelog — Notificación de Prueba" \
			"¡Excelente! Tu entorno de escritorio recibe notificaciones de kchangelog de forma correcta."; \
		echo "✓ Notificación enviada con éxito."; \
		echo "Si no ves la alerta emergente, verifica que tu entorno de escritorio no esté en modo 'No Molestar'."; \
	else \
		echo "✗ Error: El comando 'notify-send' (libnotify-bin) no está instalado en el sistema."; \
		echo "Instálalo ejecutando: sudo apt install libnotify-bin"; \
		exit 1; \
	fi

# 2. Instalación del Script
install-script: check-flags
	@echo "Instalando script en $(DESTDIR)$(BINDIR)..."
	mkdir -p $(DESTDIR)$(BINDIR)
	cp $(SCRIPT) $(DESTDIR)$(BINDIR)/$(SCRIPT)
	chmod 755 $(DESTDIR)$(BINDIR)/$(SCRIPT)
	@echo "✓ Script kchangelog instalado correctamente en $(DESTDIR)$(BINDIR)/$(SCRIPT)."
	@echo "Instalando manpage en $(DESTDIR)$(MANDIR)..."
	mkdir -p $(DESTDIR)$(MANDIR)
	cp $(SCRIPT).1 $(DESTDIR)$(MANDIR)/$(SCRIPT).1
	chmod 644 $(DESTDIR)$(MANDIR)/$(SCRIPT).1
	@echo "✓ Manpage kchangelog.1 instalada en $(DESTDIR)$(MANDIR)/$(SCRIPT).1."
	@echo "Instalando autocompletado de Bash en $(DESTDIR)$(BASH_COMP_DIR)..."
	mkdir -p $(DESTDIR)$(BASH_COMP_DIR)
	cp $(SCRIPT)-completion.bash $(DESTDIR)$(BASH_COMP_DIR)/$(SCRIPT)
	chmod 644 $(DESTDIR)$(BASH_COMP_DIR)/$(SCRIPT)
	@echo "✓ Autocompletado de Bash instalado."
	@echo "Instalando autocompletado de Zsh en $(DESTDIR)$(ZSH_COMP_DIR)..."
	mkdir -p $(DESTDIR)$(ZSH_COMP_DIR)
	cp _$(SCRIPT) $(DESTDIR)$(ZSH_COMP_DIR)/_$(SCRIPT)
	chmod 644 $(DESTDIR)$(ZSH_COMP_DIR)/_$(SCRIPT)
	@echo "✓ Autocompletado de Zsh instalado."
	@echo "Instalando autocompletado de Fish en $(DESTDIR)$(FISH_COMP_DIR)..."
	mkdir -p $(DESTDIR)$(FISH_COMP_DIR)
	cp $(SCRIPT).fish $(DESTDIR)$(FISH_COMP_DIR)/$(SCRIPT).fish
	chmod 644 $(DESTDIR)$(FISH_COMP_DIR)/$(SCRIPT).fish
	@echo "✓ Autocompletado de Fish instalado."

# 3. Instalación del Servicio Systemd
install-service:
	@echo "Instalando el servicio y timer systemd para el usuario actual..."
	@if [ -f "$(DESTDIR)$(BINDIR)/$(SCRIPT)" ]; then \
		"$(DESTDIR)$(BINDIR)/$(SCRIPT)" --install-service; \
	elif [ -f "./$(SCRIPT)" ]; then \
		./$(SCRIPT) --install-service; \
	else \
		echo "Error: No se encontró el ejecutable kchangelog en $(DESTDIR)$(BINDIR) ni en el directorio actual."; \
		exit 1; \
	fi

# 4. Instalación completa (Script + Servicio)
install: install-script
	@echo "Configurando servicio systemd..."
	@if [ "$$(id -u)" -eq 0 ]; then \
		if [ -n "$$SUDO_USER" ]; then \
			echo "Detectado uso de sudo. Instalando el servicio para el usuario: $$SUDO_USER..."; \
			sudo -u $$SUDO_USER DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$$(id -u $$SUDO_USER)/bus "$(DESTDIR)$(BINDIR)/$(SCRIPT)" --install-service || \
			sudo -u $$SUDO_USER "$(DESTDIR)$(BINDIR)/$(SCRIPT)" --install-service; \
		else \
			echo "ADVERTENCIA: Ejecutando como root pero no se detectó la variable SUDO_USER."; \
			echo "El servicio systemd se instalará para el usuario root."; \
			"$(DESTDIR)$(BINDIR)/$(SCRIPT)" --install-service; \
		fi \
	else \
		"$(DESTDIR)$(BINDIR)/$(SCRIPT)" --install-service; \
	fi
	@echo "✓ Instalación completa finalizada con éxito."

# 5. Desinstalación del Script
uninstall-script:
	@echo "Eliminando script de $(DESTDIR)$(BINDIR)..."
	rm -f $(DESTDIR)$(BINDIR)/$(SCRIPT)
	@echo "✓ Script desinstalado de $(DESTDIR)$(BINDIR)/$(SCRIPT)."
	@echo "Eliminando manpage de $(DESTDIR)$(MANDIR)..."
	rm -f $(DESTDIR)$(MANDIR)/$(SCRIPT).1
	@echo "✓ Manpage desinstalada."
	@echo "Eliminando autocompletados..."
	rm -f $(DESTDIR)$(BASH_COMP_DIR)/$(SCRIPT)
	rm -f $(DESTDIR)$(ZSH_COMP_DIR)/_$(SCRIPT)
	rm -f $(DESTDIR)$(FISH_COMP_DIR)/$(SCRIPT).fish
	@echo "✓ Autocompletados desinstalados."

# 6. Desinstalación del Servicio Systemd
uninstall-service:
	@echo "Removiendo el servicio y timer systemd..."
	@if [ -x "$(DESTDIR)$(BINDIR)/$(SCRIPT)" ]; then \
		"$(DESTDIR)$(BINDIR)/$(SCRIPT)" --remove-service; \
	elif [ -x "./$(SCRIPT)" ]; then \
		./$(SCRIPT) --remove-service; \
	else \
		echo "Ejecutable no encontrado. Eliminando archivos de servicio manualmente..."; \
		rm -f $(SYSTEMD_USER_DIR)/kchangelog.service $(SYSTEMD_USER_DIR)/kchangelog.timer; \
		systemctl --user daemon-reload 2>/dev/null || true; \
	fi
	@echo "✓ Servicio systemd desinstalado."

# 7. Desinstalación completa (Script + Servicio)
uninstall: uninstall-service uninstall-script
	@echo "✓ Desinstalación completa finalizada."
