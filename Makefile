PROJECT_NAME := spring-boot-$(shell date '+%s')
CODE_BUILD_CACHE_BUCKET := 1632566015-code-build-cache

init:
	echo $(PROJECT_NAME) > .projectname && \
	cd infrastructure && \
	aws cloudformation deploy \
		--capabilities CAPABILITY_IAM \
		--template-file code-build.yml \
		--stack-name $(PROJECT_NAME)-build \
		--parameter-overrides \
			ProjectName=$(PROJECT_NAME) \
			ArtifactBucketName=$(PROJECT_NAME) \
			CacheBucket=$(CODE_BUILD_CACHE_BUCKET) && \
	aws cloudformation deploy \
		--capabilities CAPABILITY_IAM \
		--template-file code-deploy.yml \
		--stack-name $(PROJECT_NAME)-deploy \
        --parameter-overrides \
        	ProjectName=$(PROJECT_NAME)

build:
	aws codebuild start-build --project-name $(shell cat .projectname)

deploy:
	aws deploy create-deployment \
		--deployment-group-name $(shell cat .projectname) \
		--application-name $(shell cat .projectname) \
		--s3-location bucket=$(shell cat .projectname),key=$(shell cat .projectname)/build-output.zip,bundleType=zip \
		--deployment-config-name CodeDeployDefault.OneAtATime

destroy:
	aws s3 rm s3://$(shell cat .projectname) --recursive && \
	cd infrastructure && \
	aws cloudformation delete-stack --stack-name $(shell cat .projectname)-build && \
	aws cloudformation delete-stack --stack-name $(shell cat .projectname)-deploy && \
	cd .. && rm .projectname
