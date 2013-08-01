<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>Gestionnaire de PDF</title>
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
			width: 610px;
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
                input.command
{
background-color: transparent;
width: 500px;
}
		</style>
    </head>
 
    <body>
        <div class='verticAlign'>
		<nav>

            <a href="pdf.php?do=merge"><img src="img/merge.png" alt="merge" /></a>
            <a href="pdf.php?do=split"><img src="img/split.png" alt="split" /></a>
            <a href="pdf.php?do=unlock"><img src="img/unlock.png" alt="unlock" /></a>
            <a href="pdf.php?do=shell"><img src="img/shell.png" alt="shell" /></a>
		</nav>
		<br />
		<div id="status">
			<?php
			$do = $_GET['do'];
			$command = $_POST['command'];
			if ($do=="merge") {
				exec('pdftk /var/www/owncloud/data/lionel/files/PDF/Fusionner/*.pdf cat output /var/www/owncloud/data/lionel/files/PDF/Fusionner/combined.pdf');
				echo "<green>Fichiers fusionnés. A récupérer dans votre dossier owncloud PDF/Fusionner.</green><br />--<br />";
			}
			elseif ($do=="split") {
				exec('pdftk /var/www/owncloud/data/lionel/files/PDF/Separer/*.pdf burst output /var/www/owncloud/data/lionel/files/PDF/Separer/page_%02d.pdf');
				echo "<green>Pages spérarées. A récupérer dans votre dossier owncloud PDF/Separer.</green><br />--<br />";
			}
			elseif ($do=="unlock") {
				exec('pdftk /var/www/owncloud/data/lionel/files/PDF/Deverrouiller/*.pdf output /var/www/owncloud/data/lionel/files/PDF/Deverrouiller/out.pdf allow AllFeatures');
				echo "<green>Fichier déverouillé. A récupérer dans votre dossier owncloud PDF/Deverrouiller.</green><br />--<br />";
			}
			elseif ($command<>"") {
				exec($command);
                                echo "<green>Commande exécutée. A récupérer dans votre dossier owncloud PDF/Special.</green><br />--<br />";
			}
			echo '1 - Déposer le ou les fichiers à traiter sur owncloud.<br />';
			echo 'a - Pour fusionner des fichiers : les déposer dans le dossier PDF/Fusionner. Les fichiers seront fusionnés par ordre alphabétique.<br />';
			echo 'b - Pour séparer un fichier : le déposer dans le dossier PDF/Separer.<br />';
			echo 'c - Pour déverrouiller un fichier : le déposer dans le dossier PDF/Deverrouiller.<br />';
			echo 'd - Pour executer une commande spécifique PDFtk : déposer le fichier dans le dossier PDF/Spécial.<br />';
			echo '2 - Executer la commande correspondant à votre besoin.<br />';
			echo '3 - Récuperer votre fichier dans le dossier correspondant à votre commande OwnCloud.<br />';

			?>
			
		</div>
		<br />
<?php
if ($do=="shell") {
?>
		<div id="status">
		<form action="pdf.php?do=shell" method="post">
		<input type="text" name="command" class="command" />
		<input type="submit" name="submit" />
		</form>
		</div>
<?php
}
?>
		</div>
	</body>
</html>