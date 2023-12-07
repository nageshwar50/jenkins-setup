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



## Provision Server Using Terraform
Modify the values of ec2.tfvars file present in the terraform-aws/vars folder. You need to replace the values highlighted in bold with values relevant to your AWS account & region.

If you are using us-west-2, you can continue with the same AMI id.
<pre>
# EC2 Instance Variables
region         = "us-west-2"
ami_id         = "ami-0efcece6bed30fd98"
instance_type  = "t2.micro"
key_name       = "nageshwar"
instance_count = 1
volume-size = 25

# VPC id
vpc_id  = "vpc-0ce1c1c34c9d1afe2"
subnet_ids     = ["subnet-02da9422af0bbc93c"]

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
terraform plan --var-file=../vars/ec2.tfvars
terraform apply --var-file=../vars/ec2.tfvars
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
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/858d1b35-50e1-414c-8982-6f281792bc0d)

<pre>  ssh -i nageshwar.pem ubuntu@54.188.1.49</pre>

Copy your Public IP and paste on Chrome tab with pub:8080
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/82a8963c-d219-4187-9544-e442dc94a96d)
<pre>
  Run 
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
</pre>
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/60023a81-86df-48b5-80c2-91e0a0781efa)
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/0e21ec35-bb0c-4ef2-85fb-32ba61be5398)

## Installing Nginx
<pre>
  sudo apt install nginx
  systemctl status nginx
</pre>
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/db015292-5e94-4805-b812-d64d24a7f98e)

Make sure you have added the domain records in your Domain
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/fc4c2601-8a46-40a9-a2bf-df1f02be2d02)


In order for Nginx to serve this content, it’s necessary to create a server block with the correct directives.
<pre>
  sudo vi /etc/nginx/sites-available/jenkins.nageshwarpandey.co.in
</pre>
Paste in the following configuration block, which is similar to the default, but updated for our new directory and domain name:
<pre>
  upstream jenkins{
    server 127.0.0.1:8080;
}

server{
    listen      80;
    server_name jenkins.nageshwarpandey.co.in

    access_log  /var/log/nginx/jenkins.access.log;
    error_log   /var/log/nginx/jenkins.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://jenkins;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        proxy_set_header    Host            $host;
        proxy_set_header    X-Real-IP       $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;
    }

}

</pre>
Next, let’s enable the file by creating a link from it to the sites-enabled directory, which Nginx reads from during startup:
<pre>
  sudo ln -s /etc/nginx/sites-available/jenkins.nageshwarpandey.co.in /etc/nginx/sites-enabled/
</pre>
Next, test to make sure that there are no syntax errors in any of your Nginx files:

<pre> sudo nginx -t </pre>
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/9e2a5b36-246d-4f01-9de5-9c1883670259)

If there aren’t any problems, restart Nginx to enable your changes:

<pre> sudo systemctl restart nginx</pre>
Nginx should now be serving Jenkins from your domain name. You can test this by navigating to http://your_domain

![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/73d9a630-42f0-4648-88ef-649bed659395)

## Configure Jenkins with SSL
The first step to using Let’s Encrypt to obtain an SSL certificate is to install the Certbot software on your server.

<pre> sudo apt install certbot python3-certbot-nginx </pre>
## Confirming Nginx’s Configuration
Certbot needs to be able to find the correct server block in your Nginx configuration for it to be able to automatically configure SSL. Specifically, it does this by looking for a server_name directive that matches the domain you request a certificate for.

<pre> sudo vi /etc/nginx/sites-available/jenkins.nageshwarpandey.co.in </pre>
## Obtaining an SSL Certificate
Certbot provides a variety of ways to obtain SSL certificates through plugins. The Nginx plugin will take care of reconfiguring Nginx and reloading the config whenever necessary. To use this plugin, type the following:

<pre> sudo certbot --nginx -d jenkins.nageshwarpandey.co.in </pre>
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/7678352f-8e62-4729-a0f9-390e07e30f15)
Verifying Certbot Auto-Renewal
Let’s Encrypt’s certificates are only valid for ninety days. This is to encourage users to automate their certificate renewal process. The certbot package we installed takes care of this for us by adding a systemd timer that will run twice a day and automatically renew any certificate that’s within thirty days of expiration.

You can query the status of the timer with systemctl:

<pre> sudo systemctl status certbot.timer </pre>
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/4fbbc94c-7a12-40a2-8750-373af7114266)

To test the renewal process, you can do a dry run with certbot:

<pre> sudo certbot renew --dry-run </pre>

Nginx should now be serving your domain name. You can test this by navigating to https://your_domai
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/cbfa92c0-8504-4034-9d54-1d9f079456d9)

Now we have to change the Jenkins Configure URL 
<pre> Dashboard - > Manage Jenkins -> System and paste the URL then save it </pre>

![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/cf83b504-5b07-4cd1-b71b-b2d866825ad1)

## Set up a Jenkins agent on the  EC2 machine
Create a new ec2 server for Slave agent 
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/2181ccce-af9a-44b0-9009-c37bc94d1ffa)

Noww copy your slave ec2 server pem file 
<pre>  cat slave.pem  </pre>
And create a file with same pem file name in master slave EC2 Server and paste the Pem Key

<pre>
  vi slave.pem
  chmod 400 slave.pem
</pre>
Now SSH into Slave ec2 server and copy the user-data.sh file and  run following command
<pre>
  chmod 700 user-data.sh
  ./user-data.sh
</pre>

## Lets Go to the our Jenkins server and setup slave node
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/37a54396-6f38-4396-8688-0d13273e600b)

![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/b309be9c-5d36-42cb-9dc9-a8abd01e6f7d)
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/4f7e251c-ffd9-41a0-81e5-dc41fa015106)

* Paste here your Pem key here and then save it and then select Credentials as you saved and Host Key Verification Strategy:
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/317eca61-c986-481f-9e14-d91ba7c07e73)
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/c5ad7544-0515-4379-b151-eefb3f038a9d)

* Now you can check logs massage on Dashboard -> Nodes -> slave-node .-> Log
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/3325e014-39e9-4ee2-b192-297d006ecc27)

Let's verify whether everything working fine or not, create a Pipeline 
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/7685740e-7eb9-4133-be3d-569b7fbccb67)
* Paste this Pipeline code
  <pre>
    pipeline {
    agent any
    stages {
        stage('Hello Nageshwar') {
            steps {
                echo 'Hello Nageshwar'
            }
        }
    }
}
  </pre>
* Now we can see that our slave node is working
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/4d7e874a-bd04-4bcf-bda6-743edbf58d5b)

## Lets Integration with Slack
Go to your Slack Dashboard and select 
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/e2cbb451-ab7d-460b-85d1-7f237f6a6af2)

![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/a517815e-f87b-4be4-9e2f-04c906ac0a27)
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/a3b9b29c-c744-4d4b-9452-115300eb6d1a)

Go to your Jenkins Dashboard -> Manage Jenkins -> System -> add your slack-Jenkins API token and your slack channel 

![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/15849049-c72f-44bd-8c06-43903fb7e854)
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/24a48f56-1112-4785-be18-6f5ff27539b2)

* Let's Test our Slack with pipeline 
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/00bc7eaa-534c-450a-a448-7be868b2eb3f)
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/7abfbc68-748a-4353-97de-0f8f02097388)
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/bca3d5c7-06f1-4116-85d2-1d7e11da91a5)
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/d8f5d8a4-75e4-4e04-96e4-02ab9a80ce5a)
## Result 
![image](https://github.com/nageshwar50/jenkins-setup/assets/128671109/ef239cd6-92b9-44a8-89d8-e7a82142e0b2)













