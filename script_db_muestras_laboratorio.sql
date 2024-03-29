CREATE TABLE `ds_tipo_muestra` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL COMMENT 'Nombre del tipo de la muestra',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO ds_tipo_muestra (id,nombre) values(1,'Aspirado/Hisopado nasofaringeo');
INSERT INTO ds_tipo_muestra (id,nombre) values(2,'Hisopado de la garganta');
INSERT INTO ds_tipo_muestra (id,nombre) values(3,'Aspirado/Hisopado nasofaringeo e Hisopado de la garganta');


CREATE TABLE `ds_tipo_prueba` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL COMMENT 'Nombre del tipo de la prueba',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO ds_tipo_prueba (id,nombre) values(1,'PCR');
INSERT INTO ds_tipo_prueba (id,nombre) values(2,'Prueba Rápida');


CREATE TABLE `ds_estado_prueba` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL COMMENT 'Nombre del estado de la prueba',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO ds_estado_prueba (id,nombre) values(1,'Registrada');
INSERT INTO ds_estado_prueba (id,nombre) values(2,'En Proceso');
INSERT INTO ds_estado_prueba (id,nombre) values(3,'Finalizada');
INSERT INTO ds_estado_prueba (id,nombre) values(4,'Pendiente');
INSERT INTO ds_estado_prueba (id,nombre) values(5,'Rechazada');
INSERT INTO ds_estado_prueba (id,nombre) values(6,'Muestra Inadecuada');


CREATE TABLE `ds_estado_paciente` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL COMMENT 'Nombre del estado del paciente',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO ds_estado_paciente (id,nombre) values(1,'Sin síntomas');
INSERT INTO ds_estado_paciente (id,nombre) values(2,'Síntomas leves');
INSERT INTO ds_estado_paciente (id,nombre) values(3,'Síntomas fuertes');
INSERT INTO ds_estado_paciente (id,nombre) values(4,'Hospitalizado');
INSERT INTO ds_estado_paciente (id,nombre) values(5,'Fallecido');


