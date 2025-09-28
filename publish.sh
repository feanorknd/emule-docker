#!/bin/bash

branch="$1"
clean="$2"

if [ -x ${branch} ]
then
	echo "please specify branch!"
	echo "'master' or 'xpra'"
	exit 1
fi

if [ "$branch" == "master" ]
then
	tag="latest"
else
	tag="${branch}"
fi

if [ -x ${clean} ]
then
	cleaning=false
else
	cleaning=true
fi

echo ""
echo "-------------------------------------------------------------------------------------------"
echo "Build"
docker build -t feanorknd/emule-docker:${tag} .
echo ""
echo "-------------------------------------------------------------------------------------------"
echo "Push dockerhub"
docker push feanorknd/emule-docker:${tag}
echo ""
echo "-------------------------------------------------------------------------------------------"
echo "Push github"
git add *; git commit -m "Fixed"; git push origin ${branch}
echo ""
echo "-------------------------------------------------------------------------------------------"
echo "Clean"
if ${cleaning}
then
	/usr/bin/docker system prune -f -a --volumes
fi
