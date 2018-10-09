# neilpiper.me Parent Organisation POM file

## What this is?

Source code for the parent pom settings for the Organisation 'neilpiper.me'.

The pom is minimal with the intent of setting up the basic rules and properties for the neilpiper.me
organisation.  This allows other inheriting POM's to inherit those values.

Specific child POM's can then be created based on need such as Plain Java, Spring,  Activiti, Mulesoft, Node.js etc;


# How to use the Parent POM?

## Pre-Requisites

 * AWS Storage Repo S3 for Repository
 * github account - OAuth token
 * travis-ci account

## New Git project

### Create a new Git project

```
mvn archetype
..
git init
git add . && git commit -am "initial commit"
git remote add origin https://github.com/npiper/[PROJECT_NAME].git
git push origin
```

### Copy a sample travis-ci file and .gitignore

```
wget https://raw.githubusercontent.com/npiper/npiper-parent-pom/master/.gitignore .
wget https://raw.githubusercontent.com/npiper/npiper-parent-pom/master/deploy.sh .
wget https://raw.githubusercontent.com/npiper/npiper-parent-pom/master/.travis.sample .travis.yml
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
		<url>https://github.com/npiper/hello-world</url>
		<developerConnection>scm:git:https://github.com/npiper/[repo-name].git</developerConnection>
	</scm>
```

### Choose the Parent

Release versions can be browsed using the 'tags' [https://github.com/npiper/npiper-parent-pom/tags](https://github.com/npiper/npiper-parent-pom/tags)

The parent versions can be browsed at: https://s3-ap-southeast-2.amazonaws.com/solveapuzzle-repo

Release Naming Convention:  *MAJOR.MINOR.PATCH* _BUILD.COMMIT*

```
  <parent>
    <groupId>neilpiper.me</groupId>
    <artifactId>parent.org</artifactId>
    <version>0.0.1_51.b4a6634</version>
  </parent>
```

### Set the project name

A lot of the project inherits location and github projects

```
  <name>hello-world</name>
  <description>Hello world test of parent</description>
  ```

## Conventions to follow?

Repository is in Github team.

project.name = GIT repository name

Use git issue tracking (default)

When using `site` put published version into github pages as path `${project.name}`


## Overiding key behaviours?

# Baseline

The initial version is based on developing maven built, Java applications in the following minimum standards.


  * Maven version > 3.2.1

# Validation

 * Maven at required versions (Enforcer)

# License

[MIT License](https://opensource.org/licenses/mit-license.php)

# Release Baselining (Maven snapshots, releases)

Release versions are baselined into an S3 Bucket owned by
solveapuzzledev.  The extension [maven-s3-wagon](https://github.com/jcaddel/maven-s3-wagon) is used to communicate to S3.  

The build server will need authentication/authorisation to the S3 bucket to deploy releases but read-only access is public.

## Release process

Use semantic versioning in your POM file to consider a release candidate of the change you are intending to make, and the CI server to guide the succesful build candidate to take forward.

Why: You know the change you are after,.. it might take a few builds and tests to get it so the code traceability is always built in.

```
mvn deploy scm:tag -Drevision=${GIT-SHORT-TAG}
```
