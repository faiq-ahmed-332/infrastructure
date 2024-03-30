# SharedAffairs infrastructure terraform to create
- VPC
- Route 53 Zone
- public (for ELB) and appdata ( instances and RDS) subnets
- cloudtrail logs direct 

# prereqsuites
- terraform 12.29 installed
- aws cli
- git bash


# client set up (terraform exe, aws cli and git bash)
 - 1 installing terraform
    navigate to https://releases.hashicorp.com/terraform/ and pull zip for the client platform (linux windwos) 
    unzip and move the terraform binary executable to the system path of a machine (eg) (eg copy terraform.exe to c:\windows\system32 for windows)
 -  2 download the aws cli for the client platform and install in a similar way
     https://aws.amazon.com/cli/
 -  3 install git bash (for windows https://gitforwindows.org/) or linux yum install git or sudo apt-get git
# IAM setup for dev account with codecommit
 *  Create a policy with the name DEV_Bootstrap_role_policy using the JSON below (replace source_account with account number of Dev Account. Then create an IAM Role DEV_bootstrap and attach this policy. 
---
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codecommit:BatchGet*",
                "codecommit:Get*",
                "codecommit:List*",
                "codecommit:Create*",
                "codecommit:DeleteBranch",
                "codecommit:Describe*",
                "codecommit:Put*",
                "codecommit:Post*",
                "codecommit:Merge*",
                "codecommit:Test*",
                "codecommit:Update*",
                "codecommit:GitPull",
                "codecommit:GitPush",
                "codebuild:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::[source_account]:role/DEV_bootstrap"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:List*",
                "kms:Get*",
                "kms:Describe*",
                "kms:CreateGrant",
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateData*",
                "kms:ReEncrypt*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": [
                        "ec2.eu-west-2.amazonaws.com",
                        "s3.eu-west-2.amazonaws.com",
                        "rds.eu-west-2.amazonaws.com",
                        "dms.eu-west-2.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstances"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "ec2:Region": "eu-west-2"
                }
            }
        },
        {
            "Effect": "Deny",
            "Action": [
                "CodeCommit:DeleteRepository"
            ],
            "Resource": "*"
        }
    ]
    }

- in IAM Create a policy STS_assume_DEV_bootstrap_policy to be able to switch to the role in the same AWS account  
---
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::[source_account]:role/DEV_bootstrap"
        },
        {
            "Effect": "Allow",
            "Action": "iam:*",
            "Resource": "arn:aws:iam::[source_account]:role/*"
        }
    ]
    }
---
- Create an IAM Group DEV_bootstrap_group for assuming DEV_bootstrap role and attach: 
   DEV_bootstrap_role_policy 
   STS_assume_DEV_bootstrap_policy
- assign user with DEV_bootstrap_group (so he gets the role)
# access keys on aws cli and git config to be able to access CLI
- set default keys on aws cli using aws configure 
   for profile sts assume for DEV_bootstrap read (ignore 2fa settings )
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html
- and details for setting up credentials manager for code
https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-windows.html

# Test  aws CLI and automatic assume  pulling down from git
- in AWS console - switch role DEV_bootstrap and navigate to codecommit
- create a repostitory eg bootstrap_guide (for this text file)
- Add a file to repo eg READMe.md (copy the contents of this file)
- copy url of repo to ciipboard
- run git bash navigate to a free folder on workstation and 
   git clone https://git-codecommit.eu-west-2.amazonaws.com/v1/repos/bootstrap_guide 



# Running terraform in target (PRD) account setup to be able to run terraform (need s3 bucket for terraform state)
background: read https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa
- Create Target Role in target account eg PRD_Admin set trusted entties as DEV account and attach AWSAdministratorAccess 
- Create target role switch policies eg STS_assume_PRD_Admin_policy  
- Create an IAM user  eg amir.hasan.prd and group PRD_Admin_Group and attach STS_assume_PRD_Admin_policy 
- Test by login to AWS console via IAM console login for target account to amir.hasan.prd and switch role 
-   ACCOUNT_ID TARGET_ACCOUNT_ID
-   ROLE PRD_Admin 
- You are now logged into the target account with a role that has AWSAdministratoraccess with the role switched 
- in target account create terraform state bucket setting versioning on and encryption to kms key eg fmk-prd-state
- in target account create cloudtrail logs bucket setting encryption to kms key  in 1 and s3 bucket create policy for cloudtrail service to be able write to it see https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-set-bucket-policy-for-multiple-accounts.html (ignore mulliaccounts bit in this json Iam policy document just refer to the prod account id)

# Changing terraform variables according
-  set variables correctly in terraform variables.tf to the state bucket Above if different
- the infrastrcutre code uploads and ssh key  (to be used for ssh to instances in target account) use the steps below to create the ssh key note (note- if using git-bash for windows prefix ssl commands with winpty otherwise openssl hangs in git-bash for windows) otherwise remote winpty prefix below:
---
    $ winpty openssl genrsa -out terraform_fmk_private.pem 2048
    $ winpty openssl rsa -in terraform_fmk_private.pem -outform PEM -pubout -out terraform_fmk_pub.pem
    $ ssh-keygen -f terraform_fmk_pub.pem -i -mPKCS8 >terraform_dev.pub
---
- set access keys with access on target account  account and setting:
-  STS assume role with  PRD_Admin to target PRD account  (see https://docs.aws.amazon.com/cli/latest/reference/sts/-   
- export temporary variables session variables to work with target account copying the fields from the output of aws sts assume-role:
---
    export AWS_SECRET_KEY_ID=
    export AWS_SECRET_ACCESS_KEY=
    export AWS_SESSION_TOKEN=
---
- running the terraform 
- navigate to the code in git bash or terminal and run
---
    $ ./terraform_remote.sh
---
-  attempts to initialise terraform and the   remote state backend - talks to S3 using the access keys set on the local variables above:
- In order to see what effect the terraform code will have on the target account terraform reports a plan of all the changes
---
    $ terraform plan
---
- In order to apply the changes
---
    $ terraform apply
---

# Steps for webservices
1) run the infrastructure terraform
2) launch a box on the public subnet (bastion)
3) check you can ssh on to it (server might take some time to get)
4) change the ami in the webservices terraform and correct the bucket in the variables
5) run the webservice terraform
6) scp the terraform private key to the bastion
7) try to ssh from the bastion to the app mon servers after the ELB and ASG settle and make sure ssh is working on them

### scp example 
    $ scp -i privatekeypemfile.pem ./privatekeypemfile.pem ec2-user@target:privatekeypemfile.pem