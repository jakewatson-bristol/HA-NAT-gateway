# Conntrackd NAT Gateway Example

This project demonstrates how to set up redundant NAT gateways using [conntrackd](https://manpages.debian.org/testing/conntrackd/conntrackd.8.en.html) and [keepalived](https://keepalived.org/) for stateful failover of network connections. It uses Vagrant and Docker to create a test environment with two NAT gateways and two client machines on separate networks.

## Project Structure

- **natgateway/**: Contains configuration files and scripts for NAT gateway containers.
- **Dockerfile.client**: Dockerfile for client containers.
- **Vagrantfile**: Defines the topology and provisioning for the test environment.
- **.vagrant/**: Vagrant state directory.

## Topology

- **nat1**: NAT gateway on `net1` (172.23.0.10) and `net2` (172.24.0.10)
- **nat2**: Redundant NAT gateway on `net1` (172.23.0.11) and `net2` (172.24.0.11)
- **client1**: Host on `net1` (172.23.0.20)
- **client2**: Host on `net2` (172.24.0.20)

### Network Diagram
```mermaid
flowchart LR
c1[Client 1] -->|172.23.0.100| virtual_gateway
virtual_gateway -->|SNAT 172.24.0.100| c2[Client 2]
    subgraph virtual_gateway[Virtual Gateway]
        nat1[nat1 Primary]
        nat2[nat2 Backup]
        nat1 <-->|conntrackd sync| nat2
        nat1 <-->|Keepalived| nat2
    end
    subgraph net1[Network 1 172.23.0.0/16]
        c1
    end
    subgraph net2[Network 2 172.24.0.0/16]
        c2
    end
```

## Features

- **Stateful NAT failover**: conntrackd synchronizes connection tracking state between gateways.
- **VRRP failover**: keepalived manages VIPs and failover between gateways.
- **Health checks and notifications**: Scripts handle state transitions and log events.

## Usage

### Prerequisites

- [Vagrant](https://www.vagrantup.com/) (with Docker provider)
- [Docker](https://www.docker.com/)

### Start the Example

1. **Clone the repository** and enter the directory:
    ```sh
    git clone <repo-url>
    cd conntracd-test
    ```

2. **Start the environment**:
    ```sh
    # create the 2 docker networks
    docker network create --subnet=172.23.0.0/16 net1
    docker network create --subnet=172.24.0.0/16 net2
    vagrant up --parallel
    ```

3. **Check status**:
    ```sh
    vagrant status
    vagrant docker-logs
    ```

4. **Access containers**:
    ```sh
    docker exec -it $(docker ps -q -f name=nat1) /bin/bash
    docker exec -it $(docker ps -q -f name=nat2) /bin/bash
    docker exec -it $(docker ps -q -f name=client1) /bin/bash
    docker exec -it $(docker ps -q -f name=client2) /bin/bash
    ```

### Testing Failover

- Simulate failover by stopping `nat1` or `nat2` and observe VIP migration and state sync.
- Use `ping`, `tcpdump`, or other tools inside clients to test connectivity.

#### SSH Connectivity Test

This test demonstrates that `client1` can connect to `client2` via the NAT gateway and maintain the SSH session even if the primary NAT gateway fails.

1. **Prepare SSH Access on `client2`:**
    ```sh
    docker exec -it $(docker ps -q -f name=client2) passwd test
    # The 'test' user is created in Dockerfile.client
    ```

2. **Configure Routing:**
    ```sh
    # On client1, route traffic to net2 via the NAT gateway
    docker exec -it $(docker ps -q -f name=client1) ip route add 172.24.0.0/16 via 172.23.0.100

    # On client2, route traffic to net1 via the NAT gateway
    docker exec -it $(docker ps -q -f name=client2) ip route add 172.23.0.0/16 via 172.24.0.100
    ```

3. **Monitor SSH Traffic on `nat2`:**
    ```sh
    # Run in a separate terminal to observe failover
    docker exec -it $(docker ps -q -f name=nat2) tcpdump -i any host 172.24.0.20 and port 22
    ```

4. **Establish SSH Connection:**
    ```sh
    docker exec -it $(docker ps -q -f name=client1) ssh test@172.24.0.20
    # keep printing the date to keep the session alive and track failover
    # This will show that the session remains active even if nat1 goes down
    /bin/bash -c 'while true; do clear && echo $SSH_CONNECTION && for i in {1..10}; do date && sleep 1; done; done'
    ```

5. **Simulate Failover:**
    ```sh
    # Stop nat1 to trigger failover
    docker stop $(docker ps -q -f name=nat1)
    # The SSH session should remain active, now routed through nat2
    ```

6. **Restore Primary NAT Gateway:**
    ```sh
    docker start $(docker ps -a -q -f name=nat1)
    # SSH traffic should switch back to nat1; session remains active
    ```

7. **Optional: Test Further Failover**
    ```sh
    # Stop nat2 to confirm SSH session persists through nat1
    docker stop $(docker ps -q -f name=nat2)
    ```

**Tip:** Use `tcpdump` to observe traffic flow and verify seamless failover between gateways.
### Cleanup

```sh
vagrant destroy --parallel
```