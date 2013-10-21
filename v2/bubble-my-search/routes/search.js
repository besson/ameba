var solr = require("solr-client");
var HashMap = require("hashmap").HashMap;
var map = new HashMap();
var async = require("async");

exports.go = function(req, res){
  var keywords = (req.body.keywords).split(",");
  var client = solr.createClient("127.0.0.1", 8984, "search", "/solr");

  var searches = 0;

  async.each(keywords,
    function(entry, e ) {
      var query = client.createQuery().q(entry).rows(3).fl("name").sort("popularity desc");
      client.search(query,function(err,obj) {
        console.log(obj.response.docs);
        map.set(entry, obj.response.docs);
        searches++;

        if (searches == keywords.length) {
          res.render("search", { title: "results", results: map });
        }

      });
      e();
    }
  );
}
