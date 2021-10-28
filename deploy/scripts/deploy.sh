echo "Github Workspace: $GITHUB_WORKSPACE"
echo "ls in chkk path"
ls ${CHKK_INSTALL_PATH}
echo "ls finish"
echo "adding helm repo"
helm repo add tg https://tarabutgateway.github.io/application-helm/
helm repo update
echo "ls in chkk path"
ls ${CHKK_INSTALL_PATH}
echo "ls finish"
helm upgrade --install --create-namespace -f deploy/helm-values/dev.yaml --set deployment.image.tag="${IMAGE_TAG}" -n dev golang-app-dev tg/application-helm --post-renderer=$GITHUB_WORKSPACE/bin/chkk-post-renderer
