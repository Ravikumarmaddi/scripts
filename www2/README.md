# backup region demonstration
- copy the site file and remove state data

cp -R -p www www2; rm www2/\*state\*

- sub the "region.primary" for "region.backup" variables

sed -i s/region.primary/region.backup/g www2/*.tf

- modify the route53 record if desired; likely not in practice

sed -i s/www/www2/g dnsrecords.tf

- run a "terraform plan" to ensure no errors before deployment

terraform plan
