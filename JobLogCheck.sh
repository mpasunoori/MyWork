#!/bin/sh
####################################################
<<<<<<< HEAD
#	Usage: checklog <wf_logname>		   #
=======
#	Usage: JobLogCheck <wf_logname>		   #
#
>>>>>>> dd4611475d1037ae40a4bbb2a8cf8b1999b5bcfe
####################################################

function checkWF()
{
### Renaming the wrong name
namelog=$1
#case  $namelog  in
#    invoice_fact_xclick)
#	namelog="xclick_invoice_fact";;
#   T_CUST_ACCT_CLCTN)
#       namelog="T_CLCTN";;
#    wf_rpymnt_fact_us)
#	namelog="wf_rpymnt_fact";;
#        *);;
esac

### Variables
path="/informatica/paypal/scripts/etl/etl_operations/CheckLog/";
FOLDERS="/informatica/paypal/scripts/etl/etl_operations/CheckLog/folders.txt";
WFERRORS="Execution failed|Could not|aborted";
SSERRORS="Session task|Command task|release|EEvent|aborted";
SESSIONLOGERROR="ORA|err|input";
#SESSIONLOGERROR="ORA-|Input/Output|overflow/conversion error|fatal signal|too wide|Error occurred loading library|Could not acquire";

### No case sensitive
shopt -s nocaseglob

### Search for error in the list of folders
FILE=$FOLDERS;

while read -a folder
do

    RESULT=$(echo $folder/*$namelog*bin|xargs ls -ltr 2> /dev/null|awk '{print $9}'|tail -1) 2> /dev/null;

if [ "$RESULT" ];then

    TIMESTAMP=`ls -ltr $RESULT|awk '{print $6,$7,$8}'`;
    ERROR=`strings $RESULT|egrep -i "${WFERRORS}"|egrep "${SSERRORS}"`;
    SESSIONPATH=`echo $folder |sed 's/WorkflowLogs/SessLogs/g'|sed 's/wf_.*//g'`;
    SESSIONLOG=`echo $SESSIONPATH/*$1*bin|xargs ls -ltr 2> /dev/null|awk '{print $9}'|tail -1` 2> /dev/null;
    SESSIONTIMESTAMP=`ls -ltr $SESSIONLOG|awk '{print $6,$7,$8}'`;
    SESSIONERROR=`strings $SESSIONLOG|egrep -i "${SESSIONLOGERROR}"`;
    EXTRASESSIONNAME=`echo $ERROR|sed 's/.*\[//g'|sed 's/\].*//g'`;
    EXTRASESSIONLOG=`echo $SESSIONPATH/*$EXTRASESSIONNAME*bin|xargs ls -ltr 2> /dev/null|awk '{print $9}'|tail -1` 2> /dev/null;
    EXTRASESSIONTIMESTAMP=`ls -ltr $EXTRASESSIONLOG|awk '{print $6,$7,$8}'`;
    EXTRASESSIONERROR=`strings $EXTRASESSIONLOG|egrep -i "${SESSIONLOGERROR}"`;
    echo "************************** Workflow Info ***********************************";
	strings $RESULT|head
    echo " ";
    echo "************************** Timestamp ***************************************";

    if [ "$TIMESTAMP" ];then
	echo "Workflow Log time : $TIMESTAMP";
    else
	echo "Workflow Log time : -";	
    fi

    if [ "$SESSIONLOG" ];then
	echo "Session Log time : $SESSIONTIMESTAMP";
    elif [ "$EXTRASESSIONLOG" ];then
	echo "Session Log time : $EXTRASESSIONTIMESTAMP";
    else
	echo "Session Log time : -";
    fi

    echo "************************** Path ********************************************";
    echo " ";
    
    ls -ltr $RESULT|awk '{print $9}';
    if [ "$SESSIONLOG" ];then
	ls -ltr $SESSIONLOG|awk '{print $9}';
    elif [ "$EXTRASESSIONLOG" ];then
	ls -ltr $EXTRASESSIONLOG|awk '{print $9}';
    else
	echo "-";
    fi
    
    if [ "$ERROR" ];then
	echo " ";
    	echo "************************** WorkflowLog Error *******************************";
    	echo "$ERROR";
    	echo " ";
    	echo "************************** SessionLog Error ********************************";
	if [ "$SESSIONERROR" ];then
		echo "$SESSIONERROR"|more;
	else
		echo "$EXTRASESSIONERROR"|more;
	fi
		
	echo "****************************************************************************";
	echo "Output generated: `date`";
	exit 0;
    else
        echo " ";
        echo "************************** Error not found *********************************";
        echo "Output generated: `date`";
	exit 0;
    fi
    echo " ";
    exit 0;
else
    echo > /dev/null 2>&1;
fi

done <$FILE

    echo "Nothing was found";

}

if [ -z $1 ];then
  echo "Please input workflow name";
  echo "USAGE: CheckLog <Workflow name>";
else
  logname=$(echo $1|sed 's/wf_//g'|sed 's/_dpkg//g'|sed 's/_stg//g');
  echo "Workflow Log Name: $logname";
  checkWF $logname
fi
