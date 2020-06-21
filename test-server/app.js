const express = require('express')
const fs = require('fs')
const http = require('http')
const https = require('https')
const privateKey = fs.readFileSync('./private.pem', 'utf8')
const certificate = fs.readFileSync('./file.crt', 'utf8')
const credentials = {
    key: privateKey,
    cert: certificate
}
const app = express()
const httpServer = http.createServer(app)
const httpsServer = https.createServer(credentials, app)

const port = 80
const sslPort = 443

httpServer.listen(port, function(){
    console.log('http server is listening on http://localhost:%s', port)
})

httpsServer.listen(sslPort, function(){
    console.log('https server is listening on https://localhost:%s', sslPort)
})

var path = require('path');
var bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.get('/get/:test', function(req, res){
    console.log("%s get %s", req.protocol, req.params)
    res.send(req.params)
});

app.post('/post', function(req, res){
    console.log("%s post %s", req.protocol, req.body)
    res.send(req.body);

});