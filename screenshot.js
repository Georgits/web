var page = require('webpage').create();
page.open('http://ambebi.ge', function(status) {
  console.log("Status: " + status);
  if(status === "success") {
    page.render('example.jpg');
  }
  phantom.exit();
});