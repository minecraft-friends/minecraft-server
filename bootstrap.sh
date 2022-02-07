#! /bin/bash

apt update -y
apt upgrade -y
# shellcheck disable=SC2154
# shellcheck disable=SC2086
apt install -y ${java.type}-${java.version}-jre ${java.type}-${java.version}-jdk unzip

# install the AWS CLI for S3 interactions
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# TODO: need to setup a role to access EC2 metadata to get credentials (and configure an IAM user for the service)
# shellcheck disable=SC2154
# shellcheck disable=SC2086
aws s3 cp s3://${bucket.bucket}/${snapshot.name}.${snapshot.ext} .
# shellcheck disable=SC2154
# shellcheck disable=SC2086
unzip ${snapshot.name}.${snapshot.ext}
# shellcheck disable=SC2086
cd ${snapshot.name} || exit 10
./run.sh