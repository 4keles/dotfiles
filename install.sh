#!/usr/bin/env bash
# ==============================================================================
# Kontrollü ve Adım Adım Dotfiles Kurulum Betiği
# Bileşenler: Kitty, Tmux, Zsh, Oh My Zsh, Powerlevel10k, Eklentiler, Nerd Font
# ==============================================================================

# Hata durumunda hemen çıkmasın, her adımı kontrollü yönetsin
set -u

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Renkler & Biçimlendirme
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
BOLD="\033[1m"
DIM="\033[2m"
NC="\033[0m"

# Log fonksiyonları
log_info()    { echo -e "${BLUE}[BİLGİ]${NC} $1"; }
log_ok()      { echo -e "${GREEN}[  ✓  ]${NC} $1"; }
log_missing() { echo -e "${RED}[  ✗  ]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[UYARI]${NC} $1"; }
log_step()    { echo -e "\n${BOLD}${CYAN}==>${NC} ${BOLD}$1${NC}"; }

# Kullanıcıya Evet/Hayır sorma fonksiyonu
ask_yes_no() {
    local question="$1"
    local default="${2:-Y}" # Y veya N
    local prompt="[E/h]"
    [ "$default" = "N" ] && prompt="[e/H]"

    if [ "${AUTO_CONFIRM:-false}" = "true" ]; then
        echo -e "${YELLOW}[OTO-ONAY]${NC} $question $prompt -> Evet"
        return 0
    fi

    while true; do
        read -r -p "$question $prompt: " choice
        choice="${choice:-$default}"
        case "$choice" in
            [eE]|[yY]|[eE][vV][eE][tT]|[yY][eE][sS]) return 0 ;;
            [hH]|[nN]|[hH][aA][yY][ıI][rR]|[nN][oO]) return 1 ;;
            *) echo -e "  ${DIM}Lütfen 'e' (evet) veya 'h' (hayır) giriniz.${NC}" ;;
        esac
    done
}

# Paket yöneticisi tespiti
detect_package_manager() {
    if command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "unknown"
    fi
}

PKG_MGR=$(detect_package_manager)

# Paket kurma yardımcısı
install_single_package() {
    local pkg="$1"
    log_info "'$pkg' paketi kuruluyor..."
    case "$PKG_MGR" in
        dnf)
            sudo dnf install -y "$pkg"
            ;;
        apt)
            sudo apt-get update -qq && sudo apt-get install -y "$pkg"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "$pkg"
            ;;
        brew)
            if [ "$pkg" = "kitty" ]; then
                brew install --cask kitty 2>/dev/null || brew install kitty
            else
                brew install "$pkg"
            fi
            ;;
        *)
            log_warn "Otomatik paket yöneticisi bulunamadı. Lütfen '$pkg' paketini manuel kurunuz."
            return 1
            ;;
    esac
}

# Nerd Font kontrolü
has_nerd_font() {
    if fc-list : family 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
        return 0
    fi
    if [ -d "$HOME/.local/share/fonts/JetBrainsMono" ] && [ -n "$(ls -A "$HOME/.local/share/fonts/JetBrainsMono" 2>/dev/null)" ]; then
        return 0
    fi
    if [ -d "$HOME/Library/Fonts" ] && ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi "JetBrainsMono"; then
        return 0
    fi
    return 1
}

# Sembolik bağ durum kontrolü
check_symlink_status() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        local current_target
        current_target="$(readlink -f "$dest" 2>/dev/null || true)"
        local expected_target
        expected_target="$(readlink -f "$src" 2>/dev/null || true)"
        if [ "$current_target" = "$expected_target" ]; then
            echo "LINKED"
            return
        else
            echo "WRONG_LINK"
            return
        fi
    elif [ -e "$dest" ]; then
        echo "EXISTS"
        return
    else
        echo "MISSING"
        return
    fi
}

# ------------------------------------------------------------------------------
# 1. SİSTEM DURUM RAPORU (DASHBOARD)
# ------------------------------------------------------------------------------
print_row() {
    local col1="$1"
    local status_type="$2"
    local col2="$3"
    local col3="$4"

    local color="$NC"
    case "$status_type" in
        "OK") color="$GREEN" ;;
        "MISSING") color="$RED" ;;
        "WARN") color="$YELLOW" ;;
        "INFO") color="$CYAN" ;;
        *) color="$NC" ;;
    esac

    printf "  %-30s ${color}%-18s${NC} ${DIM}%s${NC}\n" "$col1" "$col2" "$col3"
}