CREATE TABLE `ds_laboratorio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL COMMENT 'Nombre del laboratorio',
  `abreviatura` varchar(50) NOT NULL COMMENT 'Siglas',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO ds_laboratorio (id,nombre,abreviatura) values(1,'Laboratorio Nacional de Referencia', 'LNR');
INSERT INTO ds_laboratorio (id,nombre,abreviatura) values(2,'Hospital General ISSS','HGISSS');
INSERT INTO ds_laboratorio (id,nombre,abreviatura) values(3,'Hospital Nacional Santa Ana SA "San Juan de Dios"','HSA');
INSERT INTO ds_laboratorio (id,nombre,abreviatura) values(4,'Hospital Nacional San Miguel SM "San Juan de Dios"','HSM');



CREATE TABLE `ds_equipo_muestra` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL COMMENT 'Nombre del equipo',
  `caracter_identificador` char(1) NOT NULL COMMENT 'Caracter identificador',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO ds_equipo_muestra (id,nombre,caracter_identificador) values(1,'Hospital', 'A');
INSERT INTO ds_equipo_muestra (id,nombre,caracter_identificador) values(2,'Unidad de Salud','B');
INSERT INTO ds_equipo_muestra (id,nombre,caracter_identificador) values(3,'Cabina Móvil','C');
INSERT INTO ds_equipo_muestra (id,nombre,caracter_identificador) values(4,'Águila y Epidemiología','D');



CREATE TABLE `ds_configuracion_ubicacion_muestras` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_establecimiento_base` int(11) NOT NULL COMMENT 'id establecimiento',
  `id_municipio` int(11) NOT NULL COMMENT 'id_municipio',
  `id_laboratorio` int(11) NOT NULL COMMENT 'id_laboratorio destino que procesará los resultados',
  `id_equipo` int(11) NOT NULL COMMENT 'id_equipo vacunador',
  `id_usuario` int(11) NOT NULL COMMENT 'id_usuario que apertura',
  `descripcion` varchar(256)  NULL COMMENT 'Descripción opcional, posiblemente va el nombre de la unidad vacunadora definida internamente en el establecimiento',
  `comentario` varchar(256)  NULL COMMENT 'Comentario opcional',
  `fecha_envio_laboratorio` date NULL COMMENT 'Fecha de envio muestras a laboratorio',
  `created_at` datetime NULL COMMENT 'Fecha de creación',
  `updated_at` datetime NULL COMMENT 'Fecha de modificación',
  PRIMARY KEY (`id`),
  KEY `FK_ds_configuracion_ds_establecimiento` (`id_establecimiento_base`),
  KEY `FK_ds_configuracion_ds_municipio` (`id_municipio`),
  KEY `FK_ds_configuracion_ds_laboratorio` (`id_laboratorio`),
  KEY `FK_ds_configuracion_ds_equipo` (`id_equipo`),
  KEY `FK_ds_configuracion_ds_usuario` (`id_usuario`),
  KEY `FK_ds_configuracion_created` (`created_at`),
  CONSTRAINT `FK_ds_configuracion_ds_establecimiento` FOREIGN KEY (`id_establecimiento_base`) REFERENCES `ds_establecimiento` (`id`),
  CONSTRAINT `FK_ds_configuracion_ds_municipio` FOREIGN KEY (`id_municipio`) REFERENCES `ds_municipio` (`id`),
  CONSTRAINT `FK_ds_configuracion_ds_laboratorio` FOREIGN KEY (`id_laboratorio`) REFERENCES `ds_laboratorio` (`id`),
  CONSTRAINT `FK_ds_configuracion_ds_equipo` FOREIGN KEY (`id_equipo`) REFERENCES `ds_equipo_muesta` (`id`),
  CONSTRAINT `FK_ds_configuracion_ds_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `ds_usuario` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `tz_muestra_laboratorio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_persona` int(11) NOT NULL COMMENT 'id persona',
  `codigo_muestra` varchar(19) DEFAULT NULL COMMENT 'Código en formato A22-0112-0625-00001',
  `id_tipo_prueba` int(11) NOT NULL COMMENT 'id_tipo_prueba ds_tipo_prueba, pcr y prueba rapida',
  `id_tipo_muestra` int(11) NOT NULL COMMENT 'ds_tipo_muestra',
  `id_estado_prueba` int(11) NOT NULL COMMENT 'ds_estado_prueba',
  `id_configuracion_ubicacion_muestra` int(11) NOT NULL COMMENT 'ds_configuracion_ubicacion_muestra',
  `id_usuario_modifica` int(11) DEFAULT NULL COMMENT 'id_usuario que modifica el estado de la muestra',
  `id_estado_paciente` int(11) NOT NULL COMMENT 'ds_estado_paciente',
  `id_laboratorio_recibe` int(11) DEFAULT NULL,
  `fecha_toma_muestra` datetime DEFAULT NULL COMMENT 'Fecha de toma de muestra',
  `created_at` datetime DEFAULT NULL COMMENT 'Fecha de creación',
  `updated_at` datetime DEFAULT NULL COMMENT 'Fecha de modificación',
  PRIMARY KEY (`id`),
  KEY `FK_ds_muestra_ds_elegibilidad` (`id_persona`),
  KEY `FK_ds_muestra_codigo` (`codigo_muestra`),
  KEY `FK_ds_muestra_ds_tipo_prueba` (`id_tipo_prueba`),
  KEY `FK_ds_muestra_ds_tipo_muestra` (`id_tipo_muestra`),
  KEY `FK_ds_muestra_ds_estado_prueba` (`id_estado_prueba`),
  KEY `FK_ds_muestra_ds_configuracion_ubicacion` (`id_configuracion_ubicacion_muestra`),
  KEY `FK_ds_muestra_ds_estado_paciente` (`id_estado_paciente`),
  KEY `FK_ds_muestra_fecha` (`fecha_toma_muestra`),
  KEY `FK_ds_muestra_created` (`created_at`),
  KEY `FK_ds_muestra_ds_usuario` (`id_usuario_modifica`),
  KEY `tz_muestra_laboratorio_FK` (`id_laboratorio_recibe`),
  CONSTRAINT `FK_ds_muestra_ds_configuracion_ubicacion` FOREIGN KEY (`id_configuracion_ubicacion_muestra`) REFERENCES `tz_configuracion_ubicacion_muestras` (`id`),
  CONSTRAINT `FK_ds_muestra_ds_elegibilidad` FOREIGN KEY (`id_persona`) REFERENCES `ds_elegibilidad` (`id`),
  CONSTRAINT `FK_ds_muestra_ds_estado_paciente` FOREIGN KEY (`id_estado_paciente`) REFERENCES `tz_estado_paciente` (`id`),
  CONSTRAINT `FK_ds_muestra_ds_estado_prueba` FOREIGN KEY (`id_estado_prueba`) REFERENCES `tz_estado_prueba` (`id`),
  CONSTRAINT `FK_ds_muestra_ds_tipo_muestra` FOREIGN KEY (`id_tipo_muestra`) REFERENCES `tz_tipo_muestra` (`id`),
  CONSTRAINT `FK_ds_muestra_ds_tipo_prueba` FOREIGN KEY (`id_tipo_prueba`) REFERENCES `tz_tipo_prueba` (`id`),
  CONSTRAINT `FK_ds_muestra_ds_usuario` FOREIGN KEY (`id_usuario_modifica`) REFERENCES `ds_usuario` (`id`),
  CONSTRAINT `tz_muestra_laboratorio_FK` FOREIGN KEY (`id_laboratorio_recibe`) REFERENCES `tz_laboratorio` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;


CREATE TABLE `ds_resultado_prueba_laboratorio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_muestra_laboratorio` int(11) NOT NULL COMMENT 'ds_muestra_laboratorio',
  `id_usuario` int(11) NOT NULL COMMENT 'ds_usuario usuario que registra el resultado',
  `id_laboratorio` int(11) DEFAULT NULL,
  `resultado` varchar(10) DEFAULT NULL COMMENT 'Resultado de la prueba NEGATIVO, POSITIVO',
  `gen_e` double(12,2) DEFAULT NULL,
  `gen_n` double(12,2) DEFAULT NULL,
  `gen_rdrp_s` double(12,2) DEFAULT NULL,
  `comentario` varchar(256) DEFAULT NULL COMMENT 'Comentario opcional',
  `created_at` datetime DEFAULT NULL COMMENT 'Fecha de creación',
  `updated_at` datetime DEFAULT NULL COMMENT 'Fecha de modificación',
  PRIMARY KEY (`id`),
  KEY `FK_ds_resultado_ds_muestra` (`id_muestra_laboratorio`),
  KEY `FK_ds_resultado_usuario` (`id_usuario`),
  KEY `FK_ds_resultado_resultado` (`resultado`),
  KEY `FK_ds_resultado_created` (`created_at`),
  KEY `tz_resultado_prueba_laboratorio_id_laboratorio_IDX` (`id_laboratorio`) USING BTREE,
  CONSTRAINT `FK_ds_resultado_ds_muestra` FOREIGN KEY (`id_muestra_laboratorio`) REFERENCES `tz_muestra_laboratorio` (`id`),
  CONSTRAINT `FK_ds_resultado_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `ds_usuario` (`id`),
  CONSTRAINT `tz_resultado_prueba_laboratorio_FK` FOREIGN KEY (`id_laboratorio`) REFERENCES `tz_laboratorio` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO ds_establecimiento_fisico
