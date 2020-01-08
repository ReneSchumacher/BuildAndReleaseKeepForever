
### Why do we need this plugin?
When a release has successfully deployed to PRODUCTION environment, we wanted to keep that release defintion and all its associated builds forever. This Release task will automate the process.


### Releases
- 1.0.x - Initial release
- 2.0.x - Updated code to work with VSTS also
- 2.2.x - Packaged PowerShell task SDK with task

### Building the Extension
- Ensure that your machine has internet access.
- Ensure that you have the TFX command line client installed (run `npm install -g tfx-cli` to install).
- Run the build.ps1 script to download the latest version of the PowerShell task SDK and package everything.

## Included Tasks
### Build Release Retension Task
This task sets the 'keep forever' retension flag on a Release and its all associated builds. It takes one parameter, the build selection mode, set to either:

* Select only the primary build associated with the release (default)
* All the build artifacts associated with the release
* (Advanced) Use use build agents default credentials as opposed to agent token - usually only every needed for TFS usage 

### Screenshots


![ScreenShot](https://github.com/haribabubavanari/BuildAndReleaseKeepForever/blob/master/images/Screenshot1.png)


![ScreenShot](https://github.com/haribabubavanari/BuildAndReleaseKeepForever/blob/master/images/Screenshot2.png)
