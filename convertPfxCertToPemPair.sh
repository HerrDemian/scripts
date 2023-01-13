#!/bin/bash

# Input validation
if [ $# -ne 2 ]; then
    echo "Usage: $0 fullpath_of_pfx_file password"
    echo "This script takes the full path of the pfx certificate and the password as input. It first validates the input to check if the file provided is a valid file and if the right number of arguments have been passed. Then, it uses the OpenSSL command-line tool to extract the key and certificate from the pfx file. The key is saved in a file with the same name as the original file but with a "-key.pem" extension, and the certificate is saved in a file with a ".pem" extension. Finally, it extracts the Subject CN and valid dates from the certificate file and prints them to the console, along with a success message."
    exit 1
fi

if [ ! -f $1 ]; then
    echo "Error: $1 is not a valid file"
    exit 1
fi

# Extract key and certificate
openssl pkcs12 -in $1 -nocerts -out ${1%.*}-key.pem -nodes -password pass:$2
openssl pkcs12 -in $1 -clcerts -nokeys -out ${1%.*}.pem -password pass:$2

# Extract Subject CN and valid dates
openssl x509 -noout -subject -in ${1%.*}.pem | grep "CN="
openssl x509 -noout -dates -in ${1%.*}.pem

echo "Successfully converted $1 to ${1%.*}.pem and ${1%.*}-key.pem"

