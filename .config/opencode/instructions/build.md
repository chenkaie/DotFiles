# Build, Deploy, and Run Workflow

- `camera-build` repo (git@gitlab.com:company/camera/camera-build.git) is a Yocto build system for the camera-soc-yocto repo (git@gitlab.com:company/camera/camera-soc-yocto.git).
- You need to run every build command inside docker contianer which can be done by `./docker_shell.py exec -- bash -c "<command>"`

## Target Device (DUT)
- Default DUT IP: `192.168.10.99`
- User: `root`
- SSH command: `ssh root@192.168.10.99 "<command>"`

## Camera Types
Supported camera types: `bagheera`, `bison`, `hyrax`, `hornet`, `hummingbird`, `bumblebee`, `coati`, `cashewnut`, `hazelnut`, `strawberry`

## Full Build Commands

### ARM Build (for device)
```bash
./docker_shell.py exec -- bash -c "./build_arm.sh <camera_type> [revX] [skip-camera-apps] [cooper-sdk]"
# Example:
./docker_shell.py exec -- bash -c "./build_arm.sh bumblebee"
./docker_shell.py exec -- bash -c "./build_arm.sh bumblebee cooper-sdk"
```

### x86 Build (for host testing)
```bash
./docker_shell.py exec -- bash -c ""./build_x86.sh"
```

## Incremental Build (Single Binary/Module)

### Yocto Recipe Build with bitbake
```bash
# Use the bitbake wrapper
./docker_shell.py exec -- bash -c "source /build/subprojects/camera-soc-yocto/cooper_linux_sdk/ambarella/build/poky/oe-init-build-env /build/build-yocto-arm/; bitbake -h"

```

### C++ Apps (after initial build_arm.sh)
```bash
# Source the toolchain first
./docker_shell.py exec -- bash -c "source /build/build-yocto-arm/images/environment-setup-* /build/build-yocto-arm/"

# Build specific target
cd /buil/build-arm
ninja <target_name>

# Common targets:
ninja framework_app
ninja health_monitor
ninja mqtt_bridge
ninja deploy-service
ninja network_manager_agent
```

### Rust Crates
```bash
# Use the cargo wrapper script
./docker_shell.py exec -- bash -c "./scripts/cargo-aarch64.sh build --release -p <crate_name>"

# Example:
./docker_shell.py exec -- bash -c "./scripts/cargo-aarch64.sh build --release -p mqtt_bridge"
./docker_shell.py exec -- bash -c "./scripts/cargo-aarch64.sh build --release -p deploy-service"
./docker_shell.py exec -- bash -c "./scripts/cargo-aarch64.sh build --release -p registration_service"
```

## Deploy Binary to Device

### Deploy single binary
```bash
scp <binary_path> root@192.168.10.99:/usr/bin/
scp <library_path> root@192.168.10.99:/usr/lib/
```

### Deploy all apps (using helper script)
```bash
./scripts/deploy_apps.sh 192.168.10.99
```

### Common deploy examples
```bash
# Framework app
scp build-arm/src/camera-apps/framework_app/framework_app root@192.168.10.99:/usr/bin/

# Rust services (after cargo build)
scp target/aarch64-unknown-linux-gnu/release/mqtt_bridge root@192.168.10.99:/usr/bin/
scp target/aarch64-unknown-linux-gnu/release/deploy-service root@192.168.10.99:/usr/bin/
scp target/aarch64-unknown-linux-gnu/release/health_monitor root@192.168.10.99:/usr/bin/

# Libraries
scp build-arm/src/camera-apps/utility_lib/libutility_lib.so root@192.168.10.99:/usr/lib/
```

## Run on Device via SSH

### Run a binary directly
```bash
ssh root@192.168.10.99 "/usr/bin/<binary_name>"
ssh root@192.168.10.99 "/tmp/<binary_name>"  # if deployed to /tmp
```

### Restart a service
```bash
ssh root@192.168.10.99 "systemctl restart <service_name>"

# Common services:
ssh root@192.168.10.99 "systemctl restart framework_app"
ssh root@192.168.10.99 "systemctl restart mqtt_bridge"
ssh root@192.168.10.99 "systemctl restart health_monitor"
ssh root@192.168.10.99 "systemctl restart deploy-service"
```

### Check service status
```bash
ssh root@192.168.10.99 "systemctl status <service_name>"
ssh root@192.168.10.99 "journalctl -u <service_name> -f"  # follow logs
```

## Quick Workflow: Build -> Deploy -> Run

### Example: Rebuild and deploy framework_app
```bash
# 1. Build
source /build/build-yocto-arm/tmp/environment-setup-aarch64-poky-linux
cd build-arm && ninja framework_app && cd ..

# 2. Deploy
scp build-arm/src/camera-apps/framework_app/framework_app root@192.168.10.99:/usr/bin/

# 3. Restart
ssh root@192.168.10.99 "systemctl restart framework_app"
```

### Example: Rebuild and deploy a Rust service
```bash
# 1. Build
./scripts/cargo-aarch64.sh build --release -p mqtt_bridge

# 2. Deploy
scp target/aarch64-unknown-linux-gnu/release/mqtt_bridge root@192.168.10.99:/usr/bin/

# 3. Restart
ssh root@192.168.10.99 "systemctl restart mqtt_bridge"
```

## Device Debugging Commands

### System info
```bash
ssh root@192.168.10.99 "top -b -n 1 | head -40"
ssh root@192.168.10.99 "free -h"
ssh root@192.168.10.99 "df -h"
ssh root@192.168.10.99 "cat /etc/os-release"
```

### Process management
```bash
ssh root@192.168.10.99 "ps aux | grep <process_name>"
ssh root@192.168.10.99 "killall <process_name>"
```

### Logs
```bash
ssh root@192.168.10.99 "journalctl -f"                    # all logs
ssh root@192.168.10.99 "journalctl -u <service> -n 100"   # last 100 lines
ssh root@192.168.10.99 "dmesg | tail -50"                 # kernel logs
```

## Build Output Locations

| Type | Location |
|------|----------|
| ARM C++ binaries | `build-arm/src/camera-apps/<app_name>/` |
| ARM Rust binaries | `target/aarch64-unknown-linux-gnu/release/` |
| x86 binaries | `build-x86/` |
| Firmware images | `build-arm/firmware/` |

## Key Source Directories

| Directory | Description |
|-----------|-------------|
| `src/camera-apps/` | C++ camera applications and plugins |
| `src/crates/` | Rust crates and services |
| `src/mqtt-connect/` | MQTT connection library |
| `scripts/` | Build and deployment scripts |
| `yocto/` | Yocto build configuration |
