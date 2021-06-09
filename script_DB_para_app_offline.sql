-- public.ds_confirmados definition

CREATE TABLE `ds_confirmados` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Llave primaria de la tabla ds_confirmados',
  `dui` varchar(50) NOT NULL COMMENT 'Campo que almacena el numero de DUI de la personas',
  `id_establecimiento_fisico` int(11) DEFAULT NULL COMMENT 'Campo que almacena el id de la relacion con la tabla ds_estableicmiento_fisico',
  `fecha_cupo` date NOT NULL COMMENT 'Campo que almacena la fecha asignada a la vacunacion relacionada con ds_cupo',
  `hora_cupo` time NOT NULL COMMENT 'Campo que almacena la hora asignada a la vacunacion relacionada con la tabla ds_cupo',
  `estado` tinyint(1) DEFAULT NULL COMMENT '0: no confirmado, 1: confirmado, 2: cancelado por motivo, 3: eliminado de agenda',
  `id_registrador` int(11) DEFAULT NULL,
  `id_dosis` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;


-- public.ds_aplicacion_vacuna definition

CREATE TABLE `ds_aplicacion_vacuna` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Llave primaria',
  `id_persona` int(11) NOT NULL COMMENT 'ds_elegibilidad',
  `id_vacuna_lote` int(11) NOT NULL COMMENT 'ds_vacuna_lote (incluye id vacuna tambien), es el lote aplicado en el drop down',
  `fecha_hora` datetime DEFAULT NULL COMMENT 'fecha hora de registro de la vacuna',
  `id_establecimiento` int(11) NOT NULL COMMENT 'establecimiento que aplica la vacuna para offline irá seteado el 208',
  `dosis` int(11) NOT NULL COMMENT 'dosis aplicada, 1: primera dosis, 2: segunda dosis',
  `id_confirmado` int(11) DEFAULT NULL COMMENT 'cita en la cual se aplico la vacuna (cita actual activa)',
  `id_proximo_confirmado` int(11) DEFAULT NULL COMMENT 'proxima cita, esto en caso sea primera dosis, si es segunda dosis esta queda en cero',
  `id_usuario_reg` int(11) NOT NULL COMMENT 'Empleado que efectuo la vacunacion, ds_empleados->id',
  `id_usuario` int(11) DEFAULT NULL COMMENT 'ID del usuario que habia iniciado sesion al momento de la vacuna,  ds_usuario->id',
  PRIMARY KEY (`id`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;

-- public.ds_elegibilidad definition

CREATE TABLE `ds_elegibilidad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(50) NOT NULL COMMENT 'este es el documento sin ceros a la izquierda y sin guiones',
  `dui` varchar(50) NOT NULL COMMENT 'Seria el DNI hondurenio',
  `fecha_nacimiento` date NOT NULL,
  `primer_nombre` varchar(50) NOT NULL,
  `segundo_nombre` varchar(50) DEFAULT NULL,
  `tercer_nombre` varchar(50) DEFAULT NULL,
  `primer_apellido` varchar(50) NOT NULL,
  `segundo_apellido` varchar(50) DEFAULT NULL,
  `apellido_casada` varchar(50) DEFAULT NULL,
  `id_pais_domicilio` int(11) NOT NULL COMMENT 'id de honduras = 102',
  `id_departamento_domicilio` int(11) ,
  `id_municipio_domicilio` int(11) ,
  `id_establecimiento` int(11) DEFAULT NULL COMMENT 'id_establecimiento_base = 208 vacunacion offline',
  `id_fase` int(11) DEFAULT NULL COMMENT 'id_fase = 33 extrangero no residente ',
  `tipo_doc` int(1) DEFAULT NULL COMMENT 'colocar 4 (DNI hondurenio)',
  `id_sexo` int(11) NOT NULL COMMENT '1: masculino, 2: femenino, 3: indefinido',
  `id_nacionalidad` int(11) DEFAULT NULL COMMENT 'colocar 101 (hondurenia)',
  PRIMARY KEY (`id`)  
) ENGINE=MYISAM DEFAULT CHARSET=utf8;



-- public.ds_usuario definition

CREATE TABLE `ds_usuario` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(100) CHARACTER SET latin1 DEFAULT NULL COMMENT 'DUI del registrador',
  `hash` varchar(64) CHARACTER SET latin1 DEFAULT NULL COMMENT 'md5(<DUI>:<password>)',
  `id_establecimiento` int(11) DEFAULT NULL COMMENT 'dejar por defecto 208',
  `nombre` varchar(100) CHARACTER SET latin1 DEFAULT '100',
  PRIMARY KEY (`id`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;


-- public.ds_empleados definition

CREATE TABLE `ds_empleados` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave primaria',
  `nombre` varchar(100) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `dui` varchar(50) CHARACTER SET latin1 COLLATE latin1_spanish_ci DEFAULT NULL,
  `id_tipo` int(11) DEFAULT NULL COMMENT 'buscar solo 2:vacunador para listado de vacunadores',
  `id_establecimiento_fisico` int(11) DEFAULT NULL COMMENT 'buscar solo en 208',
  PRIMARY KEY (`id`) 
) ENGINE=MYISAM DEFAULT CHARSET=utf8 COMMENT='Almacena empleados, mayormente son vacunadores';



-- public.ds_vacuna definition

CREATE TABLE `ds_vacuna` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Llave primarya',
  `marca` varchar(255) DEFAULT NULL,
  `dosis_por_frasco` varchar(255) DEFAULT NULL,
  `dosis_totales` int(11) DEFAULT NULL,
  `dias_entre_dosis` int(11) DEFAULT NULL COMMENT 'se usa para calcular fecha de proxima dosis segun los dias aqui especificados',
  `activo` tinyint(1) DEFAULT '1',
  `nombre_comercial` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;


-- public.ds_vacuna_lote definition

CREATE TABLE `ds_vacuna_lote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_vacuna` int(11) NOT NULL DEFAULT '0',
  `lote` varchar(50) NOT NULL COMMENT 'CODIGO DE LOTE',
  `frascos` double DEFAULT NULL COMMENT 'Frascos totales asignados',
  `activo` tinyint(1) DEFAULT '1',
  `id_establecimiento` int(11) DEFAULT NULL COMMENT 'Default tendrá 208',
 PRIMARY KEY (`id`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8;