#!/usr/bin/node

//var Gpio = require('onoff').Gpio;

var Blynk = require('blynk-library');
var config = require('./config');
var LngLat = 'not defined';
var AUTH = config.AUTH;

//var blynk = new Blynk.Blynk(AUTH,options= { port:443 });
var blynk = new Blynk.Blynk(AUTH, options = {
  connector : new Blynk.TcpClient()
});

var v0 = new blynk.VirtualPin(0);//LCD 1行目
var v1 = new blynk.VirtualPin(1);//スライダー
var v2 = new blynk.VirtualPin(2);//LCD 2行目
var v3 = new blynk.WidgetLED(3);//LED USB
var v4 = new blynk.WidgetLED(4);//LED Camera
var v5 = new blynk.WidgetLED(5);//LED Youtube
var v6 = new blynk.WidgetLED(6);//LED File
var v7 = new blynk.VirtualPin(7);//GPS
var v8 = new blynk.VirtualPin(8);//LOG
var v9 = new blynk.VirtualPin(9);//meter
var v10 = new blynk.VirtualPin(10);//SW Start
var v11 = new blynk.VirtualPin(11);//SW Stop
var v12 = new blynk.VirtualPin(12);//HEADING
var v13 = new blynk.VirtualPin(13);//Weather/Restart services
var v14 = new blynk.VirtualPin(14);//Destination Menu
var v15 = new blynk.VirtualPin(15);//DISTANCE
var v16 = new blynk.WidgetMAP(16);//MAP
var v17 = new blynk.VirtualPin(17);//Humidity
var v18 = new blynk.VirtualPin(18);//Temperature
var v19 = new blynk.VirtualPin(19);//Pressure
var v20 = new blynk.VirtualPin(20);//WanaPi

var keyvalue=128;
var workerid='1'
var PLACE = "未設定";
var YahooAddress = '未取得';

v1.write(keyvalue);
v0.write("Welcome to");
v2.write("VT250F");
v3.turnOff();
v4.turnOff();
v5.turnOff();
v6.turnOff();
v10.write(0);
v11.write(0);
v13.write(0);

const exec = require('child_process').exec;

//var LED = new Gpio(24, 'out');

function check_status(){
  v1.write(keyvalue);

  exec('pgrep -l youtube-', (err, stdout, stderr) => {
    //if (err) { console.log(err); }
    if(stdout){
      //console.log(stdout);
      v5.turnOn();
      //LED.writeSync(1);
    }
    else{
      v5.turnOff();
      //LED.writeSync(0);
    }
  });

  exec('pgrep -l file-', (err, stdout, stderr) => {
    //if (err) { console.log(err); }
    if(stdout != ""){
      //console.log(stdout);
      v6.turnOn();
    }
    else{
      v6.turnOff();
    }
  });

  var fs = require('fs');
    fs.readFile('/var/tmp/lnglat.txt', 'utf8', function (err, text) {
      //console.log(err);
      if(!err){
        var textarray = text.split(",");
        if(text){
          LngLat = text; //ロケーションを常にアップデート
          v0.write(textarray[0]);
          v2.write(textarray[1]);
        }
        else{
          v0.write("GPS not ready");
          v2.write("in lnglat.txt");
        }
      }
      else{
        v0.write("no GPS data");
        v2.write("in /var/tmp/");
      }
    });

    fs.readFile('/var/tmp/heading.txt', 'utf8', function (err, text) {
      //console.log(err);
      if(!err){
        if(text){
          v12.write(text);
        }
        else{
          v12.write("nan");
        }
      }
    });

    fs.readFile('/var/tmp/distance.txt', 'utf8', function (err, text) {
      //console.log(err);
      if(!err){
        if(text){
          v15.write(text);
        }
        else{
          v15.write("nan");
        }
      }
    });

    fs.readFile('/var/tmp/humidity.txt', 'utf8', function (err, text) {
      //console.log(err);
      if(!err){
        if(text){
          v17.write(text);
        }
        else{
          v17.write("nan");
        }
      }
    });

    fs.readFile('/var/tmp/temperature.txt', 'utf8', function (err, text) {
      //console.log(err);
      if(!err){
        if(text){
          v18.write(text);
        }
        else{
          v18.write("nan");
        }
      }
    });

    fs.readFile('/var/tmp/pressure.txt', 'utf8', function (err, text) {
      //console.log(err);
      if(!err){
        if(text){
          v19.write(text);
        }
        else{
          v19.write("nan");
        }
      }
    });

    fs.access('/media/pi/USB0', function (err) {
      if(err){
        v3.turnOff();
      }
      else{
        v3.turnOn();
      }
    });

    fs.access('/dev/video0', function (err) {
      if(err){
        v4.turnOff();
      }
      else{
        v4.turnOn();
      }
    });

  fs.readFile('/var/tmp/wanapi.txt', 'utf8', function (err, text) {
    if(!err){
      YahooAddress = text;
      console.log(YahooAddress);
    }
  });

  fs.readFile('/var/tmp/place.txt', 'utf8', function (err, text) {
    if(!err){
      PLACE = text;
      console.log(PLACE);
      if(PLACE == "移動中"){
        PLACE = PLACE + '(' + YahooAddress + ' ' + LngLat + ")";
      }
    }
  });
}