show_system_status() {
    echo -e "${BOLD}${CYAN}"
    echo "=================================================================="
    echo "              SİSTEM VE BİLEŞEN DURUM KONTROLÜ                    "
    echo "=================================================================="
    echo -e "${NC}"
    echo -e "  İşletim Sistemi       : $(uname -s) ($(uname -m))"
    echo -e "  Paket Yöneticisi      : ${BOLD}${PKG_MGR}${NC}"
    echo -e "  Mevcut Kabuk (\$SHELL) : $SHELL"
    echo ""
    printf "  ${BOLD}%-30s %-18s %s${NC}\n" "BİLEŞEN" "DURUM" "DETAY"
    echo "  ----------------------------------------------------------------"

    # Temel Uygulamalar
    for app in kitty tmux zsh git curl; do
        if command -v "$app" &>/dev/null; then
            print_row "$app" "OK" "[✓ YÜKLÜ]" "$(which "$app")"
        else
            print_row "$app" "MISSING" "[✗ EKSİK]" "Paket kurulu değil"
        fi
    done

    # Font
    if has_nerd_font; then
        print_row "JetBrainsMono Nerd Font" "OK" "[✓ YÜKLÜ]" "Kitty & P10k hazır"
    else
        print_row "JetBrainsMono Nerd Font" "MISSING" "[✗ EKSİK]" "İkonlar için gerekli"
    fi

    # Oh My Zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_row "Oh My Zsh" "OK" "[✓ YÜKLÜ]" "~/.oh-my-zsh"
    else
        print_row "Oh My Zsh" "MISSING" "[✗ EKSİK]" "Dizin bulunamadı"
    fi

    # Tema ve Eklentiler
    local plugins=(
        "powerlevel10k|themes/powerlevel10k|Powerlevel10k (Tema)"
        "zsh-autosuggestions|plugins/zsh-autosuggestions|zsh-autosuggestions"
        "zsh-syntax-highlighting|plugins/zsh-syntax-highlighting|zsh-syntax-highlighting"
        "fzf-tab|plugins/fzf-tab|fzf-tab (Tamamlama)"
        "zsh-history-substring-search|plugins/zsh-history-substring-search|history-substring-search"
        "you-should-use|plugins/you-should-use|you-should-use"
    )

    for item in "${plugins[@]}"; do
        IFS="|" read -r name rel_path desc <<< "$item"
        local target="$ZSH_CUSTOM/$rel_path"
        if [ -d "$target" ]; then
            print_row "$desc" "OK" "[✓ YÜKLÜ]" "$rel_path"
        else
            print_row "$desc" "MISSING" "[✗ EKSİK]" "Yüklü değil"
        fi
    done

    # CLI Yardımcıları
    for cli in fzf eza bat zoxide; do
        if command -v "$cli" &>/dev/null; then
            print_row "$cli" "OK" "[✓ YÜKLÜ]" "$(which "$cli")"
        else
            print_row "$cli" "WARN" "[! OPSİYONEL]" "Aliaslar için önerilir"
        fi
    done

    # Profil Dosyaları Bağlantı Durumu
    echo "  ----------------------------------------------------------------"
    local configs=(
        "$DOTFILES_DIR/kitty/kitty.conf|$HOME/.config/kitty/kitty.conf|Kitty Ayarı (kitty.conf)"
        "$DOTFILES_DIR/kitty/current-theme.conf|$HOME/.config/kitty/current-theme.conf|Kitty Teması (Forest Night)"
        "$DOTFILES_DIR/tmux/.tmux.conf|$HOME/.tmux.conf|Tmux Ayarı (.tmux.conf)"
        "$DOTFILES_DIR/zsh/.zshrc|$HOME/.zshrc|Zsh Ayarı (.zshrc)"
        "$DOTFILES_DIR/zsh/.p10k.zsh|$HOME/.p10k.zsh|P10k Ayarı (.p10k.zsh)"
        "$DOTFILES_DIR/zsh/.shell_common.sh|$HOME/.shell_common.sh|Ortak PATH (.shell_common.sh)"
    )

    for item in "${configs[@]}"; do
        IFS="|" read -r src dest desc <<< "$item"
        local st
        st=$(check_symlink_status "$src" "$dest")
        case "$st" in
            "LINKED")
                print_row "$desc" "OK" "[✓ BAĞLI]" "Sembolik bağ aktif"
                ;;
            "EXISTS")
                print_row "$desc" "WARN" "[! MEVCUT]" "Farklı dosya var"
                ;;
            "WRONG_LINK")
                print_row "$desc" "WARN" "[! FARKLI BAĞ]" "Farklı hedefe bağlı"
                ;;
            "MISSING")
                print_row "$desc" "INFO" "[○ BAĞSIZ]" "Henüz dosya yok"
                ;;
        esac
    done
    echo "=================================================================="
    echo ""
}

