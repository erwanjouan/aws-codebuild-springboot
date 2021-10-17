# aws-codebuild-springboot

Sandbox for AWS CodeBuild / CodeDeploy with simplistic Spring Boot application.



````sh
make init
````
creates :
- CodeBuild project (+ S3 artifact bucket)
    - Linux host with openjdk-11
    - S3 cached for deps
- CodeDeploy project (+ ALB/ASG/LC/EC2 deployment and roles)

````sh
make build
````
Triggers build:
- retrieves source code from Github repo
- builds with maven
- pushes zip artifact to S3

````sh
make deploy
````
Deploys zip artifact to ASG
- basic policy CodeDeployDefault.OneAtATime