// NIS1のMainnetを使用
// 　　第1引数はMainnet用のデフォルトのノード
// 　　第2引数はデフォルトのポート(7890)
var nem = require("nem-sdk").default // NIS1用SDKを読み込み
const endpoint = nem.model.objects.create('endpoint')
        (nem.model.nodes.defaultMainnet, nem.model.nodes.defaultPort);

setInterval(function() {
  check_status();
}, 1000);

v1.on('write', function(param) {
  console.log('V1:', param[0]);
  keyvalue = param[0];
  if(keyvalue == 0) {
    v10.write(1);
    v11.write(0);
  }
  else if(keyvalue == 255) {
    v10.write(0);
    v11.write(1);
  }
  else {
    v10.write(0);
    v11.write(0);
  }
});

v7.on('write', function(param) {
  var latitude = param[0];
  var longitude = param[1];
  var lnglat = longitude + ',' + latitude;
  var fs = require('fs');
  fs.writeFile("/var/tmp/lnglat.txt", lnglat, (err) => {
    if(err){
      console.log("lnglat.txt error" + err);
      throw err;
    }
    else{
      console.log("lnglat.txt success");
      console.log(lnglat);
    }
  });
});

v8.on('read', function() {
  exec('cat /sys/class/thermal/thermal_zone0/temp', (err, stdout, stderr) => {
    if (err) { console.log(err); }
    v8.write(stdout/1000);
   });
});

v9.on('read', function() {
  exec('cat /sys/class/thermal/thermal_zone0/temp', (err, stdout, stderr) => {
    if (err) { console.log(err); }
    v9.write(stdout/1000);
   });
});

v10.on('write', function() {
  if (keyvalue == 0){
    exec('sudo systemctl start youtube.service', (err, stdout, stderr) => {
      if (err) { console.log(err); }
      console.log(stderr);
    });}
  else{
    v10.write(0);
    v11.write(0);
  }
  keyvalue = 128;
  check_status();
});

v11.on('write', function() {
  if(keyvalue == 255){
    exec('sudo systemctl stop youtube.service', (err, stdout, stderr) => {
      if (err) { console.log(err); }
      console.log(stderr);
   });
    exec('sudo systemctl start filetube.service', (err, stdout, stderr) => {
      if (err) { console.log(err); }
      console.log(stderr);;
   });}
  else{
    v10.write(0);
    v11.write(0);
  }
  keyvalue = 128;
  check_status();
});

//v12.on('write', function() {
//  exec('sudo /home/pi/usbreset.sh', (err, stdout, stderr) => {
//      if (err) { console.log(err); }
//      console.log(stderr);
//      v2.write("Camera Reset");
//      v12.write(0);
//  });
//});

v13.on('write', function() {
  exec('sudo python3 /home/pi/live/weather.py', (err, stdout, stderr) => {
      if (err) { console.log(err); }
      console.log(stderr);
      v2.write("Weather Forecast\n");
      v13.write(0);
  });
  //exec('sudo systemctl restart meter.service', (err, stdout, stderr) => {
  //    if (err) { console.log(err); }
  //    v13.write(0);
  //});
  exec('sudo systemctl restart temphum.service', (err, stdout, stderr) => {
      if (err) { console.log(err); }
      v13.write(0);
  });
});

v14.on('write', function(param) {
  var lnglat = "136.780208,35.458272"; //デフォルトは自宅
  var PLACE = "自宅";
  v16.location(1, 35.458272, 136.780208, "Home");

  var fs = require('fs');

  if(param[0] == 1){
    v2.write("Home");
    PLACE = "自宅";
    destlnglat = "136.780208,35.458272"
    v16.location(2,35.458272,136.780208,"Home");
  }
  else if(param[0] == 2){
    v2.write("Unit13");
    PLACE = "ユニット13";
    destlnglat = "136.738721,35.465051"
    v16.location(2,35.465051,136.738721,"Unit13");
  }
  else if(param[0] == 3){
    v2.write("University");
    PLACE = "大学";
    destlnglat = "136.733861,35.466949";
    v16.location(2,35.466949,136.733861,"University");
  }
  else{
    v2.write("Others");
    PLACE = "移動中";
    destlnglat = "136.733861,35.466949"; //移動中の場合大学
  }

  fs.writeFile("/var/tmp/place.txt", PLACE, (err) => {
    if(err){
      console.log("place.txt error" + err);
      throw err;
    }
    else{
      console.log("place.txt success");
      console.log(PLACE);
    }
  });

  fs.writeFile("/var/tmp/destination.txt", destlnglat, (err) => {
    if(err){
      console.log("destination.txt error" + err);
      throw err;
    }
    else{
      console.log("destination.txt success");
      console.log(lnglat);
    }
  });
});

