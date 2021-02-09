## AWS Wavelength

You may get more info about Amazon Wavelength with below links. You need to opt-in to be able to use the service.

https://aws.amazon.com/wavelength/

https://aws.amazon.com/wavelength/getting-started/

Once you opt-in, you can list the available zones with the below command:

```shell
aws ec2 describe-availability-zones --all-availability-zones | jq '.AvailabilityZones[] | select(.ZoneType == "wavelength-zone" and .State == "available") | .ZoneName'
"us-east-1-wl1-atl-wlz-1"
"us-east-1-wl1-bos-wlz-1"
"us-east-1-wl1-dfw-wlz-1"
"us-east-1-wl1-mia-wlz-1"
"us-east-1-wl1-nyc-wlz-1"
"us-east-1-wl1-was-wlz-1"
```

## Provision to AWS Wavelength

This project creates a PoC environment for AWS Wavelenght service with the following setup:

![Alt text](./environment.jpeg?raw=true "Environment Setup")

You need to export below environment variables for the SSH connection towards AWS resources.
You may use your existing SSH keys or generate a new pair and use it.

```shell
export TF_VAR_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
export TF_VAR_PRIVATE_KEY_FILE="$HOME/.ssh/id_rsa"
```

If you prefer to use S3 bucket to store terraform state, you may update the [providers.tf](./tf/providers.tf) file:

```terraform
terraform {
  backend "s3" {
    bucket = "tf-backend"
    key = "tf/wl-infra-state"
    region = "us-east-1"
  }
}
```

You may run below commands to create the resources on AWS Wavelength:

```shell
$ cd tf/

$ terraform init

$ terraform validate

$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

...

Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bastion_host_ip = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

...

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:

bastion_host_ip = "54.82.14.253"
```

![Alt text](./ec2.png?raw=true "EC2")

You may connect to your bastion host, then connect to the wavelength machine. 
As you see, they have different default gateways:

```shell
$ ssh ec2-user@54.82.14.253
The authenticity of host '54.82.14.253 (54.82.14.253)' cannot be established.
ECDSA key fingerprint is SHA256:ElCPNhcnNkkAxmEzIom4mbYQYjfAuA+mYt5OZ3YOc8A.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '54.82.14.253' (ECDSA) to the list of known hosts.
Last login: Tue Feb  9 16:14:41 2021 from 46.196.72.234

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[ec2-user@ip-10-10-0-122 ~]$ Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         ip-10-10-0-1.ec 0.0.0.0         UG    0      0        0 eth0
10.10.0.0       0.0.0.0         255.255.255.128 U     0      0        0 eth0
instance-data.e 0.0.0.0         255.255.255.255 UH    0      0        0 eth0
[ec2-user@ip-10-10-0-122 ~]$
[ec2-user@ip-10-10-0-122 ~]$ ssh 10.10.0.174
The authenticity of host '10.10.0.174 (10.10.0.174)' cannot be established.
ECDSA key fingerprint is SHA256:R2IHYrf03TkvXpEbwJyE+Q+YpW33MqPYPAkHDq15qXo.
ECDSA key fingerprint is MD5:56:6f:88:7d:b6:66:0c:11:29:f6:b4:ad:ba:16:23:21.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.10.0.174' (ECDSA) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[ec2-user@ip-10-10-0-174 ~]$ route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         ip-10-10-0-129. 0.0.0.0         UG    0      0        0 eth0
10.10.0.128     0.0.0.0         255.255.255.192 U     0      0        0 eth0
instance-data.e 0.0.0.0         255.255.255.255 UH    0      0        0 eth0
```


## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.14 |
| aws | ~> 3.27 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.27 |
| null | ~> 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| AWS\_PUBLIC\_AZ | AWS Availability Zone for public subnet (bastion host) | `string` | `"us-east-1a"` | no |
| AWS\_REGION | AWS region, e.g. us-east-1 | `string` | `"us-east-1"` | no |
| AWS\_WL\_AZ | AWS Availability Zone for the Wavelength subnet | `string` | `"us-east-1-wl1-nyc-wlz-1"` | no |
| PRIVATE\_KEY\_FILE | SSH Private Key file for bastion host to WL hosts connection | `string` | n/a | yes |
| PUBLIC\_KEY | SSH Public Key for bastion host connection | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bastion\_host\_ip | Bastion Host Public IP Address |
