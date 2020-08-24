#!/usr/bin/env bash
usage() {
  cat <<EOM
Usage: mdsubmclone.bash
  -h          Display help		
  -f string   Specific file		( Default: ".gitmodules" )
	-q 					Quiet
EOM

  exit 2
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
	exit 1
fi

echo "$(grep -E '\[*\]' ${file:-.gitmodules} 2>/dev/null| wc -l) submodules"
