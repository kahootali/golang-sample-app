echo "adding helm repo"
helm repo add tg https://tarabutgateway.github.io/application-helm/
helm repo update
echo "Image Tag: ${IMAGE_TAG}"
helm upgrade --install --create-namespace -f deploy/helm-values/dev.yaml --set deployment.image.tag="${IMAGE_TAG}" -n dev golang-app-dev tg/application-helm --post-renderer=${CHKK_INSTALL_PATH}/chkk-post-renderer
