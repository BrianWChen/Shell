#!/bin/bash

USAGE="$0 [-x d] [-n] [-b pat] [-e pat] [-p pat] [file ...]"

xtabs=0 nfmt= bpat= epat= ppat=
for p
do
case $sk in
1) shift; sk=0; continue
esac
case $p in
-x)	shift;
	case $1 in
	[1-9]|1[0-9]) xtabs=$1; sk=1;;
	*) { >&2 echo "$0: bad value for option -x: $1"; exit 1; }
	esac
	;;
-n)	nfmt="${NFMT:-<%03d>\	}"; shift ;;
-b)	shift; bpat=$1; sk=1 ;;
-e)	shift; epat=$1; sk=1 ;;
-p)	shift; ppat=$1; sk=1 ;;
--)	shift; break ;;
*)	break
esac
done

awk '
#. prepare for tab-expansion, page-breaks and selection
BEGIN {
	if (xt = '$xtabs') while (length(sp) < xt) sp = sp " ";
	PBRK = "'"${PBRK-'.DE\n.DS\n'}"'"
	'${bpat:+' skip = 1; '}'
}
#! limit selection range
{
	'${epat:+' if (!skip && $0 ~ /'"$epat"'/) skip = 1; '}'
	'${bpat:+' if (skip && $0 ~ /'"$bpat"'/) skip = 0; '}'
	if (skip) next;
}
#! process one line of input as required
{
	if ( xt && $0 ~ "\t" )
		gsub(/\t/, sp)
	if ($0 ~ "\\") 
		gsub(/\\/, "\\e")
}
#! finally print this line
{
	'${ppat:+' if ($0 ~ /'"$ppat"'/) printf("%s", PBRK); '}'
	'${nfmt:+' printf("'"$nfmt"'", NR) '}'
	printf("\\&%s\n", $0);
}
' $*

