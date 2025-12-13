# Create Kubernetes namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    
    labels = {
      name        = var.namespace
      environment = var.environment
    }
  }
}

# Create StorageClass for EBS volumes
resource "kubernetes_storage_class" "prometheus_ebs" {
  metadata {
    name = var.storage_class_name
  }

  storage_provisioner = "kubernetes.io/aws-ebs"
  
  parameters = {
    type = "gp3"
    encrypted = "true"
  }

  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

  depends_on = [kubernetes_namespace.monitoring]
}

# Create PersistentVolumeClaim for Prometheus server
resource "kubernetes_persistent_volume_claim" "prometheus_server" {
  metadata {
    name      = "prometheus-server"
    namespace = var.namespace
    
    labels = {
      app       = "prometheus"
      component = "server"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = "${var.storage_size_gb}Gi"
      }
    }

    storage_class_name = var.storage_class_name
  }

  depends_on = [kubernetes_storage_class.prometheus_ebs]
}

# Create PersistentVolumeClaim for Prometheus alertmanager
resource "kubernetes_persistent_volume_claim" "prometheus_alertmanager" {
  metadata {
    name      = "prometheus-alertmanager"
    namespace = var.namespace
    
    labels = {
      app       = "prometheus"
      component = "alertmanager"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = "5Gi"
      }
    }

    storage_class_name = var.storage_class_name
  }

  depends_on = [kubernetes_storage_class.prometheus_ebs]
}
