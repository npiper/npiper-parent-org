#/bin/sh

dirName=$(realpath --relative-to=.. $(pwd))


## Curl on path?
if ! command -v curl &> /dev/null
then
    echo "curl could not be found, please install curl"
    exit 1;
fi

## Git on path?
if ! command -v git &> /dev/null
then
    echo "git could not be found, please install git"
    exit 1;
fi


## Is our Github Auth token set?
if [[ -z $GIT_PW ]]; then
   echo "Need to provide a Github Password token to Authenticate in environment variable GIT_PW"
   exit 1;
fi


# Check if our github project is set up
# Assumes a public repo here
# Possibly better to Authenticate at this point too using the proper Rest Query API?
#response=$(curl --write-out %{http_code} --silent --output /dev/null https://github.com/npiper/${dirName})

echo "Dirname: ${dirName} , GitPW : ${GIT_PW}"

response=$(curl --write-out %{http_code} --silent --output /dev/null  -H "Accept: application/vnd.github+json" -H "Authorization: token $GIT_PW" https://api.github.com/repos/npiper/${dirName}adfsasf)

# Check status code
if [[ "$response" -ne 200 ]] ; then
  printf "A ${dirName} repository has not been created yet in Github - to do this see this info page - https://docs.github.com/en/rest/repos/repos#create-a-repository-for-the-authenticated-user"
  exit 1;
fi


# Check environment variables
if [[ -z $AWS_ACCESS_KEY_ID || -z $GITPW || -z $AWS_SECRET_KEY ]]; then	
  printf "Environment variables AWS_ACCESS_KEY_ID, AWS_SECRET_KEY and GITPW need to be set";
  exit 1;	
fi

printf "All env variables have values"

# Initialise repository
git init
echo "# ${dirName} repostiory" > README.md
git add README.md && git commit -am "initial commit"

# Rename master to main
git branch -m master main

git remote add origin https://github.com/npiper/${dirName}.git
git push -u origin main
git push --set-upstream origin main


# Encrypt Github variables into Repository keys


# Create 'develop' branch & push to repo
git branch develop
git checkout develop
git add .
git commit -m "adding a change from the develop branch"
git checkout main
git push origin develop

# create gh-pages branch
git checkout --orphan gh-pages
git rm -rf .
echo "# broken-repo Github pages branch" >> README.md
git add README.md
git commit -m 'initial gh-pages commit'
git push origin gh-pages
git checkout develop
