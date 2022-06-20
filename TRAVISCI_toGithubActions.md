# Migrating from TravisCI to Github actions

## AWS Access keys and variables

Need to change from encrypting keys in .travis.yml file to using AWS roles.

Region: `eu-west-2` (Dublin, Ireland)

Permissions:
S3 Read/Write/Get/Put

https://github.com/seahen/maven-s3-wagon

https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html

https://www.ibm.com/docs/vi/atcm/1.3.1?topic=cir-creating-iam-role-s3-access-in-same-aws-account

https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-attach-managed-policy/

https://github.com/aws-actions/configure-aws-credentials

https://github.com/marketplace/actions/git-version

https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims

https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-use-case-4

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html

https://stackoverflow.com/questions/58886293/getting-current-branch-and-commit-hash-in-github-action


### Create the AWS Role from CLI

AccountID: 329799773336

https://github.com/npiper/npiper-parent-org

**Role to be created**
```
arn:aws:iam::329799773336:role/npiper-githubactions-role
```

[AWS Create a stack using the AWS CLI](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-cli-creating-stack.html)

```
Parameters:  
  GitHubOrg = npiper
  RepositoryName = npiper-parent-org


aws cloudformation create-stack --stack-name teststack --template-body file://$(pwd)/role-cloudformation.yaml --parameters ParameterKey=GitHubOrg,ParameterValue=npiper ParameterKey=RepositoryName,ParameterValue=npiper-parent-org --capabilities CAPABILITY_NAMED_IAM
```



## Plugins and dependencies

maven-enforcer-plugin
maven-scm-plugin
maven-deploy-plugin
com.github.github:site-maven-plugin
maven-project-info-reports-plugin
maven-s3-wagon
wagon-webdav-jackrabbit

env.TRAVIS - need a build variable for profile

### Github Step for AWS Authentication

https://github.com/marketplace/actions/configure-aws-credentials-action-for-github-actions


### S3 Bucket

https://s3-ap-southeast-2.amazonaws.com/solveapuzzle-repo/release

s3://solveapuzzle-repo/release

```
        <!-- My AWS Public repo -->
        <repository>
                 <id>solveapuzzle-repo</id>
                 <url>https://s3-ap-southeast-2.amazonaws.com/solveapuzzle-repo/release/</url>
         </repository>
```

### CI Configuration

```
	<ciManagement>
		<system>Travis-CI</system>
		<url>https://travis-ci.org/${githubOrg}/${project.name}</url>
	</ciManagement>
```

### SCM Configuration

```
	<scm>
		<url>https://github.com/${githubOrg}/${project.name}</url>
		<connection>scm:git:git://github.com/${githubOrg}/${project.name}.git</connection>
		<!-- <developerConnection>scm:git:git@github.com:npiper/${project.name}.git</developerConnection> -->

		<developerConnection>scm:git:https://github.com/${githubOrg}/${project.name}.git</developerConnection>
		<tag>HEAD</tag>
	</scm>

```


### Site plugins

https://${githubOrg}.github.io/${project.name}/

### Step 1

```
mvn clean install  -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short HEAD)
```

### Step 2

Site generate, publish, deploy

mvn site deploy scm:tag -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short
  HEAD) -Dusername=${GIT_USER_NAME} -Dpassword=${GITPW}

  