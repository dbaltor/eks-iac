locals {
  prometheus_datasource = "prometheus-datasource"
}


##################################################
# Grafana datasources
##################################################
resource "kubernetes_config_map" "prometheus_datasource" {
  metadata {
    name      = "prometheus-datasource"
    namespace = var.monitoring_namespace

    labels = {
      grafana_datasource = 1
    }
  }

  data = {
    "prometheus-datasource.yaml" = templatefile("${path.root}/monitoring/prometheus-datasource.yaml", {
    region = var.region,
    workspace_query_url = aws_prometheus_workspace.prometheus_eks.prometheus_endpoint,
    prometheus_datasource = local.prometheus_datasource
    })
  }

  depends_on = [ module.eks_blueprints_addons ]
}

##################################################
# Grafana dashboards
##################################################
resource "kubernetes_config_map" "node_exporter_dashboard" {
  metadata {
    name      = "node-exporter-dashboard"
    namespace = var.monitoring_namespace

    labels = {
      grafana_dashboard = 1
    }
  }

  data = {
    "node-exporter-dashboard.json" = file("${path.root}/monitoring/dashboards/node-exporter.json")
  }

  depends_on = [ module.eks_blueprints_addons ]
}

resource "kubernetes_config_map" "kubernetes_overview_dashboard" {
  metadata {
    name      = "kubernetes-overview-dashboard"
    namespace = var.monitoring_namespace

    labels = {
      grafana_dashboard = 1
    }
  }

  data = {
    "kubernetes-overview-dashboard.json" = templatefile("${path.root}/monitoring/dashboards/kubernetes-overview.json", {
      DS_SYSTEM-PROMETHEUS = local.prometheus_datasource
    })
  }

  depends_on = [ module.eks_blueprints_addons ]
}

resource "kubernetes_config_map" "cadvisor_dashboard" {
  metadata {
    name      = "cadvisor-dashboard"
    namespace = var.monitoring_namespace

    labels = {
      grafana_dashboard = 1
    }
  }

  data = {
    "cadvisor-dashboard.json" = templatefile("${path.root}/monitoring/dashboards/cadvisor.json", {
      DS_PROMETHEUS = local.prometheus_datasource
    })
  }
  
  depends_on = [ module.eks_blueprints_addons ]
}