# ------------------------------------------------------------------------------
# 2. ADIM ADIM KONTROLLÜ KURULUM
# ------------------------------------------------------------------------------

# 1. Adım: Uygulama Kontrolleri (Kitty, Tmux, Zsh)
step_check_applications() {
    log_step "1. Temel Uygulamaların Kontrolü (Kitty, Tmux, Zsh, Git, Curl)"

    # Kitty
    if command -v kitty &>/dev/null; then
        log_ok "Kitty yüklü ($(which kitty))."
    else
        log_missing "Kitty terminal bulunamadı."
        if ask_yes_no "Kitty terminal paketini yüklemek istiyor musunuz?" "Y"; then
            install_single_package "kitty"
        fi
    fi

    # Tmux
    if command -v tmux &>/dev/null; then
        log_ok "Tmux yüklü ($(which tmux))."
    else
        log_missing "Tmux bulunamadı."
        if ask_yes_no "Tmux paketini yüklemek istiyor musunuz?" "Y"; then
            install_single_package "tmux"
        fi
    fi

    # Zsh
    if command -v zsh &>/dev/null; then
        log_ok "Zsh kabuğu yüklü ($(which zsh))."
    else
        log_missing "Zsh kabuğu bulunamadı."
        if ask_yes_no "Zsh paketini yüklemek istiyor musunuz?" "Y"; then
            install_single_package "zsh"
        fi
    fi

    # Git & Curl
    for tool in git curl; do
        if command -v "$tool" &>/dev/null; then
            log_ok "$tool yüklü."
        else
            log_missing "$tool bulunamadı."
            if ask_yes_no "$tool paketini yüklemek istiyor musunuz?" "Y"; then
                install_single_package "$tool"
            fi
        fi
    done
}

# 2. Adım: Font Kontrolü (JetBrainsMono Nerd Font)
step_check_fonts() {
    log_step "2. Nerd Font Kontrolü (İkonlar ve Karakterler İçin)"

    if has_nerd_font; then
        log_ok "JetBrainsMono Nerd Font zaten sistemde mevcut."
    else
        log_missing "JetBrainsMono Nerd Font bulunamadı!"
        echo -e "  ${DIM}Not: Kitty ve Powerlevel10k git/durum ikonlarının düzgün görünmesi için bu font gereklidir.${NC}"
        if ask_yes_no "JetBrainsMono Nerd Font indirilsin ve otomatik kurulsun mu?" "Y"; then
            local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
            mkdir -p "$font_dir"
            local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
            log_info "Font arşivi GitHub'dan indiriliyor..."
            if curl -fL --progress-bar "$font_url" -o /tmp/JetBrainsMono.tar.xz; then
                tar -xf /tmp/JetBrainsMono.tar.xz -C "$font_dir"
                rm -f /tmp/JetBrainsMono.tar.xz
                if command -v fc-cache &>/dev/null; then
                    fc-cache -f "$font_dir" 2>/dev/null || true
                fi
                log_ok "JetBrainsMono Nerd Font başarıyla yüklendi!"
            else
                log_warn "Font indirilemedi. Lütfen manuel kurunuz: https://www.nerdfonts.com/"
            fi
        fi
    fi
}

# 3. Adım: Oh My Zsh Kontrolü
step_check_oh_my_zsh() {
    log_step "3. Oh My Zsh Çerçevesinin Kontrolü"

    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_ok "Oh My Zsh zaten kurulu (~/.oh-my-zsh)."
    else
        log_missing "Oh My Zsh kurulu değil."
        if ask_yes_no "Oh My Zsh çerçevesini şimdi kurmak istiyor musunuz?" "Y"; then
            log_info "Oh My Zsh resmi betiği çalıştırılıyor..."
            RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            log_ok "Oh My Zsh kuruldu."
        fi
    fi
}

