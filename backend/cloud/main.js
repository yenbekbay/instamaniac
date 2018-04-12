/*
CONSTANTS
*/

var INSTAGRAM_CLIENT_ID = "f82b8f8fcdd2456e9d830c7e5f35ca29";

/*
DEFINITIONS & JOBS
*/

Parse.Cloud.job("testTotalUserCount", function(request, status) {
  Parse.Cloud.run("getTotalUserCount", null, {
    success: function(userCount) {
      status.success("User count: " + userCount);
    },
    error: status.error
  });
});

Parse.Cloud.define("saveInstagramUser", function(request, response) {
  var instagramUserQuery = new Parse.Query("InstagramUser");
  instagramUserQuery.equalTo("instagramId", request.params.instagramId);
  instagramUserQuery.first({
    success: function(instagramUser) {
      if (instagramUser) {
        instagramUser.save({
          accessToken: request.params.accessToken
        }, response);
      } else {
        createInstagramUser();
      }
    },
    error: function(error) {
      createInstagramUser();
    }
  });
  function createInstagramUser() {
    var InstagramUser = Parse.Object.extend("InstagramUser");
    var instagramUser = new InstagramUser();
    instagramUser.save({
      instagramId: request.params.instagramId,
      username: request.params.username,
      name: request.params.name,
      picture: request.params.picture,
      followers: request.params.followers,
      following: request.params.following,
      media: request.params.media,
      accessToken: request.params.accessToken
    }, response);
  }
});

Parse.Cloud.beforeSave("InstagramUser", function(request, response) {
  if (!request.object.get("instagramId")) {
    response.error("Id is required for an instagram user");
  } else {
    response.success();
  }
});

Parse.Cloud.define("getTotalUserCount", function(request, response) {
  var totalUserCountQuery = new Parse.Query("TotalUserCount");
  totalUserCountQuery.equalTo("active", true);
  totalUserCountQuery.first({
    success: function(lastTotalUserCount) {
      if (lastTotalUserCount) {
        var expirationDate = lastTotalUserCount.createdAt;
        expirationDate.setTime(expirationDate.getTime() + 60*60*1000);
        var now = new Date();
        if (now >= expirationDate) {
          lastTotalUserCount.save({
            active: false
          }, {
            success: function(lastTotalUserCount) {
              findTotalUserCount(lastTotalUserCount.get("count") + 50*1000, {
                success: function(count) {
                  saveNewTotalUserCount(count, response);
                },
                error: response.error
              });
            },
            error: function(error) {
              console.error(error);
              response.success(lastTotalUserCount.get("count"));
            }
          });
        } else {
          response.success(lastTotalUserCount.get("count"));
        }
      } else {
        findTotalUserCount(-1, {
          success: function(count) {
            saveNewTotalUserCount(count, response);
          },
          error: response.error
        });
      }
    },
    error: function(error) {
      console.error(error);
      findTotalUserCount(-1, {
        success: function(count) {
          saveNewTotalUserCount(count, response);
        },
        error: response.error
      });
    }
  });
});

/*
FUNCTIONS
*/

function findTotalUserCount(maxCount, response) {
  var count;
  if (maxCount > 0) {
    count = maxCount;
  } else {
    count = 2.1*1000*1000*1000;
  }
  console.log("Testing user id " + count);
  var url = "https://api.instagram.com/v1/users/" + count + "/";
  Parse.Cloud.httpRequest({
    url: url,
    params: {
      client_id : INSTAGRAM_CLIENT_ID
    }
  }).then(function(httpResponse) {
    response.success(count);
  },function(httpResponse) {
    if (httpResponse.status == 400) {
      findTotalUserCount(count - 5000, response);
    } else {
      response.success(count);
    }
  });
}

function saveNewTotalUserCount(count, response) {
  var TotalUserCount = Parse.Object.extend("TotalUserCount");
  var newTotalUserCount = new TotalUserCount();
  newTotalUserCount.save({
    count: count,
    active: true
  }, {
    success: function(newTotalUserCount) {
      console.log("Found new total user count");
      response.success(newTotalUserCount.get("count"));
    },
    error: function(newTotalUserCount, error) {
      response.error(error);
    }
  });
}
