#!/bin/bash
# ------------------------------------------------------------------------------------------------------ 
# onboarding - Maptime onboarding tool
# 
# Bash script to assist in the Maptime onboarding process on Github.
# Before running, user must have a Github personal access token
# saved in an environment variable named GH_TOKEN
# Requires jq for json parsing.  See: http://stedolan.github.io/jq/download/ 

echo -n "Enter the Maptime chapter repo name: "
read chapter

echo -n "Enter the admin username: "
read admin

curl -H "Content-Type: application/json" \
	-u ${GH_TOKEN}:x-oauth-basic https://api.github.com/orgs/maptime/repos \
	-X POST -d "{\"name\":\"$chapter\",\"description\":\"Repo for Maptime $chapter\"}"

tempdir=$(mktemp -dt "starter.XXXXXXXXXX")
git clone git@github.com:maptime/starter.git $tempdir
cd $tempdir
git remote add local git@github.com:maptime/${chapter}.git
git push local gh-pages

id=$(curl -H "Content-Type: application/json" \
	-u ${GH_TOKEN}:x-oauth-basic https://api.github.com/orgs/maptime/teams \
	-d "{\"name\":\"us-${chapter}-admin\",\"permission\":\"admin\",\"repo_names\":[\"maptime/${chapter}\"]}" \
	| jq -r '.id')

curl -u ${GH_TOKEN}:x-oauth-basic -X PUT https://api.github.com/teams/${id}/memberships/${admin}
