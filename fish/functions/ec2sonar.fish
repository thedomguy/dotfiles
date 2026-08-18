function ec2sonar --wraps='ssh -i ~/ssh/aca-whitelabel/sonar-ec2.pem ubuntu@ec2-47-129-204-101.ap-southeast-1.compute.amazonaws.com' --wraps='ssh -i ~/.ssh/aca-whitelabel/sonar-ec2.pem ubuntu@ec2-47-129-204-101.ap-southeast-1.compute.amazonaws.com' --description 'alias ec2sonar=ssh -i ~/.ssh/aca-whitelabel/sonar-ec2.pem ubuntu@ec2-47-129-204-101.ap-southeast-1.compute.amazonaws.com'
  ssh -i ~/.ssh/aca-whitelabel/sonar-ec2.pem ubuntu@ec2-47-129-204-101.ap-southeast-1.compute.amazonaws.com $argv
        
end
