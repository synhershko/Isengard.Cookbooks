Isengard.Cookbooks
==================

A collection of Chef Cookbooks used for the Isengard project. I didn't come up with this ridiculous project name, BTW.

## Updating sub-trees

### Java

git subtree pull --prefix java https://github.com/agileorbit-cookbooks/java.git master --squash

### Kafka

git subtree pull --prefix kafka https://github.com/mthssdrbrg/kafka-cookbook.git master --squash

### Hadoop

git subtree pull --prefix hadoop https://github.com/continuuity/hadoop_cookbook.git master --squash

### Elasticsearch

git subtree pull --prefix elasticsearch https://github.com/elasticsearch/cookbook-elasticsearch.git master --squash

### apt

git subtree pull --prefix apt https://github.com/opscode-cookbooks/apt.git master --squash

### yum

git subtree pull --prefix yum https://github.com/opscode-cookbooks/yum.git master --squash
