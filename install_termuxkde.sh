#!/bin/bash

# ════════════════════════════════════════════════
#   TermuxKDE Installer — by xenoZ0x (c) 2026
# ════════════════════════════════════════════════

LOG="$HOME/termuxkde_error.log"
START_TIME=$(date +%s)
BYTES_BEFORE=$(cat /proc/net/dev 2>/dev/null | awk '/wlan0|rmnet/{sum+=$2} END{print sum+0}')

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

_task_label=""

# ── Output helpers ────────────────────────────────
info()  { echo -e "${CYAN}[*]${RESET} $1"; }
step()  { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }

# task "Pending label" "Description shown while running"
task() {
  _task_label="$1"
  echo -e "${CYAN}[*]${RESET} $1"
  echo -e "${DIM}    └─ $2${RESET}"
}

# task_done "Completed label"
task_done() {
  printf "\033[2A\r\033[2K${GREEN}[✓]${RESET} %b\n\r\033[2K" "$1"
  _task_label=""
}

# error "Failure label"   (rewrites pending line with [✗], then exits)
error() {
  if [[ -n "$_task_label" ]]; then
    printf "\033[2A\r\033[2K${RED}[✗]${RESET} %b${DIM} — cat ~/termuxkde_error.log${RESET}\n\r\033[2K" "$1"
    _task_label=""
  else
    echo -e "${RED}[✗]${RESET} $1${DIM} — cat ~/termuxkde_error.log${RESET}"
  fi
  exit 1
}

# ── Terminal Size Check ───────────────────────────
REQUIRED_COLS=88
REQUIRED_LINES=35

check_terminal_size() {
  local cols lines
  cols=$(tput cols 2>/dev/null || echo "${COLUMNS:-0}")
  lines=$(tput lines 2>/dev/null || echo "${LINES:-0}")

  if [[ "$cols" -lt "$REQUIRED_COLS" || "$lines" -lt "$REQUIRED_LINES" ]]; then
    clear
    echo -e "${RED}${BOLD}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║        Terminal Size Too Small!          ║"
    echo "  ╚══════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "  ${DIM}Current size :${RESET} ${RED}${BOLD}${cols}x${lines}${RESET}"
    echo -e "  ${DIM}Required     :${RESET} ${GREEN}${BOLD}${REQUIRED_COLS}x${REQUIRED_LINES}${RESET}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}How to resize in Termux:${RESET}"
    echo -e "  ${DIM}1. Pinch-zoom out on your keyboard to shrink font size${RESET}"
    echo -e "  ${DIM}2. Or long-press on the terminal → More → Resize Terminal${RESET}"
    echo -e "  ${DIM}3. Or run this command to set font size manually:${RESET}"
    echo ""
    echo -e "     ${CYAN}tput reset${RESET}"
    echo -e "     ${CYAN}# Then pinch-zoom until you see ${REQUIRED_COLS}x${REQUIRED_LINES}${RESET}"
    echo ""
    echo -e "  ${DIM}Check current size anytime with:${RESET}"
    echo -e "     ${CYAN}echo \"\${COLUMNS}x\${LINES}\"${RESET}"
    echo ""
    echo -e "  ${DIM}Once resized, re-run the installer:${RESET}"
    echo -e "     ${CYAN}bash install_termuxkde.sh${RESET}"
    echo ""
    exit 1
  fi
}

# ── Detect Shell ──────────────────────────────────
detect_shell() {
  if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
    SHELL_NAME="zsh"
  else
    RC_FILE="$HOME/.bashrc"
    SHELL_NAME="bash"
  fi
}

# ── Banner ────────────────────────────────────────
show_banner() {
  clear
  echo -e "${BOLD}${CYAN}"
  echo "  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗██╗  ██╗██████╗ ███████╗"
  echo "  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝██║ ██╔╝██╔══██╗██╔════╝"
  echo "     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ █████╔╝ ██║  ██║█████╗  "
  echo "     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ ██╔═██╗ ██║  ██║██╔══╝  "
  echo "     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗██║  ██╗██████╔╝███████╗"
  echo "     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝"
  echo -e "${RESET}"
  echo -e "${YELLOW}KDE Plasma for Termux${RESET} ${DIM}by xenoZ0x (c) 2026${RESET}"
}

# ── Confirmation ──────────────────────────────────
confirm() {
  echo -e "${DIM}Shell: ${SHELL_NAME} → ${RC_FILE}${RESET}"
  echo -ne "${YELLOW}Continue? [Y/n]:${RESET} "
  read -r CHOICE
  case "$CHOICE" in
    Y|y|"") echo -e "${GREEN}Starting...${RESET}\n" ;;
    *)       echo -e "${RED}Cancelled.${RESET}"; exit 0 ;;
  esac
}

