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


#Testa os parametros de entrada para o Script

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

IFS=$'\n'


echo -n "Criando lista de arquivos para serem copiados..."
listaArquivos=($(find "$1"))

numeroDeArquivos="${#listaArquivos[@]}"

echo -e "$LIMPAR_LINHA""Foram encontrados $numeroDeArquivos arquivos e pastas."

echo "Iniciando cópia..."

read



sucesso=0
erros=0


for index in ${!listaArquivos[*]}
do

	arquivo=${listaArquivos["$index"]}

	if [ -d "$arquivo" ];
	then
		mkdir -p "$2"/"$arquivo"
	else

		novoArquivo="$(echo "$2"/"$arquivo" | sed 's/\/\+/\//g')"

		restantes=$(($numeroDeArquivos - ($sucesso + $erros)))
		echo -en " [$VERDE$sucesso$PADRAO|$VERMELHO$erros$PADRAO|$restantes] Copiando arquivo $novoArquivo"

		dd if="$arquivo" of="$novoArquivo" bs=4096 > /dev/null 2>&1 &

		ddpid=$!

		wait $ddpid


		statusdd=$?

		if [ "$statusdd" != "0" ];
		then

			echo -e "$LIMPAR_LINHA$VERMELHO    ERRO:$PADRAO $arquivo."
			echo "$arquivo" >> $LOG_ERROS

			((erros++))

		else
			echo -e "$LIMPAR_LINHA$VERDE Sucesso:$PADRAO $arquivo"

			((sucesso++))
		fi
	fi	
done

IFS="$backupIFS"
