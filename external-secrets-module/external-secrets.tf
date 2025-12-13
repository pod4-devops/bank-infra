resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_role.arn
    }
  }
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = kubernetes_namespace.external_secrets.metadata[0].name
  create_namespace = false
  version          = var.external_secrets_operator_version

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.external_secrets.metadata[0].name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets_role.arn
  }

  depends_on = [kubernetes_service_account.external_secrets]
}

resource "time_sleep" "wait_for_operator" {
  depends_on = [helm_release.external_secrets]

  create_duration = "30s"
}

resource "kubernetes_manifest" "secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "aws-secret-store"
      namespace = kubernetes_namespace.external_secrets.metadata[0].name
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = data.aws_region.current.name
          auth = {
            jwt = {
              serviceAccountRef = {
                name = kubernetes_service_account.external_secrets.metadata[0].name
              }
            }
          }
        }
      }
    }
  }

  depends_on = [time_sleep.wait_for_operator]
}

resource "kubernetes_manifest" "external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "bank-app-secrets"
      namespace = kubernetes_namespace.external_secrets.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = kubernetes_manifest.secret_store.manifest.metadata.name
        kind = "SecretStore"
      }
      target = {
        name           = "bank-app-db-credentials"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "username"
          remoteRef = {
            key      = var.secret_name
            property = "username"
          }
        },
        {
          secretKey = "password"
          remoteRef = {
            key      = var.secret_name
            property = "password"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.secret_store]
}

output "external_secret_name" {
  value       = kubernetes_manifest.external_secret.manifest.metadata.name
  description = "Name of the ExternalSecret resource"
}

output "secret_store_name" {
  value       = kubernetes_manifest.secret_store.manifest.metadata.name
  description = "Name of the SecretStore resource"
}

output "kubernetes_namespace" {
  value       = kubernetes_namespace.external_secrets.metadata[0].name
  description = "Kubernetes namespace where External Secrets is deployed"
}