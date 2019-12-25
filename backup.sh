#!/bin/bash
clear

echo [`date +'%d.%m.%Y %H:%M'`] Iniciando Backup ...
	 echo "+-------------------------------------------------+OK"

echo [`date +'%d.%m.%Y %H:%M'`] Exportar configuração atual [1/4] ...
rm /var/lib/pmg/backup/*
pmgbackup backup
	 echo "+-------------------------------------------------+OK"

# Diretórios para fazer backup, /etc /root /var
source='/etc /Scripts /lib/systemd/system /root /usr/local /var/dcc /var/lib/pmg/ /var/log /opt'

# Diretório de backup, /Backup
#backup=/Backup/"`hostname`"
backup=/Backup
mkdir -p $backup

# Definição de Variavel
datum=$(date +'%Y%m%d')
dateiname=$backup/"`hostname -a`"-backup$datum.tar

# -----------------------------------------------------
function f_delFiles()
# -----------------------------------------------------
# $1 Diretório de backup
{
  loeschdatum=$(date --date='7 days ago' +'%Y%m%d')
  rm $1/"`hostname -a`"-backup$loeschdatum.tar
}

echo [`date +'%d.%m.%Y %H:%M'`] Exclundo arquivos em $backup, com mais de 7 dias [2/4] ...
f_delFiles $backup
	 echo "+-------------------------------------------------+OK"

echo [`date +'%d.%m.%Y %H:%M'`] Salve $source em $dateiname [3/4] ...
tar Pcf $dateiname $source
	 echo "+-------------------------------------------------+OK"

echo [`date +'%d.%m.%Y %H:%M'`] Sincronizar com armazenamento online [4/4] ...
bash /Scripts/upload.sh
	 echo "+-------------------------------------------------+OK"

echo [`date +'%d.%m.%Y %H:%M'`] Pronto!
	 echo "+-------------------------------------------------+OK"

