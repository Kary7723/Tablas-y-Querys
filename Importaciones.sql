-- Tabla Importador
CREATE TABLE Importador (
    id_importador NUMBER PRIMARY KEY,
    nombre VARCHAR2(50),
    apellido VARCHAR2(50),
    empresa VARCHAR2(100),
    fecha_registro DATE,
    email VARCHAR2(100),
    telefono VARCHAR2(20)
);

-- Tabla Importacion
CREATE TABLE Importacion (
    codigo_importacion NUMBER PRIMARY KEY,
    fecha_llegada DATE,
    descripcion VARCHAR2(200),
    id_importador_responsable NUMBER,
    FOREIGN KEY (id_importador_responsable) REFERENCES Importador(id_importador)
);

-- Tabla Importacion_Importador (para la relación muchos a muchos entre Importacion e Importador)
CREATE TABLE Importacion_Importador (
    codigo_importacion NUMBER,
    id_importador NUMBER,
    PRIMARY KEY (codigo_importacion, id_importador),
    FOREIGN KEY (codigo_importacion) REFERENCES Importacion(codigo_importacion),
    FOREIGN KEY (id_importador) REFERENCES Importador(id_importador)
);

-- Tabla Producto
CREATE TABLE Producto (
    id_producto NUMBER PRIMARY KEY,
    codigo_importacion NUMBER,
    descripcion VARCHAR2(200),
    valor_declarado NUMBER(10,2),
    estado VARCHAR2(10) CHECK (estado IN ('en_transito', 'recibido')),
    usuario_registro VARCHAR2(50),
    FOREIGN KEY (codigo_importacion) REFERENCES Importacion(codigo_importacion)
);

-- Insertar datos de ejemplo

-- Insertar importadores
INSERT INTO Importador VALUES (1, 'Roberto', 'García', 'ImportEx S.A.', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 'roberto@importex.com', '123456789');
INSERT INTO Importador VALUES (2, 'Ana', 'Martínez', 'Global Imports Ltd.', TO_DATE('2019-08-20', 'YYYY-MM-DD'), 'ana@globalimports.com', '987654321');
INSERT INTO Importador VALUES (3, 'Carlos', 'Rodríguez', 'Mega Importaciones', TO_DATE('2021-03-10', 'YYYY-MM-DD'), 'carlos@megaimport.com', '456789123');

-- Insertar importaciones
INSERT INTO Importacion VALUES (1, TO_DATE('2024-09-19', 'YYYY-MM-DD'), 'Electrónicos de Asia', 1);
INSERT INTO Importacion VALUES (2, TO_DATE('2024-09-20', 'YYYY-MM-DD'), 'Textiles de India', 2);
INSERT INTO Importacion VALUES (3, TO_DATE('2024-09-21', 'YYYY-MM-DD'), 'Alimentos de Sudamérica', 3);
INSERT INTO Importacion VALUES (4, TO_DATE('2024-09-22', 'YYYY-MM-DD'), 'Maquinaria de Alemania', 1);
INSERT INTO Importacion VALUES (5, TO_DATE('2024-09-23', 'YYYY-MM-DD'), 'Juguetes de China', 2);
INSERT INTO Importacion VALUES (6, TO_DATE('2024-09-24', 'YYYY-MM-DD'), 'Vinos de Francia', 3);
INSERT INTO Importacion VALUES (7, TO_DATE('2024-09-25', 'YYYY-MM-DD'), 'Automóviles de Japón', 1);
INSERT INTO Importacion VALUES (8, TO_DATE('2024-09-26', 'YYYY-MM-DD'), 'Cosméticos de Corea', 2);
INSERT INTO Importacion VALUES (9, TO_DATE('2024-09-27', 'YYYY-MM-DD'), 'Café de Colombia', 3);
INSERT INTO Importacion VALUES (10, TO_DATE('2024-09-28', 'YYYY-MM-DD'), 'Tecnología de EE.UU.', 1);

