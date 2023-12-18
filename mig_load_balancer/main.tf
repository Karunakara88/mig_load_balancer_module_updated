

resource "google_compute_network" "vpc_network_karunakara" {
  project                 = var.project_id
  name                    = "vpc-network-karunakara"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet_karunakara" {
  name          = "subnetwork-karunakara"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network_karunakara.id
}

/* resource "google_service_account" "karunakara-sa" {
  project      = var.project_id 
  account_id   = "karunakara-sa"
  display_name = "karunakara-sa"
}
*/



resource"google_compute_instance_template" "instance_template_karna" {
  name         = "my-template-karna"
  machine_type = "e2-micro"
  tags         = ["allow-ssh"]

  disk {
    source_image = var.image_id
    }
    

  network_interface {
    network    = google_compute_network.vpc_network_karunakara.id
    subnetwork = google_compute_subnetwork.subnet_karunakara.id
    
   access_config {}

  }


  metadata_startup_script = "sudo apt update; yes Y | sudo apt install apache2"

   
   service_account {
    
    email = "karna-sa@prj-sandbox-infra-01.iam.gserviceaccount.com"

    scopes = [ "https://www.googleapis.com/auth/compute",
               "https://www.googleapis.com/auth/cloud-platform",
               "https://www.googleapis.com/auth/userinfo.email"]

    
  } 
  
} 

resource "google_compute_region_instance_group_manager" "mig-karna" {
  name     = "l7-ilb-mig1-karna"
  region   = var.region

  version {
    instance_template = google_compute_instance_template.instance_template_karna.id
    name              = "primary-karna"
  }

  base_instance_name = "vm-karna"
  target_size        = 2
  
   named_port {
    name = "http"
    port = "80"
  }

}


resource "google_compute_firewall" "instance_firewall" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network_karunakara.id
  target_tags   = ["allow-ssh"]
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "443"]
  }

  source_ranges = ["0.0.0.0/0"] 
}

resource "google_compute_http_health_check" "example_health_check" {
  name               = "example-health-check"
  request_path       = "/"
  check_interval_sec = 5
}

resource "google_compute_backend_service" "example_backend_service" {
  name             = "example-backend-service"
  backend {
    group =  google_compute_region_instance_group_manager.mig-karna.instance_group  // Replace with your instance group URL
  }
  port_name   = "http"
  health_checks = [google_compute_http_health_check.example_health_check.id]
} 


resource "google_compute_url_map" "example_url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.example_backend_service.self_link
}

resource "google_compute_target_http_proxy" "example_http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.example_url_map.self_link
}


resource "google_compute_global_forwarding_rule" "example_forwarding_rule" {
  name       = "forwarding-rule"
  target     = google_compute_target_http_proxy.example_http_proxy.id
  ip_protocol = "tcp"
  port_range = "80"
} 













/*
# URL Map
resource "google_compute_url_map" "example_url_map" {
  name            = "my-url-map"
  default_url_redirect {
    https_redirect = true
  }

  //default_service = google_compute_instance.karunakara_vm.self_link
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "example_http_proxy" {
  name    = "my-http-proxy"
  url_map = google_compute_url_map.example_url_map.self_link
}

# Forwarding Rule
resource "google_compute_global_forwarding_rule" "example_forwarding_rule" {
  name       = "my-forwarding-rule"
  target     = google_compute_target_http_proxy.example_http_proxy.self_link
  port_range = "80"
}
*/

/*
resource "google_compute_forwarding_rule" "default" {
  // provider              = google-beta
  name                  = "website-forwarding-rule"
  region                = var.region
  port_range            = 80
  backend_service       = google_compute_region_backend_service.backend.id
}
resource "google_compute_region_backend_service" "backend" {
  // provider              = google-beta
  name                  = "website-backend"
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.hc.id]
}
resource "google_compute_region_health_check" "hc" {
  // provider           = google-beta
  name               = "check-website-backend"
  check_interval_sec = 1
  timeout_sec        = 1
  region             = "us-central1"

  tcp_health_check {
    port = "80"
  }
}
*/
/*
resource "google_compute_backend_service" "example_backend_service" {
  name             = "backend-service"
  backend = google_compute_instance.karunakara_vm.self_link
  // port             = 80
  protocol         = "HTTP"
}
*/

/*
resource "google_compute_url_map" "example_url_map" {
  name            = "url-map"
  default_service = google_compute_instance.karunakara_vm.self_link
}

resource "google_compute_target_http_proxy" "example_http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.example_url_map.self_link
}


resource "google_compute_global_forwarding_rule" "example_forwarding_rule" {
  name       = "forwarding-rule"
  target     = google_compute_instance.karunakara_vm.id
  port_range = "80"
} */


/* resource "google_compute_address" "my_external_ip" {
  name = "my-external-ip"
}

resource "google_compute_forwarding_rule" "my_forwarding_rule" {
  name                  = "my-forwarding-rule"
  region                = var.region
  ip_address            = google_compute_address.my_external_ip.address
  target                = google_compute_instance.karunakara_vm.self_link
  port_range            = 80
  load_balancing_scheme = "EXTERNAL" # Or "INTERNAL" for internal forwarding rules
}
*/

/*resource "google_compute_instance_group" "single_vm_group" {
  name        = "single-vm-instance-group"
  description = "Instance group for a single VM"
  zone        = var.zone # Specify the zone

  instances = [ 
    {
    instance = "karunakara_vm",
    }
  ] # Replace with the name of your 
}
/*
resource "google_compute_http_health_check" "example_health_check" {
  name               = "example-health-check"
  request_path       = "/"
  check_interval_sec = 5
}

// Create a backend service
resource "google_compute_backend_service" "example_backend_service" {
  name             = "example-backend-service"
  backend {
    group = google_compute_instance_group.single_vm_group.self_link // Replace with your instance group URL
  }
  health_checks = [google_compute_http_health_check.example_health_check.self_link]
} */