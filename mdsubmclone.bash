#!/usr/bin/env bash
# branch not supported yet. because idk pattern
usage() {
	cat <<EOM
$(co 34 "Usage: mdsubmclone.bash"|tr -d '\n')
	-h					Display help		
	-f	string	Specific file		( Default: ".gitmodules" )
	-q					Quiet
EOM

	exit 2
}
co() {
    printf "\e["$argv[1]"m""$argv[2]"'\n'
}
clone() {
	git clone --depth=1 --single-branch --recursive --shallow-submodules $uri $path 2>>.log
	co 33 "cloned:[$?]: $uri -> $path" |tee .log
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
	co 31 'File Not Found'
	exit 1
fi

co 34 "$(grep -E '\[*\]' ${file:-.gitmodules} 2>/dev/null|grep -vE '^\;\#'| wc -l) / $(grep -E '\[*\]' ${file:-.gitmodules} 2>/dev/null| wc -l) submodules"

for subm in $(cat ${file:-.gitmodules}|grep -vE '^\;\#'|grep -E '\[submodule ".*"\]'|awk '{print $2}'|tr -d \"\]|tr '\n' ' ')
do
	export baseline=$(grep -nE "submodule \"$subm\"" ${file:-.gitmodules} | sed -e 's/:.*//g')
	export path=$(sed -n $(($baseline + 1))p ${file:-.gitmodules} | sed -E 's/.*path.= //g')
	export uri=$(sed -n $(($baseline + 2))p ${file:-.gitmodules} | sed -E 's/.*url.= //g')
	clone &
done

while sleep 1
do
	if ! ps|grep git 1>/dev/null ; then
	break
	fi
done
