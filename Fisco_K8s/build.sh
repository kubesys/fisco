#!/bin/bash


set -e
exsist_node_num=0
node_groups=



function ReadINIfile() {
    Key=$1
    Section=$2
    Configfile=$3
    ReadINI=`awk -F '=' '/\['$Section'\]/{a=1}a==1&&$1~/'$Key'/{print $2;exit}' $Configfile`
    echo "$ReadINI"
}

function count_nodes() {
    for ((i = 0; i < ${#nodes[*]}; i++)); do
            server_name=${nodes[${i}]}
            ip=(`ReadINIfile "ip" "$server_name" "$configFile"`)
            num=(`ReadINIfile "num" "$server_name" "$configFile"`)
            for((k=0;k<$num;k++)); do
                if [ -d ${output}/${ip}/node${k} ]; then
                    exsist_node_num=`expr $exsist_node_num + 1`
                fi
            done
    done
    echo "已有节点数量:${exsist_node_num}"
}

function count_groups(){
    for ((i = 0; i < ${#nodes[*]}; i++)); do
            server_name=${nodes[${i}]}
            ip=(`ReadINIfile "ip" "$server_name" "$configFile"`)
            groups=(`ReadINIfile "groups" "$server_name" "$configFile"`)
            for((k=0;k< ${#groups[*]};k++)); do
                group_id=${groups[${k}]}
                node_groups[${group_id}]=${group_id}
            done
    done
    echo "已存在分组:${node_groups[@]}"
}


function update_config() {
    local group_insert_row="${1}"
    local conf_nodeid="${2}"
    local output="${3}"
    for ((m = 0; m < ${#nodes[*]}; m++)); do
        local server_name=${nodes[${m}]}
        local ip=(`ReadINIfile "ip" "$server_name" "$configFile"`)
        local agencyName=(`ReadINIfile "agencyName" "$server_name" "$configFile"`)
        local num=(`ReadINIfile "num" "$server_name" "$configFile"`)
        local groups=(`ReadINIfile "groups" "$server_name" "$configFile"`)
        for((t=0;t<$num;t++)); do
            if [ -d ${output}/${ip}/node${t} ]; then
                echo "${output}/${ip}/node${t}"
                sed -i "${conf_insert_row} i\\    ${conf_nodeid}"  ${output}/${ip}/node${t}/config.ini
            fi
        done
    done
}


function k8s_deployment(){
    total_num=0
    for ((i = 0; i < ${#nodes[*]}; i++)); do
        server_name=${nodes[${i}]}
        ip=(`ReadINIfile "ip" "$server_name" "$configFile"`)
        ports=(`ReadINIfile "ports" "$server_name" "$configFile"`)
        num=(`ReadINIfile "num" "$server_name" "$configFile"`)
        IFS=',' read -ra port_array <<< "$ports"
        port1=${port_array[0]}
        port2=${port_array[1]}
        port3=${port_array[2]}
        if ls ${output}/${ip}/node*-deployment.yaml 1> /dev/null 2>&1; then
            rm ${output}/${ip}/node*-deployment.yaml
        fi
        for ((k=$total_num;k<$total_num+$num;k++)); do
cat >${output}/${ip}/node${k}-deployment.yaml <<EOF
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: node${k}-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: node${k}
  template:
    metadata:
      labels:
        app: node${k}
    spec:
      hostNetwork: true
      containers:
      - name: node${k}
        image: fiscoorg/fiscobcos:v2.9.1
        args: ["-c", "config.ini"]
        workingDir: /data
        ports:
        - containerPort: `expr ${port1} + ${k} - ${total_num}`
        - containerPort: `expr ${port2} + ${k} - ${total_num}`
        - containerPort: `expr ${port3} + ${k} - ${total_num}`
        volumeMounts:
        - name: fisco-volume
          mountPath: /data
      volumes:
      - name: fisco-volume
        hostPath:
          path: /root/fisco/nodes/${ip}/node`expr ${k} - ${total_num}`
EOF
        done
    total_num=`expr ${total_num} + $num`
    done
}



function external_config() {
    for ((i = 0; i < ${#nodes[*]}; i++)); do
        server_name=${nodes[${i}]}
        ip=(`ReadINIfile "ip" "$server_name" "$configFile"`)
        num=(`ReadINIfile "num" "$server_name" "$configFile"`)
        for ((t=0;t<$num;t++)); do
            sed -i "s/jsonrpc_listen_ip=127.0.0.1/jsonrpc_listen_ip=${ip}/" ${output}/${ip}/node${t}/config.ini
            for ((j = 0; j < ${#nodes[*]}; j++)); do
                if [ $j -ne $i ]; then
                jserver_name=${nodes[${j}]}
                jip=(`ReadINIfile "ip" "$jserver_name" "$configFile"`)
                jexternal_ip=(`ReadINIfile "external_ip" "$jserver_name" "$configFile"`)
                sed -i "s/${jip}/${jexternal_ip}/" ${output}/${ip}/node${t}/config.ini
                fi
            done
        done
    done
}


function load_config {
    BASEDIR=$(dirname "$0")
    cd $BASEDIR
    WORKINGDIR=$(pwd)
    configFile="${WORKINGDIR}/config.ini"
    debug=`ReadINIfile "debug" "fisco" "$configFile"`
    gm=`ReadINIfile "gm" "fisco" "$configFile"`
    nodes=(`ReadINIfile "nodes" "fisco" "$configFile"`)
    output=(`ReadINIfile "output" "fisco" "$configFile"`)
    echo ""
    echo "Loaded Build Config"
    echo "fisco:"
    echo "  gm: ${gm}"
    echo "  output: ${output}"
    echo "nodes:"
    for ((i = 0; i < ${#nodes[*]}; i++)); do
        server_name=${nodes[${i}]}
        echo "  ${server_name}:"
        ip=(`ReadINIfile "ip" "$server_name" "$configFile"`)
        echo "  ip: ${ip}"
        num=(`ReadINIfile "num" "$server_name" "$configFile"`)
        echo "  num: ${num}"
        agencyName=(`ReadINIfile "agencyName" "$server_name" "$configFile"`)
        echo "  agencyName: ${agencyName}"
        groups=(`ReadINIfile "groups" "$server_name" "$configFile"`)
        echo "  groups: ${groups}"
        ports=(`ReadINIfile "ports" "$server_name" "$configFile"`)
        echo "  ports: ${ports}"
        echo " "
    done

has_server=
has_ip=
if [ -d ${output} ]; then
    count_nodes
    count_groups
	# rm -rf ${output}
    index=0
    for ((i = 0; i < ${#nodes[*]}; i++)); do
        server_name=${nodes[${i}]}
        ip=(`ReadINIfile "ip" "$server_name" "$configFile"`)
        agencyName=(`ReadINIfile "agencyName" "$server_name" "$configFile"`)
        num=(`ReadINIfile "num" "$server_name" "$configFile"`)
        groups=(`ReadINIfile "groups" "$server_name" "$configFile"`)
        ports=(`ReadINIfile "ports" "$server_name" "$configFile"`)
        IFS=',' read -ra port_array <<< "$ports"
        port1=${port_array[0]}
        port2=${port_array[1]}
        port3=${port_array[2]}
        echo "--------------${output}/${ip}/${num}"
        if [ -d ${output}/${ip} ]; then
            index=$i
            for((k=0;k<$num;k++)); do
                if [ -d ${output}/${ip}/node${k} ]; then
                    has_server=${nodes[${index}]}
                    has_ip=(`ReadINIfile "ip" "$has_server" "$configFile"`)
                    echo "已存在${ip}/node${k}"
                else
                    echo "新增节点${ip}/node${k}"
                    echo "${output}/cert/${agencyName}"
                    bash gen_node_cert.sh -c ${output}/cert/${agencyName} -o ${output}/${ip}/node${k}
                    cp ${output}/${has_ip}/node0/config.ini ${output}/${ip}/node${k}/config.ini
                    sed -i "s/channel_listen_port=.*/channel_listen_port=`expr $port2 + $k`/" ${output}/${ip}/node${k}/config.ini
                    sed -i "s/jsonrpc_listen_port=.*/jsonrpc_listen_port=`expr $port3 + $k`/" ${output}/${ip}/node${k}/config.ini
                    sed -i "s/listen_port=$port1/listen_port=`expr $port1 + $k`/" ${output}/${ip}/node${k}/config.ini
                    cp ${output}/${has_ip}/node0/conf/group.1.genesis ${output}/${ip}/node${k}/conf/group.1.genesis
                    cp ${output}/${has_ip}/node0/conf/group.1.ini ${output}/${ip}/node${k}/conf/group.1.ini
                    cp ${output}/${has_ip}/node0/*.sh ${output}/${ip}/node${k}/
                    cp -r ${output}/${has_ip}/node0/scripts ${output}/${ip}/node${k}/
                    conf_row_num=$(grep -n "certificate_blacklist"  ${output}/${ip}/node${k}/config.ini | head -1 | cut -d ":" -f 1)
                    echo "${conf_row_num}"
                    conf_insert_row=`expr $conf_row_num - 2`
                    echo "${conf_insert_row}"
                    group_node_port=`expr ${port1} + ${k}`
                    conf_nodeid="node.${exsist_node_num}=${ip}:${group_node_port}"
                    echo "${conf_nodeid}"
                    update_config  ${conf_insert_row} ${conf_nodeid} ${output}
                    exsist_node_num=`expr $exsist_node_num + 1`
                fi
            done
        else
            echo "新增节点${ip}"
            hasports=(`ReadINIfile "ports" "$has_server" "$configFile"`)
            IFS=',' read -ra hasport_array <<< "$hasports"
            hasport1=${hasport_array[0]}
            for((J=0;J<$num;J++)); do
                echo "新增节点${ip}/node${J}"
                bash gen_node_cert.sh -c ${output}/cert/${agencyName} -o ${output}/${ip}/node${J}
                cp -r ${output}/${has_ip}/sdk ${output}/${ip}/sdk
                cp ${output}/${has_ip}/*.sh ${output}/${ip}/
                cp ${output}/${has_ip}/node0/config.ini ${output}/${ip}/node${J}/config.ini
                sed -i "s/channel_listen_port=.*/channel_listen_port=`expr $port2 + $J`/" ${output}/${ip}/node${J}/config.ini
                sed -i "s/jsonrpc_listen_ip=${has_ip}/jsonrpc_listen_ip=${ip}/" ${output}/${ip}/node${J}/config.ini
                sed -i "s/jsonrpc_listen_port=.*/jsonrpc_listen_port=`expr $port3 + $J`/" ${output}/${ip}/node${J}/config.ini
                sed -i "s/listen_port=${hasport1}/listen_port=`expr $port1 + $J`/" ${output}/${ip}/node${J}/config.ini
                cp ${output}/${has_ip}/node0/conf/group.1.genesis ${output}/${ip}/node${J}/conf/group.1.genesis
                cp ${output}/${has_ip}/node0/conf/group.1.ini ${output}/${ip}/node${J}/conf/group.1.ini
                cp ${output}/${has_ip}/node0/*.sh ${output}/${ip}/node${J}/
                cp -r ${output}/${has_ip}/node0/scripts ${output}/${ip}/node${J}/
                conf_row_num=$(grep -n "certificate_blacklist"  ${output}/${ip}/node${J}/config.ini | head -1 | cut -d ":" -f 1)
                echo "${conf_row_num}"
                conf_insert_row=`expr $conf_row_num - 2`
                echo "${conf_insert_row}"
                group_node_port=`expr ${port1} + ${J}`
                conf_nodeid="node.${exsist_node_num}=${ip}:${group_node_port}"
                echo "${conf_nodeid}"
                update_config  ${conf_insert_row} ${conf_nodeid} ${output}
                exsist_node_num=`expr $exsist_node_num + 1`
            done
        fi
    done
else
    cat >nodes.conf <<EOF
$(for ((j = 0; j < ${#nodes[*]}; j++)); do
server_name=${nodes[${j}]}
ip=(`ReadINIfile "ip" "$server_name" "$configFile"`)
num=(`ReadINIfile "num" "$server_name" "$configFile"`)
agencyName=(`ReadINIfile "agencyName" "$server_name" "$configFile"`)
groups=(`ReadINIfile "groups" "$server_name" "$configFile"`)
ports=(`ReadINIfile "ports" "$server_name" "$configFile"`)
echo "${ip}:${num} ${agencyName} ${groups} ${ports}"
done)
EOF
    bash build_chain.sh -d -f nodes.conf -T -o ${output}
    rm -rf nodes.conf
    for ((j = 0; j < ${#nodes[*]}; j++)); do
        server_name=${nodes[${j}]}
        agencyName=(`ReadINIfile "agencyName" "$server_name" "$configFile"`)
        cp ${output}/cert/${agencyName}/cert.cnf  ${output}/cert/${agencyName}/channel/
    done
fi

}

function show_usage {
    echo ""
    echo "Usage: ./one_build.sh"
}

main() {
    load_config
    echo "生成k8s-deployment"
    k8s_deployment
    echo "修改节点的config.ini"
    external_config
	exit 0
}

main $@
