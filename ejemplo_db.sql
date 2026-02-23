-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 11-01-2026 a las 06:49:43
-- Versión del servidor: 11.2.2-MariaDB
-- Versión de PHP: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ejemplo_db`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_actividad_del`$$
CREATE PROCEDURE `sp_actividad_del` (IN `iActividadId` INTEGER)   BEGIN

        DELETE FROM actividad WHERE actividad_id=iActividadId;

        SELECT ROW_COUNT() AS result;

    END$$

DROP PROCEDURE IF EXISTS `sp_actividad_save`$$
CREATE PROCEDURE `sp_actividad_save` (IN `iActividadId` INTEGER, IN `dActividadInicio` DATETIME, IN `sActividadTitulo` VARCHAR(255), IN `sActividadLugar` VARCHAR(255), IN `sActividadDetalle` TEXT, IN `sActividadEstado` CHAR(1))   BEGIN

        DECLARE iExist INTEGER;
        DECLARE iRetorno INTEGER;

        SET iRetorno = 0;

        SELECT COUNT(*) INTO iExist FROM actividad WHERE actividad_id=iActividadId;

        IF iExist > 0 THEN

            UPDATE actividad SET
                actividad_fecha = now(),
                actividad_inicio = dActividadInicio,
                actividad_titulo = sActividadTitulo,
                actividad_lugar = sActividadLugar,
                actividad_detalle = sActividadDetalle,
                actividad_estado = sActividadEstado
            WHERE actividad_id = iActividadId;

            SET iRetorno = iActividadId;

        ELSE
            INSERT INTO actividad (
                actividad_fecha,
                actividad_inicio,
                actividad_titulo,
                actividad_lugar,
                actividad_detalle,
                actividad_estado
            )VALUES(
                now(),
                dActividadInicio,
                sActividadTitulo,
                sActividadLugar,
                sActividadDetalle,
                sActividadEstado
            );

            IF ROW_COUNT() > 0 THEN SET iRetorno = LAST_INSERT_ID(); END IF;
        END IF;

        SELECT iRetorno AS result;

    END$$

DROP PROCEDURE IF EXISTS `sp_galeria_del`$$
CREATE PROCEDURE `sp_galeria_del` (IN `iGaleriaId` INTEGER)   BEGIN

        DELETE FROM galeria WHERE galeria_id=iGaleriaId;

        SELECT ROW_COUNT() AS result;

END$$

DROP PROCEDURE IF EXISTS `sp_galeria_save`$$
CREATE PROCEDURE `sp_galeria_save` (IN `iGaleriaId` INTEGER, IN `sGaleriaTitulo` VARCHAR(255), IN `sGaleriaCateg` VARCHAR(45), IN `sGaleriaImg` VARCHAR(255), IN `sGaleriaDesc` VARCHAR(255), IN `sGaleriaVisible` CHAR(1))   BEGIN

    DECLARE iExist INTEGER;
    DECLARE iRetorno INTEGER;

    SET iRetorno = 0;

    SELECT COUNT(*) INTO iExist FROM galeria WHERE galeria_id=iGaleriaId;

    IF iExist > 0 THEN

        UPDATE galeria SET
            galeria_titulo = sGaleriaTitulo,
            galeria_categ = sGaleriaCateg,
            galeria_img = sGaleriaImg,
            galeria_desc = sGaleriaDesc,
            galeria_visible = sGaleriaVisible
        WHERE galeria_id = iGaleriaId;

        SET iRetorno = iGaleriaId;

    ELSE
        INSERT INTO galeria (
            galeria_titulo,
            galeria_categ,
            galeria_fecha,
            galeria_img,
            galeria_desc,
            galeria_visible
        )VALUES(
            sGaleriaTitulo,
            sGaleriaCateg,
            now(),
            sGaleriaImg,
            sGaleriaDesc,
            sGaleriaVisible
        );

        IF ROW_COUNT() > 0 THEN 
            SET iRetorno = LAST_INSERT_ID(); 
            UPDATE galeria SET galeria_carpeta = CONCAT_WS('_','GAL',LPAD(iRetorno,6,'0')) WHERE galeria_id = iRetorno;
        END IF;
    END IF;

    SELECT iRetorno AS result;

