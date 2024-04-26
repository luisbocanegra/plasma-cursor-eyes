/*
  KWin script to send cursor to Cursor Eyes widget (Javascript version)
  https://github.com/luisbocanegra/plasma-cursor-eyes
 */

const SERVICE_NAME = "luisbocanegra.cursor.eyes"
const PATH = "/cursor"
var cursorPosLast = { x: -1, y: -1 }

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
    // console.log("changed", position_str)
    callDBus(SERVICE_NAME, PATH, SERVICE_NAME, "save_position", position_str);
  }
  delay(16, update);
}

update()
