
module "create_an_instance_and_host_webserver_and_apply_load_balancer" {
    source = "../mig_load_balancer"

    project_id = "prj-sandbox-infra-01" 
    region = "us-central1"
    zone = "us-central1-a"
    cidr = "10.2.0.0/16"
    image_id = "debian-cloud/debian-11" 

}