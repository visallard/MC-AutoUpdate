# Get latest snapshot release number
echo "Updating";
$latest = Invoke-WebRequest -Uri https://launchermeta.mojang.com/mc/game/version_manifest.json | ConvertFrom-Json;
$latest = $latest.latest.snapshot;

# Download file
wget "https://s3.amazonaws.com/Minecraft.Download/versions/$latest/minecraft_server.$latest.jar" -outfile ".\minecraft_server.jar";
echo "Update complete";

$psi = New-Object System.Diagnostics.ProcessStartInfo;
$psi.FileName = "java";
$psi.UseShellExecute = $false; #start the process from it's own executable file
$psi.RedirectStandardInput = $true; #enable the process to read from standard input
$psi.Arguments = "-jar minecraft_server.jar nogui";
$psi.WorkingDirectory = $pwd.Path;

# Execute
echo "Launching server";
$server = [System.Diagnostics.Process]::Start($psi);

# While loop
while(1){
	sleep 300;
	$new = Invoke-WebRequest -Uri https://launchermeta.mojang.com/mc/game/version_manifest.json | ConvertFrom-Json;
	$new = $new.latest.snapshot;
	if($new -ne $latest){
		echo "Out of date";
		$latest = $new;
		wget "https://s3.amazonaws.com/Minecraft.Download/versions/$latest/minecraft_server.$latest.jar" -outfile ".\minecraft_servernew.jar";
		$server.StandardInput.WriteLine("say Le server va redémarrer dans 5 minutes");
		sleep 240;
		$server.StandardInput.WriteLine("say Le server va redémarrer dans 1 minute");
		sleep 60;
		$server.StandardInput.WriteLine("stop");
		sleep 10;
		Remove-item minecraft_server.jar;
		Move-item minecraft_servernew.jar minecraft_server.jar;
		sleep 5;
		$server = [System.Diagnostics.Process]::Start($psi);
	}
	echo "Up to date";
}
