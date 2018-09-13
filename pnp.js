var webPage = require('webpage');
var page = webPage.create();
page.open('http://www.ontarioimmigration.ca/en/pnp/OI_PNPNEW.html',function(status){
    console.log('Status:'+status);
    var content= page.content;
    var RegExp = /Last\ Modified(.*)<\/p>/;
    var match = RegExp.exec(content)[1];
    console.log('Match: ' + match);
    phantom.exit(match);
});