(id, nombre, direccion, id_institucion, id_departamento, id_municipio, fecha_desde, fecha_hasta, num_equipos_vac, capacidad_diaria, capacidad_hora, id_establecimiento_base, latitud, longitud, centro_vacunacion, agrupacion_mapa)
VALUES(250, 'Laboratorio Nacional de Referencia SS "Dr. Max Bloch"', 'Alameda Roosevelt entre Hospital Rosales y el Hospital Ex-Militar', 1, 6, 110, '2021-07-22', '2021-12-31', NULL, NULL, NULL, 2, 13.700017, -89.207577, 0, 1);


UPDATE ds_establecimiento_fisico SET nombre='Tamizaje Nacional Covid19' WHERE id=250;


ALTER TABLE ds_resultado_prueba_laboratorio ADD gen_e double(12,2) AFTER resultado;
ALTER TABLE ds_resultado_prueba_laboratorio ADD gen_n double(12,2) AFTER gen_e;
ALTER TABLE ds_resultado_prueba_laboratorio ADD gen_rdrp_s double(12,2) AFTER gen_n;



ALTER TABLE ds_tipo_muestra RENAME tz_tipo_muestra;

ALTER TABLE ds_tipo_prueba RENAME tz_tipo_prueba;

ALTER TABLE ds_estado_prueba RENAME tz_estado_prueba;

ALTER TABLE ds_estado_paciente RENAME tz_estado_paciente;

ALTER TABLE ds_laboratorio RENAME tz_laboratorio;

ALTER TABLE ds_equipo_muestra RENAME tz_equipo_muestra;

