#!/bin/sh

GREEN='\e[0;32m'
RESET='\e[0;0m'

echo -e "${GREEN}\n##########################  MINIKUBE STOP  #########################\n${RESET}"

minikube stop
minikube delete

echo -e "${GREEN}\n##########################  MINIKUBE START #########################\n${RESET}"

minikube start --driver=docker
minikube addons enable dashboard

echo -e "${GREEN}\n##########################  METALLB SETUP  #########################\n${RESET}"

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
kubectl get secret -n metallb-system memberlist
if [ $? != 0 ]
then
    kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
fi

echo -e "${GREEN}\n########################  EXTERNAL IP SETUP #########################\n${RESET}"

export EXTERNAL_IP=`minikube ip`

envsubst '$EXTERNAL_IP' < srcs/yaml/configmaps/metallb_configmap.yaml           > srcs/yaml/metallb_configmap.yaml
envsubst '$EXTERNAL_IP' < srcs/yaml/configmaps/wp_db_configmap.yaml             > srcs/yaml/wp_db_configmap.yaml

envsubst '$EXTERNAL_IP' < srcs/yaml/services_and_deployments/mysql.yaml         > srcs/yaml/mysql.yaml
envsubst '$EXTERNAL_IP' < srcs/yaml/services_and_deployments/wordpress.yaml     > srcs/yaml/wordpress.yaml
envsubst '$EXTERNAL_IP' < srcs/yaml/services_and_deployments/phpmyadmin.yaml    > srcs/yaml/phpmyadmin.yaml
envsubst '$EXTERNAL_IP' < srcs/yaml/services_and_deployments/nginx.yaml         > srcs/yaml/nginx.yaml
envsubst '$EXTERNAL_IP' < srcs/yaml/services_and_deployments/ftps.yaml          > srcs/yaml/ftps.yaml
envsubst '$EXTERNAL_IP' < srcs/yaml/services_and_deployments/grafana.yaml       > srcs/yaml/grafana.yaml
envsubst '$EXTERNAL_IP' < srcs/yaml/services_and_deployments/influxdb.yaml      > srcs/yaml/influxdb.yaml

echo -e "${GREEN}\n######################  SECRETS/CONFIGMAP APPLY #########################\n${RESET}"

kubectl apply -f srcs/yaml/secrets

kubectl apply -f srcs/yaml/metallb_configmap.yaml
kubectl apply -f srcs/yaml/wp_db_configmap.yaml


chmod +x srcs/*/srcs/*.sh

echo -e "${GREEN}\n##########################  BUILDING IMAGES #########################\n${RESET}"

eval $(minikube docker-env)
docker build -t my_mysql        srcs/mysql      --network=host
docker build -t my_wordpress    srcs/wordpress  --network=host
docker build -t my_phpmyadmin   srcs/phpmyadmin --network=host
docker build -t my_nginx        srcs/nginx      --network=host
docker build -t my_ftps         srcs/ftps       --network=host
docker build -t my_grafana      srcs/grafana    --network=host
docker build -t my_influxdb     srcs/influxdb   --network=host

echo -e "${GREEN}\n############################  YAML APPLY #########################\n${RESET}"

kubectl apply -f srcs/yaml/mysql.yaml
kubectl apply -f srcs/yaml/wordpress.yaml
kubectl apply -f srcs/yaml/phpmyadmin.yaml
kubectl apply -f srcs/yaml/nginx.yaml
kubectl apply -f srcs/yaml/ftps.yaml
kubectl apply -f srcs/yaml/grafana.yaml
kubectl apply -f srcs/yaml/influxdb.yaml

kubectl get all

minikube dashboard &