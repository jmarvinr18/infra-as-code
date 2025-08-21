build: 
  echo Building…

test: 
  echo Testing…

lint: 
  echo Linting…

commit: 
  git add -A
  git commit -m "update file"
  git remote -v
  git remote set-url origin git@bitbucket.org:xctuality/infra-as-code.git
  git push origin main
  git remote -v
  git remote set-url origin git@github.com:jmarvinr18/infra-as-code.git
  git push origin main
  git remote -v
  
git-personal: 
  eval $(ssh-agent)
  ssh-add ~/.ssh/personal-git

git-xctuality: 
  eval $(ssh-agent)
  ssh-add ~/.ssh/xctuality-git-key

aws-configure: 
  export AWS_PROFILE=xctuality

tf-init: 
  terraform init

tf-apply: 
  terraform apply --auto-approve=true

tf-destroy: 
  terraform destroy --auto-approve=true

path: 
  pwd
