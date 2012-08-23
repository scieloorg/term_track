#!/bin/bash

# ------------------------------------------------------------------------- #
# procTPh.sh - Processa base artigohuc
# ------------------------------------------------------------------------- #
#     Entrada : M/F artigohuc
#       Saida : I/F artigohuc
#    Corrente : term_track
#     Chamada : shs/procTPh.sh [opcoes]
#     Exemplo : shs/procTPh.sh -d 4
# Objetivo(s) : Gerar I/F com tecnica 3 (/..../)
# Comentarios : 
# Observacoes :	A variavel DEBUG eh mapeada por BIT conforme:
#		bit Atribuicao
#		 0  Aguarda tecla <ENTER>	(1)
#		 1  Mostra mensagens de DEBUG	(2)
#		 2  Modo verboso		(4)
#		 3  .
#		 4  .
#		 5  .
#		 6  .
#		 7  .
#       Notas : 
# Dependencia : 
# ------------------------------------------------------------------------- #
#             QAPLA Comercio e Servicos de Informatica Ltda-ME
#                    QAPLA / QAPLAWEB / INFOISIS (P)2012
# ------------------------------------------------------------------------- #
# Historico
# versao data, Responsavel
#	- Descricao
cat > /dev/null <<HISTORICO
vrs:  0.01 20120820, FJLopes
	- Edicao original
HISTORICO

# ========================================================================= #
#                                  Funcoes                                  #
# ========================================================================= #
# isNumber - Determina se o parametro eh numerico
# PARM $1  - String a verificar se eh numerica ou nao
# Obs.    `-eq` soh opera bem com numeros portanto se nao for numero da erro
#
isNumber() {
	[ "$1" -eq "$1" ] 2> /dev/null
	return $?
}
#

# ========================================================================= #
# ClrFS - Clear File System
# PARM $1 - Identificador dos temporarios a apagar
#
ClrFS () {
        rm -f *$1*
        return
}

# ========================================================================= #
# timo - Aborta execucao de comando ao ultrapassar o TIME-OUT
# ----
# From:
# http://www.cyberciti.biz/faq/shell-scripting-run-command-under-alarmclock/
# alarm TIME-OUT cmd arg1 arg2 arg3...
#
# ( /path/to/slow command with options ) & sleep TIME-OUT; kill $!
# Encontrado em:
# http://stackoverflow.com/questions/687948/timeout-a-command-in-bash-without-unnecessary-delay
#
# BASH based (mais claro um pouco)
# TIMEOUT=”60″
# $MYPROGRAM >/dev/null &
# pid=$!
# sleep $TIMEOUT && kill -KILL $pid >/dev/null 2>&1 && echo “$MYPROGRAM failed”
# Encontrado em:
# http://www.itbert.de/2010/06/03/bash-timeout-function/
# ----
#
timo() {
	perl -e 'alarm shift; exec @ARGV' "$@";
}
#

# ========================================================================= #
# PegaValor - Obtem valor de uma clausula
# PARM $1 - Item de configuracao a ser lido
# Obs: O arquivo a ser lido eh o contido na variavel CONFIG 
#
PegaValor () {
	if [ -f "$CONFIG" ]; then
		grep "^$1" $CONFIG > /dev/null
		RETORNO=$?
		if [ $RETORNO -eq 0 ]; then
			RETORNO=$(grep $1 $CONFIG | tail -n "1" | cut -d "=" -f "2")
			echo $RETORNO
		else
			false
		fi
	else
		false
	fi
	return
}
#

# ========================================================================= #

if [ -n "$DEBUG" ]; then
	clear
	echo "*****"
	echo "** Chave de depuracao (\$DEBUG) esta ativa nesta execucao"
	echo "*****"
	echo
fi

CURRD=$(pwd)
HINIC=$(date '+%s')
HRINI=$(date '+%Y.%m.%d %H:%M:%S')
TREXE=$(basename $0)
PRGDR=$(dirname $0)
LCORI=$*

# ------------------------------------------------------------------------- #
# Texto de ajuda de utilizacao do comando

AJUDA_USO="
Uso: $TREXE [OPCOES] [TELL_FACTOR]

