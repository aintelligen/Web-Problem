var fs = require('fs');
var path = require('path');

function travel(dir, callback) {
  var list = [];
  var truePath = [];
  fs.readdirSync(dir).forEach(function(file) {
    var pathname = path.join(dir, file);
    if (fs.statSync(pathname).isDirectory()) {
      if (String(pathname).indexOf('.git') < 0) {
        truePath.push(String(pathname));
        list.push(
          String(pathname)
            .replace('FC-customers', 'FC-guide')
            .replace('_nfcp', '')
        );
      }
    }
  });
  callback(list, truePath);
}
var guidePath = [];
var guideTure = [];
var customersPath = [];
var customersTure = [];
travel(__dirname + '/pc', function(list, truePath) {
  guidePath = list;
  guideTure = truePath;
  console.log('......>>>>');
});

travel(__dirname + '/admin', function(list, truePath) {
  customersPath = list;
  customersTure = truePath;
});
var flag = false;
var index = 0;
guidePath.forEach(function(item, i) {
  if (guidePath[i] === customersPath[i]) {
    console.log(guideTure[i] + '：目录：' + customersTure[i]);
    /* fs.copyFile(
      customersTure[i] + '\\WebRoot\\newpc\\img\\logo.png',
      guideTure[i] + '\\newpc\\extension\\img\\logo.png',
      err => {
        if (err) throw err;
        index += 1;
      }
    ); */
    /* try {
      fs.unlinkSync(guideTure[i] + '\\newpc\\extension\\js\\config.js');
      console.log('已成功删除:' + guideTure[i]);
    } catch (err) {
      // 处理错误
      console.log('处理错误:' + guideTure[i]);
    } */
  }
});

console.log('index ' + index);
