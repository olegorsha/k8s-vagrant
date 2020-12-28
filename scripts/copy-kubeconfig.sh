#/bin/bash

vagrant ssh master -c 'sudo cat /root/.kube/config' >  ~/.kube/k8s-vagrant
