PROJECT_NAME := spring-boot-$(shell date '+%s')
CODE_BUILD_CACHE_BUCKET := 1632566015-code-build-cache

init:
	@echo $(PROJECT_NAME) > .projectname && \
	cd infrastructure && \
	(aws cloudformation deploy \
		--capabilities CAPABILITY_IAM \
		--template-file code-build.yml \
		--stack-name $(PROJECT_NAME)-build \
		--parameter-overrides \
			ProjectName=$(PROJECT_NAME) \
			ArtifactBucketName=$(PROJECT_NAME) \
			CacheBucket=$(CODE_BUILD_CACHE_BUCKET) > /dev/null & ) && \
	./dump_events.sh $(PROJECT_NAME)-build

build:
	@PROJECT_NAME=$(shell cat .projectname) && \
	BUILD_ID=$$(aws codebuild start-build --project-name $${PROJECT_NAME} --query "build.id" --output text) && \
	SPLIT_BUILD_ID=($${BUILD_ID//:/ }) && \
	aws logs tail /aws/codebuild/$${PROJECT_NAME} --follow --log-stream-name-prefix "$${SPLIT_BUILD_ID[1]}"

deploy:
	@PROJECT_NAME=$(shell cat .projectname) && \
	(aws cloudformation deploy \
		--capabilities CAPABILITY_IAM \
		--template-file infrastructure/code-deploy.yml \
		--stack-name $(shell cat .projectname)-deploy \
		--parameter-overrides \
        		ProjectName=$${PROJECT_NAME} > /dev/null & ) && \
	./infrastructure/dump_events.sh $${PROJECT_NAME}-deploy && \
	aws deploy create-deployment \
		--deployment-group-name $${PROJECT_NAME} \
		--application-name $${PROJECT_NAME} \
		--s3-location bucket=$${PROJECT_NAME},key=$${PROJECT_NAME}/build-output.zip,bundleType=zip \
		--deployment-config-name CodeDeployDefault.OneAtATime && \
	ALB_DNS=$$(aws cloudformation describe-stacks --stack-name $${PROJECT_NAME}-deploy --query "Stacks[0].Outputs[0].OutputValue" --output text) && \
	echo ALB_DNS = $${ALB_DNS}

destroy:
	@PROJECT_NAME=$(shell cat .projectname) && \
	@aws s3 rm s3://$${PROJECT_NAME} --recursive && \
	cd infrastructure && \
	aws cloudformation delete-stack --stack-name $${PROJECT_NAME}-build && \
	aws cloudformation delete-stack --stack-name $${PROJECT_NAME}-deploy && \
	cd .. && rm .projectname
