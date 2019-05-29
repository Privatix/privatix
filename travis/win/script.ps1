cd $HOME\build\Privatix\privatix\build\win\
mkdir $HOME\art
wget http://artdev.privatix.net/artefacts_win.zip -OutFile $HOME\artefacts_win.zip
Expand-Archive -Path $HOME\artefacts_win.zip -DestinationPath $HOME\art
.\publish-dapp.ps1 -staticArtefactsDir $HOME\art -product vpn -gitpull -prodConfig -Verbose