OPCOES:
 -h, --help             Exibe este texto de ajuda e para a execucao
 -V, --version          Exibe a versao corrente do comando e para a execucao
 -d, --debug NIVEL      Define nivel de depuracao com valor numerico positivo
 -c, --config NOMEARQU  Usa NOMEARQU para obter a configuracao do aplicativo
                        (uso de path eh permitido em NOMEARQU)
 --changelog            Lista o historico das alteracoes do programa

PARAMETROS:
 PARM1 - Fator tell a ser utilizado no processo (numerico)
"

# ------------------------------------------------------------------------- #
# Texto de sintaxe do comando

SINTAXE="

Uso: $TREXE [OPCOES] [TELL_FACTOR]

"

# ------------------------------------------------------------------------- #
# Ajustes de ambiente

# ------------------------------------------------------------------------- #
# Ajustes de operacao por omissao

CONFIG="config/config.txt"

# -------------------------------------------------------------------------- #
# Tratamento das opcoes de linha de comando (qdo houver alguma)

while test -n "$1"
do
	case "$1" in
		
		-h | --help)
			echo "$AJUDA_USO"
			exit 0
		;;
		
		-V | --version)
			echo -e -n "\n$TREXE "
			grep '^vrs: ' $PRGDR/$TREXE | tail -1
			echo
			exit 0
		;;
		
		-d | --debug)
			shift
			isNumber $1
			[ $? -ne 0 ] && echo -e "\n$TREXE: O argumento da opcao DEBUG deve existir e ser numerico.\n$AJUDA_USO" && exit 1
			DEBUG=$1
		;;
		
		-c | --config)
			shift
			CONFIG="$PRGDR/$1"
			if [ ! -s "$CONFIG" ]; then
				echo "Arquivo de configuracao $CONFIG nao localizado ou vazio"
				exit 1
			fi
		;;
		
		--changelog)
			TOTLN=$(wc -l $0 | awk '{ print $1 }')
			INILN=$(grep -n "<SPICEDHAM" $0 | tail -1 | cut -d ":" -f "1")
			LINHAI=$(expr $TOTLN - $INILN)
			LINHAF=$(expr $LINHAI - 2)
			echo -e -n "\n$TREXE "
			grep '^vrs: ' $PRGDR/$TREXE | tail -1
			echo -n "==> "
			tail -$LINHAI $0 | head -$LINHAF
			echo
			exit 0
		;;
		
		*)
			if [ $(expr index $1 "-") -ne 1 ]; then
				if test -z "$PARM1"; then PARM1=$1; shift; continue; fi
				if test -z "$PARM2"; then PARM2=$1; shift; continue; fi
				if test -z "$PARM3"; then PARM3=$1; shift; continue; fi
				if test -z "$PARM4"; then PARM4=$1; shift; continue; fi
				if test -z "$PARM5"; then PARM5=$1; shift; continue; fi
				if test -z "$PARM6"; then PARM6=$1; shift; continue; fi
				if test -z "$PARM7"; then PARM7=$1; shift; continue; fi
				if test -z "$PARM8"; then PARM8=$1; shift; continue; fi
				if test -z "$PARM9"; then PARM9=$1; shift; continue; fi
			else
				echo "Opcao nao valida! ($1)"
			fi
		;;
	esac
	# Argumento tratado, desloca os parametros e trata o proximo
	shift
done

isNumber $DEBUG
[ $? -ne 0 ] && DEBUG=0

# ------------------------------------------------------------------------- #
# Assume configuracao DEFAULT na falta do arquivo DEFAULT de configuracao
PATH_LINDG4="cisis"

# ------------------------------------------------------------------------- #
# Le configuracao do arquivo se este existir

if [ -s "$CONFIG" ]; then
        # Valores sao opcionais
        TEMP=$(PegaValor PATH_G4_DIR); [ -n "$TEMP" ] && PATH_LINDG4=$TEMP

        # Valores derivados
fi

if [ "$DEBUG" -gt 1 ]; then
        echo "= DISPLAY DE VALORES INTERNOS ="
        echo "==============================="
        
	echo "PRGDR = $PRGDR"
	echo "TREXE = $TREXE"
	echo "LCORI = $LCORI"
	echo "CURRD = $CURRD"
	echo
        test -n "$PARM1" && echo "PARM1 = $PARM1"
        test -n "$PARM2" && echo "PARM2 = $PARM2"
        test -n "$PARM3" && echo "PARM3 = $PARM3"
        test -n "$PARM4" && echo "PARM4 = $PARM4"
        test -n "$PARM5" && echo "PARM5 = $PARM5"
        test -n "$PARM6" && echo "PARM6 = $PARM6"
        test -n "$PARM7" && echo "PARM7 = $PARM7"
        test -n "$PARM8" && echo "PARM8 = $PARM8"
        test -n "$PARM9" && echo "PARM9 = $PARM9"
        echo
        echo "     CONFIG = $CONFIG"
        echo "PATH_LINDG4 = $PATH_LINDG4"
        
        echo "==============================="
        echo
