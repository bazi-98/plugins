#!/bin/sh
# *----------------------------------------------------*
# * Senderlisten fuer das Netz von Vodafone generieren *
# *----------------------------------------------------*

# *------------------------------------------------------*
# * Zeilen nach n Zeichen an einer Wortgrenze umbrechen  *
# *------------------------------------------------------*
zeilenumbruch ()
{
	sed -e 's/.\{70\}\,/&\n/g' $1 | sed -e 's/^ *//g' | sed -e 's/^/COMMENT=/g' >> $2
}

# *-------------------------------*
# * Temporäre Dateien löschen *
# *-------------------------------*
delete_files ()
{
	rm -f /tmp/bundesland.*
	rm -f /tmp/netz.*
	rm -f /tmp/subnetz.*
	rm -f /tmp/suborte.*
	rm -f /tmp/kabelservice.sel
	rm -f /tmp/belegung.html
	rm -f /tmp/cookies.txt
	rm -f /tmp/myservices.*
	rm -f /tmp/services.* 
	rm -f /tmp/cables.* 
	rm -fr /tmp/zapit
}

# *------------------*
# * Auswahl Provider *
# *------------------*
security_check ()
{
	msgbox size=22 title="Sicherheitsabfrage" msg="~cWollen Sie wirklich die Sendeliste erneuern?~n~cDie bestehende wird gesichert und~n~ckann mit der Auswahl reset~n~cwieder hergestellt werden!" order=3 absolute=1 default=1 select="Ja,Reset,Nein"
	auswahl=$?

	case $auswahl	in
	1)
		url="https://helpdesk.vodafonekabelforum.de"
		;;
	2)
		load_backup
		;;
	*)
		delete_files
		exit
		;;
	esac
}


# *-------------------*
# * Bundeslandauswahl *
# *-------------------*
bundeslandauswahl ()
{
	rm -f /tmp/bundesland.*
	echo FONT=/share/fonts/neutrino.ttf					>  /tmp/bundesland.conf
	echo FONTSIZE=22							>> /tmp/bundesland.conf
	echo HEIGHT=480								>> /tmp/bundesland.conf
	echo WIDTH=800								>> /tmp/bundesland.conf
	echo LINESPP=16								>> /tmp/bundesland.conf
	echo "MENU=Bitte wählen sie ihr Bundesland:"				>> /tmp/bundesland.conf
	echo "ACTION='Baden-W'~u'rttemberg',echo '1' > /tmp/bundesland.data"	>> /tmp/bundesland.conf
	echo "ACTION='Bayern',echo '2' > /tmp/bundesland.data"			>> /tmp/bundesland.conf
	echo "ACTION='Berlin',echo '3' > /tmp/bundesland.data"			>> /tmp/bundesland.conf
	echo "ACTION='Brandenburg',echo '4' > /tmp/bundesland.data"		>> /tmp/bundesland.conf
	echo "ACTION='Bremen',echo '5' > /tmp/bundesland.data"			>> /tmp/bundesland.conf
	echo "ACTION='Hamburg',echo '6' > /tmp/bundesland.data"			>> /tmp/bundesland.conf
	echo "ACTION='Hessen',echo '7' > /tmp/bundesland.data"			>> /tmp/bundesland.conf
	echo "ACTION='Mecklenburg-Vorpommern',echo '8' > /tmp/bundesland.data"	>> /tmp/bundesland.conf
	echo "ACTION='Niedersachsen',echo '9' > /tmp/bundesland.data"		>> /tmp/bundesland.conf
	echo "ACTION='Nordrhein-Westfalen',echo '10' > /tmp/bundesland.data"	>> /tmp/bundesland.conf
	echo "ACTION='Rheinland-Pfalz',echo '11' > /tmp/bundesland.data"	>> /tmp/bundesland.conf
	echo "ACTION='Saarland',echo '12' > /tmp/bundesland.data"		>> /tmp/bundesland.conf
	echo "ACTION='Sachsen',echo '13' > /tmp/bundesland.data"		>> /tmp/bundesland.conf
	echo "ACTION='Sachsen-Anhalt',echo '14' > /tmp/bundesland.data"		>> /tmp/bundesland.conf
	echo "ACTION='Schleswig-Holstein',echo '15' > /tmp/bundesland.data"	>> /tmp/bundesland.conf
	echo "ACTION='Th'~u'ringen',echo '16' > /tmp/bundesland.data"		>> /tmp/bundesland.conf
	echo "ENDMENU"								>> /tmp/bundesland.conf
	if [ -s /var/tuxbox/plugins/shellexec.so ]; then
	/var/tuxbox/plugins/shellexec.so /tmp/bundesland.conf > /dev/null
	else
	/usr/share/tuxbox/neutrino/plugins/shellexec.so /tmp/bundesland.conf > /dev/null
	fi
	if [ -s /tmp/bundesland.data ]; then
		select=`sed -n 1p /tmp/bundesland.data`; select=`echo $select`
	else
		url=""
		exit
	fi
}

