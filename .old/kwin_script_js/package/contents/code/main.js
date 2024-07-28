/*
  KWin script to send cursor to Cursor Eyes widget (Javascript version)
  https://github.com/luisbocanegra/plasma-cursor-eyes
 */

const SERVICE_NAME = "luisbocanegra.cursor.eyes"
const PATH = "/cursor"
const METHOD = "save_position"
var cursorPosLast = { x: -1, y: -1 }
var updatesPerSecond = readConfig("UpdatesPerSecond", 30);
var reloadIntervalMs = 1000 / updatesPerSecond
var enableDebug = readConfig("EnableDebug", false);

printLog`Updates per second: ${updatesPerSecond} interval: ${reloadIntervalMs.toFixed(2)}`

function printLog(strings, ...values) {
  if (enableDebug) {
    let str = 'CURSOR_EYES_JS_SCRIPT: ';
    strings.forEach((string, i) => {
      str += string + (values[i] !== undefined ? values[i] : '');
    });
    console.log(str);
  }
}

function delay(milliseconds, callbackFunc) {
  var timer = new QTimer();
  timer.timeout.connect(function () {
    timer.stop();
    callbackFunc();
  });
  timer.start(milliseconds);
  return timer;
}

// cursorPosChanged signal called every time the cursor changes,
// so we use a delay instead to reduce CPU usage
// workspace.cursorPosChanged.connect(function () { });

function update() {
  // console.log("updating")
  const cursorPos = { x: workspace.cursorPos.x, y: workspace.cursorPos.y }
  if (cursorPos.x !== cursorPosLast.x || cursorPos.y !== cursorPosLast.y) {
    cursorPosLast = { x: cursorPos.x, y: cursorPos.y }
    const position_str = cursorPos.x + "," + cursorPos.y
    printLog`Cursor position changed x:${cursorPos.x} y:${cursorPos.y}`
    callDBus(SERVICE_NAME, PATH, SERVICE_NAME, METHOD, position_str);
  }
  delay(reloadIntervalMs, update);
}

update()
