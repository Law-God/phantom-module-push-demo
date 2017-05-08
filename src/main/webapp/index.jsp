<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE HTML>
<html>
<head>
    <title>云巴推送demo</title>
    <meta charset="utf-8">
    <!--[if lte IE 7]>
    <script type="text/javascript" src="js/json2.js"></script>
    <![endif]-->
    <script type="text/javascript" src="js/socket.io-1.3.5.js"></script>
    <script type="text/javascript" src="js/yunba-js-sdk.js"></script>
    <script type="text/javascript" src="js/jquery-1.10.2.min.js"></script>
    <style>
        input {
            height: 30px;
            font-weight: bold;
        }

        input[type="radio"] {
            height: 15px;
        }

        .green {
            color: green;
        }

        fieldset {
            margin-top: 20px;
        }

        b {
            margin-left: 10px;
        }

        .clear {
            clear: both;
        }
    </style>
    <script type="text/javascript">
        // hack
        var subscribedTopics = window.subscribedTopics = [];
        var originEmit = io.Socket.prototype.emit;
        io.Socket.prototype.emit = function(ev, data) {
            if (ev == 'subscribe') {
                subscribedTopics.push(data.topic);
            }
            return originEmit.apply(this, arguments);
        }
        window.onbeforeunload = function(e) {
            try {
                var topic;
                for(var i = 0, length = subscribedTopics.length; i < length; i++) {
                    topic = subscribedTopics[i];
                    if(topic.substr(-2) === '/p') {
                        yunba.unsubscribe_presence({topic: topic.substr(0, topic.length-2)});
                    } else {
                        yunba.unsubscribe({topic: topic});
                    }
                }
            }catch(e){}
            var now = +new Date();
            while((+new Date()) - now < 200){};
        };
    </script>
    <script>
        var yunba = new Yunba({
            appkey : '581aa8d84e540a245aec53f9'
        });
        yunba.init(function(success){
            if(success){
                $("#msg").html('<div style="color:green">已连接上 socket</div>');
                $('#msg').append('<div style="color:green">SocketId: ' + yunba.socket.id + '</div>');
                mqtt_connect();
            }else{
                $("#msg").html('<div style="color:red">未连接上 socket</div>');
            }
        });
        yunba.set_message_cb(function(data){
            $('#msg_end').before('来自频道：' + data.topic);
            $('#msg_end').before('&nbsp;&nbsp;&nbsp;消息内容：' + data.msg);
            $('#msg_end').before("\<br\/\>");

            if (data.presence) {
                console.log(data.presence);
            }
            msg_end.scrollIntoView();
        });
        function mqtt_connect(){
            yunba.connect(function(success,msg){
                if(success){
                    $('#connect_status').html('Connected Success !');
                    $('#connect_status').css('color', 'green');
                }else {
                    alert(msg)
                }
            });
        }
        function mqtt_disconnect(){
            yunba.disconnect(function (success, msg) {
                if (success) {
                    $('#connect_status').html('Disconnected Success !');
                    $('#connect_status').css('color', 'red');
                } else {
                    alert(msg);
                }
            });
        }
        function mqtt_subscribe(){
            if($('#topic_sub').val().trim() == ''){
                alert("请输入频道...");
                return false;
            }
            var topic = $("#topic_sub").val().trim();
            yunba.subscribe({topic:topic},function(success,msg){
                if(success){
                    $('#topic_list').append('<b id="topic_id_' + topic + '">' + topic + '</b>');
                }else{
                    alert(msg);
                }
            });
        }

        function mqtt_unsubscribe(){
            if($('#topic_sub').val().trim() == ''){
                alert("请输入频道...");
                return false;
            }
            var topic = $("#topic_sub").val().trim();
            yunba.unsubscribe({topic:topic},function(success,data){
                if(success){
                    $('#topic_id_' + topic).remove();
                }else{
                    alert(data);
                }
            });
        }

        function mqtt_publish(){
            if($('#topic_pub').val().trim() == ''){
                alert("请输入频道...");
                return false;
            }
            var topic = $("#topic_pub").val().trim();
            var message =  $("#message").val().trim();
            yunba.publish({topic:topic,msg:message},function(success,msg){
                if(success){

                }else{
                    alert(msg);
                }
            });
        }
    </script>
</head>
<body>
<div style="float:left;width:50%">
    <fieldset style="height:100px;">
        <legend>WebSocket Info</legend>
        <div id="msg"></div>
    </fieldset>
</div>
<div style="float:left;width:50%">
    <fieldset style="height:100px;">
        <legend>Connect & Disconnect</legend>
        <div id="connect_status"></div>
        <input type="button" value="Connect" onclick="mqtt_connect();"/>
        <input type="button" value="Disconnect" onclick="mqtt_disconnect();"/>
    </fieldset>
</div>
<div class="clear"></div>
<fieldset>
    <legend>Subscribe & Unsubscribe</legend>
    <input type="text" placeholder="输入频道..." id="topic_sub"/>
    <input type="button" value="Subscribe" onclick="mqtt_subscribe();"/>
    <input type="button" value="Unsubscribe" onclick="mqtt_unsubscribe();"/>
    <!--<input type="button" value="Subscribe_Presence" onclick="mqtt_subscribe_presence();"/>-->
    <!--<input type="button" value="Unsubscribe_Presence" onclick="mqtt_unsubscribe_presence();"/>-->
    <br/>

    <div style="float:left;width:50%;">
        <fieldset id="topic_list" style="height:200px;overflow:auto">
            <legend>已订阅频道:</legend>
        </fieldset>
    </div>
    <div style="float:left;width:50%;">
        <fieldset style="height:200px;">
            <legend>收到消息</legend>
            <div id="msg_list" style="Overflow-y:scroll;height:180px;">
                <div id="msg_end" style="height:0px; overflow:hidden"></div>
            </div>
        </fieldset>
    </div>
</fieldset>
<fieldset>
    <legend>按频道发布(publish)</legend>
    频道：<input type="text" placeholder="输入频道..." id="topic_pub"/>
    消息：<input type="text" placeholder="随便输入点什么..." id="message" style="width:300px;"/>

    <input type="button" value="Publish" onclick="mqtt_publish();"/>
</fieldset>
</body>
</html>
