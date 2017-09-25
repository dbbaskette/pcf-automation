BOSH_ADDRESS=`bbl director-address`
BOSH_USERNAME=`bbl director-username`
BOSH_PW=`bbl director-password`
STEMCELL_URL="https://network.pivotal.io/api/v2/products/stemcells/releases/7073/product_files/30716/download"

bbl director-ca-cert > bosh.cert

bosh -e $BOSH_ADDRESS alias-env $BOSH_ENV --ca-cert ./bosh.cert
bosh -e $BOSH_ENV login --client=$BOSH_USERNAME --client-secret=$BOSH_PW

wget https://github.com/concourse/concourse/releases/download/v3.4.1/concourse-3.4.1.tgz
wget https://github.com/concourse/concourse/releases/download/v3.4.1/garden-runc-1.6.0.tgz

git clone https://github.com/patrickcrocker/pcf-stuff.git
./pcf-stuff/pivnet token $PIVNET_TOKEN
./pcf-stuff/pivnet download ${STEMCELL_URL} 

bosh -e $BOSH_ENV upload-stemcell *stemcell*.tgz
bosh -e $BOSH_ENV upload-release  concourse*.tgz
bosh -e $BOSH_ENV upload-release  garden*.tgz
bosh -e $BOSH_ENV deploy -d concourse ./concourse-manifest.yml -n

gcloud compute firewall-rules create "concourse-web" --allow tcp:8080 --network ${BOSH_ENV}-network --source-ranges=0.0.0.0/0 --target-tags="concourse-web"

echo "Add Concourse Web Server to your DNS"

brew install caskroom/cask/fly