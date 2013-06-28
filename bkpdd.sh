#!/bin/bash


###############################################################################
#  Backupeador utilizando dd                                                  #
#                                                                             #
#  Copia diretórios utilizando o comando dd.                                  #
#                                                                             #
#  Utiliza o dd pois o cp tenta corrigir o arquivo caso exista erro de I/O.   #
#                                                                             #
#  Autor: Gabriel Henrique Martinez Saraiva                                   #
#  Email: extremez3r0@gmail.com                                               #
#                                                                             #
###############################################################################


LOG_ERROS=".LOG_ERROS"

LIMPAR_LINHA="\r\033[K"
VERMELHO="\033[1;31m"
VERDE="\033[1;32m"
PADRAO="\033[0m"

if [ -z "$1" ] || [ -z "$2" ];
then
	echo "ERRO! Uso: $(basename $0) ARQUIVO_ORIGEM ARQUIVO_DESTINO"
	exit 1
fi


if [ ! -e "$1" ];
then
	echo "ERRO! $1 não existe ou não pode ser acessado."
	exit 2
fi

if [ ! -e "$2" ];
then
	echo "AVISO: $2 não existe."
	echo "Tentando criar a pasta."
	mkdir -p "$2"
	wait $!

	if [ "$?" != "0" ];
	then
		echo "ERRO. Não foi possivel criar a pasta $2 ."
		exit 3
	else
		echo "Pasta $2 criada com sucesso."
	fi

	
fi
	
# Troca o Separador de Campo interno do shell por outro que não comprometa a leitura
backupIFS="$IFS"

IFS=$(echo -en "\n\b") 


for arquivo in $(find "$1" )
do
	if [ -d "$arquivo" ];
	then
		mkdir -p "$2"/"$arquivo"
	else

		novoArquivo="$(echo "$2"/"$arquivo" | sed 's/\/\+/\//g')"

		echo -en "Iniciando cópia do arquivo $novoArquivo"

		dd if="$arquivo" of="$novoArquivo" bs=4096 > /dev/null 2>&1 &

		ddpid=$!

		wait $ddpid


		statusdd=$?

		if [ "$statusdd" != "0" ];
		then

			echo -e "$LIMPAR_LINHA$VERMELHO ---> ERRO:$PADRAO O arquivo $arquivo não pode ser lido corretamente e não foi copiado."
			echo "Erro: O arquivo $arquivo não pode ser lido corretamente e não foi copiado." >> $LOG_ERROS

		else
			echo -e "$LIMPAR_LINHA$VERDE ---> Sucesso:$PADRAO $arquivo"
		fi
	fi	
done

IFS="$backupIFS"
