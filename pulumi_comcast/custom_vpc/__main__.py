import pulumi
import pulumi_aws as aws

# 1️⃣ Create a VPC
vpc = aws.ec2.Vpc(
    "custom-vpc",
    cidr_block="10.0.0.0/16",
    enable_dns_hostnames=True,
    enable_dns_support=True,
    tags={"Name": "CustomVPC"},
)

# 2️⃣ Create an Internet Gateway
igw = aws.ec2.InternetGateway(
    "custom-igw",
    vpc_id=vpc.id,
    tags={"Name": "CustomInternetGateway"},
)

# 3️⃣ Create a Public Subnet
public_subnet = aws.ec2.Subnet(
    "public-subnet",
    vpc_id=vpc.id,
    cidr_block="10.0.1.0/24",
    map_public_ip_on_launch=True,
    availability_zone="us-east-1a",
    tags={"Name": "PublicSubnet"},
)

# 4️⃣ Create a Route Table
route_table = aws.ec2.RouteTable(
    "public-rt",
    vpc_id=vpc.id,
    routes=[{
        "cidr_block": "0.0.0.0/0",
        "gateway_id": igw.id,
    }],
    tags={"Name": "PublicRouteTable"},
)

# 5️⃣ Associate the Subnet with the Route Table
route_table_assoc = aws.ec2.RouteTableAssociation(
    "public-rt-assoc",
    subnet_id=public_subnet.id,
    route_table_id=route_table.id,
)

# 6️⃣ Create a Security Group
security_group = aws.ec2.SecurityGroup(
    "web-sg",
    vpc_id=vpc.id,
    description="Allow SSH and HTTP",
    ingress=[
        {"protocol": "tcp", "from_port": 22, "to_port": 22, "cidr_blocks": ["0.0.0.0/0"]},
        {"protocol": "tcp", "from_port": 80, "to_port": 80, "cidr_blocks": ["0.0.0.0/0"]},
    ],
    egress=[
        {"protocol": "-1", "from_port": 0, "to_port": 0, "cidr_blocks": ["0.0.0.0/0"]},
    ],
    tags={"Name": "WebSecurityGroup"},
)

# 7️⃣ Export Outputs
pulumi.export("vpc_id", vpc.id)
pulumi.export("public_subnet_id", public_subnet.id)
pulumi.export("security_group_id", security_group.id)
