// 在 Cloud code 里初始化 Express 框架
var express = require('express');
var app = express();
var crawler = require("crawler");
var jsdom = require("jsdom");
app.use(express.favicon("/public/favicon.ico"));
// App 全局配置
app.set('views','cloud/views');   // 设置模板目录
app.set('view engine', 'ejs');    // 设置 template 引擎
app.use(express.bodyParser());    // 读取请求 body 的中间件
app.use(express.static('public'));
// 使用 Express 路由 API 服务 /hello 的 HTTP GET 请求
app.get('/hello', function(req, res) {
  res.render('hello', { message: 'Congrats, you just set up your app!' });
});

app.get('/view/:profileId/:templateId', function(req, res) {
  //res.redirect('/help');
  var pId = req.params.profileId;
  var tId = req.params.templateId;
  var ua  = req.headers['user-agent'];
  var profile = AV.Object.extend("profile");
  var p_query = new AV.Query(profile);

  var template = AV.Object.extend("template");
  var t_query=new AV.Query(template);
  t_query.get(tId, {
  success: function(tInfo) {
    // object is an instance of AV.Object.
    var c = new crawler({
      maxConnections : 20,
      forceUTF8: true,
      jQuery: jsdom
    });
    var realUrl=tInfo.get("baikeUrl")
    if(ua.indexOf("iPhone") > -1)
      realUrl=tInfo.get("wapUrl");
    c.queue({
      uri: realUrl,
      callback: function(error, result, $){
        //console.log(result.body);
        // $('img').each(function(index, avatar) {
        //   if ($(avatar).attr("alt") === t.get("name")) {
        //     var src = $(avatar).attr('src');
        //
        //     // $(avatar).setAttr('src','');
        //   }
        //   var src = $(avatar).attr('src');
        //   $(avatar).setAttr('src', 'http://baike.baidu.com' + src)
        // });

        p_query.get(pId, {
          success: function(pInfo) {
            console.log(pInfo);
            $('img').each(function(index, avatar) {
              var tName = tInfo.get("name").split('（')[0];
              if ($(avatar).attr("alt") === tName) {
                $(avatar).attr("alt", pInfo.get("name"));
                $(avatar).attr("src", pInfo.get("photo").url());
              }
            });

            var pName = pInfo.get("name");
            var htmlBody = result.body;
            var reg = new RegExp(tInfo.get("name"),'g');
            htmlBody = htmlBody.replace(reg, pName);

            reg = new RegExp(tInfo.get("name").split('（')[0], 'g');
            htmlBody = htmlBody.replace(reg, pName);
            res.send(htmlBody);
          },error: function(pInfo, error) {
            // do nothing
          }
        });
      }
    });
  },
  error: function(tInfo, error) {
    // error is an instance of AV.Error.
  }});

});

// 最后，必须有这行代码来使 express 响应 HTTP 请求
app.listen();