# *-------------*
# * Netzauswahl *
# *-------------*
netzauswahl ()
{
	rm -f /tmp/netz.*
	echo FONT=/share/fonts/neutrino.ttf                                    >  /tmp/netz.conf
	echo FONTSIZE=22                                                       >> /tmp/netz.conf
	echo HEIGHT=480                                                         >> /tmp/netz.conf
	echo WIDTH=800                                                         >> /tmp/netz.conf
	echo LINESPP=16                                                        >> /tmp/netz.conf
	echo "MENU=Bitte wählen sie ihr Netz:"                                 >> /tmp/netz.conf
	cat /tmp/kabelservice.sel | \
	sed -n "/<select/,/\/select/p" | \
	sed -n "/\/select/,/\/select/p" | sed -n "/option/p" | sed -e "1,2d" | \
	sed -e "s/^.*=\"\(.*\)\">\(.*\)<.*$/ACTION=\'\2\',echo \'\1\' \> \/tmp\/netz.data/g"   >> /tmp/netz.conf
	echo "ENDMENU"                                                         >> /tmp/netz.conf
	if [ -s /var/tuxbox/plugins/shellexec.so ]; then
	/var/tuxbox/plugins/shellexec.so /tmp/netz.conf > /dev/null
	else
	/usr/share/tuxbox/neutrino/plugins/shellexec.so /tmp/netz.conf > /dev/null
	fi
	if [ -s /tmp/netz.data ]; then
		auswahl=`cut -b 1-2 /tmp/netz.data`
		if [ "$auswahl" == "k_" ]; then
			select=`cat /tmp/netz.data | sed -e 's/^..//g'`; select=`echo $select`
			curl --no-progress-meter --insecure -k -L "$url/sendb/kopfstationen.html" | \
			sed -n "/name=\"netz\"/p" > /tmp/netz.html
			subnetzauswahl /tmp/netz.html
		else
			subnetz=`cat /tmp/netz.data`; subnetz=`echo $subnetz`
		fi
	else
		rm -f /tmp/bundesland.data
	fi
}

# *----------------*
# * Subnetzauswahl *
# *----------------*
subnetzauswahl ()
{
	rm -f /tmp/subnetz.*
	echo FONT=/share/fonts/neutrino.ttf					>  /tmp/subnetz.conf
	echo FONTSIZE=22							>> /tmp/subnetz.conf
	echo HEIGHT=480								>> /tmp/subnetz.conf
	echo WIDTH=800								>> /tmp/subnetz.conf
	echo LINESPP=16								>> /tmp/subnetz.conf
	echo "MENU=Bitte wählen sie ihr Subnetz:"				>> /tmp/subnetz.conf
	zeilen=`sed -n -e '$ =' $1`;  zeilen=`expr "$zeilen"`
	i=1; step=1
	while [ "$i" -le "$zeilen" ]; do
		subnetz=`sed -n "$i"p $1 | sed -e 's/^.*value=\"//g' -e 's/\" type.*$//g'`; subnetz=`echo $subnetz`
		suborte=`sed -n "$i"p $1 | sed -e 's/^.*radio=\"//g' -e 's/<[^>]*>//g'`; suborte=`echo $suborte`
		echo "ACTION='Subnetz $i',echo '$subnetz' > /tmp/subnetz.data"	>> /tmp/subnetz.conf
		echo $suborte > /tmp/subnetz.wrap
		zeilenumbruch /tmp/subnetz.wrap /tmp/subnetz.conf
		i=`expr $i + $step`
	done
	echo "ENDMENU"								>> /tmp/subnetz.conf
	if [ -s /var/tuxbox/plugins/shellexec.so ]; then
	/var/tuxbox/plugins/shellexec.so /tmp/subnetz.conf > /dev/null
	else
	/usr/share/tuxbox/neutrino/plugins/shellexec.so /tmp/subnetz.conf > /dev/null
	fi
	if [ -s /tmp/subnetz.data ]; then
		subnetz=`cat /tmp/subnetz.data`; subnetz=`echo $subnetz`
	else
		rm -f /tmp/bundesland.data
	fi
}

