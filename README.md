# minecraft-server

## Disclaimer
This project WILL deploy AWS resources using your AWS CLI config.  By executing this project you understand that
you may be charged for the running of AWS resources.  You are responsible for making sure they are started/stopped
appropriately/affordably for your use-case.


## Requirements
1. An [AWS account](https://aws.amazon.com/) with configured [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) credentials
2. [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. A command line
4. A bucket containing a zipped server snapshot
5. A secret containing linux credentials for the service user

## Creating a Server
Make sure you install the required tools listed above.  Then, you can do the following to create the server:
1. `./gen_ssh.sh` - generates a new RSA-4096 cert to secure SSH connections to the server
2. Import the private certificate into your SSH Client (usually put it in `~/.ssh`)
3. Generate a terraform plan: `terraform plan -out tfplan`
4. Evaluate the plan output to make sure the infrastructure is created correctly
5. Execute the plan: `terraform apply tfplan`

### Variables 
| Variable        | Description                                                                           | Default                | Example                      |
|-----------------|---------------------------------------------------------------------------------------|------------------------|------------------------------|
| `instance_size` | The [instance size](https://aws.amazon.com/ec2/instance-types/) to use for the server | `m6i.large`            | `m6i.large`                  |
| `region`        | The region in which to deploy the instance                                            | `us-east-1`            | `us-west-2`                  |
| `ssh_key_name`  | What to name the SSH key in AWS                                                       | `minecraft-server-key` | `my-server-key`              |
| `ssh_key_path`  | The path to the SSH key (locally) that you'd like to use                              | `./ssh_key.pub`        | `/path/to/my/file`           |
| `port`          | The port to run the server on                                                         | `14375`                | `19999`                      |
| `allow_ssh`     | A list of other IPs you'd like to allow SSH access to the server                      | `<your WAN IP>`        | `24.35.142.98,34.234.894.23` |

## Resources
| Resource                | TF Key                                                  | Description                                                        |
|-------------------------|---------------------------------------------------------|--------------------------------------------------------------------|
| EC2 Instance            | `aws_instance.minecraft_server`                         | The EC2 instance this server will run on                           |
| AMI                     | `aws_ami.ubuntu`                                        | The AMI the server will use to run the server (ubuntu)             |
| SSH Key Pair            | `aws_key_pair.key_pair`                                 | The SSH keypair to authenticate SSH access to the server           |
| VPC                     | `aws_vpc.minecraft_server_vpc`                          | The VPC we'll create to expose the server to the internet          |
| Subnet                  | `aws_subnet.minecraft_server_public_subnet`             | The PUBLIC subnet to which your server will be deployed            |
| Internet Gateway        | `aws_internet_gateway.minecraft_server_igw`             | The egress connecting our VPC to the internet                      |
| Route Table             | `aws_route_table.minecraft_server_route_table`          | The route table to expose the private VPC to the internet          |
| Route Table Association | `aws_route_table_association.minecraft_crt_association` | An association between the subnet and route table required by AWS  |
| Security Group          | `aws_security_group.minecraft_server_allow_ssh`         | The security group that permits external access for ssh and egress |

# Outputs
| Output             | Description                                 |
|--------------------|---------------------------------------------|
| `server_public_ip` | The public IP address of the server created |
