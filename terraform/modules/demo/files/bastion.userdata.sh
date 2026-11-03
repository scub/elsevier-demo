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
}
EOF

# Start agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent


apt update ; apt install -y python3
curl -LsSf https://astral.sh/uv/install.sh | sh

curl -Lso /root/.ssh/authorized_keys https://github.com/scub.keys
mkdir -p /var/www
echo "Hello, World!" > /var/www/index.html

cat > /etc/systemd/system/httpd.service <<'EOF'
[Unit]
Description=FastAPI Server
After=network.target

[Service]
Type=simple
ExecStart=/root/.local/bin/uv --directory /var/www run fastapi run
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now httpd.service
