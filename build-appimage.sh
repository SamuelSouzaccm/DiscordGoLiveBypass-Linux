#!/usr/bin/env bash
# Monta o AppImage universal do DiscordGoLiveBypass (sem Discord dentro).
# Uso: ./build-appimage.sh   (compila o binario se faltar)
set -euo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

BIN=DiscordGoLiveBypass-linux
APP=DiscordGoLiveBypass.AppDir
OUT=DiscordGoLiveBypass-x86_64.AppImage
AI="$PWD/appimagetool.AppImage"

# 1) binario
if [ ! -x "$BIN" ]; then
  echo ">> compilando o binario..."
  go build -trimpath -ldflags "-s -w -X main.version=dev-linux" -o "$BIN" .
fi

# 2) appimagetool
if [ ! -x "$AI" ]; then
  echo ">> baixando appimagetool..."
  curl -fL -o "$AI" https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
  chmod +x "$AI"
fi

# 3) AppDir
rm -rf "$APP"
mkdir -p "$APP/usr/bin" \
         "$APP/usr/share/applications" \
         "$APP/usr/share/icons/hicolor/256x256/apps"

cp "$BIN" "$APP/usr/bin/$BIN"
cp Abrir-Discord.sh "$APP/AppRun"
chmod +x "$APP/AppRun" "$APP/usr/bin/$BIN"

cat > "$APP/usr/share/applications/discordgolivebypass.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=DiscordGoLiveBypass
Comment=Abre o Discord por um IP fora do Brasil (Linux)
Exec=AppRun
Icon=discordgolivebypass
Terminal=true
Categories=Network;
EOF
cp "$APP/usr/share/applications/discordgolivebypass.desktop" "$APP/discordgolivebypass.desktop"

# 4) icone (PNG solido, sem dependencias)
python3 - "$APP/usr/share/icons/hicolor/256x256/apps/discordgolivebypass.png" <<'PY'
import sys, zlib, struct
w = h = 256
out = sys.argv[1]
rows = bytearray()
for y in range(h):
    rows += b"\x00"  # filtro None
    for x in range(w):
        # degrade do azul do Discord (#5865F2) pro tom mais escuro; valores sempre 0..255
        t = (x + y) / (2 * w)
        r = int(0x58 + 0x1C * t)   # 88  -> 116
        g = int(0x65 - 0x02 * t)   # 101 -> 99
        b = int(0xF2 - 0x20 * t)   # 242 -> 210
        rows += bytes((r, g, b, 255))

def chunk(tag, data):
    return (struct.pack(">I", len(data)) + tag + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
png = (b"\x89PNG\r\n\x1a\n"
       + chunk(b"IHDR", ihdr)
       + chunk(b"IDAT", zlib.compress(bytes(rows), 9))
       + chunk(b"IEND", b""))
open(out, "wb").write(png)
print("icone:", out)
PY

# o appimagetool exige o icone na raiz do AppDir (e na hicolor)
cp "$APP/usr/share/icons/hicolor/256x256/apps/discordgolivebypass.png" "$APP/discordgolivebypass.png"

# 5) empacota (--appimage-extract-and-run: nao depende de FUSE pra rodar o appimagetool)
echo ">> montando $OUT ..."
"$AI" --appimage-extract-and-run "$APP" "$OUT"
chmod +x "$OUT"
ls -lh "$OUT"
echo ">> pronto: $OUT"
