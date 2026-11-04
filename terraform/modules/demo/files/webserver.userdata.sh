#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Create configuration directory and file
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
sudo cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/aws/ec2/user-data",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%b %d %H:%M:%S"
          }
        ]
      }
    }
  }
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent",
          "mem_available_percent",
          "mem_used",
          "mem_available",
          "mem_total"
        ],
      }
    }
  }
}
EOF

# Start agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

apt update ; apt install -y python3 unzip
curl -LsSf https://astral.sh/uv/install.sh | sh

curl -Lso /root/.ssh/authorized_keys https://github.com/scub.keys
mkdir -p /var/www

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
aws --version

# Pull down web bundle, explode it and sync deps
aws s3 cp s3://${asset_bucket}/webapp/bundle.zip /tmp/bundle.zip
unzip -d /var/www /tmp/bundle.zip
/root/.local/bin/uv --directory /var/www sync

# Used to trigger redeploys when the app bundle updates
echo ${asset_checksum} > /tmp/app_bundle_checksum

SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id ${secretsmanager_secret} --query "SecretString" --output text)

# Start up service
cat > /etc/systemd/system/httpd.service <<EOF
[Unit]
Description=FastAPI Server
After=network.target

[Service]
Type=simple
ExecStart=/root/.local/bin/uv --directory /var/www run fastapi run
Restart=on-failure
Environment="SECRETSMANAGER_KEY=$SECRET_VALUE"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now httpd.service
