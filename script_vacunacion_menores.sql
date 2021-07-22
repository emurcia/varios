-- NUEVAS TABLAS Y ALTERS A ELEGIBILIDAD PARA VACUNACION MENORES

CREATE TABLE `ds_parentesco` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `si01` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

ALTER TABLE ds_parentesco AUTO_INCREMENT = 1;

INSERT INTO ds_parentesco (nombre,si01) VALUES
	 ('Padre',1),
	 ('Madre',2),
	 ('Hijo(a)',3),
	 ('Abuelo(a)',4),
	 ('Tio(a)',5),
	 ('Cuñado(a)',6),
	 ('Primo(a)',7),
	 ('Esposo(a)',8),
	 ('Compañero(a)',9),
	 ('Nieto (a)',10),
	 ('Hermano(a)',11),
	 ('Sobrino (a)',12),
	 ('Otros',13),
	 ('Desconocido(a)',14),
	 ('Suegro(a)',15);

CREATE TABLE `ds_responsable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_menor` int(11) NOT NULL COMMENT 'id_persona identificado como menor de edad',
  `id_responsable` int(11) NOT NULL COMMENT 'id_persona responsable del menor de edad',
  `id_parentesco` int(11) NOT NULL COMMENT 'Parentesco del responsable',
  PRIMARY KEY (`id`),
  KEY `FK_ds_responsable_ds_elegibilidad1` (`id_menor`),
  KEY `FK_ds_responsable_ds_elegibilidad2` (`id_responsable`),
  KEY `FK_ds_responsable_ds_parentesco` (`id_parentesco`),
  CONSTRAINT `FK_ds_responsable_ds_elegibilidad1` FOREIGN KEY (`id_menor`) REFERENCES `ds_elegibilidad` (`id`),
  CONSTRAINT `FK_ds_responsable_ds_elegibilidad2` FOREIGN KEY (`id_responsable`) REFERENCES `ds_elegibilidad` (`id`),
  CONSTRAINT `FK_ds_responsable_ds_parentesco` FOREIGN KEY (`id_parentesco`) REFERENCES `ds_parentesco` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


ALTER TABLE ds_elegibilidad ADD nup varchar(25) DEFAULT NULL COMMENT 'Número Unico Previsional (AFPs)';
ALTER TABLE ds_elegibilidad ADD nit varchar(25) DEFAULT NULL COMMENT 'Número Identificación Tributaria';
ALTER TABLE ds_elegibilidad ADD isss varchar(25) DEFAULT NULL COMMENT 'Número de Afiliación ISSS';
ALTER TABLE ds_elegibilidad ADD pasaporte varchar(25) DEFAULT NULL COMMENT 'Numero de Pasaporte';
ALTER TABLE ds_elegibilidad ADD menor_verificado tinyint(1) DEFAULT NULL COMMENT 'NULL: ADULTO, 0: MENOR NO VERIFICADO, 1: MENOR VERIFICADO';
ALTER TABLE ds_elegibilidad ADD partida_nacimiento varchar(25) DEFAULT NULL COMMENT 'Número de Partida de Nacimiento';
ALTER TABLE ds_elegibilidad ADD libro varchar(25) DEFAULT NULL COMMENT 'Número de Libro de la Partida de Nacimiento';
ALTER TABLE ds_elegibilidad ADD folio varchar(25) DEFAULT NULL COMMENT 'Número de Folio de la Partida de Nacimiento';
ALTER TABLE ds_elegibilidad ADD id_municipio_nacimiento int DEFAULT NULL COMMENT 'Muncipio de nacimiento de la persona';



