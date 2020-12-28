BOX_IMAGE = "ubuntu/focal64"
SETUP_MASTER = true
SETUP_NODES = true
NODE_COUNT = 1
MASTER_IP = "192.168.26.10"
NODE_SUBNET = "192.168.26."
POD_NW_CIDR = "10.244.0.0/16"
HOSTNAME = "oam.cluster-01.company.com"

#Generate new using steps in README
KUBETOKEN = "b029ee.968a33e8d8e6bb0d"

$kubeminionscript = <<MINIONSCRIPT

#kubeadm reset
#kubeadm join --token #{KUBETOKEN} #{MASTER_IP}:6443

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null master:~/joincluster.sh .
sudo sh ./joincluster.sh 

MINIONSCRIPT

$kubemasterscript = <<SCRIPT

#kubeadm reset
kubeadm init --apiserver-advertise-address=#{MASTER_IP} --pod-network-cidr=#{POD_NW_CIDR} --token #{KUBETOKEN} --token-ttl 0
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubeadm token create --print-join-command > ./joincluster.sh

SCRIPT

#config.vagrant.plugins = "vagrant-hosts"
system('./generate-key.sh')

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |l|
    l.cpus = 1
    l.memory = "1024"
  end

  config.vm.provision :shell, :path => "scripts/setup-k8s-node.sh"
  config.vm.provision "file", source: ".ssh/id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
  config.vm.provision "file", source: ".ssh/id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
  config.vm.provision :shell, :path => "scripts/copy-ssh-key.sh", privileged: false

  #config.hostmanager.enabled = true
  #config.hostmanager.manage_guest = true
  # config.vm.network "public_network"

  if SETUP_MASTER
    config.vm.define "master" do |node|
      node.vm.hostname = "master"
      node.vm.network :private_network, ip: MASTER_IP
      node.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        vb.customize ["modifyvm", :id, "--memory", "2048"]
      end
      node.vm.provision :hosts do |provisioner|
        provisioner.autoconfigure = true
        provisioner.sync_hosts = true
      end
      node.vm.network "forwarded_port", guest: 6443, host: 6443
#      node.vm.provision "init-cluster", :type => "shell", :path => "scripts/setup-cluster.sh" do |s|
#        s.args = ["#{MASTER_IP}", "#{POD_NW_CIDR}"]
#      end
      node.vm.provision :shell, inline: $kubemasterscript
      node.vm.provision "setup-loadbalancer", :type => "shell", :path => "scripts/setup-metallb.sh" do |s|
        s.args = ["#{NODE_SUBNET}"]
      end
      node.vm.provision "setup-helm", :type => "shell", :path => "scripts/setup-helm.sh"
      node.vm.provision "setup-metrics", :type => "shell", :path => "scripts/setup-metrics.sh"
      node.vm.provision "setup-traefik", :type => "shell", :path => "scripts/setup-traefik.sh" do |s|
        s.args = ["#{HOSTNAME}", "#{NODE_SUBNET}"]
      end
      node.vm.provision "setup-dashboard", :type => "shell", :path => "scripts/setup-dashboard.sh" do |s|
        s.args = ["#{HOSTNAME}"]
      end
    end
  end

  if SETUP_NODES
    (1..NODE_COUNT).each do |i|
      config.vm.define "node#{i}" do |node|
        node.vm.hostname = "node#{i}"
        node.vm.network :private_network, ip: NODE_SUBNET + "#{i + 10}"
        node.vm.provision :hosts do |provisioner|
          provisioner.autoconfigure = true
          provisioner.sync_hosts = true
        end
        node.vm.provision :shell, inline: $kubeminionscript, privileged: false
      end
    end
  end
end

system('scripts/copy-kubeconfig.sh')
