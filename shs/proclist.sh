#!/bin/bash

# ------------------------------------------------------------------------- #
# proclist.sh - Processa lista de termos a rastrear
# ------------------------------------------------------------------------- #
#     Entrada : PARM1 arquivo com termos a carregar para  rastreio
#		Arquivo CSV no diretorio LIST
#       Saida : Bases gizmos geradas
#    Corrente : proc ou term_track
#     Chamada : proclist.sh [opcoes]
#     Exemplo : shs/proclist.sh -d 4
# Objetivo(s) : Gerar gizmos de termos a indexar
# Comentarios : Os termos do CSV nao tem espacos nas 'pontas'
#		O primeiro elemento deve ser ignorado
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
#       Notas : Uma opcao de processa idioma selecionado porderia ser bom
# Dependencia : 
# ------------------------------------------------------------------------- #
#             QAPLA Comercio e Servicos de Informatica Ltda-ME
#                    QAPLA / QAPLAWEB / INFOISIS (P)2012
# ------------------------------------------------------------------------- #
# Historico
# versao data, Responsavel
#	- Descricao
cat > /dev/null <<HISTORICO
vrs:  0.00 20120819, FJLopes
	- Edicao original
HISTORICO

# ========================================================================= #
#                                  Funcoes                                  #
# ========================================================================= #

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
Uso: $TREXE [OPCOES] [<ARQUIVO.CSV>]

OPCOES:
 -h, --help             Exibe este texto de ajuda e para a execucao
 -V, --version          Exibe a versao corrente do comando e para a execucao
 -d, --debug NIVEL      Define nivel de depuracao com valor numerico positivo
 -c, --config NOMEARQU  Usa NOMEARQU para obter a configuracao do aplicativo
                        (uso de path eh permitido em NOMEARQU)
 --changelog            Lista o historico das alteracoes do programa

PARAMETROS:
 PARM1  Nome do arquivo CSV contendo os termos para rastrear
"

# ------------------------------------------------------------------------- #
# Texto de sintaxe do comando

SINTAXE="

Uso: $TREXE [OPCOES] [<ARQUIVO.CSV>]

"

# ------------------------------------------------------------------------- #
# Ajustes de ambiente

#export CIPAR=$TABS/GBASE.cip

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
PATH_LINDG4=cisis

[ -z "$PARM1" ] && PARM1=lista_wok.csv

# ------------------------------------------------------------------------- #
# Le configuracao do arquivo se este existir

if [ -s "$CONFIG" ]; then
        # Valores sao opcionais
        TEMP=$(PegaValor PATH_G4_DIR);   [ -n "$TEMP" ] && PATH_LINDG4=$TEMP

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

#### COMECO DO SHELL
#     12345678901234567890
echo "[PLIST] Gera gizmo de termos para indexacao"

echo "[PLIST] Garente condicoes de execucao"
echo "[PLIST] - gizmo de UTF-8"
if [ ! -s "gizmo/gutf8ans.xrf" ]; then
	[ "$DEBUG" -ge 4 ] && echo "[PLIST] >>> id2i gizmo/gutf8ans.id create=gizmo/gutf8ans"
        $PATH_LINDG4/id2i gizmo/gutf8ans.id create=gizmo/gutf8ans
        source shs/common/checkerror.sh
fi

echo "[PLIST] - controle de execucao mx"
echo "gizmo=gizmo/gutf8ans"     >  input/plist.input
echo "proc='Gsplit/clean=1='" >> input/plist.input
echo "proc='Gsplit/clean=2='" >> input/plist.input
echo "proc='Gsplit/clean=3='" >> input/plist.input
echo "uctab=tab/ucans.tab"      >> input/plist.input
echo "actab=tab/acans.tab"      >> input/plist.input
echo "lw=0"                     >> input/plist.input
echo "now"                      >> input/plist.input
[ "$DEBUG" -ge 4 ] && echo "====================" && cat input/plist.input && echo "===================="