END$$

DROP PROCEDURE IF EXISTS `sp_noticia_del`$$
CREATE PROCEDURE `sp_noticia_del` (IN `iNoticiaId` INTEGER)   BEGIN

    DELETE FROM noticia WHERE noticia_id=iNoticiaId;

    SELECT ROW_COUNT() AS result;

END$$

DROP PROCEDURE IF EXISTS `sp_noticia_save`$$
CREATE PROCEDURE `sp_noticia_save` (IN `iNoticiaId` INTEGER, IN `sNoticiaTitulo` VARCHAR(255), IN `sNoticiaContenido` TEXT, IN `sNoticiaImagen` VARCHAR(255), IN `dNoticiaFecha` DATETIME, IN `sNoticiaVisible` CHAR(1), IN `iTipoId` INTEGER, IN `iGaleriaId` INTEGER, IN `sNoticiaFuente` VARCHAR(255))   BEGIN

    DECLARE iExist INTEGER;
    DECLARE iRetorno INTEGER;

    SET iRetorno = 0;

    SELECT COUNT(*) INTO iExist FROM noticia WHERE noticia_id=iNoticiaId;

    IF iExist > 0 THEN

        UPDATE noticia SET
            noticia_titulo = sNoticiaTitulo,
            noticia_contenido = sNoticiaContenido,
            noticia_imagen = sNoticiaImagen,
            noticia_fecha = dNoticiaFecha,
            noticia_visible = sNoticiaVisible,
            tipo_id = iTipoId,
            galeria_id = iGaleriaId,
            noticia_fuente = sNoticiaFuente
        WHERE noticia_id = iNoticiaId;

        SET iRetorno = iNoticiaId;

    ELSE
        INSERT INTO noticia (
            noticia_titulo,
            noticia_contenido,
            noticia_imagen,
            noticia_fecha,
            noticia_visible,
            tipo_id,
            galeria_id,
            noticia_fuente
        )VALUES(
            sNoticiaTitulo,
            sNoticiaContenido,
            sNoticiaImagen,
            dNoticiaFecha,
            sNoticiaVisible,
            iTipoId,
            iGaleriaId,
            sNoticiaFuente
        );

        IF ROW_COUNT() > 0 THEN SET iRetorno = LAST_INSERT_ID(); END IF;
    END IF;

    SELECT iRetorno AS result;

END$$

DROP PROCEDURE IF EXISTS `sp_usuario_login`$$
CREATE PROCEDURE `sp_usuario_login` (IN `sLogin` VARCHAR(45), IN `sPass` VARCHAR(45))   BEGIN
	SELECT usuario_id as id,
	       usuario_nombre as nombre,
	       usuario_login as login,
	       usuario_perfil as perfil
	FROM usuario
	WHERE usuario_login=sLogin 
	  AND usuario_pass=MD5(sPass) 
	  AND usuario_estado='H';
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `actividad`
--

