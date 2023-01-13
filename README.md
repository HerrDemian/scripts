# scripts

renewApigeeVHCert.sh

This script takes the name of the certificate and key files, and the name of the environment group as input. It first validates the input by checking if the certificate and key files exist. Then it validates that the environment group name matches the CN of the certificate and also check if the cert is not expired.
It then updates the overrides file with the new certificate and key names, and applies the changes using the



