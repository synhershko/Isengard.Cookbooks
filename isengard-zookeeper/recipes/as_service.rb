# download and install base package
include_recipe 'zookeeper::install'

# set config path and render config
include_recipe 'zookeeper::config_render'

# start as a service
include_recipe "runit::default"
include_recipe "zookeeper::service"
