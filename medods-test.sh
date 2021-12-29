#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
ENDCOLOR="\033[0m"

file_list="https://raw.githubusercontent.com/GreatMedivack/files/master/list.out"
name="SERVER"
DATE=`date +"%d_%m_%Y"`



# проверяем есть ли параметр
if [ -z $1 ]
 then fname="${name}_${DATE}"
 else fname="${1}_${DATE}"
fi

echo $fname

if [ -e archives/$fname.tar.bz2 ]
 then
   echo -e "${RED}Arhive ${fname}.tar.bz2 already exist ${ENDCOLOR}"
   echo -e "${RED}Exit...${ENDCOLOR}"
   exit
 else
   echo "Download list.out"
fi


mkdir temp
cd temp

wget --quiet $file_list

if [ -e list.out ]
 then
   echo -e "${GREEN}Download done${ENDCOLOR}"
 else
   echo -e "${RED}Error download, exit....${ENDCOLOR}"
   exit
fi
# Формируем файл ${fname}_failed.out
echo "Create file ${fname}_failed.out"
for L in $(cat list.out | grep -P 'Error|CrashLoopBackOff' | awk '{print $1}'); do
      echo "${L%-*-*}" >> "$fname"_failed.out
      let i=i+1;
done
echo "Количество сервисов с ошибками: ${i}" >> "$fname"_failed.out
if [ -e "$fname"_failed.out ]
 then
   echo -e "${GREEN}Created...${ENDCOLOR}"
 else
   echo -e "${RED}Create failed ${fname}_failed.out${ENDCOLOR}"
   exit
fi

# Формируем файл ${fname}_running.out
echo "Create file ${fname}_running.out"
for L in $(cat list.out | grep -P 'Running' | awk '{print $1}'); do
      echo "${L%-*-*}" >> "$fname"_running.out
      let j=j+1;
done
echo "Количество работающих сервисов: ${j}" >> "$fname"_running.out
if [ -e "$fname"_running.out ]
 then
   echo -e "${GREEN}Created...${ENDCOLOR}"
 else
   echo -e "${RED}Create failed ${fname}_running.out${ENDCOLOR}"
   exit
fi

# Формируем файл ${fname}_report.out
echo "Create file ${fname}_report.out"
printf "Количество перезапустившихся сервисов: `cat list.out | awk '{print $4}' | grep [1-9] | wc -l`\n" >> "$fname"_report.out
echo "Имя системного пользователя: $USER">> "$fname"_report.out
echo "Дата: $DATE">> "$fname"_report.out
if [ -e "$fname"_report.out ]
 then
   echo -e "${GREEN}Created...${ENDCOLOR}"
 else
   echo -e "${RED}Create failed ${fname}_report.out${ENDCOLOR}"
   exit
fi

rm list.out

# создаем архив
echo "Create and test arhive"
tar -jcvf $fname.tar.bz2 *
   bunzip2 -c $fname.tar.bz2 | tar t > /dev/null && echo -e "${GREEN}Arhive is GOOD${ENDCOLOR}"
   
echo "Copy arhive file in arhive folder" 

mv ${fname}.tar.bz2 ../archives/
cd ..
rm -rf temp

#cp $fname.tar .
#cd ..
#rm -rf temp



