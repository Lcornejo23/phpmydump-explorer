<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>PhpMyDump-Explorer</title>
</head>
<body>
<style type="text/css">
	body{
		font-family: Arial;
		font-size: 12px;
		font-weight: normal;
	}
	h4{
		text-align: center;
		font-weight: bold;
		background-color: #0a0;
		border-radius: 4px;
		padding: 8px 6px;
		width: 100%;
		color:#fff;
		margin:0;
	}
	span.icon{
		display: block;
		padding: 8px 6px;
		width: 16px;
		height: 6px;
		text-align: center;
		font-weight: bold;
		font-size:18px;
		color:#fff;
		top:13px;
		line-height: 5px;
		border:2px solid rgb(0,0,0,.2);
		cursor: pointer;
		position: absolute;
		border-radius: 4px;
	}
	span.icon.x{
		right: 12px;
		background-color: #c00;
	}
	span.icon.c{
		right: 46px;
		background-color: #00c;
	}
	span.icon.e{
		right: 80px;
		background-color: #07c;
	}
	ul{
		list-style: none;
		padding: 2px 8px;
		margin: 0;
	}
	li{
		list-style: none;
		padding: 1px;
	}
	li a{
		text-decoration: none;
		color:#0a0;
	}
	table{
		border-collapse: collapse;
	}
	table th{
		padding:4px 8px;
	}
	#modal{
		display:none; 
		padding: 10px 20px; 
		border:2px solid #333; 
		background-color: #ffffef; 
		position: fixed; 
		z-index: 1000; 
		top:50px; 
		margin-left: 50%; 
		left:-250px; 
		width: 500px; 
		max-height: 600px;
		height: auto; 
		overflow: scroll;		
	}
	.novisible{
		display:none;
	}
	.seleccion{
		margin:0;
		padding: 0;
		display:block;
		float:left;
	}
</style>
<table border="1" width="100%">
	<thead>
		<tr>
		    <th align="left">Tablas&nbsp; &nbsp;<button type="button" name="btn-exp" onclick="exportarInsert()">Exportar data de tablas seleccionadas</button></th>
		    <th align="left">Procedimientos / Funciones</th>
		    <th align="left">Vistas</th>
		</tr>
	</thead>
	<tbody>
<?php if(($mibd) !=''){ ?>
		<tr>
			<td valign="top">
				<ul id="lista-tabla">
					<?php foreach ($data['tabla'] as $ko => $vo){ ?><li><input class="seleccion" type="checkbox" name="tabla" value="<?php echo $ko; ?>" /><a href="#" data-obj="tabla" data-nom="<?php echo $ko ?>"><?php echo $ko ?></a></li><?php } ?>
				</ul>
			</td>

			<td valign="top">
				<ul id="lista-proc">
					<?php foreach ($data['proc'] as $ko => $vo){ ?><li><a href="#" data-obj="proc" data-nom="<?php echo $ko ?>"><?php echo $ko ?></a></li><?php } ?>
				</ul>
			</td>

			<td valign="top">
				<ul id="lista-vista">
					<?php foreach ($data['vista'] as $ko => $vo){ ?><li><a href="#" data-obj="vista" data-nom="<?php echo $ko ?>"><?php echo $ko ?></a></li><?php } ?>
				</ul>
			</td>
		</tr>
<?php }else{ ?>
		<tr>
			<td colspan="3" valign="top">
				Falta variable GET "bd"
			</td>	
		</tr>
<?php } ?>
	</tbody>
</table>

<div id="modal">
	<div style="width: auto; height: auto;">
		<h4 id="titulo"></h4>
		<span title="cerrar" class="icon x" onclick="cerrar()">x</span>
		<span title="copiar" class="icon c" onclick="copiarAlPortapapeles()">☺</span>
  		<pre id="ddlContenido"></pre>
	</div>
</div>

<script type="text/javascript">
	const bdFile = '<?php echo $mibd; ?>';
	const bdObjeto = <?php echo json_encode($data); ?>;
	const bdIndices = <?php echo json_encode($indiceInsert); ?>;
	let tablas = [];
	document.getElementById('lista-tabla')
	  .addEventListener('click', function (e) {

	    const link = e.target.closest('a');
	    if (!link) return;

	    e.preventDefault();

	    const tipo   = link.dataset.obj;
	    const nombre = link.dataset.nom;

	    mostrarObjeto(tipo, nombre);
	});
	document.getElementById('lista-proc')
	  .addEventListener('click', function (e) {

	    const link = e.target.closest('a');
	    if (!link) return;

	    e.preventDefault();

	    const tipo   = link.dataset.obj;
	    const nombre = link.dataset.nom;

	    mostrarObjeto(tipo, nombre);
	});
	document.getElementById('lista-vista')
	  .addEventListener('click', function (e) {

	    const link = e.target.closest('a');
	    if (!link) return;

	    e.preventDefault();

	    const tipo   = link.dataset.obj;
	    const nombre = link.dataset.nom;

	    mostrarObjeto(tipo, nombre);
	});
	function mostrarObjeto(vtipo,vnombre){
		document.getElementById('ddlContenido').textContent = bdObjeto[vtipo][vnombre];
		let mititulo = document.getElementById('titulo');
		mititulo.innerHTML=vtipo+' : '+vnombre;
		mititulo.dataset.tipo = vtipo;
		mititulo.dataset.nombre = vnombre;
		
		document.getElementById('modal').style.display = 'block';
		document.querySelector('.icon.c').innerHTML='☺';
	}
	function cerrar(){
		document.getElementById('modal').style.display = 'none';
	}
	function exportarInsert(){
		const chksSel = document.querySelectorAll('input.seleccion[type="checkbox"]:checked');

		const indicesExportar = {};

		chksSel.forEach(function(chk) {
		
		    const tabla = chk.value;
		    if(bdIndices[tabla]) indicesExportar[tabla] = bdIndices[tabla];
		
		});

		
		const datos = { 
			comando: 'exportar',
			archivo:   bdFile, 
			tablas: indicesExportar
		};
		fetch('exportar.php', {
		    method: 'POST',
		    headers: {
		        'Content-Type': 'application/json'
		    },
		    body: JSON.stringify(datos)
		})
		.then(response => response.json())
		.then(data => {
			alert(data.mensaje);
		})
		.catch(error => console.error('Error:', error));
	}

	async function copiarAlPortapapeles() {
	  try {
	  	let texto = document.getElementById('ddlContenido').innerHTML
	    await navigator.clipboard.writeText(texto);
	    document.querySelector('.icon.c').innerHTML='✔';
	    console.log('Contenido copiado al portapapeles');
	  } catch (err) {
	    console.error('Error al copiar: ', err);
	  }
	}
</script>
</body>
</html>
