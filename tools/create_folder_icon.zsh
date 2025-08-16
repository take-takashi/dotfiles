#!/usr/bin/env zsh
set -euo pipefail

# --- 設定（必要に応じて変更） ---
# ベースのフォルダアイコン（標準フォルダ）
GENERIC_ICNS="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericFolderIcon.icns"
# アプリのアイコンを中央に載せるときの縮尺（%）
OVERLAY_SCALE_PERCENT=60

usage() {
  cat <<'EOS'
Usage:
  make-folder-like-app-icon.sh -a /path/to/App.app -o /path/to/output.icns
  or
  make-folder-like-app-icon.sh -i /path/to/appicon.icns -o /path/to/output.icns
  or
  make-folder-like-app-icon.sh -p /path/to/appicon.png -o /path/to/output.icns

Options:
  -a  .app のパス（内部の .icns を自動抽出）
  -i  直接 .icns を指定
  -p  直接 PNG を指定（512x512 以上推奨・透過PNGだと綺麗）
  -o  出力する .icns のパス（例: ~/Desktop/MyFolder.icns）
  -s  アプリアイコン縮尺（%）。デフォルト 60
Notes:
  * 依存: ImageMagick (magick / convert), iconutil
  * 作成後は、対象フォルダの「情報を見る」で左上のアイコンにペースト
EOS
}

APP_PATH=""
ICNS_IN=""
PNG_IN=""
OUT_ICNS=""
SCALE="$OVERLAY_SCALE_PERCENT"

while getopts "a:i:p:o:s:h" opt; do
  case "$opt" in
    a) APP_PATH="$OPTARG" ;;
    i) ICNS_IN="$OPTARG" ;;
    p) PNG_IN="$OPTARG" ;;
    o) OUT_ICNS="$OPTARG" ;;
    s) SCALE="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

if [[ -z "$OUT_ICNS" ]]; then
  echo "[ERR] 出力 .icns を -o で指定してください" >&2
  usage; exit 1
fi

# 依存チェック
command -v magick >/dev/null 2>&1 || command -v convert >/dev/null 2>&1 || {
  echo "[ERR] ImageMagick が必要です。brew install imagemagick" >&2; exit 1;
}
command -v iconutil >/dev/null 2>&1 || { echo "[ERR] iconutil が見つかりません"; exit 1; }

# 作業用ディレクトリ
WORKDIR="$(mktemp -d)"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

BASE_ICONSET="$WORKDIR/base.iconset"
mkdir -p "$BASE_ICONSET"

# 標準フォルダの512px PNGを抽出
# iconutil は icns -> iconset も可能
iconutil -c iconset "$GENERIC_ICNS" -o "$BASE_ICONSET" >/dev/null 2>&1 || true
if [[ -f "$BASE_ICONSET/icon_512x512.png" ]]; then
  cp "$BASE_ICONSET/icon_512x512.png" "$WORKDIR/folder_base.png"
else
  # フォールバック：sips で直接png化（サイズは後で拡大）
  sips -s format png "$GENERIC_ICNS" --out "$WORKDIR/folder_base.png" >/dev/null
fi

# ベースを512x512に整える
sips -Z 512 "$WORKDIR/folder_base.png" --out "$WORKDIR/folder_base_512.png" >/dev/null

# --- オーバーレイ（アプリのアイコン）を準備 ---
OVERLAY_PNG="$WORKDIR/overlay.png"

extract_icns_from_app() {
  local app="$1"
  # まず CFBundleIconFile を見る
  local name
  name=$(defaults read "$app/Contents/Info" CFBundleIconFile 2>/dev/null || true)
  if [[ -n "$name" ]]; then
    [[ "$name" == *.icns ]] || name="${name}.icns"
    if [[ -f "$app/Contents/Resources/$name" ]]; then
      echo "$app/Contents/Resources/$name"; return 0
    fi
  fi
  # フォールバック：Resources 内の .icns 先頭1つ
  local first_icns
  first_icns=($(ls "$app/Contents/Resources/"*.icns 2>/dev/null || true))
  if [[ ${#first_icns[@]} -gt 0 ]]; then
    echo "${first_icns[1]}"; return 0
  fi
  return 1
}

if [[ -n "$APP_PATH" ]]; then
  [[ -d "$APP_PATH" && "$APP_PATH" == *.app ]] || { echo "[ERR] -a には .app を指定してください"; exit 1; }
  ICNS_IN="$(extract_icns_from_app "$APP_PATH")" || { echo "[ERR] アプリから .icns を見つけられませんでした"; exit 1; }
fi

if [[ -n "$ICNS_IN" ]]; then
  # .icns -> iconset -> 512png
  APP_ICONSET="$WORKDIR/app.iconset"
  mkdir -p "$APP_ICONSET"
  iconutil -c iconset "$ICNS_IN" -o "$APP_ICONSET" >/dev/null 2>&1 || true
  if [[ -f "$APP_ICONSET/icon_512x512.png" ]]; then
    cp "$APP_ICONSET/icon_512x512.png" "$OVERLAY_PNG"
  else
    # フォールバックで sips 変換
    sips -s format png "$ICNS_IN" --out "$OVERLAY_PNG" >/dev/null
  fi
elif [[ -n "$PNG_IN" ]]; then
  cp "$PNG_IN" "$OVERLAY_PNG"
else
  echo "[ERR] -a か -i か -p のいずれかでオーバーレイ元を指定してください" >&2
  exit 1
fi

# オーバーレイを512に整形（透過維持）
sips -Z 512 "$OVERLAY_PNG" --out "$WORKDIR/overlay_512.png" >/dev/null

# --- 合成（中央） ---
# ImageMagick のコマンド名（magick 優先）
IMCMD="magick"
command -v magick >/dev/null 2>&1 || IMCMD="convert"

# オーバーレイを縮小して中央合成
$IMCMD "$WORKDIR/folder_base_512.png" \
  \( "$WORKDIR/overlay_512.png" -resize "${SCALE}%" \) \
  -gravity center -compose over -composite \
  "$WORKDIR/composited_512.png"

# --- iconset 生成 ---
OUT_ICONSET="$WORKDIR/out.iconset"
mkdir -p "$OUT_ICONSET"

gen_one() {
  local size=$1
  local name="icon_${size}x${size}.png"
  sips -Z "$size" "$WORKDIR/composited_512.png" --out "$OUT_ICONSET/$name" >/dev/null
}

for sz in 16 32 128 256 512; do
  gen_one "$sz"
  # @2x も作成（32,64,256,512,1024）
  sips -Z $((sz*2)) "$WORKDIR/composited_512.png" --out "$OUT_ICONSET/icon_${sz}x${sz}@2x.png" >/dev/null
done

# --- icns へパッケージ ---
iconutil -c icns "$OUT_ICONSET" -o "$OUT_ICNS"

echo "[OK] 出力: $OUT_ICNS"
echo "ヒント: フォルダを選択して ⌘I → 左上のアイコンをクリック → ⌘V で適用できます。"