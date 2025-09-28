#!/bin/bash

branch="$1"

if [ -x ${branch} ]
then
	echo "please specify branch!"
	echo "'master' or 'xpra'"
	exit 1
fi

echo ""
echo "-------------------------------------------------------------------------------------------"
echo "Build"
docker build -t feanorknd/emule-docker:${branch} .
echo ""
echo "-------------------------------------------------------------------------------------------"
echo "Push dockerhub"
docker push feanorknd/emule-docker:${branch}
echo ""
echo "-------------------------------------------------------------------------------------------"
echo "Push github"
git add *; git commit -m "Fixed"; git push origin ${branch}
echo ""
echo "-------------------------------------------------------------------------------------------"
echo "Clean"
/usr/bin/docker system prune -f -a --volumes
