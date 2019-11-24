# neilpiper.me Parent Organisation POM file

## What this is?

Source code for the parent pom settings for the Organisation 'neilpiper.me'.

The pom is minimal with the intent of setting up the basic rules and properties for the neilpiper.me
organisation.  This allows other inheriting POM's to inherit those values.

Specific child POM's can then be created based on need such as Plain Java, Spring,  Activiti, Mulesoft, Node.js etc;

```
groupId: neilpiper.me
artifactId: parent.org

Current Major Version: 0
Suggested Maven Import Range:  (,1.0]  x <= 1.0

```

# How to use the Parent POM?

## Pre-Requisites

 * AWS Storage Repo S3 for Repository
 * github account - OAuth token
 * travis-ci account
 * docker hub account

## Creating a New Git project

Use the shell script `gitsetup.sh` to create a project and appropriate branches for typical development.

```
- develop : development branch - trunk based development
- gh-pages : Github pages - a maven  and reports site will be deployed using a plugin
- master : semantic versioning and deployments run through this branch
```


### Encrypt keys into .travis.yml

The following encrypted variables are used on a succesful build and `mvn deploy` to the Release repository.

 * Authenticate to S3 Release repo and push deploy image to Repo
 * Git Tag and push to master


```
travis encrypt AWS_ACCESS_KEY_ID=[Your_AWS_Access_Key] --add
travis encrypt AWS_SECRET_KEY=[Your_AWS_Secret_Key] --add
travis encrypt GIT_USER_NAME=npiper --add
travis encrypt GITPW=[Your GIT OAuth] --add
travis encrypt DOCKER_USERNAME=[Your Dockerhub user] --add
travis encrypt DOCKER_PASSWORD=[Your Dockerhub password] --add
```

### Add Repository , overwrite SCM URL in pom.xml

```
  	<!-- REPOSITORIES & PLUGIN REPOSITORIES - chicken/egg for travis-ci -->
	<repositories>
		<!-- public release repo -->
		<repository>
			<id>solveapuzzle-repo</id>
			<url>https://s3-ap-southeast-2.amazonaws.com/solveapuzzle-repo/release/</url>
		</repository>
	</repositories>

	<!-- Workaround to an inconsistency in Maven that child projects scm tag, appends parent's pom name -->
	<scm>
		<url>https://github.com/${githubOrg}/[repo-name]</url>
		<developerConnection>scm:git:https://github.com/${githubOrg}/[repo-name].git</developerConnection>
	</scm>
```

# Using the Parent POM


### Choose the righ Parent Version

Release versions can be browsed using the 'tags' [https://github.com/npiper/npiper-parent-pom/tags](https://github.com/npiper/npiper-parent-pom/tags)

The parent versions can be browsed at: https://s3-ap-southeast-2.amazonaws.com/solveapuzzle-repo

Release Naming Convention:  *MAJOR.MINOR.PATCH* _BUILD.COMMIT*

Release management should only be done off the master branch.

```
  <parent>
    <groupId>neilpiper.me</groupId>
    <artifactId>parent.org</artifactId>
    <version>(,1.0]</version>
  </parent>
```

### Set the project name

A lot of the project inherits location and github projects

```
  <name>hello-world</name>
```

There is a default `<description>` that puts in Project metadata in the site report and best to leave as is so you get this information.
  
### Set / Override the Github Organisation

The default Github Organisation for this POM is `npiper`.

It is possible to overwrite the Organisation by setting this property in the Child POM.

```
<githubOrg>solveapuzzle-dev</githubOrg>
```

## Parent POM - Release process

Tagging, Site documentation generation and deployment to the S3 Maven repository MUST only ever be done from the build server.

Build metadata:
* Travis CI build number
* Git commit ID - short Ref

Project tags and the site documentation 'About' page give traceability of which CI tag and build the semantic version was built against.

```
[Semantic Version]_[BuildNumber].[gitCommitId]
```

Use semantic versioning in your POM file to consider a release candidate of the change you are intending to make, and the CI server to guide the succesful build candidate to take forward.

Why: You know the change you are after,.. it might take a few builds and tests to get it so the code traceability is always built in.

The `.travis.yml` build file should be structured to only permit these actions to happen on the build server.

A maven `<profile>` is used so it is not possible to do this locally (unless you need to debug.)

```
mvn site deploy scm:tag -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short HEAD) -Dusername=${GIT_USER_NAME} -Dpassword=${GITPW}
```

#### Debugging locally

When refactoring or when you need to test, - try to this as a rolling patch or minor revision that you throw away.

e.g.

```
0.1 Current--> 0.2 Test, throwaway --> 0.3  Next
```

Set up environment variables so you can behave like a build server:

```
export AWS_ACCESS_KEY_ID=[Your_AWS_Access_Key]
export AWS_SECRET_KEY=[Your_AWS_Secret_Key]
export GIT_USER_NAME=npiper 
export GITPW=[Your GIT OAuth] 
export DOCKER_USERNAME=[Your Dockerhub user] 
export DOCKER_PASSWORD=[Your Dockerhub password] 
export TRAVIS_BUILD_NUMBER=01TEST
export TRAVIS=true
```

Run the maven command from `.travis.yml` to test a build and deploy process:
```
mvn site deploy scm:tag -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short HEAD) -Dusername=${GIT_USER_NAME} -Dpassword=${GITPW}
```

## Conventions to follow?

Repository is in Github team.

project.name = GIT repository name

Use git issue tracking (default)

When using `site` put published version into github pages as path `${project.name}`


## Overiding key behaviours?

# Baseline

The initial version is based on developing maven built, Java applications in the following minimum standards.

Properties in the project can be used, to see them use the command `mvn help:effective-pom`

  * Maven version > 3.5+

# Validation

 * Maven at required versions (Enforcer)
 * JDK 1.8

# License

[MIT License](https://opensource.org/licenses/mit-license.php)

# Release Baselining (Maven snapshots, releases)

## Travis CI Lifecycle

https://docs.travis-ci.com/user/deployment
https://docs.travis-ci.com/user/customizing-the-build/#the-build-lifecycle

```
before_install
// set up Git and maven settings
git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
cp .travis.settings.xml $HOME/.m2/settings.xml

install
mvn clean install -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short HEAD)

after_success
- echo Versions, etc;

deploy (only on master)
  on:
    branch: master
    
scm:tag -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse -
-short HEAD)

after deploy (only on master)
 on:
   branch: master
   mvn site

release notes - git tag comparison?

```


Release versions are baselined into an S3 Bucket owned by
solveapuzzledev.  The extension [maven-s3-wagon](https://github.com/jcaddel/maven-s3-wagon) is used to communicate to S3.  

The build server will need authentication/authorisation to the S3 bucket to deploy releases but read-only access is public.



# Suggestions

 * Can the s3 repositories go in a settings.xml for Travis-ci?
 https://blog.travis-ci.com/2017-03-30-deploy-maven-travis-ci-packagecloud/
