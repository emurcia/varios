
ALTER TABLE ds_elegibilidad ADD hash_certificado varchar(50) DEFAULT NULL;

UPDATE ds_elegibilidad AS de SET hash_certificado = md5(CONCAT(de.dui,de.fecha_nacimiento)) WHERE de.img_foto IS NULL;
