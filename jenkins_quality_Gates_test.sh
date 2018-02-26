
#!/bin/bash
#Script esta sendo modificado....................

admin_pwd=admin
sonar_url="http://192.168.35.134:9000"

url=$(cat $WORKSPACE/.scannerwork/report-task.txt | grep ceTaskUrl | cut -c11- )
echo "URL=${url}"
curl -u admin:${admin_pwd} -L $url | python -m json.tool

curl -u admin:${admin_pwd} -L $url -o task.json
echo "cat task.json"
cat task.json
#status=$(python -m json.tool < task.json | grep -i "status" | cut -c20- | sed 's/.(.)$/\1/'| sed 's/.$//' )
status=`python -m json.tool < task.json | grep -oP '(?<="status": ")[^"]*'`
echo "Status Analise: ${status}"

if [ ${status} = SUCCESS ]; then
  #analysisID=$(python -m json.tool < task.json | grep -i "analysisId" | cut -c24- | sed 's/.(.)$/\1/'| sed 's/.$//')
analysisID=`python -m json.tool < task.json | grep -oP '(?<="analysisId": ")[^"]*'`
analysisUrl="${sonar_url}/api/qualitygates/project_status?analysisId=${analysisID}"

echo ${analysisID}

echo ${analysisUrl}

else

echo "Sonnar run was not sucess"

exit 1

fi

curl -u admin:$admin_pwd ${analysisUrl} | python -m json.tool

curl -u admin:$admin_pwd ${analysisUrl} | python -m json.tool | grep -i "status" | cut -c28- | sed 's/.$//' >> tmp.txt
cat tmp.txt

sed -n '/ERROR/p' tmp.txt >> error.txt

cat error.txt

if [ $(cat error.txt | wc -l) -eq 0 ]; then

echo "Quality Gate Passed ! Setting up SonarQube Job Status to Success ! "

else

exit 1

echo "Quality Gate Failed ! Setting up SonarQube Job Status to Failure ! "

fi

unset url

unset status

unset analysisID

unset analysisUrl
