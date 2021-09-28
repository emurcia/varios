ALTER TABLE ds_elegibilidad ADD habilitado_3ra_dosis BOOL DEFAULT false NOT NULL;

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `indice_busqueda` AS
select
    `e`.`id` AS `id`,
    `e`.`codigo` AS `codigo`,
    `e`.`dui` AS `dui`,
    replace(`e`.`dui`,
    '-',
    '') AS `documento`,
    `e`.`tipo_doc` AS `tipo_doc`,
    `e`.`primer_nombre` AS `primer_nombre`,
    `e`.`segundo_nombre` AS `segundo_nombre`,
    `e`.`tercer_nombre` AS `tercer_nombre`,
    `e`.`primer_apellido` AS `primer_apellido`,
    `e`.`segundo_apellido` AS `segundo_apellido`,
    `e`.`apellido_casada` AS `apellido_casada`,
    concat(`e`.`primer_apellido`, ' ', coalesce(if((`e`.`apellido_casada` = ''), NULL, concat('DE ', `e`.`apellido_casada`)), coalesce(`e`.`segundo_apellido`, '')), ', ', coalesce(`e`.`primer_nombre`, ''), ' ', coalesce(`e`.`segundo_nombre`, '')) AS `nombre_completo`,
    `e`.`fecha_nacimiento` AS `fecha_nacimiento`,
    `e`.`calle_avenida` AS `calle_avenida`,
    `e`.`casa_apartamento` AS `casa_apartamento`,
    `e`.`telefono` AS `telefono`,
    `e`.`correo` AS `correo`,
    `ps`.`nombre` AS `pais/nombre`,
    `ps`.`dominio2` AS `pais/dominio2`,
    `ps`.`dominio3` AS `pais/dominio3`,
    `mn`.`id_departamento` AS `municipio/id_departamento`,
    `mn`.`nombre` AS `municipio/nombre`,
    `mn`.`abreviatura` AS `municipio/abreviatura`,
    `mndp`.`nombre` AS `municipio/departamento/nombre`,
    `mndp`.`abreviatura` AS `municipio/departamento/abreviatura`,
    `mndp`.`id_pais` AS `municipio/departamento/id_pais`,
    `cl`.`nombre` AS `colonia/nombre`,
    `cl`.`nombre_min` AS `colonia/nombre_min`,
    `cl`.`nombre_may` AS `colonia/nombre_may`,
    `e`.`id_fase` AS `id_fase`,
    `e`.`img_foto` AS `foto/img_foto`
from
    (((((`ds_elegibilidad` `e`
left join `ds_pais` `ps` on
    ((`e`.`id_pais_domicilio` = `ps`.`id`)))
left join `ds_colonia` `cl` on
    ((`e`.`id_colonia_domicilio` = `cl`.`id`)))
left join `ds_canton` `ct` on
    ((`e`.`id_canton_domicilio` = `ct`.`id`)))
left join `ds_municipio` `mn` on
    ((`e`.`id_municipio_domicilio` = `mn`.`id`)))
left join `ds_departamento` `mndp` on
    ((`mn`.`id_departamento` = `mndp`.`id`)));
    
    
    
ALTER TABLE ds_fase ADD habilitado BOOL DEFAULT false NOT NULL;
