deploy:
	@git config --global url."https://oauth2:$${GITHUB_TOKEN}@github.com".insteadOf "https://github.com"
	@cd environments/stable && terragrunt run-all apply --terragrunt-non-interactive