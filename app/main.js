// Modules to control application life and create native browser window
const { app, Menu, BrowserWindow, ipcMain } = require('electron')

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow

// Variables with the processes IDs
let psTree = require('ps-tree')
let pids = []

// Menu
let template = [
  { label: "Menu 1", submenu: [
    { label: 'custom action 1', accelerator: 'Command+R',       click() { test() } },
    { label: 'custom action 2', accelerator: 'Shift+Command+R', click() { console.log('go!') } },
    { type: 'separator' },
    { role: 'quit', accelerator: 'Ctrl+Q' }
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
  mainWindow.on('closed', function (e) {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    
    console.log("CLose windows");

    mainWindow = null
  })
  
  // Set application menu
  Menu.setApplicationMenu(menu)
} // end createWindow


/*
App functions
*/


// This method will be called when Electron has finished initialization 
// and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// before quit: App close handler
app.on('before-quit', () => {
  console.log( 'Before-quit');
  mainWindow.removeAllListeners('close');
  mainWindow.close();
})

// app.on('before-quit', function() {
  // console.log( 'Before-quit');
//   console.log(pids);
//   pids.reverse().forEach(function(pid) {
//     console.log( 'Kill man processes %s', pid );
//     // A simple pid lookup
//     // process.kill( pid );
//   //   process.kill( pid, function( err ) {
//   //     if (err) {
//   //       throw new Error( err );
//   //     }
//   //     else {
//   //       console.log( 'Main Process %s has been killed!', pid );
//   //     }
//   // });

//   const find = require('find-process');

//   find('pid', pid )
//     .then(function (list) {
//       console.log(list);
//     }, function (err) {
//       console.log(err.stack || err);
//     })

//     // Kill all process and sub-processes
//     console.log( psTree );
//     psTree(pid, function (err, children) {  // check if it works always
//       console.log( "psTree: ", children );
//       children.map(function (p) {
//         console.log( 'Process %s has been killed2!', p.PID );
//         // process.kill(p.PID);                
//       });
//     });
//   });

  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  // if (process.platform !== 'darwin') {
  //   app.quit();
  // }
// })

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  console.log( 'window-all-closed' );
  console.log(pids);
  pids.reverse().forEach(function(pid) {
    // Kill all sub-processes
    psTree(pid, function (err, children) {  // check if it works always
      children.forEach(function(p) {
      // children.map(function (p) {
        console.log( 'Process %s has been killed!', p.PID );
        process.kill(p.PID);
      });
      // On OS X it is common for applications and their menu bar
      // to stay active until the user quits explicitly with Cmd + Q
      if (process.platform !== 'darwin') {
        app.quit();
      }    
    });
  });

  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  // if (process.platform !== 'darwin') {
    // app.quit();
  // }
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

// Connect the "main" process of electron with the javascript library
ipcMain.on('pid-message', function(event, arg) {
  // add the shell process to list of PIDs
  console.log("Main: ", arg);
  pids.push(arg);
});  