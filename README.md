# terraform-remote-state
This simple Terraform module creates an ec2 instance on a default subnet and VPC with default security group. It uses Amazon Linux by default so no need to go to the AWS console to find the ami-id. To pull the ami-id, it uses the Terraform data sources. All the parameters for resource creation are input variables. The type of variables can be seen in the [variable.tf](http://variable.tf) file.  It also output the public IP of the ec2 but since this is module, we need to output from the code we are calling this module. Below is an example on how to use this module to create an ec2 instance and ouput it's public IP,

```bash
module "demo" {
  source         = "git::https://github.com/slama34849/terraform-remote-state.git"
  region         = "us-east-2"
  key_name       = "your_key"
  public_ip      = true
  user_data      = ""
  instance_count = 1
  instance_tag   = "simple-test"
  instance_type  = "t2.micro"
}

output "ip" {
    value = module.demo.public_ip
}
```

To add user_data create a file in the same folder as the .tf file and use file function as below,

```bash
user_data = file("tomcat.sh")
```
