require("cloud/app.js");

var crawler = require("crawler");
var jsdom = require("jsdom");
var _ = require('underscore');

var c = new crawler({
  maxConnections : 20,
  forceUTF8: true,
  jQuery: jsdom
});

AV.Cloud.define("crawler", function(request, response) {
  console.log("crawling baike views...");
  var query = new AV.Query("template");
  query.find().then(function(templates) {
    _.each(templates, function(t) {
      var baikeUrl = t.get("baikeUrl");
      c.queue({
        uri: baikeUrl,
        callback: function(error, result, $) {
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
          console.log(t);
          t.save(null, {
            success: function(t) {
              // Execute any logic that should take place after the object is saved.
              console.log('object created or updated with objectId: ' + t.id);
            },
            error: function(t, error) {
              // Execute any logic that should take place if the save fails.
              // error is a AV.Error with an error code and description.
              console.log('Failed to create or update object, with error code: ' + error.description);
            }
          });
        }});
    });
  });
});
