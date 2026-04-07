#!/bin/bash

apt-get update -y
apt-get install nginx -y

systemctl start nginx
systemctl enable nginx

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Ansh Server 1</title>
  <style>
    body {
      margin: 0;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      flex-direction: column;
      font-family: Arial, sans-serif;
      color: white;
      background: linear-gradient(135deg, #1e3c72, #2a5298);
    }
    h1 {
      font-size: 3em;
      margin-bottom: 10px;
    }
    p {
      font-size: 1.3em;
    }
    .box {
      background: rgba(255, 255, 255, 0.2);
      padding: 15px 25px;
      border-radius: 10px;
      margin-top: 10px;
      font-size: 1.5em;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <h1>Welcome to Ansh Server !</h1>
  <p>This server is proudly hosted as:</p>
  <div class="box">Server-1 ($(hostname))</div>
</body>
</html>
EOF
