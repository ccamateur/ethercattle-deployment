#!/bin/bash -xe
printf "log_group = \"${FallBackLG}\"\nstate_file = \"/var/lib/journald-cloudwatch-logs/state\"" > /usr/local/etc/journald-cloudwatch-logs.conf

rm /var/lib/ethereum/geth.ipc || true
/etc/systemd/system/geth.service || true
ln -s /etc/systemd/system/geth-fallback.service /etc/systemd/system/geth.service
systemctl daemon-reload
systemctl enable geth-fallback.service
systemctl start geth-fallback.service

/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource ReplicaLaunchTemplate --configsets cs_install --region ${AWS::Region}

if [ -f /usr/bin/replica-hook ]
then
  /usr/bin/replica-hook
fi