# *----------------------------*
# * Archiv holen und entpacken *
# *----------------------------*
get_archiv ()
{
	rm -rf /tmp/var
	rm -rf /tmp/zapit
	exporturl=`curl --no-progress-meter $url/sendb/belegung-$subnetz.html | \
	sed -n "/Neutrino/p" | \
	sed -e 's/^.*href=\"//g' -e 's/\"><b.*$//g' -e 's/\&amp;/\&/g'`
	exporturl=`echo $url$exporturl`
	curl --no-progress-meter --insecure -k -L -o /tmp/subnetz.zip "$exporturl"
	unzip -oq /tmp/subnetz.zip -d /tmp
	cp -r /tmp/var/tuxbox/config/zapit/ /tmp
	cp -r /tmp/var/tuxbox/config/cables.xml /tmp/
	rm -rf /tmp/var
}

# *---------------------*
# * cables.xml aendern *
# *---------------------*
mod_cables ()
{
	cat /tmp/cables.xml | \
	sed -e 's/vom/mit Inanspruchnahme von Daten dess/g' \
		-e 's/Kabel Deutschland/Vodafone/g' \
		-e 's/kdgforum/vodafonekabelforum/g' \
		-e 's/KDG/Vodafone-Kabel/g' > /tmp/zapit/cables_new.xml

}

# *---------------------*
# * services.xml aendern *
# *---------------------*
mod_services ()
{
	cat /tmp/zapit/services.xml | \
	sed -e 's/vom/mit Inanspruchnahme von Daten dess/g' \
		-e 's/kdgforum/vodafonekabelforum/g' \
		-e 's/KDG/Vodafone-Kabel/g' \
		-e 's/<zapit>/<zapit api=\"4\">/g' \
		-e 's/\" name=\"/\" n=\"/g' \
		-e 's/<cable/<cable position=\"3840\"/g' \
		-e 's/transponder/TS/g' \
		-e 's/modulation/mod/g' \
		-e 's/fec_inner/fec/g' \
		-e 's/symbol_rate/sr/g' \
		-e 's/000\" inversion/\" inv/g' \
		-e 's/onid/on/g' \
		-e 's/type="a"/type="2"/g' \
		-e 's/frequency/frq/g' \
		-e 's/channel service_id/S i/g' \
		-e 's/mod="5">/mod="5" sys="2">/g' \
		-e 's/mod="3">/mod="3" sys="2">/g' \
		-e 's/Kabel Deutschland/Vodafone/g' \
		-e 's/ÃƒÂ¶/Ã¶/g' \
		-e 's/ÃƒÂ¼/Ã¼/g' \
		-e 's/Ãƒ/Ãœ/g' \
		-e '/automatically generated/d' \
		-e '/Senderlisten/d' \
		-e 's/service_type/t/g'  > /tmp/zapit/services_new.xml
}

# *-------------------------*
# * myservices.xml ändern *
# *-------------------------*
mod_myservices ()
{
	cat /tmp/zapit/myservices.xml | \
	sed -e 's/vom/mit Inanspruchnahme von Daten dess/g' \
		-e 's/kdgforum/vodafonekabelforum/g' \
		-e 's/KDG/Vodafone-Kabel/g' \
		-e 's/<zapit>/<zapit api=\"4\">/g' \
		-e 's/\" name=\"/\" n=\"/g' \
		-e 's/<cable/<cable position=\"3840\"/g' \
		-e 's/transponder/TS/g' \
		-e 's/modulation/mod/g' \
		-e 's/fec_inner/fec/g' \
		-e 's/symbol_rate/sr/g' \
		-e 's/000\" inversion/\" inv/g' \
		-e 's/onid/on/g' \
		-e 's/frequency/frq/g' \
		-e 's/channel action/S a/g' \
		-e 's/service_id/i/g' \
		-e 's/mod="5">/mod="5" sys="2">/g' \
		-e 's/mod="3">/mod="3" sys="2">/g' \
		-e 's/Kabel Deutschland/Vodafone/g' \
		-e 's/ÃƒÂ¶/Ã¶/g' \
		-e 's/ÃƒÂ¼/Ã¼/g' \
		-e 's/Ãƒ/Ãœ/g' \
		-e 's/service_type/t/g'  > /tmp/zapit/myservices_new.xml
}

