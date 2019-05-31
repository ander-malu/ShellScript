#!/bin/bash
# Versão 1.0
# Script para configuração automática do agente zabbix em servidores monitorados pelo DC Matrix.
# Foram realizados testes em servidores Debian 9 e CentOS 7 (SELinux desativado). 
#
# IPs dos servidores proxy.
# PRX-PS-01 = 192.168.4.61
# PRX-PS-02 = 200.202.17.8 = 
# PRX-PS-03 = 192.168.4.63 - 172.16.254.47
# PRX-PS-04 = 192.168.4.64 - 200.201.216.11
#
# Em servidores com internet, basta rodar o comando abaixo para realizar o download do script.
# wget --no-check-certificate https://clouddrive.matrix.net.br/zabbix-agent.bash

echo ""

echo "Endereços dos servidores proxy: "
echo "1) PRX-PS-01"
echo "2) PRX-PS-02"
echo "3) PRX-PS-03"
echo "4) PRX-PS-04"
echo ""


echo "Digite a opção relativa ao Proxy que irá monitorar esse servidor:"
read alt

case $alt in

	[1]*)
		proxy=192.168.4.61
		echo "Você escolheu o PROXY-01 ($proxy)"
	;;

	[2]*)
		proxy=200.202.17.8
		echo "Você escolheu o PROXY-02 ($proxy)"
	;;
	
	[3]*)
		proxy=172.16.254.47
		echo "Você escolheu o PROXY-03 ($proxy)"
	;;
	
	[4]*)
		proxy=200.201.216.11
		echo "Você escolheu o PROXY-04 ($proxy)"
	;;
	
	*)
		echo "Você não escolheu nenhuma das opções acima."
		exit 1
	;;
	
esac

echo ""


os=$(cat /etc/*-release | grep PRETTY | awk '{print $1}' | cut -d '"' -f 2)
os=$(echo $os | tr [A-Z] [a-z])


if [ $os = debian ] || [ $os = ubuntu ]
	then
		echo "Sua distro é Debian ou Ubuntu. Deseja prosseguir?"
		read resp
		
		if [ $resp == sim ] || [ $resp == yes ]
		then

			echo "Caso necessário, você pode baixar e ativar o repositório do zabbix maunalmente.
		
			Debian 9
			# wget http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix-release/zabbix-release_3.4-1+stretch_all.deb
			# dpkg -i zabbix-release_3.4-1+stretch_all.deb

		
			Debian 8
			# wget http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix-release/zabbix-release_3.4-1+jessie_all.deb
			# dpkg -i zabbix-release_3.4-1+jessie_all.deb
		
			Ubuntu 16.04
			# wget http://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.4-1+xenial_all.deb
			# dpkg -i zabbix-release_3.4-1+xenial_all.deb
		
			Ubuntu 18.04
			# wget http://repo.zabbix.com/zabbix/3.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.4-1%2Bbionic_all.deb
			# dpkg -i zabbix-release_3.4-1+trusty_all.deb
			"
		
			echo "Instalando agente"
			apt-get install zabbix-agent -y > /dev/null
			echo ""
		
			echo "Criando arquivo de backup"
			cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf_bkp
			echo ""
		
			echo "Alterando o arquivo de configuração"
			sed -i "s/127.0.0.1/$proxy/g" /etc/zabbix/zabbix_agentd.conf
			sed -i "s/Zabbix server/$HOSTNAME/g" /etc/zabbix/zabbix_agentd.conf
			sed -i "s/10050/10051/g" /etc/zabbix/zabbix_agentd.conf
			sed -i '/10051/s/^#//' /etc/zabbix/zabbix_agentd.conf
			echo ""
		
			echo "Restartando o agente"
			service zabbix-agent restart > /dev/null
			echo ""
			echo ""
			
			service zabbix-agent status
			
			else 
				echo "Saindo..."
				exit 1
		fi
		
	elif [ $os = centos ]
	then
		echo "Sua distro é CentOS. Deseja continuar?"
			read resp
		
		if [ $resp == sim ] || [ $resp == yes ]
			then
			echo "Caso necessário, você pode baixar e ativar o repositório do zabbix maunalmente.
		
			CentOS/RHEL 7:
			rpm -Uvh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm

			CentOS/RHEL 6:
			rpm -Uvh http://repo.zabbix.com/zabbix/3.4/rhel/6/x86_64/zabbix-release-3.4-1.el6.noarch.rpm
			"
			
			echo "Instalando agente"
			yum install zabbix-agent -y >/dev/null
			echo ""
		
			echo "Criando arquivo de backup"
			cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf_bkp
			echo ""
		
		
			echo "Alterando o arquivo de configuração"
			sed -i "s/127.0.0.1/$proxy/g" /etc/zabbix/zabbix_agentd.conf
			sed -i "s/Zabbix server/$HOSTNAME/g" /etc/zabbix/zabbix_agentd.conf
			sed -i "s/10050/10051/g" /etc/zabbix/zabbix_agentd.conf
			sed -i '/10051/s/^#//' /etc/zabbix/zabbix_agentd.conf
			echo ""
		
		
			echo "Restartando o agente"
			systemctl restart zabbix-agent > /dev/null
			echo ""
			echo ""
			systemctl status zabbix-agent

		else 
			echo "Saindo..."
			exit 1
		fi
			
		else 
			echo "Sua distro $os não é conhecida por mim."
			echo "Saindo..."

fi