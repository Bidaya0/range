#! /bin/bash
IP="0.0.0.0"
PORT="8087"
IASTIP=${1}
TOKEN=${2}
ProjectNam=${3}
tar -xvf openjdk-16_linux-x64_bin.tar.gz
cd jdk-16/bin
curl -X GET $IASTIP'/openapi/api/v1/agent/download?url='$IASTIP'/openapi&language=java' -H 'Authorization: Token '$TOKEN -o agent.jar -k
if [ ! -f "agent.jar" ]; then
echo "Please check your address and token ! ! !"
exit 1
fi
if [ `ls -s agent.jar |awk '{print $1}'` -lt 10240 ];then
echo "Please check your address and token ! ! !"
exit 1
fi
nohup ./java -javaagent:agent.jar -Ddongtai.app.name=${ProjectNam} -Ddongtai.log.level=debug -Ddongtai.log=true -Ddongtai.app.version=2.1  \
--add-opens="java.xml/com.sun.xml.internal.stream=ALL-UNNAMED" \
--add-opens="java.xml/com.sun.org.apache.xerces.internal.utils=ALL-UNNAMED" \
--add-opens="java.xml/com.sun.org.apache.xerces.internal.impl=ALL-UNNAMED" \
-jar ../../webgoat-server-8.2.2.jar --server.address=$IP --server.port=$PORT &
echo "项目启动中...，请等待"
for i in {399..1}
do
sleep 1

a=`lsof -i:8087 | wc -l`
if [ "$a" -gt "0" ];then
    echo 靶场在倒计时进行到 $i 时提前启动了!!!
    break
else
    echo 靶场正在努力启动中: $i !!!
fi
done
cd ../../
HOST="http://"$IP":"$PORT
curl -H 'Content-type: application/x-www-form-urlencoded'  -X POST -d 'username=usertest&password=123456&matchingPassword=123456&agree=agree' ${HOST}/WebGoat/register.mvc 
echo "开始触发靶场流量"
./webgoat.sh $HOST
echo "流量触发结束ok!!!"
#sleep 1m
#echo "开始漏洞检测"
#./webgoat-check.sh $ProjectNam $IASTIP $TOKEN
tail -f /dev/null
