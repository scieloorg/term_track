#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Sixtax error: tabulacao.sh \"TERMO DE BUSCA\""
fi

 mx artigouc "text=$1" "pft=v880/" now | sort > "$1.lst"
 mx seq="$1.lst" -all now tab=v1 | sort -n

