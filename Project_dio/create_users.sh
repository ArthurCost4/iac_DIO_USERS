#!/bin/bash

echo 'Criando grupos e seus respectivos diretorios'
declare -a GROUP_ARRAY

while true; do 
	echo 'Qual sera o nome do grupo? (digite "0" para sair ou caso os grupos ja estão criados'
	read -r name
	
	if [ "$name" = 0 ]; then
			break
		else

			GROUP_ARRAY+=("${name}")

			echo 'Por conveniencia todos os diretorios de seus respectivos grupos ficaram na /home/... agora por favor, qual sera o nome?'
			read -r diretorio

			mkdir /home/${diretorio}
			groupadd ${name}
			chown root:${name} /home/${diretorio}
			chmod g+rwx /home/${diretorio}
			echo "grupo ${name} criado com sucesso!!!"
	fi
done


############################################################################
# O seguinte codigo verifica a existencia de grupos criados anteriormente caso futuramente fosse adcionar mais usuarios
current_groups=()

all_grups=$(cut -d: -f1 /etc/group)

# Loop através de todos os grupos
for group in $all_grups; do
    # Obtém o ID do grupo
    group_id=$(grep "^$group:" /etc/group | cut -d: -f3)

    # Verifica se o ID do grupo é maior ou igual a 1000 (comumente usado para grupos de usuários)
    if [ "$group_id" -ge 1000 ]; then
        current_groups+=("$group")
    fi
done

#echo "${current_groups[@]}"

#############################################################################
echo 'Adcionando usuarios'

while true; do
	echo 'Qual o nome do usuario? (digite "0" para sair ou se ja acabou)'
	read -r name

	if [ "$name" = 0 ]; then
			break			
		else
			echo 'Qual a descrição para esse usuario?'
			read -r description

			if [ ${#GROUP_ARRAY[@]} -eq 0 ]; then

				    	echo "Vi que não foi criado grupos, no caso ele pertence a algum desses? caso sim por favor digite o nome ou digite '0' para sair"

					for indx in "${!current_groups[@]}"; do
					    echo "Índice: $indx, Nome grupo: ${current_groups[$indx]}"
					done

					echo 'escolha o indice do grupo desejado:'
					read -r chose
					useradd "$name" -c "$description" -s /bin/bash -p $(openssl passwd -1 Senha123)
					passwd "$name" -e
					usermod -G "${current_groups[chose]}" "$name"
					echo "usuario ${name} criado com sucesso e adcionado ao grupo ${current_groups[chose]}!!!"

				else
    					echo "Qual grupo ele pertence?"
					for indx in "${!GROUP_ARRAY[@]}"; do
						echo "indice: $indx, Nome grupo: ${GROUP_ARRAY[$indx]}"
					done
					echo 'Escolha:'
					read -r chose
					useradd "$name" -c "$description" -s /bin/bash -p $(openssl passwd -1 Senha123)
					passwd "$name" -e
                                        usermod -G "${GROUP_ARRAY[chose]}" "$name"
					echo "usuario ${name} criado com sucesso e adcionado ao grupo ${GROUP_ARRAY[chose]}!!!"

			fi

	fi

done

# Verifica se a pasta publica ja foi criada e se caso não, ja o cria e seta as permissoes desejadas
caminho="/home/publica"

if [ -d "$caminho" ]; then
    echo "A pasta existe."
else
    mkdir /home/publica
    chmod 777 /home/publica
fi
