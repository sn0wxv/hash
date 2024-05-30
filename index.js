const { app, BrowserWindow, Menu } = require('electron');

function createWindow() {
    const mainWindow = new BrowserWindow({
        width: 2000,
        height: 1050,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false,
            enableRemoteModule: true,
            webSecurity: false,  // Allow loading content from remote sources
            allowRunningInsecureContent: true,  // Allow loading insecure content such as HTTP URLs
            allowDisplayingInsecureContent: true  // Allow displaying insecure content such as HTTP images
        }
    });

    mainWindow.loadFile('login.html');
}

app.whenReady().then(() => {
    createWindow();

    // Remove the default menu
    Menu.setApplicationMenu(null);
}).catch((error) => {
    console.error('An error occurred:', error);
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});
