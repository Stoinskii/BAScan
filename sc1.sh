#!/bin/bash
source ./scan.lib

while getopts "m:i" OPTION; do
 case $OPTION in
  m)
	MODE=$OPTARG
	;;
  i)
	INTERACTIVE=true
	;;
 esac
done

scan_domain(){
	DOMAIN=$1
	DIRECTORY=${DOMAIN}_recon
	echo "Creating $DIRECTORY directory"
	mkdir $DIRECTORY
	case $MODE in
	  nmap-only)
		nmap_scan
		;;
	  dirsearch-only)
		dirsearch_scan
		;;
	  crt-only)
		crt_scan
		;;
	  *)
		nmap_scan
		dirsearch_scan
		crt_scan
		;;
	esac
}

report_domain(){
 DOMAIN=$1
 DIRECTORY=${DOMAIN}_recon
 echo "Generating recon report for $DOMAIN"
 TODAY=$(date)
if [ -f $DIRECTORY/nmap ];then
 echo "Nmap results: " >> $DIRECTORY/report
  grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
fi 
if [ -f $DIRECTORY/dirsearch ];then
 echo"Dirsearch results: " >> $DIRECTORY/report
  cat $DIRECTORY/dirsearch >> $DIRECTORY/report
fi 
if [ -f $DIRECTORY/crt ];then
 echo"Crt.sh results: " >> $DIRECTORY/report
  jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report
fi
}
if [ $INTERACTIVE ];then
 INPUT="BLANK"
 while [ $INPUT != "quit" ];do
	echo "Input domain: "
	read INPUT
	if [ $INPUT != "quit" ];then
	 scan_domain $INPUT
	 report_domain $INPUT
	fi
 done
else
  for i in "${@:$OPTIND:$#}";do
	scan_domain $i
	report_domain $i
  done
fi
