-- USUARIOS

-- Usuario administrador
CREATE USER 'usuario_admin'@'localhost' IDENTIFIED BY 'admin123*';
GRANT 'rol_administrador' TO 'usuario_admin'@'localhost';
SET DEFAULT ROLE 'rol_administrador' TO 'usuario_admin'@'localhost';

FLUSH PRIVILEGES;

-- Usuario gerente

CREATE USER 'usuario_gerente'@'localhost' IDENTIFIED BY 'gerente123*';
GRANT 'rol_gerente' TO 'usuario_gerente'@'localhost';
SET DEFAULT ROLE 'rol_gerente' TO 'usuario_gerente'@'localhost';

FLUSH PRIVILEGES;

-- Usuario vendedor

CREATE USER 'usuario_vendedor'@'localhost' IDENTIFIED BY 'vendedor123*';
GRANT 'rol_vendedor' TO 'usuario_vendedor'@'localhost';
SET DEFAULT ROLE 'rol_vendedor' TO 'usuario_vendedor'@'localhost';
FLUSH PRIVILEGES;

-- Usuario cajero

CREATE USER 'usuario_cajero'@'localhost' IDENTIFIED BY 'Cajero123*';
GRANT 'rol_cajero' TO 'usuario_cajero'@'localhost';
SET DEFAULT ROLE 'rol_cajero' TO 'usuario_cajero'@'localhost';
FLUSH PRIVILEGES;

-- Usuario auditor

CREATE USER 'usuario_auditor'@'localhost' IDENTIFIED BY 'Auditor123*';
GRANT 'rol_auditor' TO 'usuario_auditor'@'localhost';
SET DEFAULT ROLE 'rol_auditor' TO 'usuario_auditor'@'localhost';
FLUSH PRIVILEGES;

-- Verificacion
-- Ver privilegios de cada usuario
SHOW GRANTS FOR 'usuario_admin'@'localhost';
SHOW GRANTS FOR 'usuario_gerente'@'localhost';
SHOW GRANTS FOR 'usuario_cajero'@'localhost';
SHOW GRANTS FOR 'usuario_vendedor'@'localhost';
SHOW GRANTS FOR 'usuario_auditor'@'localhost';