ALTER TABLE ds_configuracion_ubicacion_muestras RENAME tz_configuracion_ubicacion_muestras;

ALTER TABLE ds_muestra_laboratorio RENAME tz_muestra_laboratorio;

ALTER TABLE ds_resultado_prueba_laboratorio RENAME tz_resultado_prueba_laboratorio;


ALTER TABLE tz_configuracion_ubicacion_muestras CHANGE descripcion procedencia varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT 'Procedencia opcional, posiblemente va el nombre de la unidad vacunadora definida internamente en el establecimiento';


INSERT INTO ds_fase (id_fase, descripcion_fase, fecha_desde, fecha_hasta, id_fase_d, habilitado) VALUES(46, 'Menores de edad entre 0 a 5 años ', '2021-09-22', '2021-12-31', 3, 0);


CREATE TABLE `tz_persona_direcciones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_persona` int(11) NOT NULL COMMENT 'ds_elegibilidad',
  `id_departamento` int(11) NOT NULL COMMENT 'ds_departamento',
  `id_municipio` int(11) NOT NULL COMMENT 'ds_municipio',
  `calle_avenida` varchar(150) NULL COMMENT 'Calle Avenida',
  `casa_apartamento` varchar(150) NULL COMMENT 'numero de casa apartamento',
  `tipo_direccion` varchar(50) NULL DEFAULT 'ENVIO' COMMENT 'numero de casa apartamento',
  `created_at` datetime NULL COMMENT 'Fecha de creación',
  `updated_at` datetime NULL COMMENT 'Fecha de modificación',
  PRIMARY KEY (`id`),
  CONSTRAINT `FK_ds_persona` FOREIGN KEY (`id_persona`) REFERENCES `ds_elegibilidad` (`id`) on update cascade on delete cascade,  
  CONSTRAINT `FK_ds_direccion_ds_departamento` FOREIGN KEY (`id_departamento`) REFERENCES `ds_departamento` (`id`) on update cascade on delete cascade,
  CONSTRAINT `FK_ds_direccion_ds_municipio` FOREIGN KEY (`id_municipio`) REFERENCES `ds_municipio` (`id`) on update cascade on delete cascade
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `tz_usuario_laboratorio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL COMMENT 'ds_usuario',
  `id_laboratorio` int(11) NOT NULL COMMENT 'tz_laboratorio',
  `created_at` datetime DEFAULT NULL COMMENT 'Fecha de creación',
  `updated_at` datetime DEFAULT NULL COMMENT 'Fecha de modificación',
  PRIMARY KEY (`id`),
  KEY `FK_ds_usuario` (`id_usuario`),
  KEY `FK_tz_laboratorio` (`id_laboratorio`),
  CONSTRAINT `FK_ds_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `ds_usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_tz_laboratorio` FOREIGN KEY (`id_laboratorio`) REFERENCES `tz_laboratorio` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


INSERT INTO ds_roles (id, rol_nombre) VALUES(13, 'admin_pruebas_lab');
INSERT INTO ds_roles (id, rol_nombre) VALUES(14, 'reg_pruebas_lab');
INSERT INTO ds_roles (id, rol_nombre) VALUES(15, 'reg_lab');
INSERT INTO ds_roles (id, rol_nombre) VALUES(16, 'reg_result_lab');

