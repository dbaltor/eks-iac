# ##########################################
# ## Install Prometheus Operator CRD
# ##########################################

# ## BROKEN - we need to run kubectl create due to the CRDs size
# # resource "kubectl_manifest" "prometheus_operator_crd" {
# #     for_each = fileset(".", "${path.module}/prometheus/manual-install/prometheus-operator-crd/*.yaml")
# #     yaml_body = file(each.value)
# # }

# resource "local_file" "install_operator_crd_sh" {
#     content  = templatefile("${path.module}/prometheus/manual-install/install-operator-crd.sh.tpl", {
#         cluster_name = module.eks.cluster_name,
#         path         = abspath(path.module)
#     })
#     filename = "/tmp/install-operator-crd.sh"

#     depends_on = [module.eks]
# }

# resource "null_resource" "prometheus_operator_crd" {
#     provisioner "local-exec" {
#         command = <<EOF
#         chmod +x install-operator-crd.sh
#         ./install-operator-crd.sh
#         EOF
#         interpreter = ["/bin/bash", "-c"]
#         working_dir = "/tmp"
#     }

#     depends_on = [local_file.install_operator_crd_sh]
# }

# ##########################################
# ## Install Prometheus Operator
# ##########################################
# resource "kubectl_manifest" "prometheus_operator" {
#     for_each = fileset(".", "${path.module}/prometheus/manual-install/prometheus-operator/*.yaml")
#     yaml_body = templatefile(each.value,
#         {prometheus_operator_version = "0.68.0"}
#     )

#     # depends_on = [kubectl_manifest.prometheus_operator_crd]
#     depends_on = [null_resource.prometheus_operator_crd]
# }

# ##########################################
# ## Install Prometheus Agent
# ##########################################
# resource "kubectl_manifest" "prometheus_agent" {
#     for_each = fileset(".", "${path.module}/prometheus/manual-install/prometheus-agent/*.yaml")
#     yaml_body = templatefile(each.value,
#         {
#             prometheus_agent_version      = "2.47.0",
#             prometheus_remote_writer_role = aws_iam_role.prometheus_remote_writer.arn,
#             workspace_uri                 = "${aws_prometheus_workspace.prometheus_eks.prometheus_endpoint}api/v1/remote_write"
#         }
#     )

#     depends_on = [
#         kubectl_manifest.prometheus_operator,
#         aws_iam_role.prometheus_remote_writer,
#         aws_prometheus_workspace.prometheus_eks
#     ]
# }

# ##########################################
# ## Install Node Exporter
# ##########################################
# resource "kubectl_manifest" "node_exporter" {
#     for_each = fileset(".", "${path.module}/prometheus/manual-install/node-exporter/*.yaml")
#     yaml_body = templatefile(each.value,
#         {node_exporter_version = "1.6.1"}
#     )

#     depends_on = [kubectl_manifest.prometheus_agent]
# }

# ##########################################
# ## Install CAdvisor
# ##########################################
# resource "kubectl_manifest" "cadvisor" {
#     for_each = fileset(".", "${path.module}/prometheus/manual-install/cadvisor/*.yaml")
#     yaml_body = templatefile(each.value,
#         {cadvisor_version = "0.47.2"}
#     )

#     depends_on = [kubectl_manifest.node_exporter]
# }

# ##########################################
# ## Install Kube State Metrics
# ##########################################
# resource "kubectl_manifest" "kube_state_metrics" {
#     for_each = fileset(".", "${path.module}/prometheus/manual-install/kube-state-metrics/*.yaml")
#     yaml_body = templatefile(each.value,
#         {kube_state_metrics_version = "2.10.0"}
#     )

#     depends_on = [kubectl_manifest.cadvisor]
# }