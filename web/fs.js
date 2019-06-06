var fs = require('fs')
var path = require('path')

function travel(dir, callback) {
    var list = [];
    var truePath = [];
    fs.readdirSync(dir).forEach(function(file) {        
        var pathname = path.join(dir, file);
        if(fs.statSync(pathname).isDirectory()) {            
            if(String(pathname).indexOf('.git') < 0){
                truePath.push(String(pathname));
                list.push(String(pathname).replace('_nfcp','').replace('aaa','bbb'));
            }
        }
    });
    callback(list,truePath)
}
var guidePath = []
var guideTure = []
var customersPath = []
var customersTure = []
travel(__dirname+'/FC-guide',function(list,truePath){
    guidePath=list
    guideTure = truePath
    console.log('......>>>>')
})

travel(__dirname+'/FC-customers',function(list,truePath){
    customersPath=list
    customersTure = truePath
})
var flag = false;
var index  = 0;
guidePath.forEach(function(item,i){
    if(guidePath[i] === customersPath[i]){        
        fs.copyFile(customersTure[i] + '\\WebRoot\\newpc\\img\\RLogo.png',guideTure[i]+'\\newpc\\extension\\img\\RLogo.png',(err)=>{
            if(err) throw err;
            index +=1;
        })
    }
})

console.log('index ' + index)
