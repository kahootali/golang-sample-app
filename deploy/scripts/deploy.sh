echo "ls in chkk path"
ls ${CHKK_INSTALL_PATH}
pushd deploy || exit 1
export CHKK_ACCESS_TOKEN=${{ secrets.CHKK_TOKEN }}
echo "adding helm repo"
helm repo add tg https://tarabutgateway.github.io/application-helm/
helm repo update
helm upgrade --install --create-namespace -f helm-values/dev.yaml --set deployment.image.tag="${IMAGE_TAG}" -n dev golang-app-dev tg/application-helm --post-renderer=${CHKK_INSTALL_PATH}/chkk-post-renderer
