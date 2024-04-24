
let cursorPos = workspace.cursorPos

let position_str = cursorPos.x + "," + cursorPos.y

SERVICE_NAME = "luisbocanegra.cursor.eyes"
PATH = "/cursor"

// print(position_str)
callDBus(SERVICE_NAME, PATH, SERVICE_NAME, "save_position", position_str);
