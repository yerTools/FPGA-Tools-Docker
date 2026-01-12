```bash
podman pull ghcr.io/yertools/fpga-tools-docker:branch-works-on-my-machine && \
    mkdir -p ~/Distrobox/fpga-tools/ && \
    distrobox rm -f fpga-tools && \
    distrobox create \
        --image ghcr.io/yertools/fpga-tools-docker:branch-works-on-my-machine \
        --name fpga-tools \
        --home ~/Distrobox/fpga-tools/ \
        --additional-flags "--privileged" && \
    distrobox enter fpga-tools
```

---

Execute inside the Distrobox Container:

```bash
distrobox-export --app /usr/share/applications/gowin.desktop && \
    distrobox-export --app /usr/share/applications/org.sigrok.PulseView.desktop && \
    distrobox-export --app /usr/share/applications/code.desktop && \
    code --install-extension trag1c.gleam-theme && \
    code --install-extension ms-vscode.cpptools && \
    code --install-extension ms-vscode.hexeditor && \
    code --install-extension mshr-h.veriloghdl && \
    code --install-extension lushay-labs.lushay-code && \
    code --install-extension wavetrace.wavetrace && \
    cp /etc-data/code/settings.json ~/.config/Code/User/settings.json && \
    mkdir -p ~/.fpga-tools-udev-rules && \
    cp /etc/udev/rules.d/* ~/.fpga-tools-udev-rules/ && \
    distrobox-host-exec sudo cp -r ~/.fpga-tools-udev-rules/. /etc/udev/rules.d/ && \
    distrobox-host-exec sudo udevadm control --reload-rules && \
    distrobox-host-exec sudo udevadm trigger
```
