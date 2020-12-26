const { app, BrowserWindow } = require('electron')
const { ipcMain } = require('electron')
const { spawnSync } = require('child_process');

function createWindow() {
  const win = new BrowserWindow({
    frame: false,
    width: 500,
    height: 500,
    transparent: true,
    backgroundColor: '#121212',
    webPreferences: {
      nodeIntegration: true
    }
  })

  win.loadFile('index.html')
}

app.whenReady().then(createWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})

ipcMain.on('help-data', (event, arg) => {
  const awkScript = 'extract-comments-from-skhdrc.awk'
  const skhdConfig = `${app.getPath('home')}/.skhdrc`
  const result = spawnSync('awk', ['-f', awkScript, skhdConfig]);
  if (result.status > 0) {
    console.error('Failed to parse skhd config file')
    console.error(`status: ${result.status}`)
    const error = String.fromCharCode.apply(String, result.stderr);
    console.error(`stderr: ${error}`)
    event.returnValue = { error }
    return
  }
  const stdoutStr = String.fromCharCode.apply(String, result.stdout);
  const stdoutJson = JSON.parse(stdoutStr)
  const data = stdoutJson.reduce((accumulator, { group, description, shortcut }) => {
    if (!accumulator[group]) {
      accumulator[group] = []
    }
    const keys = shortcut.split(' + ')
    accumulator[group].push({ description, keys })
    return accumulator
  }, {})
  event.returnValue = { data }
})