# 4. Adım: Eklentiler ve Tema Kontrolü
step_check_plugins_and_theme() {
    log_step "4. Zsh Eklentileri ve Powerlevel10k Teması Kontrolü"

    mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

    # Powerlevel10k
    local p10k_dir="$ZSH_CUSTOM/themes/powerlevel10k"
    if [ -d "$p10k_dir" ]; then
        log_ok "Powerlevel10k teması zaten mevcut."
    else
        log_missing "Powerlevel10k teması bulunamadı."
        if ask_yes_no "Powerlevel10k temasını klonlamak istiyor musunuz?" "Y"; then
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
            log_ok "Powerlevel10k yüklendi."
        fi
    fi

    # Eklentiler Listesi
    local plugin_list=(
        "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions|Komut tamamlama önerileri"
        "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git|Sözdizimi renklendirmesi"
        "fzf-tab|https://github.com/Aloxaf/fzf-tab|Sekme tamamlama menüsü (fzf-tab)"
        "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search|Geçmiş arama (Yukarı/Aşağı ok)"
        "you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use.git|Alias hatırlatıcı (you-should-use)"
    )

    for item in "${plugin_list[@]}"; do
        IFS="|" read -r name url desc <<< "$item"
        local target="$ZSH_CUSTOM/plugins/$name"
        if [ -d "$target" ]; then
            log_ok "Eklenti mevcut: ${BOLD}$name${NC} ($desc)"
        else
            log_missing "Eklenti eksik: ${BOLD}$name${NC} ($desc)"
            if ask_yes_no "  '$name' eklentisini indirmek istiyor musunuz?" "Y"; then
                git clone --depth=1 "$url" "$target"
                log_ok "  '$name' başarıyla indirildi."
            fi
        fi
    done
}

# 5. Adım: CLI Yardımcı Araçları (fzf, eza, bat, zoxide)
step_check_cli_tools() {
    log_step "5. Modern CLI Yardımcı Araçları (fzf, eza, bat, zoxide)"

    local missing_tools=()
    for tool in fzf eza bat zoxide; do
        if command -v "$tool" &>/dev/null; then
            log_ok "$tool yüklü."
        else
            log_warn "$tool bulunamadı (zshrc alias ve fzf önizlemeleri için önerilir)."
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        if ask_yes_no "Eksik CLI araçlarını (${missing_tools[*]}) yüklemeyi denemek istiyor musunuz?" "Y"; then
            for tool in "${missing_tools[@]}"; do
                install_single_package "$tool" || true
            done
        fi
    fi
}

# 6. Adım: Dosya Bağlama (Symlink) İşlemleri
safe_link_file() {
    local src="$1"
    local dest="$2"
    local name="$3"

    local st
    st=$(check_symlink_status "$src" "$dest")

    if [ "$st" = "LINKED" ]; then
        log_ok "$name zaten repoya doğru şekilde bağlı."
        return 0
    fi

    if [ "$st" = "EXISTS" ] || [ "$st" = "WRONG_LINK" ]; then
        log_warn "$dest dosyasında mevcut bir konfigürasyon var."
        if ask_yes_no "  Mevcut dosyayı yedekleyip repodaki profili bağlayalım mı?" "Y"; then
            mkdir -p "$BACKUP_DIR"
            mv "$dest" "$BACKUP_DIR/"
            log_info "  Eski dosya şuraya yedeklendi: $BACKUP_DIR/$(basename "$dest")"
            mkdir -p "$(dirname "$dest")"
            ln -s "$src" "$dest"
            log_ok "  $name repoya sembolik bağ (symlink) ile bağlandı."
        fi
    elif [ "$st" = "MISSING" ]; then
        if ask_yes_no "  $name ($dest) repodan bağlansın mı?" "Y"; then
            mkdir -p "$(dirname "$dest")"
            ln -s "$src" "$dest"
            log_ok "  $name repoya sembolik bağ ile bağlandı."
        fi
    fi
}

step_link_dotfiles() {
    log_step "6. Konfigürasyon Dosyalarının Bağlanması (Symlink)"

    echo -e "${DIM}Aşağıdaki adımlarda ayarlarınız repodaki dosyalara sembolik bağ ile bağlanır.${NC}"
    echo -e "${DIM}Böylece ileride git pull yaptığınızda ayarlarınız otomatik güncellenir.${NC}\n"

    # Kitty profili
    echo -e "${BOLD}--- Kitty Terminal Profili ---${NC}"
    safe_link_file "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf" "Kitty Konfigürasyonu"
    safe_link_file "$DOTFILES_DIR/kitty/current-theme.conf" "$HOME/.config/kitty/current-theme.conf" "Kitty Teması (Forest Night)"

    # Tmux profili
    echo -e "\n${BOLD}--- Tmux Profili ---${NC}"
    safe_link_file "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf" "Tmux Konfigürasyonu (.tmux.conf)"

    # Zsh profili
    echo -e "\n${BOLD}--- Zsh Profili ---${NC}"
    safe_link_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc" "Zsh Ana Konfigürasyonu (.zshrc)"
    safe_link_file "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh" "Powerlevel10k Ayarları (.p10k.zsh)"
    safe_link_file "$DOTFILES_DIR/zsh/.shell_common.sh" "$HOME/.shell_common.sh" "Ortak Shell/PATH Ayarları (.shell_common.sh)"
}

