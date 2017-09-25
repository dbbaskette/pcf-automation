
source ../enviromentSetup.sh

PCF_PIPELINES="https://network.pivotal.io/api/v2/products/pcf-automation/releases/6838/product_files/29011/download"

gcloud iam service-accounts create ${SERVICE_ACT}
gcloud iam service-accounts keys create --iam-account="${SERVICE_ACT}@${PROJECT_ID}.iam.gserviceaccount.com" "${SERVICE_ACT}.key.json"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SERVICE_ACT}@${PROJECT_ID}.iam.gserviceaccount.com" --role='roles/editor'
tr -d '\n' < $SERVICE_ACT.key.json > $SERVICE_ACT.1LINE.key.json
export SERVICE_ACT_KEY=$(<$SERVICE_ACT.1LINE.key.json)

gsutil mb gs://${BUCKET_NAME}
gcloud auth activate-service-account --key-file ${SERVICE_ACT}.key.json
gsutil versioning set on gs://${BUCKET_NAME}

../concourse/pcf-stuff/pivnet download $PCF_PIPELINES
tar xfz pcf-pipelines*.tgz



envsubst < params-template.yml > params.yml
cp -f params.yml ./pcf-pipelines/install-pcf/gcp

cd ./pcf-pipelines/install-pcf/gcp
fly -t concourse login -c http://${CONCOURSE_IP}:8080 -u admin -p p1v0tal 
fly -t concourse set-pipeline -p deploy-pcf -c pipeline.yml -l params.yml -n
fly -t concourse unpause-pipeline --pipeline deploy-pcf
fly -t concourse trigger-job --job deploy-pcf/bootstrap-terraform-state --watch
fly -t concourse trigger-job --job deploy-pcf/create-infrastructure --watch




