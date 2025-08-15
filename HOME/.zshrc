# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----- begin for homebrew ----------------------------------------------------
# homebrew向けのパス設定
eval "$(/opt/homebrew/bin/brew shellenv)"
# ----- end for homebrew ------------------------------------------------------

# ----- begin for zsh completion settings -------------------------------------
# zsh-abbrで定義したエイリアスをコマンド名として補完候補に含める
zstyle ':completion:*' completer _complete _expand_alias _correct _approximate
# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補を一覧表示したとき、Tabや矢印で選択できるようにする
zstyle ':completion:*:default' menu select=1
# ----- end for zsh completion settings ---------------------------------------

# ----- begin for zinit -------------------------------------------------------
# install zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# theme
zinit light romkatv/powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 補完定義を追加
zinit light zsh-users/zsh-completions

# コマンド入力時に履歴から自動補完
zinit light zsh-users/zsh-autosuggestions
# 補完の色が
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# コマンドの構文ハイライト
zinit light zsh-users/zsh-syntax-highlighting

# ↑↓キーで部分一致検索
zinit light zsh-users/zsh-history-substring-search

# 動的省略形管理で、短縮入力を展開・補完
zinit light olets/zsh-abbr

# ----- end for zinit ---------------------------------------------------------

# ----- begin for zsh-abbr ----------------------------------------------------
# zsh-abbr のログを抑制
typeset -g ABBR_QUIET=1
# Homebrew Upgrade & Brewfile Update
abbr -S abu=$'if brew upgrade --greedy; then
    brew bundle dump --force --describe --file=$HOME/Brewfile
fi'
alias abu='' # 補完用

# ----- end for zsh-abbr -----------------------------------------------------

# ----- begin for mise --------------------------------------------------------
eval "$(/opt/homebrew/bin/mise activate zsh)"
# ----- end for mise ----------------------------------------------------------

# ----- begin for git ---------------------------------------------------------
# SSH接続時のみ ~/.gitconfig-ssh の内容を追加で読み込む（上書き）
if [[ -n "$SSH_CONNECTION" ]]; then
    # gitコマンド実行時のみ、追加設定ファイルをエイリアスで設定する
    alias git='git -c "include.path=~/.gitconfig-ssh"'
fi
export GPG_TTY=$(tty)
# ----- end for git -----------------------------------------------------------
