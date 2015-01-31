require("cloud/app.js");

var crawler = require("crawler");
var jsdom = require("jsdom");
var _ = require('underscore');

var c = new crawler({
  maxConnections : 10,
  forceUTF8: true,
  jQuery: jsdom,

  // This will be called for each crawled page
  callback : function (error, result, $) {
    // $ is Cheerio by default

    var template = AV.Object.extend("template");
    var t = new template();

    $('.card-summary-content').each(function(index, summary) {
      t.set("summary", $(summary).html());
    });

    var relatedPersons = [];
    $('#zhixinWrap .portraitbox a').each(function(index, a) {
      relatedPersons.push($(a).attr("href"));
    });
    t.set("relatedPersons", relatedPersons);

    var tags = [];
    $('.taglist').each(function(index, taglist){
      tags.push($(taglist).html());
    });

    t.set("tags", tags);
    t.save();
  }
});

AV.Cloud.define("crawler", function(request, response) {
  console.log("crawling baike views...");
  var query = new AV.Query("template")
  query.find().then(function(templates) {
    _.each(templates, function(t) {
      var baikeUrl = t.get("baikeUrl");
      c.queue(baikeUrl);
    });
  });
});
