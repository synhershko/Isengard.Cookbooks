default['java']['jdk_version'] = '7'
default['java']['install_flavor'] = 'oracle'
default['java']['oracle']['accept_oracle_download_terms'] = true
include_recipe 'java::default'
include_recipe 'hadoop::zookeeper_server'
