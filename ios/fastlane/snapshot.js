#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(3);
captureLocalizedScreenshot("0-GlobalRanking");
window.scrollViews()[0].staticTexts()["You signed up earlier than"].tap();
target.delay(1);
captureLocalizedScreenshot("1-FollowingRanking");
window.scrollViews()[0].staticTexts()["The earliest users at the Instagram party"].tap();
target.delay(1);
captureLocalizedScreenshot("2-Leaderboard");
window.scrollViews()[0].dragInsideWithOptions({startOffset:{x:0.50, y:0.90}, endOffset:{x:0.50, y:0.75}});;
window.scrollViews()[0].staticTexts()["Your likes and comments for the last year"].tap();
window.scrollViews()[0].dragInsideWithOptions({startOffset:{x:0.50, y:0.75}, endOffset:{x:0.50, y:0.90}});;
target.delay(1);
captureLocalizedScreenshot("3-LikesAndComments");