# *-----------------------*
# * bouquets.xml aendern *
# *-----------------------*
mod_bouquets ()
{
	cat /tmp/zapit/services.xml \
		/tmp/zapit/myservices.xml | \
	sed -n '/channel/p /<transponder/p' | \
	sed -e 's/^.*service_id=/ service_id/g' \
		-e 's/^.*frequency/<frq/g' \
		-e 's/00000\".*$/\">/g' \
		-e 's/ name.*$/\\/g' \
		-e 's/\//\%/g' | \
	sed -e :a -e '/\\$/N; s/\n//; ta' | \
	sed -e :a -e '/>$/N;  s/\n//; ta' | \
	sed -e 's/</\n/g' > /tmp/zapit/freq.xml

	cat /tmp/zapit/bouquets.xml | \
	sed -e 's/vom/mit Inanspruchnahme von Daten dess/g' \
		-e 's/kdgforum/vodafonekabelforum/g' \
		-e 's/KDG/Vodafone-Kabel/g' \
		-e 's/type.*name/name/g' \
		-e 's/channel serviceID/S i/g' \
		-e 's/\/>/ s=\"3840\"\/>/g' \
		-e 's/\" name=/\" n=/g' \
		-e 's/ tsid=/ t=/g' \
		-e 's/ÃƒÂ¶/Ã¶/g' \
		-e 's/ÃƒÂ¼/Ã¼/g' \
		-e 's/Ãƒ/Ãœ/g' \
		-e 's/ onid=/ on=/g' > /tmp/zapit/bouquets_tmp.xml

	zeilen=`sed -n '$=' /tmp/zapit/bouquets_tmp.xml`

	rm -f /tmp/zapit/bouquets_new.xml
	count=1
	while [ "$count" -le "$zeilen" ]; do
		zeile=`sed -n "$count"p /tmp/zapit/bouquets_tmp.xml`
		sender=`echo $zeile | sed -n -e '/\" n=\"/ ='`
		if [ "$sender" == "" ]; then
			echo $zeile >> /tmp/zapit/bouquets_new.xml
		else
			tv=`echo $zeile | sed -e 's/^.* i=//g' -e 's/ n=.*$//g' -e 's/\//\%/g'`
			frequenz=`grep -e $tv /tmp/zapit/freq.xml | sed -e 's/>.*$//g'`
			zeile=`echo $zeile | sed -e 's/\/>//g'`
			echo $zeile $frequenz"/>" >> /tmp/zapit/bouquets_new.xml
		fi
		count=`expr "$count" + 1`
	done
}

# *-----------------------*
# * bouquets.xml aendern *
# *-----------------------*
load_backup ()
{
	cp -f /var/tuxbox/config/zapit/services.bak   /var/tuxbox/config/zapit/services.xml
	cp -f /var/tuxbox/config/zapit/myservices.bak /var/tuxbox/config/zapit/myservices.xml
	cp -f /var/tuxbox/config/zapit/bouquets.bak   /var/tuxbox/config/zapit/bouquets.xml
	cp -f /var/tuxbox/config/cables.bak   /var/tuxbox/config/cables.xml
	rm -rf /var/tuxbox/config/zapit/services.bak
	rm -rf /var/tuxbox/config/zapit/myservices.bak
	rm -rf /var/tuxbox/config/zapit/bouquets.bak
	rm -rf /var/tuxbox/config/cables.bak
	pzapit -c > /dev/null
	msgbox size=22 title="Kanallisten" msg="~cwurden wieder hergestellt"
	delete_files
	exit
}

