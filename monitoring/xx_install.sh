# #!/bin/bash

# set -eux
# BASEDIR=$(dirname $0)
# echo $BASEDIR
# HOME_DIR=$PWD

# # Export vars for HELM repo and charts
# set -a
# source $BASEDIR/.env
# set +a

# GRAFANA_RELEASE_NAME=grafana-test
# PROMETHEUS_RELEASE_NAME=prometheus

# # Add grafana
# helm repo add grafana \
#     https://grafana.github.io/helm-charts

# # Install Grafana
# helm install $GRAFANA_RELEASE_NAME \
#     grafana/grafana \
#     --create-namespace \
#     -f $BASEDIR/grafana-values.yaml \
#     -n grafana || true

# ## Prometheus
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
# helm repo update

# helm install $PROMETHEUS_RELEASE_NAME \
#     prometheus-community/prometheus \
#     --create-namespace \
#     -n prometheus-namespace \
#     -f $BASEDIR/prometheus-values.yaml || true

# # Get password
# kubectl get secret \
#     --namespace $APP_NAMESPACE $GRAFANA_RELEASE_NAME \
#     -o jsonpath="{.data.admin-password}" |
#     base64 --decode
# echo

# #    Get the Grafana URL to visit by running these commands in the same shell:
# export GRAFANA_POD_NAME=$(kubectl get pods --namespace grafana -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana-test" -o jsonpath="{.items[0].metadata.name}")
# # kubectl --namespace grafana port-forward $GRAFANA_POD_NAME 3000 &

# # Get the Prometheus server URL by running these commands in the same shell:
# export PROMETHEUS_POD_NAME=$(kubectl get pods --namespace prometheus-namespace -l "app.kubernetes.io/component=server" -o jsonpath="{.items[0].metadata.name}")
# # kubectl --namespace prometheus-namespace port-forward $PROMETHEUS_POD_NAME 9090 &

# # # Get the Alertmanager URL by running these commands in the same shell:
# #   export POD_NAME=$(kubectl get pods --namespace prometheus-namespace -l "app=prometheus,component=" -o jsonpath="{.items[0].metadata.name}")
# #   kubectl --namespace prometheus-namespace port-forward $POD_NAME 9093
