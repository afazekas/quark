#!/bin/bash
set -ex

QUDIR=$(dirname "$(readlink -f "$0")")
QUCFG="${QUDIR}/DefaultGameUserSettings.ini"
QUPRIV="${QUDIR}/private"
QUADMCFG="${QUDIR}/AllowedCheaterSteamIDs.txt"

if [[ "$1" == "install" ]]; then
	# $ useradd steam
	# $ su steam
	# and then run this script (or pick any other name than steam)

	if [[ ! -d "$HOME/Steam" ]]; then
		mkdir $HOME/Steam

		cd $HOME/Steam/
		curl -sqL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxvf -
	fi
	mkdir -p $HOME/arksrv
	if [[ ! -d "$HOME/arksrv/ShooterGame" ]]; then
		$HOME/Steam/steamcmd.sh +login anonymous +force_install_dir $HOME/arksrv +app_update 376030 +quit
	fi

	[[ -f "$QUPRIV" ]] || echo "Create $QUDIR/private (see private.example) before starting server"
	[[ -f "$QUADMCFG" ]] || echo "Possibly create also AllowedCheaterSteamIDs.txt (admins steamid64 per line)"
	exit
fi

if [[ "$1" == "update" ]]; then
    $HOME/Steam/steamcmd.sh +login anonymous +force_install_dir $HOME/arksrv +app_update 376030 +quit
    exit
fi

CFG="$HOME/arksrv/ShooterGame/Config/DefaultGameUserSettings.ini"
[[ ! -h "$CFG" ]] && rm -f "$CFG"
[[ -f "$CFG" ]] || ln -snf "$QUCFG" "$CFG"

CFG="$HOME/arksrv/ShooterGame/Saved/AllowedCheaterSteamIDs.txt"
if [[ -f "${QUADMCFG}" ]]; then
	[[ -d "$(dirname "$CFG")" ]] || mkdir -p "$(dirname "$CFG")"
	[[ -h "$CFG" ]] || rm -f "$CFG"
	[[ -f "$CFG" ]] || ln -snf "$QUADMCFG" "$CFG"
fi

OPTS=""
source "$QUPRIV"
OPTS="${OPTS} -server -log -nomansky -NoBattlEye"

cd $HOME/arksrv/ShooterGame/Binaries/Linux/
exec ./ShooterGameServer $OPTS