fi

[ "$DEBUG" -gt 0 ] && echo "DEBUG Level = $DEBUG"

echo "[TIME-STAMP] $HRINI [:INI:] $TREXE $LCORI"

# ------------------------------------------------------------------------- #

#### COMECO DO SHELL
#     12345678901234567890
echo "[PARTH] Processa artigo tipo H em upper-case"

echo "[PARTH] Garante condicoes de execucao"
echo "12 7 (|~TI_~|v12^*/)" >  fst/tipoh.fst
echo "83 7 (|~AB_~|v83^a/)" >> fst/tipoh.fst
echo "85 7 (|~KW_~|v85^k/)" >> fst/tipoh.fst
echo "40 0 'LG_'v40"        >> fst/tipoh.fst
echo "880 0 'IU_'v880"      >> fst/tipoh.fst

echo "[PARTH] Aplica gizmo de termos em ingles"
$PATH_LINDG4/mx artigohuc gizmo=gizmo/gtmen create=artigohEN -all now tell=0$PARM1
source shs/common/checkerror.sh

echo "[PARTH] Aplica gizmo de termos em espanhol"
$PATH_LINDG4/mx artigohuc gizmo=gizmo/gtmes create=artigohES -all now tell=0$PARM1
source shs/common/checkerror.sh

echo "[PARTH] Aplica gizmo de termos em portugues"
$PATH_LINDG4/mx artigohuc gizmo=gizmo/gtmpt create=artigohPT -all now tell=0$PARM1
source shs/common/checkerror.sh

echo "[PARTH] Inverte termos em ingles"
$PATH_LINDG4/mx artigohEN "fst=@fst/tipoh.fst" fullinv=artigohEN tell=0${PARM1}0
source shs/common/checkerror.sh

echo "[PARTH] Inverte termos em espanhol"
$PATH_LINDG4/mx artigohES "fst=@fst/tipoh.fst" fullinv=artigohES tell=0${PARM1}0
source shs/common/checkerror.sh

echo "[PARTH] Inverte termos em portugues"
$PATH_LINDG4/mx artigohPT "fst=@fst/tipoh.fst" fullinv=artigohPT tell=0${PARM1}0
source shs/common/checkerror.sh

# ------------------------------------------------------------------------- #
# Limpa area de trabalho
[ -f "arquivo.x" ] && rm -f arquivo.x

#### TERMINO DO SHELL

# ------------------------------------------------------------------------- #
# Contabiliza tempo de processamento e gera relato da ultima execucao

HRFIM=$(date '+%Y.%m.%d %H:%M:%S')
HFINI=$(date '+%s')
TPROC=$(expr $HFINI - $HINIC)

echo "[TIME-STAMP] $HRFIM [:FIM:] $TREXE $LCORI"
# ------------------------------------------------------------------------- #
echo -n "[$TREXE] Tempo decorrido: "

[ -z "$TPROC" ] && TPROC=0

MTPROC=$(expr $TPROC % 3600)
HTPROC=$(expr $TPROC - $MTPROC)
HTPROC=$(expr $HTPROC / 3600)
STPROC=$(expr $MTPROC % 60)
MTPROC=$(expr $MTPROC - $STPROC)
MTPROC=$(expr $MTPROC / 60)

         printf "%02d:%02d:%02d" $HTPROC $MTPROC $STPROC
THUMAN=$(printf "%02d:%02d:%02d" $HTPROC $MTPROC $STPROC)

echo " ou  $TPROC [s]"

# ------------------------------------------------------------------------- #

unset	HINIC	HFINI	TREXE	TPROC
unset	MTPROC	HTPROC	STPROC	THUMAN

# ------------------------------------------------------------------------- #
cat > /dev/null <<SPICEDHAM
CHANGELOG
20120820 Edicao original
SPICEDHAM

