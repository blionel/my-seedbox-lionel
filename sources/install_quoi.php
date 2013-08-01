<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>Que faire ?</title>
		<style>
		
		.verticAlign {
			position:absolute;
			top: 50%;
			margin-top: -200px;
			left: 50%;
			margin-left: -375px;
			}
		nav
		{
			display: box;
			box-align:center;
			width: 100%;
			border: none;
			text-align: center;
		}
		#status
		{
			display: box;
			box-align:center;
			width: 751px;
			border: 1px solid black;
			background-color : RGB(221,221,221);
			margin-left: 15px;
			border-radius: 10px;
			padding: 10px;
		}
		img
		{
			border-radius: 10px;
			box-shadow: 3px 3px 3px grey;
			margin-left: 15px;
			margin-right: 15px;
			border: 1px solid black;
		}
		green
		{
			color: green;
		}
		red
		{
			color: red;
		}
		</style>
    </head>
 
    <body>
        <div class='verticAlign'>
		<nav>
            <a href="http://torrent.boulant.com"><img src="img/rtorrent.png" alt="rTorrent" /></a>
            <a href="http://owncloud.boulant.com"><img src="img/owncloud.png" alt="rTorrent" /></a>
            <a href="http://urbackup.boulant.com"><img src="img/urbackup.png" alt="rTorrent" /></a>
        </nav>
		<br />
		<div id="status">
	<?php
		$lighttpd = exec('/etc/init.d/lighttpd status');
		if ($lighttpd=='lighttpd is running.')
			echo '<green>Etat du serveur web : '.$lighttpd.'</green><br />';
		else
			echo '<red>Etat du serveur web : '.$lighttpd.'</red><br />';

		$rtorrent = exec('ps -U lionel | grep rtorrent');
		
		if ($rtorrent <> '')
			echo '<green>Etat de rTorrent : rtorrent is running. </green><br />';
		else
			echo '<red>Etat de rTorrent : rtorrent is stopped. </red><br />';
		
		
		$bytes = disk_free_space("/"); 
		$si_prefix = array( 'o', 'Ko', 'Mo', 'Go', 'To', 'Eo', 'Zo', 'Yo' );
		$base = 1024;
		$class = min((int)log($bytes , $base) , count($si_prefix) - 1);
		
		if ($bytes>(10*1024*1024*1024))
			echo '<green>Espace disque disponible : '.sprintf('%1.2f' , $bytes / pow($base,$class)) . ' ' . $si_prefix[$class] . '</green><br />';
		else
			echo '<red>Espace disque disponible : '.sprintf('%1.2f' , $bytes / pow($base,$class)) . ' ' . $si_prefix[$class] . '</red><br />';
		
		$path = exec('readlink /backup/Lionel/current');
		$path = array_pop(explode('/', $path));
		$jour = substr($path, 4, 2);
		$mois = substr($path, 2, 2);
		$annee = substr($path, 0, 2);
		
		$dateTime = new DateTime('20'.$annee.'-'.$mois.'-'.$jour); 
		$time = $dateTime->format('U'); 
		
		if ($time+(7*24*60*60)>time())
			echo '<green>Dernier backup : '.$jour.'/'.$mois.'/'.$annee.' à '.substr($path, 7, 2).'h'.substr($path, 9, 2).'min</green>';
		else
			echo '<red>Dernier backup : '.$jour.'/'.$mois.'/'.$annee.' à '.substr($path, 7, 2).'h'.substr($path, 9, 2).'min</red>';

	?>
		</div>
		</div>
	</body>
</html>