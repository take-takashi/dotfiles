#!/bin/zsh

# --- 設定 ---
# シンボリックリンクを作成したいファイル名をこのリストに追加してください。
# ファイルは `../HOME` ディレクトリに存在する必要があります。
# (スペースや改行で区切られたリスト)
FILES_TO_LINK=(
.zshrc
.p10k.zsh
Brewfile
)
# --- ここまで ---

# スクリプトが失敗したら直ちに終了する
set -e

# このスクリプトが置かれているディレクトリを基準にdotfilesのルートディレクトリを特定
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOTFILES_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
SOURCE_DIR="${DOTFILES_ROOT}/HOME"
TARGET_DIR="${HOME}"

echo "シンボリックリンクの作成を開始します..."
echo "Dotfilesリポジトリ: ${DOTFILES_ROOT}"
echo "リンク先ディレクトリ: ${TARGET_DIR}"
echo ""

# FILES_TO_LINKで定義された各ファイルをループ処理
for filename in "${FILES_TO_LINK[@]}"; do
    # リンク元とリンク先のフルパスを組み立てる
    source_file="${SOURCE_DIR}/${filename}"
    target_file="${TARGET_DIR}/${filename}"

    # リンク元のファイルが存在するかチェック
    if [ ! -e "${source_file}" ]; then
        echo "⚠️  警告: リンク元ファイルが見つかりません。スキップします: ${source_file}"
        continue
    fi

    echo "処理中: ${filename}"

    # リンク先が既に存在し、それがシンボリックリンクでない場合（つまり通常のファイルの場合）はバックアップを作成
    if [ -f "${target_file}" ] && [ ! -L "${target_file}" ]; then
        backup_file="${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  -> 既存のファイルをバックアップします: ${backup_file}"
        mv "${target_file}" "${backup_file}"
    fi

    # シンボリックリンクを作成（-fオプションで既存のリンクは上書き）
    echo "  -> シンボリックリンクを作成します: ${source_file} -> ${target_file}"
    ln -sf "${source_file}" "${target_file}"
done

echo ""
echo "✅ 完了。すべての指定されたファイルのリンクが作成されました。"