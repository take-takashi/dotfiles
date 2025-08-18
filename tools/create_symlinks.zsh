#!/bin/zsh

# --- 設定 ---
# シンボリックリンクを作成したいファイル名をこのリストに追加してください。
# ファイルは `../HOME` ディレクトリに存在する必要があります。
# (スペースや改行で区切られたリスト)
FILES_TO_LINK=(
.config/nvim
.config/wezterm
.gemini/GEMINI.md
.gemini/settings.json
.ssh/config
.p10k.zsh
.zprofile
.zshrc
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

    # リンク先が既に存在する場合の処理
    if [ -L "${target_file}" ]; then
        # 既にシンボリックリンクの場合は削除する
        echo "  -> 既存のシンボリックリンクを削除します: ${target_file}"
        rm "${target_file}"
    elif [ -e "${target_file}" ]; then
        # シンボリックリンク以外のファイルやディレクトリが存在する場合
        backup_file="${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  -> 既存のファイルまたはディレクトリをバックアップします: ${backup_file}"
        mv "${target_file}" "${backup_file}"
    fi

    # リンク先の親ディレクトリが存在しない場合は作成する
    target_parent_dir=$(dirname "${target_file}")
    if [ ! -d "${target_parent_dir}" ]; then
        echo "  -> リンク先の親ディレクトリを作成します: ${target_parent_dir}"
        mkdir -p "${target_parent_dir}"
    fi

    # シンボリックリンクを作成
    echo "  -> シンボリックリンクを作成します: ${source_file} -> ${target_file}"
    ln -s "${source_file}" "${target_file}"
done

echo ""
echo "✅ 完了。すべての指定されたファイルのリンクが作成されました。"