#!/bin/bash
# install oci-utils and terraform with oci provider
sudo yum -y install oci-utils terraform terraform-provider-oci
mkdir ~/.oci

# generate private API key for terraform to communicate with OCI 
openssl genrsa -out ~/.oci/oci_api_key.pem 2048

# Make sure only -we- can read private keys
chmod go-rwx ~/.oci/oci_api_key.pem

# generate corresponding public API key
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem

# generate ssh keys for ol7 instance
ssh-keygen -f ~/.ssh/id_rsa_ol7oci -t rsa -N ''

# fingerprint to include in terraform.tfvars
echo "********************************************"
echo "- Run vagrant up; vagrant ssh"
echo "- Run the command below to show fingerprint"
echo "- Include this fingerprint in terraform.tfvars"
echo "********************************************"
echo 
echo "openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c"
echo 
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c

# public key to upload to OCI console
echo "********************************************"
echo " - Run this command to show the public key"
echo " - Upload this public key to the OCI console"
echo "********************************************"
echo 
echo "cat ~/.oci/oci_api_key_public.pem"
echo 
cat ~/.oci/oci_api_key_public.pem
