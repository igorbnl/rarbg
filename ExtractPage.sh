#!/bin/bash

DATA=$(date "+%H:%M | %d %B %Y")
NUM=1
total=2
PATCH="/home/igor/Documentos/rarbg"
CheckMainFile=$PATCH/mainPage$NUM.html
CheckSecondFile=$PATCH/secondPage.html
PATCHDown=$PATCH/ToDownload.txt
PATCHToScene=$PATCH/TotalScenesPage.txt
LinkMainPage="https://rarbgprx.org/torrents.php?category=2%3B14%3B15%3B16%3B17%3B21%3B22%3B42%3B18%3B19%3B41%3B27%3B28%3B29%3B30%3B31%3B32%3B40%3B23%3B24%3B25%3B26%3B33%3B34%3B43%3B44%3B45%3B46%3B47%3B48%3B49%3B50%3B51%3B52&page="

for NUM in $(seq $total );do

    cd $PATCH/

    if [ -e $CheckMainFile ]
    then
        rm $PATCH/mainPage$NUM.html
    fi

    if [ -e $PATCHDown ]
    then
        rm $PATCH/ToDownload.txt
    fi

    if [ -e $PATCHToScene ]
    then
        rm $PATCH/TotalScenesPage.txt
    fi

    aria2c --load-cookies $PATCH/cookies.txt "$LinkMainPage$NUM" --http-no-cache -o mainPage$NUM.html -d $PATCH/
echo "arquivo baixdo"

 #check download status
    if [ -e $CheckFile ]
    then
        echo "Main page successfully downloaded. Go check thread defense"
    else
        echo "Download Failed. STOPPING"
        exit 1
    fi

    #get size of File
    size=$(wc -c mainPage$NUM.html | awk '{print $1}')

    #check thread defense
    if [ $size -gt 30000 ]
      then
        echo "No thread defense. Download pages started"
        CHKFDOWN=$PATCH/ToDownload.txt
        
        scenes=$(cat mainPage$NUM.html | grep -Eo torrent/[az-AZ]*.[^'#||"']* | uniq | sed '1,8d' | sed 's/torrent//g' >> TotalScenesPage.txt)
        for i in $(seq 25);do
            nome=$(cat TotalScenesPage.txt | head -$i | tail -1)

           if grep -q $nome DoneScenesPage.txt; 
              then
                echo "$nome found not write" 
            else
                echo "not found. go write $nome"
                echo $nome >> ToDownload.txt
            fi
        done
    else
         echo "thread defense. STOPPING"
         exit 1
    fi
    
    if [ -e $CHKFDOWN ]
    then
    qntDown=$(wc -l ToDownload.txt | awk '{print $1}')
        for i in $(seq $qntDown );do
            DownloadFiles=$(cat ToDownload.txt | head -$i | tail -1)
            NameScene=$(cat ToDownload.txt | head -$i | tail -1 | sed 's/https:\/\/rarbgprx.org\/torrent\///g')
            aria2c --load-cookies $PATCH/cookies.txt https://rarbgprx.org/torrent$DownloadFiles --http-no-cache -o $NameScene -d $PATCH/ToExtract
            echo $NameScene >> DoneScenesPage.txt
         done
        echo $DATA >> controle.txt
    else
        echo "Não possui novos arquivos para baixar. STOPPING"
        echo $PATCH/ToExtract
        echo $DATA >> controle.txt
        exit 
    fi

     QNTCENAS=$(ls ToExtract | wc -l)
    #check ToExtract
    if [ $QNTCENAS -ge 1 ]
      then
        echo "Go extract files"
        cd $PATCH/
        PATCHToExtrac=$PATCH/ToExtract/
        PATCHDone=$PATCH/done/
        rm sceneToExtract.txt
        ls ToExtract >> sceneToExtract.txt

    for i in $(seq $QNTCENAS); do

        CENAS=$(cat sceneToExtract.txt | head -$i | tail -1)

        Nome=$(cat $PATCHToExtrac$CENAS | grep -Eo 'black">'.[^'</']* | sed 's/black\">//g' | sed 's/,//g')

        Magnet=$(cat $PATCHToExtrac$CENAS | grep -o 'magnet:.*' | awk '{ print $1 }' | sed 's/\"><img//g')

        #Poster=$(cat $PATCHToExtrac$CENAS | grep -Eo '<td class=\"lista\"><img src="https:\/\/dyncdn[^'\"']*')

        Imagem=$(cat $PATCHToExtrac$CENAS | grep -Eo 'id=\"description\"><a.*' | awk '{ print $2 }' | sed 's/href=\"''//g' | sed 's/\"//g')
        
        Imagem2=$(cat $PATCHToExtrac$CENAS | grep -Eo 'imagecurl.com.*' | awk '{ print $1 }' | sed 's/\"//g' | sed ':a;$!N;s/\n/;/;ta;')
        
        Tamanho=$(cat $PATCHToExtrac$CENAS | grep -Eo 'Size:</td><td class="lista" >.*' |  sed 's/Size:<\/td><td class=\"lista\" >//g' | sed 's/<\/td><\/tr>//g')
        
        DataHora=$(cat $PATCHToExtrac$CENAS | grep -Eo "<td class=\"lista\">201[0-9].[^'<']*" | sed 's/<td class=\"lista\">//g')

        echo -e "$CENAS\t $DataHora\t $Tamanho\t $Nome\t $Magnet\t $Imagem\t $Imagem2\t" >> movies.xls
        
        mv $PATCHToExtrac$CENAS $PATCHDone
        
        #echo $i - $CENAS;
    done
        else
                echo "No have file to extract. STOP"
                exit 1
        fi

done

   