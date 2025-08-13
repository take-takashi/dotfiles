#!/bin/zsh

# 補完用のキャッシュファイルを作り直すためのスクリプト

# compinitはZshの関数なので、使用する前にロードする。
autoload -Uz compinit

# ~/.zcompdump を無視して補完を再初期化します。
compinit -i -D

echo "Zsh completion cache has been recreated."