deploy:
	@cd environments/stable && terragrunt run-all apply --terragrunt-non-interactive