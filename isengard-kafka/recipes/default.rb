# Java version etc is determined and configured via attributes
include_recipe 'java'

# set vm.swapiness to 0 (to lessen swapping)
#sysctl_param 'vm.swappiness' do
#  value 0
#end

# Get Kafka Zookeeper servers
#zk_hosts = get_zk_nodes # get by roles

# get by opsworks layers (http://docs.aws.amazon.com/opsworks/latest/userguide/attributes-json-opsworks-layers.html)
zk_hosts = Array.new
node[:opsworks][:layers]['zookeeper'][:instances].each do |k,v|
  # TODO: filter out :status != 'online'
  Chef::Log.debug(v[:private_ip])
  zk_hosts << v
end

# Override Kafka related node attributes
node.override[:kafka][:zookeeper][:connect] = zk_hosts.map{|x| x[:private_ip]}
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


# install ZK gem so we can then verify the Kafka broker was registered with our ZK ensemble
# For OpsWorks compatibility see https://forums.aws.amazon.com/thread.jspa?threadID=118646
if defined?(OpsWorks) && defined?(OpsWorks::InternalGems)
  OpsWorks::InternalGems.internal_gem_package('zookeeper', :version => '>= 1.4.9')
else
  chef_gem 'zookeeper' do
    action :install
    version '>= 1.4.9'
  end
end

# ensure the Kafka broker is registered with ZK
ruby_block "kafkaup" do
  i = 0
  block do
    brokerpath="/brokers/ids/#{node[:kafka][:broker_id]}"
    zk_host = node[:kafka][:zookeeper][:connect].map{|zkh| "#{zkh}:2181"}.join(",")
    Chef::Log.info("Zookeeper hosts are #{zk_host}")
    sleep_time = 0.5
    kafka_in_zk = znode_exists?(brokerpath, zk_host)
    while !kafka_in_zk
      kafka_in_zk = znode_exists?(brokerpath, zk_host)
      if !kafka_in_zk and i < 20
        sleep(sleep_time)
        i += 1
        Chef::Log.info("Kafka server having znode #{brokerpath} is down.")
      elsif !kafka_in_zk and i >= 19 
        Chef::Application.fatal! "Kafka is reported down for more than #{i * sleep_time} seconds"
      else
        Chef::Log.info("Broker #{brokerpath} existance : #{znode_exists?(brokerpath, zk_host)}")
      end
    end
    Chef::Log.info("Kafka with znode #{brokerpath} is up and running.")
  end
  action :run
end
