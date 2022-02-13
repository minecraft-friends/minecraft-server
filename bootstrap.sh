#! /bin/bash
SEPARATOR="****************************************************************************"

echo "$SEPARATOR"
echo "* STARTING SERVER CONFIGURATION"
echo "$SEPARATOR"

echo "$SEPARATOR"
echo "* ADDING MINECRAFT USER"
echo "$SEPARATOR"
useradd -s /bin/bash -d /home/minecraft -m -G sudo minecraft

echo "$SEPARATOR"
echo "* START OS UPDATES"
echo "$SEPARATOR"
apt update -y
apt upgrade -y
echo "$SEPARATOR"
echo "* END OS UPDATES"
echo "$SEPARATOR"

echo "$SEPARATOR"
echo "* INSTALL DEPENDENCIES"
echo "$SEPARATOR"
# shellcheck disable=SC2154
# shellcheck disable=SC2086
apt install -y ${java.type}-${java.version}-jre ${java.type}-${java.version}-jdk unzip
echo "$SEPARATOR"
echo "* END INSTALL DEPENDENCIES"
echo "$SEPARATOR"

echo "$SEPARATOR"
echo "* INSTALL AWS CLI"
echo "$SEPARATOR"
# install the AWS CLI for S3 interactions
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
echo "$SEPARATOR"
echo "* INSTALLED AWS CLI"
echo "$SEPARATOR"

echo "$SEPARATOR"
echo "* SETUP SERVER VOLUME"
echo "$SEPARATOR"
# Get device id
DEVICE_FS=`sudo lsblk -o UUID -d ${device_name} -n`

echo "Device FS: $DEVICE_FS"

# Create a file system on the volume if one does not already exist
 if [ "`echo -n $DEVICE_FS`" == "" ] ; then
         mkfs.ext4 ${device_name}
 fi

# Create a mount point directory
 sudo mkdir /${zip_root}

# Backup fstab
 sudo cp /etc/fstab /etc/fstab.orig

# Setup auto mount on reboot
 echo "UUID=$${DEVICE_FS} /${zip_root} ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

# Unmount
 sudo umount /${zip_root}

# Mount and exit on error
 sudo mount -a
 if [ $? -eq 0 ]
 then
    echo "Mounted"
 else
    exit 1
 fi

# If the server directory isn't populated, download the world from S3 & prep for launch
if [ -z "$(ls -A ${zip_root})" ]; then
  # shellcheck disable=SC2154
  echo "World directory unpopulated, fetching from S3! Running: aws s3 cp s3://${bucket.bucket}/${snapshot.name}.${snapshot.ext}"

# shellcheck disable=SC2154
# shellcheck disable=SC2086
  aws s3 cp s3://${bucket.bucket}/${snapshot.name}.${snapshot.ext} .
# shellcheck disable=SC2154
# shellcheck disable=SC2086
  unzip ${snapshot.name}.${snapshot.ext}
  ls -alh

# shellcheck disable=SC2154
# shellcheck disable=SC2086
  chmod u+x ${start_script}.sh
fi

echo "$SEPARATOR"
echo "* SERVER VOLUME SETUP"
echo "$SEPARATOR"

echo "$SEPARATOR"
echo "* SETUP MINECRAFT SERVICE"
echo "$SEPARATOR"
chown -R minecraft ${zip_root}

aws s3 cp s3://${bucket.bucket}/minecraft.service /etc/systemd/system/

# shellcheck disable=SC2164
# shellcheck disable=SC2086
cd ${zip_root}

# Start the server
# shellcheck disable=SC2086
# Not doing this anymore since we're going to start the server as a systemd service
#./${start_script}.sh
systemctl enable minecraft
systemctl start minecraft
echo "$SEPARATOR"
echo "* DONE SETTING UP MINECRAFT SERVICE"
echo "$SEPARATOR"

echo "$SEPARATOR"
echo "* END SERVER CONFIGURATION"
echo "$SEPARATOR"