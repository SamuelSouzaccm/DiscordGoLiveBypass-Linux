#!/usr/bin/env bash
# DiscordGoLiveBypass — launcher universal Linux.
# Funciona avulso (ao lado do binario) ou como AppRun dentro de um AppImage.
# Uso: ./Abrir-Discord.sh [ptb|canary] [-- args extras pro Discord]
set -euo pipefail

# --- binario do bypass: dentro do AppImage ($APPDIR) ou ao lado do script ---
if [ -n "${APPDIR:-}" ]; then
  BYPASS="$APPDIR/usr/bin/DiscordGoLiveBypass-linux"
else
  DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
  BYPASS="$DIR/DiscordGoLiveBypass-linux"
fi

if [ ! -x "$BYPASS" ]; then
  echo "Faltou o DiscordGoLiveBypass-linux ao lado deste launcher." >&2
  exit 1
fi

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

# --- canal ---
CHANNEL="stable"
if [ $# -gt 0 ]; then
  case "$1" in
    ptb|canary) CHANNEL="$1"; shift ;;
  esac
fi

case "$CHANNEL" in
  stable) FOLDER="discord";       EXE="Discord";       APPID="com.discordapp.Discord";        SNAP="discord" ;;
  ptb)    FOLDER="discordptb";    EXE="DiscordPTB";    APPID="com.discordapp.DiscordPTB";     SNAP="discord-ptb" ;;
  canary) FOLDER="discordcanary"; EXE="DiscordCanary"; APPID="com.discordapp.DiscordCanary";  SNAP="discord-canary" ;;
  *) echo "canal desconhecido: use stable, ptb ou canary" >&2; exit 1 ;;
esac

# Comparacao numerica de versao: 0.0.9 < 0.0.10, e 0.0.152 < 1.0.154.
newer() { # a b -> 0 se a>b
  local i an bn
  IFS=. read -ra A <<< "$1"
  IFS=. read -ra B <<< "$2"
  for i in "${!A[@]}"; do
    an="${A[$i]}" bn="${B[$i]:-0}"
    (( an > bn )) && return 0
    (( an < bn )) && return 1
  done
  (( ${#A[@]} > ${#B[@]} ))
}

run=""     # caminho do runner (binario real, launcher do sistema ou wrapper flatpak/snap)
explain="" # o que foi achado

# 1) bootstrap: ~/.config/<canal>/<versao>/<exe> — casa 0.0.* e app-*, escolhe a maior
pick_bootstrap() {
  local best_v="" best_dir="" v d
  for d in "$config_home/$FOLDER"/0.0.*/ "$config_home/$FOLDER"/app-*/; do
    [ -x "${d}${EXE}" ] || continue
    v="${d%/}"; v="${v##*/}"; v="${v#app-}"
    if [ -z "$best_v" ] || newer "$v" "$best_v"; then
      best_v="$v"; best_dir="$d"
    fi
  done
  if [ -n "$best_dir" ]; then
    run="${best_dir}${EXE}"
    explain="bootstrap em ~/.config/$FOLDER (v$best_v)"
    return 0
  fi
  return 1
}

# 2) instalacao no sistema: /usr/share, /usr/lib, /opt, /usr/lib64 e launchers /usr/bin
pick_system() {
  local p c
  for p in "/usr/share/$FOLDER/$EXE" "/usr/lib/$FOLDER/$EXE" "/opt/$FOLDER/$EXE" "/usr/lib64/$FOLDER/$EXE"; do
    if [ -x "$p" ]; then run="$p"; explain="pacote do sistema em $p"; return 0; fi
  done
  for c in "/usr/bin/$EXE" "/usr/bin/$FOLDER" "/usr/bin/$SNAP"; do
    if [ -x "$c" ]; then run="$c"; explain="launcher do sistema em $c"; return 0; fi
  done
  return 1
}

# 3) Flatpak: o bypass precisa de um executavel que aceite as flags do Chromium;
#    um wrapper que chama 'flatpak run' cumpre o papel (o app recebe --proxy-server).
pick_flatpak() {
  command -v flatpak >/dev/null 2>&1 || return 1
  flatpak info "$APPID" >/dev/null 2>&1 || return 1
  run="$(mktemp --suffix=.sh)"
  chmod +x "$run"
  printf '#!/usr/bin/env bash\nexec flatpak run -- %s "$@"\n' "$APPID" > "$run"
  explain="Flatpak ($APPID)"
  return 0
}

# 4) Snap
pick_snap() {
  command -v snap >/dev/null 2>&1 || return 1
  snap list "$SNAP" >/dev/null 2>&1 || return 1
  run="$(mktemp --suffix=.sh)"
  chmod +x "$run"
  printf '#!/usr/bin/env bash\nexec snap run -- %s "$@"\n' "$SNAP" > "$run"
  explain="Snap ($SNAP)"
  return 0
}

if ! pick_bootstrap && ! pick_system && ! pick_flatpak && ! pick_snap; then
  echo "Nao achei nenhum Discord ($CHANNEL) instalado." >&2
  echo "Procurei: ~/.config/$FOLDER/{0.0.*,app-*}, /usr/share, /usr/lib, /opt, /usr/lib64, Flatpak e Snap." >&2
  echo "Se estiver em outro lugar, rode na mao: $BYPASS -exe <caminho> -force" >&2
  exit 1
fi

echo "Discord: $run  ($explain)"

# Derruba instancia aberta: o Discord e instancia unica, subir por cima so acorda a
# janela antiga, que continua no IP de casa. Equivale ao -force do Windows.
pattern="${FOLDER}/[^ ]*/${EXE}|/usr/(share|lib|lib64)/${FOLDER}/${EXE}|/opt/${FOLDER}/${EXE}|/usr/bin/${EXE}|flatpak run ${APPID}|snap run ${SNAP}"
if pgrep -f "$pattern" >/dev/null 2>&1; then
  echo "Discord aberto, encerrando..."
  pkill -f "$pattern" || true
  sleep 2
fi

exec "$BYPASS" -exe "$run" -force "$@"