INSERT INTO ds_establecimiento (id, id_tipo_establecimiento, nombre, direccion, telefono, fax, latitud, longitud, id_institucion, id_municipio, anio_apertura, id_cat_nivel_minsal, codestab_consumos, codestab_siaf, cod_ucsf, id_cat_tipo_expediente, id_cat_tipo_farmacia, id_cat_tipo_consumo, inst_mortalidad, digita_mortalidad, cvcd4, id_cat_pruebas, activo, id_establecimiento_padre, id_usuario_reg, fecha_hora_reg, id_usuario_mod, fecha_hora_mod, idestablesimow, idestablevigepes, estado_vigepes, estado_vacunas, estado_seps, estado_simow, idestablesumeve, estado_sumeve, cabeza_microred, hospitalizacion, idmicrored, dpna, sede, eco, idsiff, codigo_isss, centro_covid, the_geom, id_horario, max_equipo_vacunador, fase1, fase2, fase3, id_proveedor) VALUES(1677, 22, 'AGUILA 1', NULL, NULL, NULL, NULL, NULL, 1, 215, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, '2021-07-21 21:18:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO ds_establecimiento (id, id_tipo_establecimiento, nombre, direccion, telefono, fax, latitud, longitud, id_institucion, id_municipio, anio_apertura, id_cat_nivel_minsal, codestab_consumos, codestab_siaf, cod_ucsf, id_cat_tipo_expediente, id_cat_tipo_farmacia, id_cat_tipo_consumo, inst_mortalidad, digita_mortalidad, cvcd4, id_cat_pruebas, activo, id_establecimiento_padre, id_usuario_reg, fecha_hora_reg, id_usuario_mod, fecha_hora_mod, idestablesimow, idestablevigepes, estado_vigepes, estado_vacunas, estado_seps, estado_simow, idestablesumeve, estado_sumeve, cabeza_microred, hospitalizacion, idmicrored, dpna, sede, eco, idsiff, codigo_isss, centro_covid, the_geom, id_horario, max_equipo_vacunador, fase1, fase2, fase3, id_proveedor) VALUES(1678, 22, 'AGUILA 2', NULL, NULL, NULL, NULL, NULL, 1, 215, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, '2021-07-21 21:18:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO ds_establecimiento (id, id_tipo_establecimiento, nombre, direccion, telefono, fax, latitud, longitud, id_institucion, id_municipio, anio_apertura, id_cat_nivel_minsal, codestab_consumos, codestab_siaf, cod_ucsf, id_cat_tipo_expediente, id_cat_tipo_farmacia, id_cat_tipo_consumo, inst_mortalidad, digita_mortalidad, cvcd4, id_cat_pruebas, activo, id_establecimiento_padre, id_usuario_reg, fecha_hora_reg, id_usuario_mod, fecha_hora_mod, idestablesimow, idestablevigepes, estado_vigepes, estado_vacunas, estado_seps, estado_simow, idestablesumeve, estado_sumeve, cabeza_microred, hospitalizacion, idmicrored, dpna, sede, eco, idsiff, codigo_isss, centro_covid, the_geom, id_horario, max_equipo_vacunador, fase1, fase2, fase3, id_proveedor) VALUES(1679, 22, 'AGUILA 3', NULL, NULL, NULL, NULL, NULL, 1, 215, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, '2021-07-21 21:18:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO ds_establecimiento (id, id_tipo_establecimiento, nombre, direccion, telefono, fax, latitud, longitud, id_institucion, id_municipio, anio_apertura, id_cat_nivel_minsal, codestab_consumos, codestab_siaf, cod_ucsf, id_cat_tipo_expediente, id_cat_tipo_farmacia, id_cat_tipo_consumo, inst_mortalidad, digita_mortalidad, cvcd4, id_cat_pruebas, activo, id_establecimiento_padre, id_usuario_reg, fecha_hora_reg, id_usuario_mod, fecha_hora_mod, idestablesimow, idestablevigepes, estado_vigepes, estado_vacunas, estado_seps, estado_simow, idestablesumeve, estado_sumeve, cabeza_microred, hospitalizacion, idmicrored, dpna, sede, eco, idsiff, codigo_isss, centro_covid, the_geom, id_horario, max_equipo_vacunador, fase1, fase2, fase3, id_proveedor) VALUES(1680, 22, 'AGUILA 4', NULL, NULL, NULL, NULL, NULL, 1, 215, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, '2021-07-21 21:18:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO ds_establecimiento (id, id_tipo_establecimiento, nombre, direccion, telefono, fax, latitud, longitud, id_institucion, id_municipio, anio_apertura, id_cat_nivel_minsal, codestab_consumos, codestab_siaf, cod_ucsf, id_cat_tipo_expediente, id_cat_tipo_farmacia, id_cat_tipo_consumo, inst_mortalidad, digita_mortalidad, cvcd4, id_cat_pruebas, activo, id_establecimiento_padre, id_usuario_reg, fecha_hora_reg, id_usuario_mod, fecha_hora_mod, idestablesimow, idestablevigepes, estado_vigepes, estado_vacunas, estado_seps, estado_simow, idestablesumeve, estado_sumeve, cabeza_microred, hospitalizacion, idmicrored, dpna, sede, eco, idsiff, codigo_isss, centro_covid, the_geom, id_horario, max_equipo_vacunador, fase1, fase2, fase3, id_proveedor) VALUES(1681, 22, 'AGUILA 5', NULL, NULL, NULL, NULL, NULL, 1, 215, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL, '2021-07-21 21:18:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

