#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${cluster_name}
/opt/aws/bin/cfn-signal --exit-code $? --stack  ${cluster_name} --region ${aws_region}