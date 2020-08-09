var Utility = require('./utilities.js')



Parse.Cloud.define("getFeedFromCloud", (request) => {
    return("Hello world!");
});

Parse.Cloud.define("systemDate", function(request, response) {
   var now = new Date();
       response.success(now);
});

Parse.Cloud.define("getFeedUsers", async request=> {
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
               usersArray.push(results[i])
           }
         }

       return usersArray;

   } catch(error){
       throw error.message;
   }

});

Parse.Cloud.define("getFeedUsersAndPhotos", async request=> {
 
    //let results;
    //results = await Utility.doStuff;
    //return results
    var asyncModule = require('./some-async-module');

    console.log("000000000000-----------")
    //await asyncModule.then(promisedResult => console.log(promisedResult));
    return asyncModule.then(console.log("alp denememememememe"))
 });

Parse.Cloud.define("getFeedUsersAndPhotosOriginal", async request=> {
   const feedQuery = new Parse.Query(Parse.User);
   feedQuery.include("location");
   feedQuery.include("defaultUserPhoto");
   feedQuery.limit(100);

   let results;
   var photosArray;
   try{
       results = await feedQuery.find();

       var usersArray = [];
       for (let i = 0; i < results.length; ++i) {
           if (results[i].get("accountStatus") == 1) {
               usersArray.push(results[i]);
           }
         }

         photosArray = await Utility.getPhotos2

       var jsonObject = {
           "users": usersArray,
           "photos": photosArray
       };
       return jsonObject

   } catch(error){
       throw error.message;
   }

});


Parse.Cloud.define("search", function(request, response) {
   Utility.newSearch(request, null, null, false, function(searchResult){
       
       //response.success(searchResult);
       return searchResult
       
   });
});

Parse.Cloud.define("do_this_stuff", Utility.thisfunction);

Parse.Cloud.define("testere", function(request, response){
    console.log("TESTERE **** TESTERE *****");
    var query = new Parse.Query("UserPhoto");
    query.limit(3);
    query.find({
      success: function(results) {
          console.log("results");
          response.success("results");
      },
      error: function() {
        response.error("sale lookup failed");
      }
    });
  });