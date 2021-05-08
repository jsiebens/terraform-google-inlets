#! /bin/bash

sed -i "s/#Port 22/Port ${ssh_port}/" /etc/ssh/sshd_config
systemctl restart sshd

curl -SLsf https://github.com/inlets/inlets-pro/releases/download/0.8.3/inlets-pro > /usr/local/bin/inlets-pro
chmod +x /usr/local/bin/inlets-pro

cat > /etc/systemd/system/inlets-pro.service <<- EOF
${service_file}
EOF

echo "AUTHTOKEN=${token}" >> /etc/default/inlets-pro

systemctl enable inlets-pro
systemctl start inlets-pro