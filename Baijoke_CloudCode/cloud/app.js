// 在 Cloud code 里初始化 Express 框架
var express = require('express');
var app = express();

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
  var tId= req.params.templateId;

  var profile = AV.Object.extend("profile");
  var p_query = new AV.Query(profile);

  p_query.get(pId, {
  success: function(object) {
    // object is an instance of AV.Object.

  },

  error: function(object, error) {
    // error is an instance of AV.Error.
  }

});

// 最后，必须有这行代码来使 express 响应 HTTP 请求
app.listen();
