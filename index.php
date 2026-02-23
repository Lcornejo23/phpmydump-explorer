<?php

$mibd = $_GET['bd'] ?? '';


$objetos = [
	'tabla' => [],
	'vista' => [],
	'proc'  => []
];

$indiceInsert = [];

if($mibd!='') $data = parsearRespaldoSql($mibd);

include 'layout.php';

exit;

function guardarVista(string $sql) {

    global $objetos;


    if (preg_match('/CREATE\s+(?:.*?\s)?VIEW\s+`?([a-zA-Z0-9_]+)`?/i', $sql, $m)){
        $nombre = $m[1];

	    if (isset($objetos['tabla'][$nombre])) {
	        unset($objetos['tabla'][$nombre]);
	    }

        $objetos['vista'][$nombre] = $sql;
    }
}

function guardarTabla(string $sql) {

    global $objetos;

    if (preg_match(
        '/CREATE TABLE\s+(IF\s+NOT\s+EXISTS\s+)?`?(?:\w+`?\.)?`?(\w+)`?/i',
        $sql,
        $m
    )) {
        $nombre = $m[2];
        $objetos['tabla'][$nombre] = $sql;
    }
}

function guardarProcedure(string $sql) {

    global $objetos;

    if (preg_match(
        '/CREATE\s+PROCEDURE\s+`?(\w+)`?/i',
        $sql,
        $m
    )) {
        $nombre = $m[1];
        $objetos['proc'][$nombre] = $sql;
    }
}

function parsearRespaldoSql($sqlFile){

    global $objetos;
	global $indiceInsert;
	$bufProc = '';
	$captProc = false;
    $bufTabla = '';
    $captTabla = false;
    $bufView = '';
    $captView = false;

	$fh = fopen($sqlFile, 'r');


	if ($fh) {
		
		while (!feof($fh)) {

			$offset = ftell($fh);
			$line = fgets($fh);		    
		    
		    if ($line === false) break;

		    $trim = trim($line);

		    //INDEXACION DE INSERT

			if (!$captProc && preg_match('/^INSERT\s+INTO\s+`?(\w+)`?/i', $trim, $m)) {

			    $tabla = $m[1];

			    if (!isset($indiceInsert[$tabla])) {
			        $indiceInsert[$tabla] = [];
			    }

			    $indiceInsert[$tabla][] = $offset;
			}

		    // PROCEDURE
		    if (!$captProc && preg_match('/^CREATE\s+PROCEDURE/i', $trim)) {
		        $captProc = true;
		        $bufProc = $line;
		        continue;
		    }

		    if ($captProc) {
		        $bufProc .= $line;
		        if (preg_match('/\$\$\s*$/', $trim)) {
		            guardarProcedure($bufProc);
		            $captProc = false;
		        }
		        continue;
		    }

		    // TABLE
		    if (!$captTabla && preg_match('/^CREATE TABLE/i', $trim)) {
		        $captTabla = true;
		        $bufTabla = $line;
		        continue;
		    }

		    if ($captTabla) {
		        $bufTabla .= $line;
		        if (preg_match('/;\s*$/', $trim)) {
		            guardarTabla($bufTabla);
		            $captTabla = false;
		        }
		    }
		
		    // VISTA
			if (!$captView && preg_match('/^CREATE\b.*\bVIEW\b/i', $trim)) {
		        $captView = true;
		        $bufView = $line;
		        if (preg_match('/;\s*$/', $trim)){
		        	guardarVista($bufView);
			    	$captView = false;
			    	continue;
				}
			}
		    if ($captView) {
		        $bufView .= $line;
		        if (preg_match('/;\s*$/', $trim)) {
		            guardarVista($bufView);
		            $captView = false;
		        }
		    }
		}
	    fclose($fh);

		if (!is_dir('indice')) {
		    mkdir('indice', 0777, true);
		}

		$nombreBase = basename($sqlFile);

		file_put_contents(
		    "indice/{$nombreBase}.idx.json",
		    json_encode(
		        $indiceInsert,
		        JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE
		    )
		);
	}

	return $objetos;
}
?>