//v15.on('write', function() {
//  exec('sudo reboot', (err, stdout, stderr) => {
//      if (err) { console.log(err); }
//      v7.write("Reboot\n");
//      v15.write(0);
//  });
//});

//v16.on('write', function() {
//  exec('sudo shutdown -h now', (err, stdout, stderr) => {
//      if (err) { console.log(err); }
//      v7.write("Shutdown");
//      v16.write(0);
//  });
//});

v20.on('write', function(param) {
  v2.write('worker0' + workerid + ':Sending');

  console.log('worker0' + workerid + ':' + PLACE);

  transaction('worker0' + workerid + ':' + PLACE);
});

// ここからトランザクション処理をする関数
async function transaction(msg) {

  // 送金先のアドレス（config/wanapi-nis1.jsから取得）
  const toAddress = config.ADDRESS;
  // 送金額（0 XEM でも可。手数料は取られる模様）
  const sendAmount = 0;
  // 送金の際に指定するメッセージ（configの場所＋バーコード読み取り値）
  const sendMsg = config.PLACE + ":" + msg;
  // 送金元ウォレットのパスワード（空欄でも可）
  const password = '';
  // configより送金元の秘密鍵を取得
  const privateKey = config.PRIVATEKEY;
  // パスワードと秘密鍵をセットにしたオブジェクト
  const common = nem.model.objects.create('common')(password, privateKey);
  // configよりモザイクのネームスペースを取得
  const yourMosaicNamespace = config.NAMESPACE;
  // configよりモザイクのモザイク名を取得
  const yourMosaicName = config.MOSAIC;


  // Transactionの作成
  let transferTransaction1 = nem.model.objects.create('transferTransaction')(toAddress, sendAmount, sendMsg);
  // XEM mosaicを付与する
  const xemMozaic = nem.model.objects.create('mosaicAttachment')('nem', 'xem', sendAmount * 1000000);
  transferTransaction1.mosaics.push(xemMozaic);
  // XEM以外のmosaicを付与する
  const yourMosaic = nem.model.objects.create('mosaicAttachment')(yourMosaicNamespace, yourMosaicName, 1);
  transferTransaction1.mosaics.push(yourMosaic);
  // 手数料を計算するためにモザイクの定義を取得する
  let mosaicDefinitionMetaDataPair = nem.model.objects.get('mosaicDefinitionMetaDataPair');
  nem.com.requests.namespace.mosaicDefinitions(endpoint, yourMosaic.mosaicId.namespaceId).then(res => {
      // モザイク定義を取得してモザイク定義オブジェクトへ格納する
      const neededDefinition = nem.utils.helpers.searchMosaicDefinitionArray(res.data, [yourMosaicName]);
      // モザイク定義オブジェクトで使用するため、モザイクの名前を取得
      const fullMosaicName  = nem.utils.format.mosaicIdToName(yourMosaic.mosaicId);
      // モザイクの存在確認
      if (undefined === neededDefinition[fullMosaicName]) {
          return console.log('Mosaic not found !');
      }
      // モザイクの定義をモザイク定義オブジェクトへ追加する
      mosaicDefinitionMetaDataPair[fullMosaicName] = {};
      mosaicDefinitionMetaDataPair[fullMosaicName].mosaicDefinition = neededDefinition[fullMosaicName];
      nem.com.requests.mosaic.supply(endpoint, fullMosaicName).then(supplyRes => {
          // 供給量をmosaicDefinitionMetaDataPairに設定する。
          mosaicDefinitionMetaDataPair['nem:xem'].supply = 8999999999;
          mosaicDefinitionMetaDataPair[fullMosaicName].supply = 9000000000;
          // 署名をしてTransactionを送信する準備を完了する
          const transactionEntity = nem.model.transactions.prepare('mosaicTransferTransaction')
　　　　　　　(common, transferTransaction1, mosaicDefinitionMetaDataPair, nem.model.network.data.mainnet.id);
          // Transactionをブロードキャストしてネットワークへ公開する
          nem.model.transactions.send(common, transactionEntity, endpoint).then(sendRes => {
              console.log('sendRes:', sendRes); //結果を表示（任意のタイミングで返ってくる）
              v2.write(sendRes["message"]); //結果のSUCCESSなどを表示
              v20.write(0); //ボタンをもとに戻す
          }).catch(sendErr => {
              console.log('sendError:', sendErr);
            });
      }).catch(supplyErr => {
          console.log('supplyError:', supplyErr);
        });
  }).catch(err => {
      console.log('mosaicDefinitionsError:', err);
    });
}

