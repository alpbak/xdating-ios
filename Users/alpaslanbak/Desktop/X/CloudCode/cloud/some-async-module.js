module.exports = new Promise((resolve, reject) => {
    //setTimeout(resolve.bind(null, 'someValueToBeReturned'), 2000);
    var query = new Parse.Query("UserPhoto");
    query.find()
        .then(function (result) {
            console.log("*****  RESULT 1");
            return result;
        },function(){
            console.log("*****  RESULT 2");
            return [];
        })
        .then(function(result){
            console.log("*****  RESULT 3a");
            console.log(result);
            return result;
        });
});