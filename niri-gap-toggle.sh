#!/bin/bash

GAP=40

parse_outputs() {
    local name="" pos_x="" pos_y="" width="" height=""
    local re_output='^Output .* \(([^)]+)\)'
    local re_pos='Logical position: ([0-9]+), ([0-9]+)'
    local re_size='Logical size: ([0-9]+)x([0-9]+)'
    while IFS= read -r line; do
        if [[ $line =~ $re_output ]]; then
            name="${BASH_REMATCH[1]}"
        elif [[ $line =~ $re_pos ]]; then
            pos_x="${BASH_REMATCH[1]}"
            pos_y="${BASH_REMATCH[2]}"
        elif [[ $line =~ $re_size ]]; then
            width="${BASH_REMATCH[1]}"
            height="${BASH_REMATCH[2]}"
            echo "$name $pos_x $pos_y $width $height"
        fi
    done < <(niri msg outputs)
}

mapfile -t OUTPUTS < <(parse_outputs)

if [[ ${#OUTPUTS[@]} -lt 2 ]]; then
    notify-send "Niri" "Erro: menos de 2 monitores detectados"
    exit 1
fi

declare -A POS_X POS_Y WIDTH HEIGHT
NAMES=()
for out in "${OUTPUTS[@]}"; do
    read -r name x y w h <<< "$out"
    NAMES+=("$name")
    POS_X[$name]=$x
    POS_Y[$name]=$y
    WIDTH[$name]=$w
    HEIGHT[$name]=$h
done

# Primary = largest area
PRIMARY="${NAMES[0]}"
for name in "${NAMES[@]}"; do
    if (( WIDTH[$name] * HEIGHT[$name] > WIDTH[$PRIMARY] * HEIGHT[$PRIMARY] )); then
        PRIMARY=$name
    fi
done

for name in "${NAMES[@]}"; do
    [[ $name == "$PRIMARY" ]] && continue
    SECONDARY=$name

    PX=${POS_X[$PRIMARY]}
    PY=${POS_Y[$PRIMARY]}
    PW=${WIDTH[$PRIMARY]}
    PH=${HEIGHT[$PRIMARY]}
    SX=${POS_X[$SECONDARY]}
    SY=${POS_Y[$SECONDARY]}
    SW=${WIDTH[$SECONDARY]}
    SH=${HEIGHT[$SECONDARY]}

    # Check if they overlap vertically (horizontal adjacency)
    if (( PY < SY + SH && SY < PY + PH )); then
        # They are on the same "row" — horizontal adjacency
        if (( SX + SW / 2 < PX + PW / 2 )); then
            # Secondary center is left of primary center → secondary is on the LEFT
            NORMAL_X=$(( PX - SW ))
            GAMING_X=$(( NORMAL_X - GAP ))
        else
            # Secondary is on the RIGHT
            NORMAL_X=$(( PX + PW ))
            GAMING_X=$(( NORMAL_X + GAP ))
        fi
        NORMAL_Y=$SY
        GAMING_Y=$SY

    # Check if they overlap horizontally (vertical adjacency)
    elif (( PX < SX + SW && SX < PX + PW )); then
        # They are on the same "column" — vertical adjacency
        if (( SY + SH / 2 < PY + PH / 2 )); then
            # Secondary center is above primary center → secondary is ABOVE
            NORMAL_Y=$(( PY - SH ))
            GAMING_Y=$(( NORMAL_Y - GAP ))
        else
            # Secondary is BELOW
            NORMAL_Y=$(( PY + PH ))
            GAMING_Y=$(( NORMAL_Y + GAP ))
        fi
        NORMAL_X=$SX
        GAMING_X=$SX

    else
        # Diagonal or not adjacent — skip this secondary
        notify-send "Niri" "Aviso: monitor $SECONDARY não está alinhado com o primário"
        continue
    fi

    CURRENT_X=${POS_X[$SECONDARY]}
    CURRENT_Y=${POS_Y[$SECONDARY]}

    if (( CURRENT_X == GAMING_X && CURRENT_Y == GAMING_Y )); then
        NEW_X=$NORMAL_X
        NEW_Y=$NORMAL_Y
        MODE="Padrão"
    else
        NEW_X=$GAMING_X
        NEW_Y=$GAMING_Y
        MODE="Jogo"
    fi

    niri msg output "$SECONDARY" position set "$NEW_X" "$NEW_Y"
    notify-send "Niri" "Modo: $MODE"
    exit 0
done

notify-send "Niri" "Erro: nenhum monitor secundário alinhado encontrado"
exit 1
