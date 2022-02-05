# batch-handbrake
The intention of this bash script is to take a batch of video files on a remote drive, move the files to a local drive,
transcode them through HandBrakeCLI, then move the final product back to a remote drive.


Phrases in quotes are stored a variables.

- Process starts by copyig the file to a local directory
- Then runs HandBrakeCLI to process the file
- Then finaly moves the processed file back to the remote directory

"Original drectory"/Video name/filename.extention --> "local orig"/filename.extention --> HandBrakeCLI --> "local process"/filename.extention --> "Processed directory"/Video name/filename.extention
	
## Requirements
- HandBrakeCLI
- pv

HandBrakeCLI is used for the transcoding.
pv is used, so that when the status script is completed, for a progress bar for file transfers.
