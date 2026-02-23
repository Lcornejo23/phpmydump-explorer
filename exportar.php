<?php
    $json = file_get_contents('php://input');
    $datos = json_decode($json,true);
    
    // Lógica de servidor
    if (is_array($datos)){

        $comando = $datos['comando'];

        switch($comando){
            case 'exportar':
                $archivo = $datos['archivo'];
                $tablas = $datos['tablas'];

                exportarDesdeIndice($archivo,$tablas);

                $respuesta = [
                    "resultado" => "ok",
                    "mensaje" => "datos de las tablas exportados correctamente."
                ];
                break;
            default:
                $respuesta = ["resultado" => "error", "mensaje" => "Comando desconocido"];  
        }
    } else {
        $respuesta = ["resultado" => "error", "mensaje" => "No se recibieron datos"];
    }
    
    // Enviar respuesta al cliente en formato JSON
    
    header('Content-Type: application/json');
    echo json_encode($respuesta);
    exit;
    
    function exportarDesdeIndice($sqlFile, $tablas) {

        $in  = fopen($sqlFile, 'r');

        $info = pathinfo($sqlFile);

        $archivoSalida = $info['filename'] . '_data.' . $info['extension'];

        if (!is_dir('data')) {
            mkdir('data', 0777, true);
        }

        $out = fopen("data/{$archivoSalida}",'w');

        foreach($tablas as $kt => $vt){
            fwrite($out,
                "--\n" .
                "-- Volcado de datos para la tabla `{$kt}`\n" .
                "--\n\n"
            );
            foreach ($vt as $offset) {

                if (fseek($in, $offset) === 0) {
                    while (($linea = fgets($in)) !== false) {

                        fwrite($out, $linea);

                        if (str_ends_with(rtrim($linea), ';')) {
                            fwrite($out, "\n");
                            break;
                        }
                    }

                }else{
                    error_log('offset ['.$offset.'] no encontrado.'.PHP_EOL, 3, 'errorlog.txt');
                }
            }
            fwrite($out, "-- ".str_repeat("-", 56)."\n");
        }
        fclose($in);
        fclose($out);
    }
?>