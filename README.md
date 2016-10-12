# STAG Watchdog
Také vás štve, když se vám "pod rukama" mění rozvrh ve STAGu a vy pak přijdete úplně jinam a vypadáte jako idioti? Již nezoufejte, existuje řešení (tedy, pouze na ty špatné příchody)! Tento malý skritpík při spuštění zkontroluje aktuální rozvrh, který je ve STAGu a porovná ho s poslední známou verzí. Pokud se verze liší, vypíše barevně zvýrazněné změny.

Použití skriptu lze automatizovat a např. si pomocí Cronu nechat zaslat email, vždy když ke změnám dojde. V takovém případě přijde vhod volba **-q**, která omezí výstup pouze na změny a případné chyby.

## Použití

        stagWatchdog [-q] [-h hostname] -s semestr(ZS|LS) -o osobniCislo

        Povinne parametry:
                -s      Zkratka semestru, ke kteremu se ma kontrolovat rozvrh. Pripustne
                        hodnoty jsou bud 'ZS' nebo 'LS' (bez apostrofu)
                -o      Osobni cislo studenta, tak jak je ulozeno v systemu STAG.

        Nepovinne parametry:
                -h      Hostname na kterem je pristupne REST API systemu STAG. Pokud neni
                        vyplneno, pouzije se wstag.jcu.cz
                -q      Tichy rezim. Vystup se generuje pouze pri vyskutu zmeny, nebo
                        pokud nastane chyba. Tato volba je vhodna napr. pro automatizovane
                        zasilani mailu pomoci CRONu.
                        
## Licence
MIT
