# Migrating from TravisCI to Github actions

## End state

Master & Dev branches
Snapshot, Release repository uses S3 Wagon
Semantic versioning with suffix of build number, Git SHA
Maven site generated with version numbers
Github pages published with version numbers

There may be ways to shift some of the Maven functionality into Github Actions specific tasks instead of having them in the build

Consider changes for pull requests vs. commits to dev, master branches

[github: npiper/npiper-parent-org](https://github.com/npiper/npiper-parent-org)


## AWS Access keys and variables

Need to change from encrypting keys in .travis.yml file to using AWS roles.

Region: `eu-west-2` (Dublin, Ireland)

Permissions:
S3 Read/Write/Get/Put



### Create the AWS Role from CLI

AccountID: 329799773336

**Role to be created**
```
arn:aws:iam::329799773336:role/npiper-githubactions-role
```

 * [AWS Create a stack using the AWS CLI](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-cli-creating-stack.html)
 * [AWS API Reference - CloudFormation : CreateStack reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html)


```
Parameters:  
  GitHubOrg = npiper
  RepositoryName = npiper-parent-org


aws cloudformation create-stack --stack-name teststack --template-body file://$(pwd)/role-cloudformation.yaml --parameters ParameterKey=GitHubOrg,ParameterValue=npiper ParameterKey=RepositoryName,ParameterValue=npiper-parent-org --capabilities CAPABILITY_NAMED_IAM
```

![PlantUML AWS Overview diagram](http://www.plantuml.com/plantuml/svg/VLFFJYCz3B_dAKnE_QIPpeUuSLZHxHwM0wAYI9pJnBHPCaaK9qLbjU--pao1qK8vJMp__ZXsvegoIhdq3dwYSm4UGd96Y3E3ZzOZB1xMgrhSvHpfikkIUfvlRTwLJI5CElYCFizrw3lrJ4vjg7vRomLg7qDgerE-gdVxyulv_vsnbCMPzTeLyoRUyNSP-ZxuUUJmO_rx8UkHQ16Zirfb6ppxE7S2liuXgIrsQzj7XyTeZMblDPwYe2x9viErGP_vo-smbV8Qttr4GfsLtpe4cJ062R_5PnOp6iC52r03aeBReuhbvSLXEn1hygBT5Fs4kGOtQeyUxhX4bha7-Pzu3CvWgaOE5Q5yIp1Y6daLQHUo57-4U6r-eJKItIZFJVISkWiEPpxQYAaU6pcUst6FIW_pR1ENP2Ch0dA0L3oC03WYO5EiCzpRAHyUvlf-FHjPz-49VICf4ujo6eO476VqXSezzZ4abGwlErac7A3ApJBNQjZ8qQJDLPGDAWc6eFQkIjvLXbPvl4jmNpckCFMMgDvnDYwbPgZvkBas1cVrWGrNmm7uYSD80JMeiitf-HWJ_2nOevV1UzIvaRVNFvQh5FRMO6BLuGRpuxm__y-gmQH9QDjlC7rmS5aVr-KMy-tcL_K0Zc8vHbAyluE1Ef5YvauTspNZ_Vv5JrPRVSP6OK5KUgmWAQQ8odZT6CF79Rrl4yvtIGeXhj2Rqhk_)



## Plugins and dependencies

```
maven-enforcer-plugin
maven-scm-plugin
maven-deploy-plugin
com.github.github:site-maven-plugin
maven-project-info-reports-plugin
maven-s3-wagon
wagon-webdav-jackrabbit
```

env.TRAVIS - need a build variable for profile (Github actions env variable)

### Github Step for AWS Authentication

[github actions:  aws-actions/configure-aws-credential](https://github.com/marketplace/actions/configure-aws-credentials-action-for-github-actions)

Role: `arn:aws:iam::329799773336:role/npiper-githubactions-role`

```
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        role-to-assume: arn:aws:iam::329799773336:role/npiper-githubactions-role
        aws-region: eu-west-2
```


### S3 Bucket

[s3://solveapuzzle-repo/release](https://s3-ap-southeast-2.amazonaws.com/solveapuzzle-repo/release)

```
        <!-- My AWS Public repo -->
        <repository>
                 <id>solveapuzzle-repo</id>
                 <url>https://s3-ap-southeast-2.amazonaws.com/solveapuzzle-repo/release/</url>
         </repository>
```

### CI Configuration

```
https://github.com/npiper/npiper-parent-org/actions
```

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

```
https://${githubOrg}.github.io/${project.name}/
```


### Step 1

```
mvn clean install  -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short HEAD)
```

### Step 2

Site generate, publish, deploy

```
mvn site deploy scm:tag -Drevision=${TRAVIS_BUILD_NUMBER}.$(git rev-parse --short
  HEAD) -Dusername=${GIT_USER_NAME} -Dpassword=${GITPW}
```
  
## References 

[maven-s3-wagon](https://github.com/seahen/maven-s3-wagon)

[AWS cloudformation - attach a managed policy](https://aws.amazon.com/premiumsupport/knowledge-center/cloudformation-attach-managed-policy/)

[github actions - configure aws credentials](https://github.com/aws-actions/configure-aws-credentials)

[github actions - git semantic version action](https://github.com/marketplace/actions/git-version)

[github actions - OpenID connect guide](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims)

[AWS S3 example bucket policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-use-case-4)

[AWS IAM - Create role for OpenID connect](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)

[StackOverflow - getting the branch, Short SHA in github action](https://stackoverflow.com/questions/58886293/getting-current-branch-and-commit-hash-in-github-action)