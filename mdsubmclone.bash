#!/usr/bin/env bash
usage() {
	cat <<EOM
Usage: mdsubmclone.bash
	-h					Display help		
	-f	string	Specific file		( Default: ".gitmodules" )
	-q					Quiet
EOM

	exit 2
}
clone() {
	git clone --depth=1 --single-branch --recursive --shallow-submodules $url $path 2>>.log
	echo "clone:[$?]: $url -> $path" >.log
}
while getopts ":f:h" optKey; do
	case "$optKey" in
		f)
			export file=${OPTARG}
			;;
		'-h'|'--help'|*)
			usage
			;;
	esac
done

if [ ! -f ${file:-.gitmodules} ]; then
	echo 'File Not Found'
	exit 1
fi

echo "$(grep -E '\[*\]' ${file:-.gitmodules} 2>/dev/null| wc -l) submodules"

for subm in $(cat ${file:-.gitmodules}|grep -E '\[submodule ".*"\]'|awk '{print $2}'|tr -d \"\]|tr '\n' ' ')
do
	export baseline=$(grep -nE "submodule \"$subm\"" ${file:-.gitmodules} | sed -e 's/:.*//g')
	export path=$(sed -n $(($baseline + 1))p ${file:-.gitmodules} | sed -E 's/.*path.= //g')
	export url=$(sed -n $(($baseline + 2))p ${file:-.gitmodules} | sed -E 's/.*url.= //g')
	clone &
done

while sleep 1
do
	if ! ps|grep git 1>/dev/null ; then
	break
	fi
done