DROP TABLE IF EXISTS `actividad`;
CREATE TABLE IF NOT EXISTS `actividad` (
  `actividad_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `actividad_fecha` datetime NOT NULL,
  `actividad_inicio` datetime NOT NULL,
  `actividad_titulo` varchar(255) NOT NULL,
  `actividad_lugar` varchar(255) NOT NULL,
  `actividad_detalle` text NOT NULL,
  `actividad_estado` char(1) NOT NULL DEFAULT 'V' COMMENT 'V=VIGENTE, N=NO VIGENTE',
  PRIMARY KEY (`actividad_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `actividad`
--

INSERT INTO `actividad` (`actividad_id`, `actividad_fecha`, `actividad_inicio`, `actividad_titulo`, `actividad_lugar`, `actividad_detalle`, `actividad_estado`) VALUES
(1, '2026-01-10 17:30:27', '2026-01-13 20:30:00', 'actividad primera', 'Club de la union', 'Tocata homenaje a los pampinos', 'V');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

DROP TABLE IF EXISTS `categoria`;
CREATE TABLE IF NOT EXISTS `categoria` (
  `categ_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `categ_desc` varchar(255) NOT NULL,
  `categ_padre` int(10) UNSIGNED DEFAULT NULL,
  `categ_nivel` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `categ_estado` char(1) NOT NULL DEFAULT 'H' COMMENT 'H=Habilitado, D=Deshabilitado',
  PRIMARY KEY (`categ_id`),
  KEY `idx_categ_padre` (`categ_padre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `galeria`
--

DROP TABLE IF EXISTS `galeria`;
CREATE TABLE IF NOT EXISTS `galeria` (
  `galeria_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `galeria_titulo` varchar(255) NOT NULL,
  `galeria_carpeta` varchar(12) DEFAULT NULL,
  `galeria_categ` varchar(45) NOT NULL,
  `galeria_fecha` datetime NOT NULL,
  `galeria_img` varchar(255) NOT NULL,
  `galeria_desc` varchar(255) NOT NULL,
  `galeria_visible` char(1) NOT NULL DEFAULT 'N' COMMENT 'S=SI, N=NO',
  PRIMARY KEY (`galeria_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `galeria`
--

INSERT INTO `galeria` (`galeria_id`, `galeria_titulo`, `galeria_carpeta`, `galeria_categ`, `galeria_fecha`, `galeria_img`, `galeria_desc`, `galeria_visible`) VALUES
(1, 'GALERIA EJEMPLO', 'GAL_000001', 'CATEG1', '2026-01-10 21:30:19', 'GALE1.jpg', 'NUEVA GALERIA DE FOTOS', 'S');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `menu`
--

DROP TABLE IF EXISTS `menu`;
CREATE TABLE IF NOT EXISTS `menu` (
  `menu_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `menu_nombre` varchar(100) NOT NULL,
  `menu_url` varchar(255) NOT NULL,
  `menu_icon` varchar(45) DEFAULT NULL,
  `menu_padre` int(10) UNSIGNED DEFAULT NULL,
  `menu_visible` char(1) NOT NULL DEFAULT 'S',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `menu`
--

INSERT INTO `menu` (`menu_id`, `menu_nombre`, `menu_url`, `menu_icon`, `menu_padre`, `menu_visible`) VALUES
(1, 'Actividad', 'tool=actividad', NULL, NULL, 'S'),
(2, 'Galeria', 'tool=galeria', NULL, NULL, 'S'),
(3, 'Noticia', 'tool=noticia', NULL, NULL, 'S'),
(4, 'Usuario', 'tool=usuario', NULL, NULL, 'S');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticia`
--

DROP TABLE IF EXISTS `noticia`;
CREATE TABLE IF NOT EXISTS `noticia` (
  `noticia_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `noticia_titulo` varchar(255) NOT NULL,
  `noticia_contenido` text NOT NULL,
  `noticia_imagen` varchar(255) DEFAULT NULL,
  `noticia_fecha` datetime NOT NULL,
  `noticia_visita` int(10) UNSIGNED DEFAULT 0,
  `noticia_visible` char(1) NOT NULL,
  `tipo_id` int(10) UNSIGNED NOT NULL,
  `galeria_id` int(10) UNSIGNED DEFAULT NULL,
  `noticia_fuente` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`noticia_id`),
  KEY `fk_tipo_noticia` (`tipo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `noticia`
--

INSERT INTO `noticia` (`noticia_id`, `noticia_titulo`, `noticia_contenido`, `noticia_imagen`, `noticia_fecha`, `noticia_visita`, `noticia_visible`, `tipo_id`, `galeria_id`, `noticia_fuente`) VALUES
(2, 'Primera Noticia', 'Noticia nueva d e ejemplo', 'img_20260111_055515_0.jpg', '2026-01-20 02:05:00', 0, 'S', 1, NULL, ''),
(3, 'SEGUNDA NOTICIA', 'NOTICIA NUEVA NRO DOS', 'img_20260111_061238_0.png', '2026-01-16 09:15:00', 0, 'S', 1, NULL, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticia_detalle`
--

DROP TABLE IF EXISTS `noticia_detalle`;
CREATE TABLE IF NOT EXISTS `noticia_detalle` (
  `detalle_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `noticia_id` int(10) UNSIGNED NOT NULL,
  `detalle_contenido` text NOT NULL,
  `detalle_orden` int(10) UNSIGNED NOT NULL,
  `tdetalle_id` int(10) UNSIGNED NOT NULL,
  `detalle_titulo` varchar(255) DEFAULT NULL,
  `detalle_align` char(1) NOT NULL,
  PRIMARY KEY (`detalle_id`),
  KEY `fk_noticia_id` (`noticia_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfil`
--

DROP TABLE IF EXISTS `perfil`;
CREATE TABLE IF NOT EXISTS `perfil` (
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `menu_id` int(10) UNSIGNED NOT NULL,
  `perfil_estado` char(1) NOT NULL DEFAULT 'H' COMMENT 'H=Habilitado, D=Deshabilitado',
  PRIMARY KEY (`usuario_id`,`menu_id`),
  KEY `fk_menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `perfil`
--

INSERT INTO `perfil` (`usuario_id`, `menu_id`, `perfil_estado`) VALUES
(1, 1, 'H'),
(1, 2, 'H'),
(1, 3, 'H'),
(1, 4, 'H');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_noticia`
--

DROP TABLE IF EXISTS `tipo_noticia`;
CREATE TABLE IF NOT EXISTS `tipo_noticia` (
  `tipo_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `tipo_desc` varchar(100) NOT NULL,
  `tipo_visible` char(1) NOT NULL DEFAULT 'N' COMMENT 'S=SI, N=NO',
  PRIMARY KEY (`tipo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_noticia`
--

INSERT INTO `tipo_noticia` (`tipo_id`, `tipo_desc`, `tipo_visible`) VALUES
(1, 'Noticia', 'S');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE IF NOT EXISTS `usuario` (
  `usuario_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `usuario_nombre` varchar(200) NOT NULL,
  `usuario_login` varchar(45) NOT NULL,
  `usuario_pass` varchar(45) NOT NULL,
  `usuario_perfil` char(1) NOT NULL COMMENT 'A=Administrador, U=Usuario',
  `usuario_estado` char(1) NOT NULL COMMENT 'H=Habilitado, D=Deshabilitado',
  `usuario_email` varchar(255) DEFAULT NULL,
  `usuario_cod_activacion` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`usuario_id`),
  UNIQUE KEY `usuario_login` (`usuario_login`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`usuario_id`, `usuario_nombre`, `usuario_login`, `usuario_pass`, `usuario_perfil`, `usuario_estado`, `usuario_email`, `usuario_cod_activacion`) VALUES
(1, 'Admin', 'admin', 'e10adc3949ba59abbe56e057f20f883e', 'A', 'H', NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_actividad`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_actividad`;
CREATE TABLE IF NOT EXISTS `vw_actividad` (
`ActividadId` int(10) unsigned
,`ActividadFecha` datetime
,`ActividadInicio` datetime
,`ActividadTitulo` varchar(255)
,`ActividadLugar` varchar(255)
,`ActividadDetalle` text
,`ActividadEstado` char(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_categoria`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_categoria`;
CREATE TABLE IF NOT EXISTS `vw_categoria` (
`CategId` int(10) unsigned
,`CategDesc` varchar(255)
,`CategPadre` int(10) unsigned
,`CategNivel` int(10) unsigned
,`CategEstado` char(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_galeria`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_galeria`;
CREATE TABLE IF NOT EXISTS `vw_galeria` (
`GaleriaId` int(10) unsigned
,`GaleriaTitulo` varchar(255)
,`GaleriaCarpeta` varchar(12)
,`GaleriaCateg` varchar(45)
,`GaleriaFecha` datetime
,`GaleriaImg` varchar(255)
,`GaleriaDesc` varchar(255)
,`GaleriaVisible` char(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_menu`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_menu`;
CREATE TABLE IF NOT EXISTS `vw_menu` (
`MenuId` int(10) unsigned
,`MenuNombre` varchar(100)
,`MenuUrl` varchar(255)
,`MenuPadre` int(10) unsigned
,`MenuVisible` char(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_noticia`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_noticia`;
CREATE TABLE IF NOT EXISTS `vw_noticia` (
`NoticiaId` int(10) unsigned
,`NoticiaTitulo` varchar(255)
,`NoticiaContenido` text
,`NoticiaImagen` varchar(255)
,`NoticiaFecha` datetime
,`NoticiaVisita` int(10) unsigned
,`NoticiaVisible` char(1)
,`TipoId` int(10) unsigned
,`GaleriaId` int(10) unsigned
,`NoticiaFuente` varchar(255)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_noticia_detalle`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_noticia_detalle`;
CREATE TABLE IF NOT EXISTS `vw_noticia_detalle` (
`DetalleId` int(10) unsigned
,`NoticiaId` int(10) unsigned
,`DetalleContenido` text
,`DetalleOrden` int(10) unsigned
,`TdetalleId` int(10) unsigned
,`DetalleTitulo` varchar(255)
,`DetalleAlign` char(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_perfil`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_perfil`;
CREATE TABLE IF NOT EXISTS `vw_perfil` (
`UsuarioId` int(10) unsigned
,`MenuId` int(10) unsigned
,`PerfilEstado` char(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_tipo_noticia`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_tipo_noticia`;
CREATE TABLE IF NOT EXISTS `vw_tipo_noticia` (
`TipoId` int(10) unsigned
,`TipoDesc` varchar(100)
,`TipoVisible` char(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vw_usuario`
-- (Véase abajo para la vista actual)
--
DROP VIEW IF EXISTS `vw_usuario`;
CREATE TABLE IF NOT EXISTS `vw_usuario` (
`UsuarioId` int(10) unsigned
,`UsuarioNombre` varchar(200)
,`UsuarioLogin` varchar(45)
,`UsuarioPass` varchar(45)
,`UsuarioPerfil` char(1)
,`UsuarioEstado` char(1)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_actividad`
--
DROP TABLE IF EXISTS `vw_actividad`;

DROP VIEW IF EXISTS `vw_actividad`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_actividad`  AS SELECT `actividad`.`actividad_id` AS `ActividadId`, `actividad`.`actividad_fecha` AS `ActividadFecha`, `actividad`.`actividad_inicio` AS `ActividadInicio`, `actividad`.`actividad_titulo` AS `ActividadTitulo`, `actividad`.`actividad_lugar` AS `ActividadLugar`, `actividad`.`actividad_detalle` AS `ActividadDetalle`, `actividad`.`actividad_estado` AS `ActividadEstado` FROM `actividad` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_categoria`
--
DROP TABLE IF EXISTS `vw_categoria`;

DROP VIEW IF EXISTS `vw_categoria`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_categoria`  AS SELECT `categoria`.`categ_id` AS `CategId`, `categoria`.`categ_desc` AS `CategDesc`, `categoria`.`categ_padre` AS `CategPadre`, `categoria`.`categ_nivel` AS `CategNivel`, `categoria`.`categ_estado` AS `CategEstado` FROM `categoria` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_galeria`
--
DROP TABLE IF EXISTS `vw_galeria`;

DROP VIEW IF EXISTS `vw_galeria`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_galeria`  AS SELECT `galeria`.`galeria_id` AS `GaleriaId`, `galeria`.`galeria_titulo` AS `GaleriaTitulo`, `galeria`.`galeria_carpeta` AS `GaleriaCarpeta`, `galeria`.`galeria_categ` AS `GaleriaCateg`, `galeria`.`galeria_fecha` AS `GaleriaFecha`, `galeria`.`galeria_img` AS `GaleriaImg`, `galeria`.`galeria_desc` AS `GaleriaDesc`, `galeria`.`galeria_visible` AS `GaleriaVisible` FROM `galeria` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_menu`
--
DROP TABLE IF EXISTS `vw_menu`;

DROP VIEW IF EXISTS `vw_menu`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_menu`  AS SELECT `menu`.`menu_id` AS `MenuId`, `menu`.`menu_nombre` AS `MenuNombre`, `menu`.`menu_url` AS `MenuUrl`, `menu`.`menu_padre` AS `MenuPadre`, `menu`.`menu_visible` AS `MenuVisible` FROM `menu` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_noticia`
--
DROP TABLE IF EXISTS `vw_noticia`;

DROP VIEW IF EXISTS `vw_noticia`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_noticia`  AS SELECT `noticia`.`noticia_id` AS `NoticiaId`, `noticia`.`noticia_titulo` AS `NoticiaTitulo`, `noticia`.`noticia_contenido` AS `NoticiaContenido`, `noticia`.`noticia_imagen` AS `NoticiaImagen`, `noticia`.`noticia_fecha` AS `NoticiaFecha`, `noticia`.`noticia_visita` AS `NoticiaVisita`, `noticia`.`noticia_visible` AS `NoticiaVisible`, `noticia`.`tipo_id` AS `TipoId`, `noticia`.`galeria_id` AS `GaleriaId`, `noticia`.`noticia_fuente` AS `NoticiaFuente` FROM `noticia` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_noticia_detalle`
--
DROP TABLE IF EXISTS `vw_noticia_detalle`;

DROP VIEW IF EXISTS `vw_noticia_detalle`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_noticia_detalle`  AS SELECT `noticia_detalle`.`detalle_id` AS `DetalleId`, `noticia_detalle`.`noticia_id` AS `NoticiaId`, `noticia_detalle`.`detalle_contenido` AS `DetalleContenido`, `noticia_detalle`.`detalle_orden` AS `DetalleOrden`, `noticia_detalle`.`tdetalle_id` AS `TdetalleId`, `noticia_detalle`.`detalle_titulo` AS `DetalleTitulo`, `noticia_detalle`.`detalle_align` AS `DetalleAlign` FROM `noticia_detalle` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_perfil`
--
DROP TABLE IF EXISTS `vw_perfil`;

DROP VIEW IF EXISTS `vw_perfil`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_perfil`  AS SELECT `perfil`.`usuario_id` AS `UsuarioId`, `perfil`.`menu_id` AS `MenuId`, `perfil`.`perfil_estado` AS `PerfilEstado` FROM `perfil` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_tipo_noticia`
--
DROP TABLE IF EXISTS `vw_tipo_noticia`;

DROP VIEW IF EXISTS `vw_tipo_noticia`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_tipo_noticia`  AS SELECT `tipo_noticia`.`tipo_id` AS `TipoId`, `tipo_noticia`.`tipo_desc` AS `TipoDesc`, `tipo_noticia`.`tipo_visible` AS `TipoVisible` FROM `tipo_noticia` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vw_usuario`
--
DROP TABLE IF EXISTS `vw_usuario`;

DROP VIEW IF EXISTS `vw_usuario`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_usuario`  AS SELECT `usuario`.`usuario_id` AS `UsuarioId`, `usuario`.`usuario_nombre` AS `UsuarioNombre`, `usuario`.`usuario_login` AS `UsuarioLogin`, `usuario`.`usuario_pass` AS `UsuarioPass`, `usuario`.`usuario_perfil` AS `UsuarioPerfil`, `usuario`.`usuario_estado` AS `UsuarioEstado` FROM `usuario` ;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `noticia`
--
ALTER TABLE `noticia`
  ADD CONSTRAINT `fk_tipo_noticia` FOREIGN KEY (`tipo_id`) REFERENCES `tipo_noticia` (`tipo_id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `noticia_detalle`
--
ALTER TABLE `noticia_detalle`
  ADD CONSTRAINT `fk_noticia_id` FOREIGN KEY (`noticia_id`) REFERENCES `noticia` (`noticia_id`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `perfil`
--
ALTER TABLE `perfil`
  ADD CONSTRAINT `fk_menu_id` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`menu_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`usuario_id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
