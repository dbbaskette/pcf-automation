

#rm -rf ./bosh-bootloader
#git clone https://github.com/cloudfoundry/bosh-bootloader.git
#cd ./bosh-bootloader/


gcloud iam service-accounts create ${SERVICE_ACT}
gcloud iam service-accounts keys create --iam-account="${SERVICE_ACT}@${PROJECT_ID}.iam.gserviceaccount.com" "${SERVICE_ACT}.key.json"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SERVICE_ACT}@${PROJECT_ID}.iam.gserviceaccount.com" --role='roles/editor'


bbl up --iaas gcp --name concourse-bosh --gcp-service-account-key "${SERVICE_ACT}.key.json" --gcp-project-id ${PROJECT_ID} --gcp-zone us-east1-b --gcp-region us-east1

IP_TEMP=`gcloud compute instances list  --filter="metadata.items.value:concourse-web" --format="value(networkInterfaces.accessConfigs.natIP)" | sed "s/..$//g"`
export CONCOURSE_IP=`echo ${IP_TEMP:3}`
