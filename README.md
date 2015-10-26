# example multi-tier AWS environment
- converted everything to a terraform managed environment
- "www" contains the terraform environment
- "www/scripts" contains provisioning scripts
- "www/scripts/templates" contains provisioning templates
- "www2" contains a copy / DR environment pointed at backup region variables (see README.md in that directory)

# dependencies
- locally installed awscli-bundle, terraform, git, AWS IAM account, access key / secret key
- create a terraform.tfvars with:
access_key = "YOUR AWS ACCESSKEY"
secret_key = "YOUR AWS SECRETKEY"
db_password = "YOUR DB PASSWORD"
- change permissions on this and ensure it is in your '.gitignore' file (see .gitignore)
chmod 600 terraform.tfvars
- update bootstrap files to reference appropriate username and key
grep kpedersen www*/scripts/*bootstrap.sh
grep kpedersen www*/scripts/templates/*bootstrap.sh
- update variables.tf to point to your IAM keypair and local keyfile
grep kpedersen www*/variables.tf

# todo
- create instance monitoring and alarm configuration
- bootstrap with chef and create a recipe repository
