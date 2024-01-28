# Fisco_K8s

支持多机多k8s集群的FISCO部署脚本，自动为每个节点生成k8s的deployment编排文件。

脚本支持以下特性：

- 修改配置文件动态新增服务器和节点，平滑扩容
- 修改配置文件动态新增分组，无需通过console控制台
- 动态生成k8s的deployment编排文件
- 支持单k8s集群条件下的节点生成
- 支持多k8s集群条件下的节点生成
- 支持自定义端口
- 支持已经进行部署并产生交易的区块链进行节点扩容
- 支持一次新增多个节点
- 生成的节点支持区块链浏览器的订阅

## config文件配置

~~~bash
#!/bin/bash
[fisco]
#国密
gm=0
debug=1
output=./nodes
nodes=server1 server2 server3

[server1]
ip=172.24.225.115
external_ip=123.57.64.25
num=1
agencyName=agency
groups=1
ports=30300,20200,8545

[server2]
ip=172.17.229.59
external_ip=39.105.153.74
num=1
agencyName=agency
groups=1
ports=30300,20200,8545

[server3]
ip=172.24.225.117
external_ip=47.94.143.27
num=1
agencyName=agency
groups=1
ports=30300,20200,8545
~~~

- 多机单集群时，ip和external_ip取相同值，多机多集群时，external_ip为其他集群可访问该机器的公网ip

## 使用教程

### 生成节点

~~~bash
./build.sh
~~~

### 发送节点文件

- 在各个机器上新建`fisco/nodes`文件夹

- 将生成的节点文件发送到各自机器的`fisco/nodes`文件夹中

### 启动节点

- 以启动172.24.225.115机器上的节点为例

~~~bash
cd fisco/nodes/172.24.225.115
kubectl apply -f node*-deployment.yaml
~~~

### 查看状态和共识

~~~bash
tail -f nodes/172.24.225.115/node0/log/log*  | grep connected
tail -f nodes/172.24.225.115/node0/log/log*  | grep +++
~~~

### 修改config.ini新增节点或分组

- 以新增server4为例，修改config.ini,修改后的config.ini内容如下

~~~
#!/bin/bash
[fisco]
#国密
gm=0
debug=1
output=./nodes
nodes=server1 server2 server3 server4

[server1]
ip=172.24.225.115
external_ip=123.57.64.25
num=1
agencyName=agency
groups=1
ports=30300,20200,8545

[server2]
ip=172.17.229.59
external_ip=39.105.153.74
num=1
agencyName=agency
groups=1
ports=30300,20200,8545

[server3]
ip=172.24.225.117
external_ip=47.94.143.27
num=1
agencyName=agency
groups=1
ports=30300,20200,8545

[server4]
ip=172.24.225.116
external_ip=60.205.224.146
num=1
agencyName=agency
groups=1
ports=30300,20200,8545
~~~

- 再次运行build脚本

### 发送新节点文件

- 在server4机器上新建`fisco/nodes`文件夹
- 发送新生成的`172.24.225.116`文件夹到server4机器上的`fisco/nodes`文件夹中

### 启动新节点

~~~bash
cd fisco/nodes/172.24.225.116
kubectl apply -f node*-deployment.yaml
~~~

### 将新节点加入共识

- 运行仓库中的Fisco_SpringBoot项目，调用addnodes方法将新节点加入共识或使用区块链控制台手动加入
