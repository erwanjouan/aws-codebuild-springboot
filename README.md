# aws-codebuild-springboot

Sandbox for AWS CodeBuild / CodeDeploy with simplistic Spring Boot application, deployed on EC2 instances in ASG.

````sh
make init
````
- Creates hidden file with timestamp as a base for various aws projects names

````sh
make build
````
Creates CodeBuild project (+ S3 artifact bucket) if it does not exist.
    - Linux host with openjdk-11
    - S3 cached for deps
Triggers build:
- retrieves source code from Github repo
- builds with maven
- pushes zip artifact to S3

````sh
make deploy
````
- Creates a CodeDeploy project (+ ALB/ASG/LC/EC2 deployment and roles) if doesn't exist.
Deploys zip artifact to ASG
- basic policy CodeDeployDefault.OneAtATime

### Git submodule
Builds/Deployments scripts ae located in a separated repository.
```sh
git submodule add git@github.com:erwanjouan/aws-ec2-java.git infrastructure
```