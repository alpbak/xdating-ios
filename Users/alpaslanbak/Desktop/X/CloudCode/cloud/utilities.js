

// Export Modules
module.exports = {
    thisfunction: async function (request, response) {
      addComment(request, response);
    },
    thatfunction: function (request, response) {
      getComment(request, response);
    },
    bufunction: function (request, response) {
        asyncFunc(request, response);
      },
  };

  
  
  function addComment(request, response) {
      // write your code here
      //var stuff = utils.callThisFunction(param); // This is the usage of another function in another file
      //response.success("Comment added"); // or error but do not forget this
      var alp = 1900111;
      return response.alp;
  } 
  
  function getComment(request, response) {
      // write your code here
      response.success("Got Comment"); // or error but do not forget this
  }

  
  module.exports.doStuff = doStuff;
  async function doStuff() {
    return "do___stuff"
  }

  exports.getPhotos = async function (req, options) {
    var user = req.user;
    var query = new Parse.Query('UserPhotos');
    //query.equalTo('viewed', user);
    // console.log(query.toJSON());
    return query.find()
        .then(function (data) {
                return data;
            },
            function () {
                return [];
            })
        .then(function (result) {
            callBack(result);
        });
};

exports.getPhotos2 = async function (req, options){
    const feedQuery = new Parse.Query('UserPhotos');
   
    return await feedQuery.find();
}

exports.getUsers = async function (req, options){
    const feedQuery = new Parse.Query(Parse.User);
    //feedQuery.equalTo("name", request.params.grupoName);
    feedQuery.include("location");
    feedQuery.include("defaultUserPhoto");
    feedQuery.limit(100);
 
    let results;
    try{
        results = await feedQuery.find();
 
        var usersArray = [];
        for (let i = 0; i < results.length; ++i) {
            if (results[i].get("accountStatus") == 1) {
                usersArray.push(results[i]);
            }
          }
 
        var jsonObject = {
            "users": usersArray
        };
        return jsonObject
 
    } catch(error){
        throw error.message;
    }
}