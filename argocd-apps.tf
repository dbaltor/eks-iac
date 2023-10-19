
# kustomize
# kubectl apply -f argocd/examples/app-staging.yaml
resource "kubectl_manifest" "my_app_staging" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: my-app-staging
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: https://github.com/dbaltor/argocd-test.git
        targetRevision: master
        path: environments/staging/my-app
      destination:
        server: https://kubernetes.default.svc
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
          allowEmpty: false
        syncOptions:
          - Validate=true
          - CreateNamespace=false
          - PrunePropagationPolicy=foreground
          - PruneLast=true
  YAML

  depends_on = [helm_release.argocd]
}

# kustomize
# kubectl apply -f argocd/examples/app-prod.yaml
resource "kubectl_manifest" "my_app_prod" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: my-app-prod
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: https://github.com/dbaltor/argocd-test.git
        targetRevision: master
        path: environments/prod/my-app
      destination:
        server: https://kubernetes.default.svc
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
          allowEmpty: false
        syncOptions:
          - Validate=true
          - CreateNamespace=false
          - PrunePropagationPolicy=foreground
          - PruneLast=true
  YAML

  depends_on = [helm_release.argocd]
}

# helm chart
# kubectl apply -f argocd/examples/helm-application.yaml
resource "kubectl_manifest" "nginx_helm" {
  yaml_body = <<-YAML
    ---
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: nginx
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: https://charts.bitnami.com/bitnami
        targetRevision: 15.3.4
        chart: nginx
        helm:
          version: v3
          releaseName: my-ningx
          passCredentials: false
          parameters:
            - name: "image.tag"
              value: 1.25.2
          values: |
            defaultArgs:
            - --cert-dir=/tmp
            - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
            - --kubelet-use-node-status-port
            - --metric-resolution=15s
            - --kubelet-insecure-tls
      destination:
        server: https://kubernetes.default.svc
        namespace: nginx
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
          allowEmpty: false
        syncOptions:
          - Validate=true
          - CreateNamespace=true
          - PrunePropagationPolicy=foreground
          - PruneLast=true
  YAML

  depends_on = [helm_release.argocd]
}

## app of apps pattern
# kubectl apply -f argocd/examples/application.yaml
resource "kubectl_manifest" "apps_dev" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
        name: apps-dev
        namespace: argocd
        finalizers:
            - resources-finalizer.argocd.argoproj.io
    spec:
        project: default
        source:
            repoURL: https://github.com/dbaltor/argocd-test.git
            targetRevision: HEAD
            path: environments/dev/apps
        destination:
            server: https://kubernetes.default.svc
        syncPolicy:
            automated:
                prune: true
                selfHeal: true
                allowEmpty: false
            syncOptions:
                - Validate=true
                - CreateNamespace=false
                - PrunePropagationPolicy=foreground
                - PruneLast=true
  YAML

  depends_on = [helm_release.argocd]
}

## app of apps pattern with kustomize - staging
resource "kubectl_manifest" "apps_staging" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
        name: apps-staging
        namespace: argocd
        finalizers:
            - resources-finalizer.argocd.argoproj.io
    spec:
        project: default
        source:
            repoURL: https://github.com/dbaltor/argocd-test.git
            targetRevision: master
            path: environments/staging/apps
        destination:
            server: https://kubernetes.default.svc
        syncPolicy:
            automated:
                prune: true
                selfHeal: true
                allowEmpty: false
            syncOptions:
                - Validate=true
                - CreateNamespace=false
                - PrunePropagationPolicy=foreground
                - PruneLast=true
  YAML

  depends_on = [helm_release.argocd]
}

## app of apps pattern with kustomize - prod
resource "kubectl_manifest" "apps_prod" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
        name: apps-prod
        namespace: argocd
        finalizers:
            - resources-finalizer.argocd.argoproj.io
    spec:
        project: default
        source:
            repoURL: https://github.com/dbaltor/argocd-test.git
            targetRevision: master
            path: environments/prod/apps
        destination:
            server: https://kubernetes.default.svc
        syncPolicy:
            automated:
                prune: true
                selfHeal: true
                allowEmpty: false
            syncOptions:
                - Validate=true
                - CreateNamespace=false
                - PrunePropagationPolicy=foreground
                - PruneLast=true
  YAML

  depends_on = [helm_release.argocd]
}