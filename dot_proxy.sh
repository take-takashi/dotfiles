proxy-sync() {
    local mode="${1:-auto}"
    local wifi_device="${MISE_WORK_PROXY_WIFI_DEVICE:-en0}"
    local network_service="${MISE_WORK_PROXY_NETWORK_SERVICE:-Wi-Fi}"
    local target_ssid="${MISE_WORK_PROXY_SSID:-}"
    local proxy_url="${MISE_WORK_PROXY_URL:-}"
    local pac_url="${MISE_WORK_PROXY_PAC_URL:-}"
    local ssid=""
    local should_enable=""
    local current_pac_url=""
    local current_pac_state=""

    case "$mode" in
        auto | on | off) ;;
        *)
            printf 'usage: proxy-sync [auto|on|off]\n' >&2
            return 2
            ;;
    esac

    case "$mode" in
        on)
            should_enable=1
            ;;
        off)
            should_enable=0
            ;;
        auto)
            if command -v networksetup >/dev/null 2>&1 && [[ -n "$target_ssid" ]]; then
                ssid=$(networksetup -getairportnetwork "$wifi_device" 2>/dev/null | awk -F': ' '{print $2}')
                [[ "$ssid" == "$target_ssid" ]] && should_enable=1 || should_enable=0
            else
                should_enable=0
            fi
            ;;
    esac

    if command -v networksetup >/dev/null 2>&1 && [[ -n "$pac_url" ]]; then
        current_pac_url=$(networksetup -getautoproxyurl "$network_service" 2>/dev/null | awk -F': ' '/^URL:/ {print $2}')
        current_pac_state=$(networksetup -getautoproxyurl "$network_service" 2>/dev/null | awk -F': ' '/^Enabled:/ {print tolower($2)}')

        if [[ "$should_enable" == "1" ]]; then
            if [[ "$current_pac_url" != "$pac_url" || "$current_pac_state" != "yes" ]]; then
                networksetup -setautoproxyurl "$network_service" "$pac_url"
            fi
        elif [[ "$current_pac_state" == "yes" ]]; then
            networksetup -setautoproxystate "$network_service" off
        fi
    fi

    if [[ "$should_enable" == "1" && -n "$proxy_url" ]]; then
        export HTTP_PROXY="$proxy_url"
        export http_proxy="$HTTP_PROXY"
        export HTTPS_PROXY="$HTTP_PROXY"
        export https_proxy="$HTTP_PROXY"

        git config --global http.proxy "$HTTP_PROXY" 2>/dev/null
        git config --global https.proxy "$HTTP_PROXY" 2>/dev/null
    else
        unset HTTP_PROXY
        unset http_proxy
        unset HTTPS_PROXY
        unset https_proxy

        git config --global --unset http.proxy 2>/dev/null
        git config --global --unset https.proxy 2>/dev/null
    fi
}

if [[ "${PROXY_SYNC_AUTO:-1}" != "0" ]]; then
    proxy-sync auto
fi
