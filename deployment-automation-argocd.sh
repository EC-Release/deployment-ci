#!/bin/sh

apk update && apk add curl && apk add jq && apk add openssl

if [ -f .env ]
then
  export $(grep -v '^#' .env | xargs)
fi

# Check if the repo exists
checkRepoExistsCmd="curl -s -o /dev/null -w \"%{http_code}\" --request GET $githubAPIUrl/repos/$org/$repoName --header 'Authorization: token $token'"

echo "checkRepoExistsCmd: $checkRepoExistsCmd"
checkRepoExists=`eval $checkRepoExistsCmd`

echo "checkRepoExists: $checkRepoExists"

if [[ "$checkRepoExists" != "200" ]]; then
  ## Repo does not exists and create new one
  
  # Create the Repo
  createRepoCmd="curl -s -o /dev/null -w \"%{http_code}\" --request POST '$githubAPIUrl/orgs/$org/repos' --header 'Accept: application/vnd.github.v3+json' --header 'Authorization: token $token' --header 'Content-Type: application/json' --data-raw '{ \"name\":\"$repoName\", \"private\": false, \"auto_init\": true, \"description\": \"This is a test repository for github api testing and R&D\"}'"

  echo "createRepoCmd: $createRepoCmd"

  createrepo=`eval $createRepoCmd`

  echo "createrepo: $createrepo"
  
fi


# Getting the sha for latest commit
latestCommitCmd="curl --request GET '$githubAPIUrl/repos/$org/$repoName/git/refs/heads/main' --header 'Accept: application/vnd.github.v3+json' --header 'Authorization: token $token'"

echo "latestCommitCmd: $latestCommitCmd"

latestCommit=`eval $latestCommitCmd`

echo "latestCommit: $latestCommit"

latestCommitSHA=$(echo $latestCommit | jq -r '.object|"\(.sha)"')

echo "latestCommitSHA: $latestCommitSHA"


# Create new branch
createBranchCmd="curl -s -o /dev/null -w \"%{http_code}\" --request POST '$githubAPIUrl/repos/$org/$repoName/git/refs' --header 'Accept: application/vnd.github.v3+json' --header 'Authorization: token $token' --header 'Content-Type: application/json' --data-raw '{ \"ref\": \"refs/heads/$branchName\", \"sha\": \"$latestCommitSHA\" }'"

echo "createBranchCmd: $createBranchCmd"

createBranch=`eval $createBranchCmd`

echo "createBranch: $createBranch"

if [[ "$createBranch" != "201" ]]; then
  echo "Branch creation failed.. Exiting.."
  exit 1
fi

# Create files start

# Create files end

# Checking in files
curl -i -X PUT -H "Authorization: token $token" -d "{\"path\": \"temp.txt\", \
\"message\": \"update\", \"content\": \"$(openssl base64 -A -in ./temp.txt)\", \"branch\": \"$branchName\",\
\"sha\": $(curl -X GET $githubAPIUrl/repos/$org/$repoName/contents/temp.txt | jq .sha)}" \
$githubAPIUrl/repos/$org/$repoName/contents/temp.txt

