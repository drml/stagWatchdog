#! /bin/bash

# STAG SCHEDULE WATCHDOG
# 
# author: Ondrej Doktor, doktor.ml@gmail.com
#
# https://github.com/drml/stagWatchdog
#
# license: MIT




# zobrazi navod k pouziti
usage()
{
	echo ""
	echo "Pouziti: stagWatchdog [-q] [-h hostname] -s semestr(ZS|LS) -o osobniCislo" 1>&2
	echo ""
	echo "Povinne parametry:"
	echo "	-s	Zkratka semestru, ke kteremu se ma kontrolovat rozvrh. Pripustne"
	echo "		hodnoty jsou bud 'ZS' nebo 'LS' (bez apostrofu)"
	echo ""
	echo "	-o	Osobni cislo studenta, tak jak je ulozeno v systemu STAG. "
	echo ""
	echo "Nepovinne parametry:"
	echo "	-h	Hostname na kterem je pristupne REST API systemu STAG. Pokud neni"
	echo "		vyplneno, pouzije se wstag.jcu.cz"
	echo ""
	echo "	-q	Tichy rezim. Vystup se generuje pouze pri vyskutu zmeny, nebo"
	echo "		pokud nastane chyba. Tato volba je vhodna napr. pro automatizovane"
	echo "		zasilani mailu pomoci CRONu.	"
	echo ""
	exit 1
}


# prevede CSV rozvrhy do lidky citelne podoby
formatCsvHr(){

	cat $1 | \
	  cut -d\; -f 2-4,15-16,20,28-29,32,45 | \
	  column -s\; -t | \
	  sed 's/\"//g'
}


personCode=""
semester="" 
host="wstag.jcu.cz"
apiQuerry="/ws/services/rest/rozvrhy/getRozvrhByStudent?outputFormatEncoding=UTF-8&outputFormat=csv" 
qFlag=""

# ----------- Osetreni vstupu

while getopts qs:h:o: opt
do
	case "$opt" in
	(q) qFlag="-q";;
	(s) semester="$OPTARG";;
	(o) personCode="$OPTARG";;
	(h) host="$OPTARG";;
	(*) usage;;
	esac
done

if [[ -z $personCode ]]
then
        echo "Chyba: nebylo zadano osobni cislo"
        usage
fi

if [[ $semester != "ZS" && $semester != "LS" ]]
then
	echo "Chyba: volba semestr muze nabyvat pouze hodnot 'LS' nebo 'ZS'"
	usage
fi

# -------------- Priprava prostredi

apiUrl="http://${host}${apiQuerry}&osCislo=${personCode}&semestr=${semester}"
mostRecent="data/${personCode}-$(date +%s;).csv"


if [ ! -d "./data" ]		# pokud adresar neexistuje, vytvor ho
then
	mkdir ./data
fi

lastKnown=""
if [ "$(ls -A ./data)" ]		# pokud je neprazdny, hledej posledni znamy stav
then
	lastKnown=$(ls -dt ./data/* | head -1)
fi

# --------------- Ziskavani dat

wget -q -O $mostRecent $apiUrl 2> /dev/null

if [[ $? > 0 ]]
then
	echo "Chyba: nepodarilo se nacist data ze systemu STAG"
	echo "URL: $apiUrl"
	exit 2
fi


difference=""
if [ -e "$lastKnown" ]
then
	difference=$(diff $mostRecent $lastKnown);

	if [[ $? > 2 ]]		# 0 - zadna zmena, 1 - zmena, 2+ - prusvih
	then
        	echo "Chyba: nepodarilo se porovnat soubory, overte pristupova prava"
	        exit 3
	fi
fi

# -------------- Vyhodnoceni

if [[ $difference = "" && $lastKnown != "" ]]; then

	if [[ $qFlag = "" ]]
	then
		echo "-----------------------------------------"
		echo "Rozvrh se od posledni kontroly nezmenil"
		echo "-----------------------------------------"
	fi

	# Smaze ten ktery prave stahnul (kdys je stejny) a konec

	rm $mostRecent;
	exit 0
elif [[ $lastKnown = "" ]]
then

        if [[ $qFlag = "" ]]
        then
        	echo "-----------------------------------------"
	        echo "Prvni spusteni, inicialni data nactena"
	        echo "-----------------------------------------"
        fi


else
	if [[ $qFlag = "" ]]
        then
                echo "-----------------------------------------"
                echo "Rozvrh se od posledni kontroly ZMENIL!"
                echo "---------------------------==========----"
        fi

	# zobrazi oberveny rozdilovy podhled
	diff -u <(formatCsvHr $mostRecent) <(formatCsvHr $lastKnown) \
	  | sed 's/^-/\x1b[31m-/;s/^+/\x1b[32m+/;s/$/\x1b[0m/'
fi;