# 7. Adım: Varsayılan Kabuğu Zsh Yapma
step_default_shell() {
    log_step "7. Varsayılan Kabuk (Default Shell) Kontrolü"

    local current_shell
    current_shell="$(basename "$SHELL")"

    if [ "$current_shell" = "zsh" ]; then
        log_ok "Varsayılan kabuk zaten Zsh ($SHELL)."
    else
        log_warn "Şu anki kabuğunuz: ${BOLD}$SHELL${NC}"
        local zsh_path
        zsh_path="$(which zsh 2>/dev/null || echo "")"
        if [ -n "$zsh_path" ]; then
            if ask_yes_no "Varsayılan kabuğunuzu Zsh ($zsh_path) yapmak ister misiniz?" "Y"; then
                if chsh -s "$zsh_path"; then
                    log_ok "Varsayılan kabuk Zsh olarak ayarlandı."
                else
                    log_warn "chsh komutu başarısız oldu. Manuel olarak 'chsh -s $zsh_path' çalıştırabilirsiniz."
                fi
            fi
        else
            log_warn "Zsh yolu tespit edilemediği için varsayılan kabuk değiştirilemedi."
        fi
    fi
}

# ------------------------------------------------------------------------------
# ANA PROGRAM
# ------------------------------------------------------------------------------
main() {
    local mode="${1:-}"

    # Parametre kontrolleri
    case "$mode" in
        --check|-c)
            show_system_status
            exit 0
            ;;
        --auto|-y)
            AUTO_CONFIRM=true
            show_system_status
            step_check_applications
            step_check_fonts
            step_check_oh_my_zsh
            step_check_plugins_and_theme
            step_check_cli_tools
            step_link_dotfiles
            step_default_shell
            ;;
        --step-by-step|-s|"")
            show_system_status
            echo "Nasıl devam etmek istersiniz?"
            echo -e "  ${BOLD}[1]${NC} Adım Adım Kontrollü Kurulum ${GREEN}(Önerilen: Her bileşeni tek tek sorar)${NC}"
            echo -e "  ${BOLD}[2]${NC} Hızlı Kurulum ${YELLOW}(Tüm eksikleri tespit edip otomatik onaylar)${NC}"
            echo -e "  ${BOLD}[3]${NC} Sadece Durumu İncele ve Çık"
            echo ""
            read -r -p "Seçiminiz [1/2/3] (Varsayılan 1): " menu_choice
            menu_choice="${menu_choice:-1}"

            case "$menu_choice" in
                1)
                    AUTO_CONFIRM=false
                    step_check_applications
                    step_check_fonts
                    step_check_oh_my_zsh
                    step_check_plugins_and_theme
                    step_check_cli_tools
                    step_link_dotfiles
                    step_default_shell
                    ;;
                2)
                    AUTO_CONFIRM=true
                    step_check_applications
                    step_check_fonts
                    step_check_oh_my_zsh
                    step_check_plugins_and_theme
                    step_check_cli_tools
                    step_link_dotfiles
                    step_default_shell
                    ;;
                3)
                    echo "İşlem iptal edildi, hiçbir değişiklik yapılmadı."
                    exit 0
                    ;;
                *)
                    echo "Geçersiz seçim. Çıkılıyor."
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Kullanım: ./install.sh [--check | --step-by-step | --auto]"
            exit 1
            ;;
    esac

    echo ""
    echo -e "${BOLD}${GREEN}==================================================================${NC}"
    echo -e "${BOLD}${GREEN}               Kurulum ve Kontrol Tamamlandı!                     ${NC}"
    echo -e "${BOLD}${GREEN}==================================================================${NC}"
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Değiştirilen eski dosyalarınız şuraya yedeklendi:${NC} $BACKUP_DIR"
    fi
    echo ""
    echo "Terminali yeniden başlatabilir veya hemen aktif etmek için şu komutu çalıştırabilirsiniz:"
    echo -e "  ${BOLD}exec zsh${NC}"
    echo ""
    echo "Kitty terminalini açtığınızda tüm tema, şeffaflık, kısayollar ve Powerlevel10k hazır olacaktır."
    echo ""
}

main "$@"