# ── Silent pkg wrapper ────────────────────────────
# pkg_silent "Pending" "Description" "Done" "Fail" install <pkg>
pkg_silent() {
  local pending="$1" desc="$2" done_label="$3" fail_label="$4"; shift 4
  task "$pending" "$desc"
  DEBIAN_FRONTEND=noninteractive yes | pkg "$@" \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    >> "$LOG" 2>&1 || error "$fail_label"
  task_done "$done_label"
}

# ── Steps ─────────────────────────────────────────
update_system() {
  step "Update & Upgrade"

  task "Updating package lists" "Fetching latest index from Termux repos..."
  DEBIAN_FRONTEND=noninteractive yes | pkg update >> "$LOG" 2>&1 \
    || error "Failed to update package lists"
  task_done "Package lists updated"

  task "Upgrading packages" "Upgrading all outdated packages..."
  DEBIAN_FRONTEND=noninteractive yes | pkg upgrade \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    >> "$LOG" 2>&1 || error "Failed to upgrade packages"
  task_done "Packages upgraded"
}

install_x11() {
  step "X11 Setup"
  pkg_silent \
    "Installing x11-repo"            "Adding Termux X11 package repository..."         \
    "x11-repo added"                 "Failed to install x11-repo"                      \
    install x11-repo
  pkg_silent \
    "Installing termux-x11-nightly"  "Installing X11 display bridge for Termux:X11..."  \
    "termux-x11-nightly installed"   "Failed to install termux-x11-nightly"             \
    install termux-x11-nightly
}

install_kde() {
  step "KDE Plasma"
  pkg_silent \
    "Installing Plasma desktop"      "Installing KDE shell, window manager, core components..." \
    "Plasma desktop installed"       "Failed to install Plasma desktop"                         \
    install plasma
  pkg_silent \
    "Installing KDE Applications"    "Installing file manager, terminal, text editor..."        \
    "KDE Applications installed"     "Failed to install KDE Applications"                       \
    install kde-applications
}

# ── Setup Scripts, MOTD & Uninstaller ────────────
setup_aliases() {
  step "Shell Config"

  mkdir -p "$HOME/bin"

  # ── startplasma ──
  cat > "$HOME/bin/startplasma" << 'EOF'
#!/bin/bash
nohup termux-x11 -xstartup startplasma-x11 > /dev/null 2>&1 &
disown
sleep 2
echo -e "\033[1m\033[32m[✓] KDE Plasma started\033[0m  \033[2m— stop: stoplasma\033[0m"
EOF

  # ── stoplasma ──
  cat > "$HOME/bin/stoplasma" << 'EOF'
#!/bin/bash
pkill -f termux-x11 > /dev/null 2>&1
pkill -f startplasma-x11 > /dev/null 2>&1
echo -e "\033[1m\033[33m[■] KDE Plasma stopped\033[0m  \033[2m— start: startplasma\033[0m"
EOF

  # ── TermuxKDE-Remove ──
  cat > "$HOME/bin/TermuxKDE-Remove" << 'EOF'
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

echo -e "${BOLD}${RED}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║         TermuxKDE — UNINSTALLER          ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "${YELLOW}${BOLD}⚠ WARNING:${RESET} This will permanently remove:"
echo -e "${DIM}  • startplasma, stoplasma, TermuxKDE-Remove scripts"
echo -e "  • All TermuxKDE entries from your shell config"
echo -e "  • KDE Plasma & kde-applications packages"
echo -e "  • termux-x11-nightly package"
echo -e "  • termuxkde_error.log${RESET}"
echo ""
echo -ne "${YELLOW}Are you sure? This cannot be undone. [y/N]:${RESET} "
read -r CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo -e "${GREEN}Uninstall cancelled.${RESET}"
  exit 0
fi
echo ""

if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
  RC_FILE="$HOME/.zshrc"
else
  RC_FILE="$HOME/.bashrc"
fi

_task_label=""
task()      { _task_label="$1"; echo -e "\033[36m[*]\033[0m $1"; echo -e "\033[2m    └─ $2\033[0m"; }
task_done() { printf "\033[2A\r\033[2K\033[32m[✓]\033[0m %b\n\r\033[2K" "$1"; _task_label=""; }
error()     {
  if [[ -n "$_task_label" ]]; then
    printf "\033[2A\r\033[2K\033[31m[✗]\033[0m %b\033[2m — check output above\033[0m\n\r\033[2K" "$1"
    _task_label=""
  else
    echo -e "\033[31m[✗]\033[0m $1"
  fi
  echo -e "\033[2mUninstall may be incomplete. Some steps were skipped.\033[0m"
  exit 1
}

task      "Removing launcher scripts"  "Deleting startplasma, stoplasma, TermuxKDE-Remove..."
rm -f "$HOME/bin/startplasma" "$HOME/bin/stoplasma" "$HOME/bin/TermuxKDE-Remove" \
  || error "Failed to remove launcher scripts"
task_done "Scripts removed"

task      "Cleaning shell config"  "Stripping TermuxKDE block from ${RC_FILE}..."
sed -i '/# ── TermuxKDE ──/,+10d' "$RC_FILE" 2>/dev/null \
  || error "Failed to clean shell config"
task_done "Shell config cleaned"

task      "Uninstalling KDE packages"  "Removing plasma, kde-applications, termux-x11-nightly..."
DEBIAN_FRONTEND=noninteractive yes | pkg uninstall -y \
  kde-applications plasma termux-x11-nightly > /dev/null 2>&1 \
  || error "Failed to uninstall KDE packages"
task_done "Packages removed"

task      "Removing remaining dependencies"  "Running autoremove to clean up leftover packages..."
DEBIAN_FRONTEND=noninteractive yes | pkg autoremove > /dev/null 2>&1 \
  || error "Failed to autoremove packages"
task_done "Dependencies cleaned up"

task      "Removing log file"  "Deleting termuxkde_error.log..."
rm -f "$HOME/termuxkde_error.log" \
  || error "Failed to remove log file"
task_done "Log removed"

echo ""
echo -e "${GREEN}${BOLD}TermuxKDE has been fully removed.${RESET}"
EOF
}
# ── Cache Cleanup ─────────────────────────────────
cleanup_cache() {
  step "Cleanup"
  task "Cleaning package cache" "Freeing cached package files..."
  apt-get clean >> "$LOG" 2>&1 \
    || error "Failed to clean package cache"
  task_done "Package cache cleared"
}

