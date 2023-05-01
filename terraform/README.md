Install Terraform!

apt-get install wget curl unzip software-properties-common gnupg2 -y

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -

apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

apt-get update -y

apt-get install terraform -y

terraform -v
