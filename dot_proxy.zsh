_proxy_load_local() {
    [[ -r "$HOME/.proxy.local.zsh" ]] && source "$HOME/.proxy.local.zsh"
}

_proxy_set_pac() {
    local state="$1"
    local network_service="${PROXY_NETWORK_SERVICE:-Wi-Fi}"
    local pac_url="${PROXY_PAC_URL:-}"
    local current_pac_url=""
    local current_pac_state=""

    command -v networksetup >/dev/null 2>&1 || return 0
    [[ -n "$pac_url" ]] || return 0

    current_pac_url=$(networksetup -getautoproxyurl "$network_service" 2>/dev/null | awk -F': ' '/^URL:/ {print $2}')
    current_pac_state=$(networksetup -getautoproxyurl "$network_service" 2>/dev/null | awk -F': ' '/^Enabled:/ {print tolower($2)}')

    if [[ "$state" == "on" ]]; then
        if [[ "$current_pac_url" != "$pac_url" || "$current_pac_state" != "yes" ]]; then
            networksetup -setautoproxyurl "$network_service" "$pac_url"
        fi
    elif [[ "$current_pac_state" == "yes" ]]; then
        networksetup -setautoproxystate "$network_service" off
    fi
}

proxy_on() {
    _proxy_load_local

    if [[ -n "${PROXY_URL:-}" ]]; then
        export HTTP_PROXY="$PROXY_URL"
        export http_proxy="$PROXY_URL"
        export HTTPS_PROXY="$PROXY_URL"
        export https_proxy="$PROXY_URL"

        if command -v git >/dev/null 2>&1; then
            git config --global http.proxy "$PROXY_URL" 2>/dev/null
            git config --global https.proxy "$PROXY_URL" 2>/dev/null
        fi
    fi

    if [[ -n "${NO_PROXY:-}" ]]; then
        export no_proxy="$NO_PROXY"
    elif [[ -n "${no_proxy:-}" ]]; then
        export NO_PROXY="$no_proxy"
    fi

    _proxy_set_pac on
}

proxy_off() {
    _proxy_load_local

    _proxy_set_pac off

    unset HTTP_PROXY
    unset http_proxy
    unset HTTPS_PROXY
    unset https_proxy
    unset NO_PROXY
    unset no_proxy

    if command -v git >/dev/null 2>&1; then
        git config --global --unset http.proxy 2>/dev/null
        git config --global --unset https.proxy 2>/dev/null
    fi
}

proxy_status() {
    _proxy_load_local

    printf 'HTTP_PROXY=%s\n' "${HTTP_PROXY:-}"
    printf 'HTTPS_PROXY=%s\n' "${HTTPS_PROXY:-}"
    printf 'NO_PROXY=%s\n' "${NO_PROXY:-${no_proxy:-}}"

    if command -v networksetup >/dev/null 2>&1 && [[ -n "${PROXY_PAC_URL:-}" ]]; then
        networksetup -getautoproxyurl "${PROXY_NETWORK_SERVICE:-Wi-Fi}"
    fi

    if command -v git >/dev/null 2>&1; then
        git config --global --get http.proxy 2>/dev/null | awk '{print "git http.proxy="$0}'
        git config --global --get https.proxy 2>/dev/null | awk '{print "git https.proxy="$0}'
    fi
}