# ── Summary ───────────────────────────────────────
show_summary() {
  local END_TIME ELAPSED BYTES_AFTER BYTES_USED MB_USED MINS SECS
  END_TIME=$(date +%s)
  ELAPSED=$((END_TIME - START_TIME))
  BYTES_AFTER=$(cat /proc/net/dev 2>/dev/null | awk '/wlan0|rmnet/{sum+=$2} END{print sum+0}')
  BYTES_USED=$((BYTES_AFTER - BYTES_BEFORE))
  MB_USED=$(echo "scale=1; $BYTES_USED / 1048576" | bc 2>/dev/null || echo "?")
  MINS=$(( ELAPSED / 60 ))
  SECS=$(( ELAPSED % 60 ))

  clear
  echo -e "${BOLD}${CYAN}"
  echo "  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗██╗  ██╗██████╗ ███████╗"
  echo "  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝██║ ██╔╝██╔══██╗██╔════╝"
  echo "     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ █████╔╝ ██║  ██║█████╗  "
  echo "     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ ██╔═██╗ ██║  ██║██╔══╝  "
  echo "     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗██║  ██╗██████╔╝███████╗"
  echo "     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝"
  echo -e "${RESET}"
  echo -e "${GREEN}${BOLD}✓ Installation Complete!${RESET}"
  echo -e "${DIM}────────────────────────────────────${RESET}"
  echo -e "${DIM}⏱  Time  :${RESET} ${BOLD}${MINS}m ${SECS}s${RESET}"
  echo -e "${DIM}📶 Data  :${RESET} ${BOLD}${MB_USED} MB${RESET}"
  echo -e "${DIM}🐚 Shell :${RESET} ${BOLD}${SHELL_NAME} → ${RC_FILE}${RESET}"
  echo -e "${DIM}────────────────────────────────────${RESET}"
  echo -e "${GREEN}startplasma${RESET}        →  Launch KDE Plasma"
  echo -e "${YELLOW}stoplasma${RESET}          →  Stop the Desktop"
  echo -e "${RED}TermuxKDE-Remove${RESET}   →  Uninstall everything"
  echo -e "${DIM}⚠ TermuxKDE-Remove will delete all project files & packages${RESET}"
  echo -e "${DIM}────────────────────────────────────${RESET}"
  echo -e "${BOLD}<3 Enjoy Your KDE — xenoZ0x${RESET}"
  chmod +x $HOME/bin/*
  export PATH="$HOME/bin:$PATH" 
}

# ── Main ──────────────────────────────────────────
main() {
  check_terminal_size
  > "$LOG"
  detect_shell
  show_banner
  confirm
  update_system
  install_x11
  install_kde
  setup_aliases
  cleanup_cache
  show_summary
}

main