load_services ()
{
	cp -f /var/tuxbox/config/zapit/services.xml   /var/tuxbox/config/zapit/services.bak
	cp -f /tmp/zapit/services_new.xml   /var/tuxbox/config/zapit/services.xml
	cp -f /var/tuxbox/config/zapit/myservices.xml /var/tuxbox/config/zapit/myservices.bak
	cp -f /tmp/zapit/myservices_new.xml /var/tuxbox/config/zapit/myservices.xml
	cp -f /var/tuxbox/config/zapit/bouquets.xml   /var/tuxbox/config/zapit/bouquets.bak
	cp -f /tmp/zapit/bouquets_new.xml   /var/tuxbox/config/zapit/bouquets.xml
	cp -f /var/tuxbox/config/cables.xml   /var/tuxbox/config/cables.bak
	cp -f /tmp/zapit/cables_new.xml   /var/tuxbox/config/cables.xml
	pzapit -c > /dev/null
	msgbox size=22 title="Kanallisten" msg="~cwurden neu geladen"
}

	url=""
	while [ "$url" == "" ]; do
		security_check
		delete_files
		while [ ! -s /tmp/bundesland.data ]; do
			bundeslandauswahl
			curl --no-progress-meter -d "ziel=belegung&land=$select&submit=weiter" $url/sendb/belegung.html > /tmp/kabelservice.sel
			netz=`cat /tmp/kabelservice.sel | sed -n -e '/select name=\"netz\"/ ='`
			if [ "$netz" == "" ]; then
				sub=`cat /tmp/kabelservice.sel | sed -n -e '/name=\"netz\"/ ='`
				if [ "$sub" == "" ]; then
					ort=`cat /tmp/kabelservice.sel | sed -n -e '/input type=\"hidden\" name=\"Ort\"/ ='`
					if [ "$ort" == "" ]; then
						msgbox size=22 title="" msg="~cDer Provider ist in ihrem~n~cBundesland nicht vertreten"
						delete_files
						url=""
					else
						Ortinfo=`sed -n "$ort"p /tmp/kabelservice.sel | \
							sed -e 's/^.*value=\"//g' \
								-e 's/\">.*$//g'`
						Ort=`sed -n "$ort"p /tmp/kabelservice.sel | \
						sed -e 's/^.*value=\"//g' \
							-e 's/\">.*$//g' \
							-e 's/ä/\%E4/g' \
							-e 's/ö/\%F6/g' \
							-e 's/ü/\%FC/g' \
							-e 's/Ä/\%C4/g' \
							-e 's/Ö/\%D6/g' \
							-e 's/Ü/\%DC/g' \
							-e 's/ß/\%DF/g' \
							-e 's/ /+/g'`
						msgbox size=22 title="Info" popup="Netz $Ortinfo wird bearbeitet" 
						curl --no-progress-meter -c /tmp/cookies.txt -d "ziel=belegung&land=$select&Ort=$Ort&submit=weiter" $url/sendb/home.html > /tmp/belegung.html
						if [ -s /tmp/cookies.txt ]; then
							subnetz=`cat /tmp/cookies.txt | sed -n "/sendb_netz/"p | sed -e 's/^.*sendb_netz//g'`; subnetz=`echo $subnetz`
						else
							msgbox size=22 title="" msg="~cOrt nicht gefunden~n~c$Ortinfo"
							delete_files
							exit
						fi
					fi
				else
					cat /tmp/kabelservice.sel | sed -n "/name=\"netz\"/p" > /tmp/netz.html
					subnetzauswahl /tmp/netz.html
				fi
			else
				netzauswahl
			fi
		done
	done

	msgbox size=22 title="Kanallisten" popup="~cwerden bearbeitet"
	get_archiv
	mod_cables
	mod_services
	mod_myservices

	msgbox size=22 title="Providerbouquets" msg="Sollen die Bouqets ge~andert werden~ndas dauert ca. 1-2 Minuten" order=2 absolute=1 default=1 select="ja,nein"
	auswahl=$?
	if [ "$auswahl" == "1" ]; then
		mod_bouquets
	fi

	msgbox size=22 title="Kanallisten laden?" msg="" order=2 absolute=1 default=1 select="ja,nein"
	auswahl=$?
	if [ "$auswahl" == "1" ]; then
		load_services
	fi

	delete_files
	msgbox size=22 title="Plugin" msg="~cwurde beendet"
exit 0
