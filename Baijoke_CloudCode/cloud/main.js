require("cloud/app.js");

var crawler = require("crawler");
var jsdom = require("jsdom");
var _ = require('underscore');

var c = new crawler({
  maxConnections : 20,
  forceUTF8: true,
  jQuery: jsdom
});

var numPersons = 0;

function afterFetchUrl(error, result, $, t) {
  $('title').each(function(index, name) {
    t.set("name", $(name).html().split('_')[0].trim());
  });

  $('img').each(function(index, avatar) {
    if ($(avatar).attr("alt") === t.get("name")) {
      t.set("avatar", $(avatar).attr("src"));
    }
  });

  $('.card-summary-content').each(function(index, summary) {
    t.set("summary", $(summary).html());
  });

  var relatedPersons = [];
  $('#zhixinWrap .portraitbox a').each(function(index, a) {
    var url = $(a).attr("href");
    relatedPersons.push(url);

    var query = new AV.Query("template");
    query.equalTo("baikeUrl", url);
    query.count({
      success: function(count) {
        if (count <= 0 && numPersons < 1000) {
          console.log(numPersons);
          numPersons++;
          c.queue({
            uri: url,
            callback: function(error, result, $) {
              var template = AV.Object.extend("template");
              var tp = new template();
              tp.set("baikeUrl", url);

              afterFetchUrl(error, result, $, tp);
            }
          });
        }
      },
      error: function(error) {
        // do nothing
      }
    });
  });
  t.set("relatedPersons", relatedPersons);

  var tags = [];
  $('.taglist').each(function(index, taglist){
    tags.push($(taglist).html());
  });

  t.set("tags", tags);
  console.log(t.get("name"));
  console.log(t.get("baikeUrl"));
  console.log(t.get("avatar"));
  console.log("=================");
  t.save(null, {
    success: function(res) {
      // Execute any logic that should take place after the object is saved.
      console.log('object created or updated with objectId: ' + res.id);
    },
    error: function(res, error) {
      // Execute any logic that should take place if the save fails.
      // error is a AV.Error with an error code and description.
      console.log('Failed to create or update object, with error code: ' + error.description);
    }
  });
}

AV.Cloud.define("crawler", function(request, response) {
  console.log("crawling baike views...");
  var query = new AV.Query("template");
  query.find().then(function(templates) {
    _.each(templates, function(t) {
      var baikeUrl = t.get("baikeUrl");
      console.log(numPersons);
      numPersons++;
      c.queue({
        uri: baikeUrl,
        callback: function(error, result, $) {
          afterFetchUrl(error, result, $, t);
        }
      });
    });
  });
});