#ingles
echo "[PLIST] Processa o gizmo de ingles"
[ "$DEBUG" -eq 4 ] && echo "[PLIST] >>> mx \"seq=list/$PARM1,\" \"in=input/plist.input\" \"pft=if p(v1) then v1,mpu,'|/'v1'/|',v1/ fi\" > work/list_wok_en.seq"
$PATH_LINDG4/mx "seq=list/$PARM1," "in=input/plist.input" "pft=if p(v1) and mfn<>1 then v1,mpu,'|/'v1'/|',v1/ fi" > work/list_wok_en.seq
echo "[PLIST] Carrega o gizmo de ingles"
[ "$DEBUG" -eq 4 ] && echo "[PLIST] >>> mx seq=work/list_wok_en.seq create=gizmo/gtmen -all now"
$PATH_LINDG4/mx seq=work/list_wok_en.seq create=work/work -all now
[ "$DEBUG" -eq 4 ] && echo "[PLIST] >>> mxcp work/work create=gizmo/gtmen clean log=/dev/null"
$PATH_LINDG4/mxcp work/work create=gizmo/gtmen clean log=/dev/null
echo -n "[PLIST] Termos em ingles processados: "
[ "$DEBUG" -eq 4 ] && echo "[PLIST] >>> mx gizmo/gtmen +control count=0 | tail -1 | awk {' print $1 '}"
$PATH_LINDG4/mx gizmo/gtmen +control count=0 | tail -1 | awk {' print $1 '}
echo "[PLIST] Lista termos em ingles rastreaveis"
[ "$DEBUG" -ge 4 ] && echo "[PLIST] >>> mx gizmo/men \"pft=v1/\" lw=0 now > list/LST_EN.txt"
$PATH_LINDG4/mx gizmo/gtmen "pft=v1/" lw=0 now > list/lst_en.txt
$PATH_LINDG4/mx gizmo/gtmen "pft=v3/" lw=0 now > list/LST_EN.txt
echo "Termos em ingles"
echo "============================================================"
cat list/LST_EN.txt
echo "1 4" >  3p1p4
echo "3 1" >> 3p1p4
$PATH_LINDG4/retag gizmo/gtmen 3p1p4
rm -f 3p1p4

#espanhol
echo "[PLIST] Processa o gizmo de espanhol"
$PATH_LINDG4/mx "seq=list/lista_wok.csv," "in=input/plist.input" "pft=if p(v2) and mfn<>1 then v2,mpu,'|/'v2'/|',v2/ fi" > work/list_wok_es.seq
echo "[PLIST] Carrega o gizmo de espanhol"
$PATH_LINDG4/mx seq=work/list_wok_es.seq create=work/work -all now
$PATH_LINDG4/mxcp work/work create=gizmo/gtmes clean log=/dev/null
echo -n "[PLIST] Termos em espanhol processados: "
$PATH_LINDG4/mx gizmo/gtmes +control count=0 | tail -1 | awk {' print $1 '}
echo "[PLIST] Lista termos em espanhol rastreaveis"
$PATH_LINDG4/mx gizmo/gtmes "pft=v1/" lw=0 now > list/lst_es.txt
$PATH_LINDG4/mx gizmo/gtmes "pft=v3/" lw=0 now > list/LST_ES.txt
echo "Termos em espanhol"
echo "============================================================"
cat list/LST_ES.txt
echo "1 4" >  3p1p4
echo "3 1" >> 3p1p4
$PATH_LINDG4/retag gizmo/gtmes 3p1p4
rm -f 3p1p4

#Portugues
echo "[PLIST] Processa o gizmo de portugues"
$PATH_LINDG4/mx "seq=list/lista_wok.csv," "in=input/plist.input" "pft=if p(v3) and mfn<>1 then v3,mpu,'|/'v3'/|',v3/ fi" > work/list_wok_pt.seq
echo "[PLIST] Carrega o gizmo de portugues"
$PATH_LINDG4/mx seq=work/list_wok_pt.seq create=work/work -all now
$PATH_LINDG4/mxcp work/work create=gizmo/gtmpt clean log=/dev/null
echo -n "[PLIST] Termos em portugues processados: "
$PATH_LINDG4/mx gizmo/gtmpt +control count=0 | tail -1 | awk {' print $1 '}
echo "[PLIST] Lista termos em portugues rastreaveis"
$PATH_LINDG4/mx gizmo/gtmpt "pft=v1/" lw=0 now > list/lst_pt.txt
$PATH_LINDG4/mx gizmo/gtmpt "pft=v3/" lw=0 now > list/LST_PT.txt
echo "Termos em portugues"
echo "============================================================"
cat list/LST_PT.txt
echo "1 4" >  3p1p4
echo "3 1" >> 3p1p4
$PATH_LINDG4/retag gizmo/gtmpt 3p1p4
rm -f 3p1p4

# ------------------------------------------------------------------------- #
# Limpa area de trabalho
[ -f "work/linst_wor_pt.seq" ] && rm -f work/*seq

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
20120819 Edicao original
SPICEDHAM

