#!/usr/bin/env bash

__main() {
  find /host/run -maxdepth 1 -name docker.sock -exec ln -sf {} /var/run/docker.sock \;
  ln -sf /apps/data/workspace/w.code-workspace /root/w.code-workspace

}

__main
