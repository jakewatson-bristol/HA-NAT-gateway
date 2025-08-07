# make two Vagrant boxes to be NAT gateways with conntrackd
Vagrant.configure("2") do |config|
  # nat1: net1 (172.23.0.10), net2 (172.24.0.10)
  config.vm.define "nat1" do |nat1|
    nat1.vm.hostname = "nat1"
    nat1.vm.network "private_network", docker__network_name: "net1", ip: "172.23.0.10"
    nat1.vm.network "private_network", docker__network_name: "net2", ip: "172.24.0.10"
    nat1.vm.provider "docker" do |d|
      d.build_dir = "./natgateway"
      d.dockerfile = "Dockerfile"
      d.has_ssh = false
      d.remains_running = true
      d.create_args = ["--privileged"]
    end
  end

  # nat2: net1 (172.23.0.11), net2 (172.24.0.11)
  config.vm.define "nat2" do |nat2|
    nat2.vm.hostname = "nat2"
    nat2.vm.network "private_network", docker__network_name: "net1", ip: "172.23.0.11"
    nat2.vm.network "private_network", docker__network_name: "net2", ip: "172.24.0.11"
    nat2.vm.provider "docker" do |d|
      d.build_dir = "./natgateway"
      d.dockerfile = "Dockerfile"
      d.has_ssh = false
      d.remains_running = true
      d.create_args = ["--privileged"]
    end
  end

  # client1: net1 (172.23.0.20)
  config.vm.define "client1" do |client1|
    client1.vm.hostname = "client1"
    client1.vm.network "private_network", docker__network_name: "net1", ip: "172.23.0.20"
    client1.vm.provider "docker" do |d|
      d.build_dir = "./"
      d.dockerfile = "Dockerfile.client"
      d.has_ssh = false
      d.remains_running = true
      d.create_args = ["--cap-add=NET_ADMIN"]
    end
  end

  # client2: net2 (172.24.0.20)
  config.vm.define "client2" do |client2|
    client2.vm.hostname = "client2"
    client2.vm.network "private_network", docker__network_name: "net2", ip: "172.24.0.20"
    client2.vm.provider "docker" do |d|
      d.build_dir = "./"
      d.dockerfile = "Dockerfile.client"
      d.has_ssh = false
      d.remains_running = true
      d.create_args = ["--cap-add=NET_ADMIN"]
    end
  end
end