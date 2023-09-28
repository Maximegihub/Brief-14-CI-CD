    # Providers utilisés pour Proxmox => Telmate

terraform {
    required_providers {
        proxmox = {
            source  = "Telmate/proxmox"
            version = "2.9.14"
        }
    }
}

    # Informations de connexion Provider utilisées pour la connexion à Proxmox

provider "proxmox" {
    pm_api_url         = "http://192.168.50.50:8006/api2/json"
    pm_api_token_id    = "Maxime@pve!Proxmox"
    pm_api_token_secret = "2f49ec4f-bcc2-4eda-a029-577eb30f0bb4"
    #pm_tls_insecure = true  
}

    # Déclaration des noms des machines virtuelles
variable "vm_names" {
    type    = list(string)
    default = ["SRV-MINIKUBE"]
}

    # Clonage d'une template et déploiement des machines virtuelles
resource "proxmox_vm_qemu" "vms" {
    count = length(var.vm_names)
    name        = var.vm_names[count.index]
    target_node = "pve"
    clone       = "TEMPLATE-DEB11"
    full_clone  = true

    # Autres paramètres de configuration de la VM...

    boot    = "order=sata0"
    scsihw  = "virtio-scsi-single"
    memory  = "8192"
    cores   = 2
    network {
        model  = "virtio"
        bridge = "vmbr0"
    }
}

    # Provisionnement de la ressource par la connexion ssh

resource "null_resource" "ssh_target" {
    depends_on = [proxmox_vm_qemu.vms]
    connection {
        
        
        type        = "ssh"
        user        = "root"
        host        = "192.168.50.68"
        private_key = file("C:/Users/Maxime/.ssh/id_rsa")
        
      
    }

    provisioner "remote-exec" {
        inline = [
            #"hostnamectl set-hostname SRV-MINIKUBE",
            #"sudo apt-get install ca-certificate curl gnupg lsb-release",
            #"apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release -y",
            #"curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            #"sudo apt-get update",
            #"sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            #"sudo echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            #"apt install -y docker-ce docker-ce-cli containerd.io docker-compose -y",

            # Mise à jour du dépôt 
            "sudo apt-get update",
            "sudo apt-get upgrade -y",

            #Installation de docker
            "curl -fsSL https://get.docker.com -o get-docker.sh",
            "sudo sh get-docker.sh",
            "groupadd docker",
            "usermod -aG docker $USER",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",
            "sudo docker pull hello-world",
            "sudo docker run hello-world",

            # Installation de git
            "apt-get install git -y",
            "mkdir yaml",

            # Installation de minukube
            "curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/",
            "sudo chmod +x minikube",
            "sudo mv minikube /usr/local/bin/",
            "minikube start --driver=docker --force",

             # Installation de kubectl (outil de ligne de commande Kubernetes)
            "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
            "chmod +x kubectl",
            "sudo mv kubectl /usr/local/bin/",

            # Création d'un réseau Docker personnalisé
            "docker network create --subnet=192.168.50.0/24 custom-net",

            # Création d'un conteneur GitLab avec une adresse IP statique
            "docker run --name gitlab-container -d --net custom-net --ip 192.168.50.110 gitlab/gitlab-ce",
        
            # Déploiement de PrestaShop avec kubectl
            "kubectl create deployment prestashop --image=prestashop/prestashop",
            "kubectl scale deployment prestashop --replicas=2",


            # Attente jusqu'à ce que le pod PrestaShop soit en cours d'exécution
            "while [[ $(kubectl get pods -l app=prestashop -o jsonpath='{.items[0].status.phase}') != 'Running' ]]; do",
            "  sleep 5",
            "done",
            "kubectl expose deployment prestashop --type=NodePort --port=80",
        
            # Exposer PrestaShop via Minikube
            "kubectl port-forward service/prestashop 8080:80",

            # Déploiement de gitlab avec kubectl
            #"kubectl create deployment gitlab --image=gitlab/gitlab-ce",
            #"kubectl scale deployment prestashop --replicas=2",

             # Exposer Gitlab via Minikube
            #"kubectl port-forward service/gitlab 8080:83",
      
        ]
    }
}

