## ✅ Step 1: Launch EC2 Instances Using a Bash Script

1. Go to the [AWS EC2 Console](https://console.aws.amazon.com/ec2)
2. Click on **Launch Instance**
3. Fill in the details:
   - **Name**: `server-1`
   - **Amazon Machine Image (AMI)**: Select **Ubuntu Server 22.04 LTS (HVM), SSD Volume Type**
   - **Instance type**: `t2.micro` (Free Tier eligible)
   - **Key pair**: Create new or select existing
   - **Network Settings**: Use the custom VPC that you created
       - **Type**: HTTP | **Protocol**: TCP | **Port**: 80 | **Source**: Anywhere (0.0.0.0/0)
       - **Type**: SSH | **Protocol**: TCP | **Port**: 22 | **Source**: My IP





### Add User Data Script

In the **Advanced Details** section, paste the following **user-data** script:

```bash
#!/bin/bash
apt-get update
apt-get install nginx -y

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Welcome to $(hostname)</title>
  <style>
    body {
      background: linear-gradient(135deg, #1e3c72, #2a5298);
      color: white;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    h1 {
      font-size: 3em;
      margin: 0.2em 0;
    }
    p {
      font-size: 1.2em;
      color: #cce3ff;
    }
    .hostname {
      background: #ffffff33;
      padding: 0.5em 1em;
      border-radius: 10px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <h1> Welcome to Omkar Server!</h1>
  <p>This server is proudly hosted as:</p>
  <div class="hostname">$(hostname)</div>
</body>
</html>
EOF
```


**Similarly create three servers: server-1, server-2 and server-3 respectively**

![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/3c2b21a4afdb43b2bb222ee84e39c27969b3bd81/Infra-Project/Screenshot%20(9910).png)
## ✅ Step 2: Create a Target Group and Register EC2 Instances

Once your EC2 instances are launched and NGINX is running on them (port 80), the next step is to create a **Target Group** and register your instances. This Target Group will later be linked with a Load Balancer.

---

### Navigate to Target Groups

1. Go to the **AWS Management Console**
2. Open the **EC2 Dashboard**
3. From the left-hand sidebar, click on **Target Groups** under **Load Balancing**
4. Click **Create target group**




### Configure Target Group

Fill out the target group creation form as follows:

- **Target type**: `Instances`
- **Target group name**: `TargetGroup-1` (or any name you prefer)
- **Protocol**: `HTTP`
- **Port**: `80`
- **VPC**: Select the VPC where your EC2 instances are running
- **Health checks**:
  - **Protocol**: HTTP
  - **Path**: `/`

> Leave other settings as default unless you have specific health check requirements.

Click **Next**.


### Register Targets (EC2 Instances)

On the **Register targets** page:

1. You’ll see a list of running EC2 instances in the selected VPC.
2. Select the checkboxes for the 3 NGINX EC2 instances you created.
3. Under **Ports for the selected instances**, make sure the port is set to `80`.
4. Click **Include as pending below**.
5. Scroll down and click **Create target group**.



![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/3697ea189fabcadb062ab45bd827284ea6f42774/Infra-Project/Screenshot%20(9903).png)

[![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/72a65bc47995adc721158b188a27fc7c1c9cec53/Infra-Project/Screenshot%20(9907).png)

### Verify Registration

After creation:

- Go back to **Target Groups**
- Select your newly created target group
- Click on the **Targets** tab
- You should see the EC2 instances with a **healthy** status after a few seconds (if health checks pass)

[![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/dfaa160d349cf18ea0bab0aadb1e194284ce7bcb/Infra-Project/Screenshot%20(9916).png)

## ✅ Step 3: Creating an Application Load Balancer and Associating It with a Target Group

After launching EC2 instances and registering them in a **Target Group**, the next step is to set up a **Load Balancer** to distribute traffic among them.


### Navigate to Load Balancers

1. Go to the **AWS Management Console**
2. Open the **EC2 Dashboard**
3. From the left-hand menu, click **Load Balancers**
4. Click **Create Load Balancer**

### Select Load Balancer Type

Choose **Application Load Balancer (ALB)**:
- Suitable for HTTP/HTTPS traffic
- Operates at **Layer 7** (Application Layer)

Click **Create** under Application Load Balancer.


### Configure Basic Settings

Fill in the required fields:
- **Name**: `ALB-Testing`
- **Scheme**: `Internet-facing`
- **IP address type**: `IPv4`
- **Listener**: `HTTP` on port `80`


Click **Next: Configure Security Settings**




### Register Target Group

In this step, you’ll associate the previously created **Target Group** with the Load Balancer.

- **Target group name**: Select your existing target group (e.g., `TargetGroup-1`)
- **Protocol**: HTTP
- **Port**: 80

Click **Next: Register Targets**


### Review and Create

1. Review all the configurations
2. Click **Create Load Balancer**

After a few moments, your load balancer will be **provisioned and active**.

[![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/8e96fc308c426acfff9b32d601a1e7099065bd51/Infra-Project/Screenshot%20(9884).png)
[![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/eba1e1cd7ecda55e9490b152f4aaa8e65de55581/Infra-Project/Screenshot%20(9887).png)

### Access Your Load Balancer

1. Go to **EC2 → Load Balancers**
2. Copy the **DNS name** of your ALB (e.g., `my-alb-123456789.us-east-1.elb.amazonaws.com`)
3. Paste it in your browser:


> - _**Note: You cannot access the instance through the ALB DNS name why?
because the SG of ALB only allows to communicate within itself to one thing you can do you can add below rule to ALB SG this will work.**_

| Type | Protocol | Port | Source    |
| ---- | -------- | ---- | --------- |
| HTTP | TCP      | 80   | 0.0.0.0/0 |

- _**Exposing ALB to Internet is ok, but our instance also exposed to internet and hackers can directly reach the instance by the public ip, so we need to update instances SG and allow trusted traffic through ALB.**_

| Type | Port | Source                                                  |
| ---- | ---- | ------------------------------------------------------- |
| HTTP | 80   | ALB's Security Group ID ✅ (Only allow traffic from ALB)|

>-  _**Important: If using custom VPC then you need to create a new Security group for the ALB and allow traffic from every where note that ALB should be in the public subnet and anywhere rule in SG makesure to attach the SG of ALB to the server instance for security point of view**_

[![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/7270dba406f3e4f125b9e17a4d3a2f2ea36afc3b/Infra-Project/screenshotaws1.png)
[![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/a8bc55a14213be2aa321b1ad571e4952c6e4748e/Infra-Project/screenshotaws2.png)
[![Screenshot](https://github.com/ansh565/AWS-PROJECT/blob/531460e1c7afe63b3b67c1925e451beb748a3159/Infra-Project/Screenshot%20(9873).png)
> Hurray!! We are getting response from all three servers.





