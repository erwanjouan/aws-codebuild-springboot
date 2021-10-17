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
			CacheBucket=$(CODE_BUILD_CACHE_BUCKET)

build:
	aws codebuild start-build --project-name $(shell cat .projectname)

deploy:
	aws cloudformation deploy \
		--capabilities CAPABILITY_IAM \
		--template-file infrastructure/code-deploy.yml \
		--stack-name $(shell cat .projectname)-deploy \
		--parameter-overrides \
        		ProjectName=$(shell cat .projectname) && \
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
