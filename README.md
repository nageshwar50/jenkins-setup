# Jenkins Installation On Ubuntu with Reverse Proxy & TLS Certificate and Integration with Slack

This repository provides an overview and step-by-step guide for installing Jenkins on Ubuntu with a reverse proxy and TLS certificate. Additionally, it covers the integration of Jenkins with Slack for increased visibility into Jenkins job statuses.

## Prerequisites
  - [AWS Account with a key Pair](#AWS-Account-with-a-key-Pair)
  - [ AWS CLI configured with the respective account ](#AWS-CLI-configured-with-the-respective-account)
  - [ Terraform is installed on your local machine ](#Terraform-is-installed-on-your-local-machine)
  - [A Domain Name](#domain-name)
## Terraform
Terraform is one of the most popular Infrastructures as a Code created by HashiCorp. It allows developers to provision the entire infrastructure by code. We will use Terraform to provision the ec2 instance required for the setup.
## Jenkins
Jenkins is an open-source automation server that facilitates the continuous integration and continuous delivery (CI/CD) of software projects. Developed in Java and maintained by the Jenkins community, it serves as a powerful tool for automating various aspects of the software development lifecycle.
## AWS
Amazon Web Services (AWS) is a comprehensive and widely used cloud computing platform provided by Amazon. AWS offers a broad set of scalable and reliable services, allowing businesses and developers to build, deploy, and manage applications and infrastructure in the cloud
## Reverse Proxy:
A reverse proxy is a server that sits between client devices (such as web browsers) and a web server. Unlike a traditional forward proxy, which forwards requests from clients to servers, a reverse proxy handles requests from clients and forwards them to the appropriate backend servers.
* Load Balancing
*  Security  Caching 
## TLS Certificate:
Transport Layer Security (TLS) is a cryptographic protocol that ensures secure communication over a computer network. TLS certificates, often referred to as SSL certificates (though SSL is an older version of the protocol), are digital certificates that establish an encrypted link between a web server and a client's browser.
*  Authentication
*  Encryption
*  Trust


terraform init
terraform apply -var-file=ec2.tfvars -var-file=terraform.tfvars
## Provision Server Using Terraform
Modify the values of ec2.tfvars file present in the terraform-aws/vars folder. You need to replace the values highlighted in bold with values relevant to your AWS account & region.

If you are using ca-central-1, you can continue with the same AMI id.
<pre>
# EC2 Instance Variables
region         = "ca-central-1"
ami_id         = "ami-06873c81b882339ac"
instance_type  = "t2.micro"
key_name       = "pandey"
instance_count = 1
volume_size    = 20

# VPC id
vpc_id  = "vpc-0cac018cd52b8d4c1"
subnet_ids     = ["subnet-0974592fab983deaf"]

# Ec2 Tags
name        = "jenkins-stack"
owner       = "nageshwar"
environment = "dev"
cost_center = "pandey-commerce"
application = "ci/cd"
</pre>
Now we can provision the AWS EC2 & Security group using Terraform. First, we need to install Terraform

![Screenshot from 2023-12-07 10-30-00](https://github.com/nageshwar50/jenkins-setup/assets/128671109/6b7a792a-6af8-40de-a973-640e0b9b423c)

<pre>
cd /terraform-aws/jenkins/
terraform fmt
terraform init
terraform validate
</pre>
Execute the plan and apply the changes.
<pre>
terraform plan
terraform apply
</pre>

Before typing ‘yes‘ make sure the desired resources are being created.

<pre>
  
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_public_dns = [
      + (known after apply),
    ]
  + instance_public_ip  = [
      + (known after apply),
    ]
  + instance_state      = [
      + (known after apply),
    ]



</pre>
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/f204dd13-9edb-4501-aa49-8541b0772d03)


Now we can connect to the AWS EC2 machine just created using the public IP. Replace the key path/name and IP accordingly.
<pre>  ssh -i pandey.pem ubuntu@34.216.95.97</pre>
















