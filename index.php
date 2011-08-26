<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
	<title>BingeAlert</title>
	<meta name="viewport" content="width=320; initial-scale=1.0; maximum-scale=2.0; user-scalable=1;"/>
	<style type="text/css">
		img { border:none; width:100%; padding:0px;	}	
		
	</style>
</head>

<body>
				
	<div>
	
		<? 		
		
		$path='./images/';
		$handle=opendir($path);
		
		
		while (($file = readdir($handle))!==false) {
			if(strlen($file)>3) {
				$temp = explode(".jpg", $file);
				$parts = explode(":", $temp[0]);
				$theTime = strftime("%c", $parts[0]);				
				$rating = $parts[1];
				$lat = $parts[2];				
				$long = $parts[3];
				
				$link = "http://maps.google.com/maps?q=$lat,$long";
				$info = "$theTime [$rating]<br />Location: <a href='$link'>$lat, $long</a>";
				
				echo "<img src=$path$file />";
				echo "<p>$info</p>";
			}
		}
		closedir($handle);	
		?>						
	
	</div>			
		
	
</body>
</html>
