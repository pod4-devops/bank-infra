provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service_account_v1" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = var.fluent_bit_namespace
  }
}

resource "kubernetes_cluster_role_v1" "fluent_bit" {
  metadata {
    name = "fluent-bit-read"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "fluent_bit" {
  metadata {
    name = "fluent-bit-read"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.fluent_bit.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.fluent_bit.metadata[0].name
    namespace = var.fluent_bit_namespace
  }
}

resource "kubernetes_config_map_v1" "fluent_bit" {
  metadata {
    name      = "fluent-bit-config"
    namespace = var.fluent_bit_namespace
  }

  data = {
    "fluent-bit.conf" = <<-EOT
      [SERVICE]
          Flush         5
          Log_Level     info
          Daemon        off

      [INPUT]
          Name              tail
          Path              /var/log/containers/*.log
          Parser            docker
          Tag               kube.*
          Refresh_Interval  5
          Mem_Buf_Limit     5MB
          Skip_Long_Lines   On

      [FILTER]
          Name                kubernetes
          Match               kube.*
          Kube_URL            https://kubernetes.default.svc:443
          Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
          Merge_Log           On
          Keep_Log            Off

      [OUTPUT]
          Name                cloudwatch_logs
          Match               *
          region              ${var.aws_region}
          log_group_name      ${var.log_group_name}
          log_stream_prefix   fluentbit-
          auto_create_group   true
    EOT

    "parsers.conf" = <<-EOT
      [PARSER]
          Name        docker
          Format      json
          Time_Key    time
          Time_Format %Y-%m-%dT%H:%M:%S.%L
          Time_Keep   On
    EOT
  }
}

resource "kubernetes_daemon_set_v1" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = var.fluent_bit_namespace
    labels = {
      k8s-app = "fluent-bit"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "fluent-bit"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "fluent-bit"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.fluent_bit.metadata[0].name

        container {
          name  = "fluent-bit"
          image = "fluent/fluent-bit:2.1"

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }

          volume_mount {
            name       = "varlibdockercontainers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }

          volume_mount {
            name       = "fluent-bit-config"
            mount_path = "/fluent-bit/etc/"
          }
        }

        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }

        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        volume {
          name = "fluent-bit-config"
          config_map {
            name = kubernetes_config_map_v1.fluent_bit.metadata[0].name
          }
        }
      }
    }
  }
}