-- Asociar importaciones con importadores
INSERT INTO Importacion_Importador VALUES (1, 1);
INSERT INTO Importacion_Importador VALUES (1, 2);
INSERT INTO Importacion_Importador VALUES (2, 2);
INSERT INTO Importacion_Importador VALUES (3, 3);
INSERT INTO Importacion_Importador VALUES (4, 1);
INSERT INTO Importacion_Importador VALUES (5, 2);
INSERT INTO Importacion_Importador VALUES (6, 3);
INSERT INTO Importacion_Importador VALUES (7, 1);
INSERT INTO Importacion_Importador VALUES (8, 2);
INSERT INTO Importacion_Importador VALUES (9, 3);
INSERT INTO Importacion_Importador VALUES (10, 1);

-- Insertar productos
INSERT INTO Producto VALUES (1, 1, 'Smartphones', 50000.00, 'en_transito', 'aduanas1');
INSERT INTO Producto VALUES (2, 1, 'Laptops', 75000.00, 'en_transito', 'aduanas1');
INSERT INTO Producto VALUES (3, 1, 'Tablets', 30000.00, 'recibido', 'aduanas2');
INSERT INTO Producto VALUES (4, 2, 'Camisetas de algodón', 20000.00, 'en_transito', 'aduanas2');
INSERT INTO Producto VALUES (5, 2, 'Pantalones de mezclilla', 35000.00, 'en_transito', 'aduanas2');
INSERT INTO Producto VALUES (6, 3, 'Café orgánico', 15000.00, 'en_transito', 'aduanas3');
INSERT INTO Producto VALUES (7, 3, 'Quinoa', 10000.00, 'recibido', 'aduanas3');
INSERT INTO Producto VALUES (8, 3, 'Chocolate artesanal', 5000.00, 'en_transito', 'aduanas3');
-- Continuar insertando productos para las demás importaciones...

-- Consulta para contar productos por importación
SELECT i.codigo_importacion AS codigo_importacion, i.descripcion, COUNT(p.id_producto) AS cantidad_productos
FROM Importacion i
LEFT JOIN Producto p ON i.codigo_importacion = p.codigo_importacion
GROUP BY i.codigo_importacion, i.descripcion
ORDER BY i.codigo_importacion;

-- Consulta para contar importaciones por importador
SELECT im.id_importador AS id_importador, im.nombre || ' ' || im.apellido AS nombre_importador, COUNT(ii.codigo_importacion) AS cantidad_importaciones
FROM Importador im
LEFT JOIN Importacion_Importador ii ON im.id_importador = ii.id_importador
GROUP BY im.id_importador, im.nombre, im.apellido
ORDER BY im.id_importador;

-- Consulta Valor total de productos en tránsito por importación
SELECT 
    i.codigo_importacion AS codigo_importacion,
    i.descripcion AS descripcion_importacion,
    COUNT(p.id_producto) AS total_productos,
    COUNT(CASE WHEN p.estado = 'en_transito' THEN 1 END) AS productos_en_transito,
    SUM(CASE WHEN p.estado = 'en_transito' THEN p.valor_declarado ELSE 0 END) AS valor_total_en_transito
FROM 
    Importacion i
LEFT JOIN 
    Producto p ON i.codigo_importacion = p.codigo_importacion
GROUP BY 
    i.codigo_importacion, i.descripcion
ORDER BY 
    valor_total_en_transito DESC;

-- Consulta Importadores con más de una importación y sus productos asociados
SELECT 
    im.id_importador AS id_importador,
    im.nombre || ' ' || im.apellido AS nombre_importador,
    COUNT(DISTINCT ii.codigo_importacion) AS cantidad_importaciones,
    COUNT(p.id_producto) AS total_productos,
    SUM(p.valor_declarado) AS valor_total_productos
FROM 
    Importador im
JOIN 
    Importacion_Importador ii ON im.id_importador = ii.id_importador
JOIN 
    Importacion i ON ii.codigo_importacion = i.codigo_importacion
LEFT JOIN 
    Producto p ON i.codigo_importacion = p.codigo_importacion
GROUP BY 
    im.id_importador, im.nombre, im.apellido
HAVING 
    COUNT(DISTINCT ii.codigo_importacion) > 1
ORDER BY 
    cantidad_importaciones DESC, valor_total_productos DESC;