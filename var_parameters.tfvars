vpc_name                     = "temp-vpc"
private_subnet_name          = "temp-private-subnet"
public_subnet_name           = "temp-public-subnet"
public_route_table_name      = "temp-public-route-table"
private_route_table_name     = "temp-private-route-table"
instance_security_group_name = "temp-instances-sg"
instance_role_name           = "ec2-instance-profile"


instances = {
  "my-instance-1" = {
    ami             = "ami-02f0341ac93c96375"
    instance_type   = "t2.micro"
    target_instance = "my-instance-1"
    tags = {
      Name = "varnish-instance"
    }
  }

  "my-instance-2" = {
    ami             = "ami-02f0341ac93c96375"
    instance_type   = "t3.medium"
    target_instance = "my-instance-2"
    tags = {
      Name = "magento-instance"
    }
  }
}



target_groups = {
  "my-instance-1-target-group" = {
    name            = "varnish-target-group"
    port            = "80"
    target_instance = "my-instance-1"
    tags = {
      Name = "varnish-target-group"
    }
  }

  "my-instance-2-target-group" = {
    name            = "magento-target-group"
    port            = "80"
    target_instance = "my-instance-2"
    tags = {
      Name = "magento-target-group"
    }
  }
}


health_check = {
  "unhealthy_threshold" = "2"
  "healthy_threshold"   = "3"
  "timeout"             = "5"
  "interval"            = "10"
  "path"                = "/"
  # "port"              = "80"
}