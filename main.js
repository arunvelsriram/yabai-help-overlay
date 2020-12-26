const { app, BrowserWindow } = require('electron')
const { ipcMain } = require('electron')
const { spawnSync } = require('child_process')
const { existsSync } = require('fs')

function createWindow() {
  const win = new BrowserWindow({
    frame: false,
    width: 350,
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
  const awkScript = `${__dirname}/extract-comments-from-skhdrc.awk`
  console.log(`awk script: ${awkScript}`)
  const skhdConfig = `${app.getPath('home')}/.skhdrc`
  console.log(`skhd config: ${skhdConfig}`)

  if (!existsSync(awkScript)) {
    const error = `file not found: ${awkScript}`
    console.log(error)
    event.returnValue = { error }
    return
  }

  if (!existsSync(skhdConfig)) {
    const error = `file not found: ${skhdConfig}`
    console.log(error)
    event.returnValue = { error }
    return
  }

  const result = spawnSync('awk', ['-f', awkScript, skhdConfig]);
  if (result.status > 0) {
    console.log('Failed to parse skhd config file')
    console.log(`status: ${result.status}`)
    const stderr = String.fromCharCode.apply(String, result.stderr);
    console.log(`stderr: ${stderr}`)
    const error = { awkScript, skhdConfig, result }
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
