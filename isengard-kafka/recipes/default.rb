# Java version etc is determined and configured via attributes
include_recipe 'java'

# set vm.swapiness to 0 (to lessen swapping)
sysctl_param 'vm.swappiness' do
  value 0
end

# Get Kafka Zookeeper servers
#zk_hosts = get_zk_nodes # get by roles

# get by opsworks layers (http://docs.aws.amazon.com/opsworks/latest/userguide/attributes-json-opsworks-layers.html)
zk_hosts = Array.new
node[:opsworks][:layers]['zookeeper'][:instances].each do |k,v|
  Chef::Log.debug(v)
  Chef::Log.debug(v[:public_dns_name])
  zk_hosts << v[:public_dns_name]
end

# Override Kafka related node attributes
node.override[:kafka][:zookeeper][:connect] = zk_hosts.map{|x| float_host(x[:hostname])}
#node.override[:kafka][:base_url] = get_binary_server_url + "kafka"
#node.override[:kafka][:host_name] = float_host(node[:fqdn])
node.override[:kafka][:advertised_host_name] = node.hostname
#node.override[:kafka][:advertised_port] = 9092
#node.override[:kafka][:jmx_port] = node[:bcpc][:hadoop][:kafka][:jmx][:port]
node.override[:kafka][:automatic_start] = true
node.override[:kafka][:automatic_restart] = true

# Override Zookeeper related node attributes
#node.override[:bcpc][:hadoop][:zookeeper][:servers] = zk_hosts

include_recipe 'kafka'

