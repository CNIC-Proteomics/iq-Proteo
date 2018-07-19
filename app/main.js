// Modules to control application life and create native browser window
const { app, Menu, BrowserWindow } = require('electron')

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow

// Menu
let template = [
  { label: "Menu 1", submenu: [
    { label: 'custom action 1', accelerator: 'Command+R',       click() { console.log('go!') } },
    { label: 'custom action 2', accelerator: 'Shift+Command+R', click() { console.log('go!') } },
    { type: 'separator' },
    { role: 'quit' }
  ] },
  { label: "View", submenu: [
    { label: 'Reload', accelerator: 'Ctrl+R', click() { mainWindow.reload() } },
    { label: 'Toggle Developer Tools', accelerator: 'Ctrl+D', click() { mainWindow.webContents.openDevTools() } }
  ] }
]
    
const menu = Menu.buildFromTemplate(template)
    
function createWindow () {

  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 1600,
    height: 850,
    icon: __dirname + '/assets/icons/molecule.png'
  })

  // and load the index.html of the app.
  mainWindow.loadFile('index.html')
  // mainWindow.loadURL(`file://${__dirname}/index.html`)  

  // Open the DevTools.
  // mainWindow.webContents.openDevTools()

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })

  // Set application menu
  Menu.setApplicationMenu(menu)
}
  
// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
