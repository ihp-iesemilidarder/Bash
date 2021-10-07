#!/bin/bash
function printError(){
	echo -e "\033[0;31m[!]\033[0m $1."
	exit
}

function printHeader(){
	echo -e "\033[0;32m|||------------------$1------------------|||\033[0m"
	echo -ne "\t\033[0;35m[>]\033[0m 1º operator: "
	read operator1
	echo -ne "\t\033[0;35m[>]\033[0m 2º operator: "
	read operator2

	if [[ $( echo $operator1 | grep -E -o '^-?[0-9]+([.][0-9]+)?$') = "" ]];then
		printError "The operator1 is not valid"
	elif [[ $(echo $operator2 | grep -E -o '^-?[0-9]+([.][0-9]+)?$') = "" ]];then
		printError "The operator2 is not valid"
	fi

}

function sum(){
	printHeader $1
	echo -e "\033[0;32m[*]\033[0m Result: "$(bc <<< "scale=2; $operator1 + $operator2")
}

function substraction(){
	printHeader $1
	echo -e "\033[0;32m[*]\033[0m Result: "$(bc <<< "scale=2; $operator1 - $operator2")
}

function multiply(){
	printHeader $1
	echo -e "\033[0;32m[*]\033[0m Result: "$(bc <<< "scale=2; $operator1 * $operator2")
}

function divide(){
	printHeader $1
	echo -e "\033[0;32m[*]\033[0m Result: "$(bc <<< "scale=2; $operator1 / $operator2")
}

while (true)
do
	echo "=========================================="
	echo "==              CALCULADORA             =="
	echo "=========================================="
	echo "==  1  |   Sumar                        =="
	echo "==--------------------------------------=="
	echo "==  2  |   Restar                       =="
	echo "==--------------------------------------=="
	echo "==  3  |   Multiplicar                  =="
	echo "==--------------------------------------=="
	echo "==  4  |   Dividir                      =="
	echo "=========================================="
	echo ""
	echo -ne "\033[0;34m[?]\033[0m Choose the option: "
	read selector
	case $selector in
		1)
			sum "sum"
		;;
		2)
			substraction "substraction"
		;;
		3)
			multiply "multiply"
		;;
		4)
			divide "divide"
		;;
		*)
			printError "This option doesn't valid"
		;;
	esac
done
