## User Guide

### Launching the application
To launch the application, simply double-click the executable. Alternatively, you can call the application from PowerShell:
```powershell
Start-Process -FilePath 'C:\path\to\pssm.exe'
```
There is about a 5 second delay upon launch while the initial view builds. This performance should be improved in future releases.

### Main Window
![](/images/screenshot-main-window.png)
The main window features a grid view of the services on the computer. This view is scrollable; columns may be re-arranged.

Grid view columns:
    - **Status**: The current state of the service (e.g. "Started", "Stopped", etc.).
    - **Name**:  The name of the service (e.g. "testsvc").
    - **Display Name**: The friendly name of the service (e.g. "Test Service").
    - **Startup**: The startup mode of the service (e.g. "Automatic", "Delayed Start", "Manual", etc.)
    - **Log On As**: The username of the account that runs the service (e.g. "LocalSystem","DOMAIN\username", "localUsername").
    - **Uptime**: The length of time that the service has been up since its last start.
    - **Quoted**: Whether the service exectuable's filesystem path is hardened by being enclosed in quotation marks.
    - **Permissive**: Whether the service executable's filesystem permissions provide write access to the "Everyone" or "Users" groups.

![](/images/screenshot-main-window-context-menu.png)
Any service in the grid view may be right-clicked to open the context menu which offers quick access to certain features such as starting, stopping, restarting, along with shortcuts to open the service executable's parent directory in File Explorer or it's key in the registry.

Below the window are a variety of items providing access to various features:
  - **Refresh List**: Refreshes the service data in the main window's grid view.
  - **Export Data**: Provides the option to either copy the contents of the main window's grid view to your clipboard as a JSON string, or to save the main window's grid view data as a comma-separated values (CSV) file.
  - **Search**: The search field allows you to search the Name, DisplayName, and Description of services on the computer. The search input is debounced by around 250ms to prevent the application from attempting to filter the list until you're done typing (as opposed to filtering every time you type a character).
  - **Install Service**: Provides you an opportunity to supply an executable path along with other details to install a new service on the computer.
  - **Delete Service**: Prompts you for confirmation, and upon successful confirmation, deletes the selected service permanently.
  - **Start**: Attempts to start the selected service.
  - **Stop**: Attempts to stop the selected service.
  - **Restart**: Attempts to restart the selected service.

### Modals
#### Details modal
![](/images/screenshot-details-modal.png)
The details modal provides additional details about the service including the path to the service executable along with its arguments, and the description of the service.

#### Install Service modal
![](/images/screenshot-install-service-modal.png)
The install service modal provides fields needed for installing a new service:
  - **Service ID (Name)**: The name of the service. Should not contain spaces.
  - **Display Name**: The friendly name of the service.
  - **Path to Executable**: The filesystem path to the executable that will consitute the service. You can provide a path by typing/pasting into the field, or use the file icon to use a browser to select your desired executable.
  - **Startup Mode**: A drop-down menu to set how you'd like the service to start.
  - **Log On As**: The user account you'd like the service account to run as. Defaults to LocalSystem.

#### Delete Service modal
![](/images/screenshot-delete-service-modal.png)
The delete service modal requires that the user input the name of the service they wish to delete, then click the **Delete** button to commit the action. This is irreversible. Care should be taken when deleting services, as it can break various features or functionality of your operating system.

#### Export Data
![](/images/screenshot-export-data.png)
Clicking the **Export Data** button results in a menu where you can choose to either export the data to a CSV file, or to JSON.

If CSV is selected, a file browser opens to allow you to choose your desired save location and filename. 
 
If JSON is selected, the data is converted to a JSON string and copied to your clipboard; a popup window appears when the JSON has been copied to the clipboard as confirmation.