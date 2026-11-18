
-- TRABALHO PRÁTICO - GESTÃO DE BANCO DE DADOS
-- Projeto: Anaroma Perfumaria & Cosméticos

-- JUSTIFICATIVA E CONTEXTUALIZAÇÃO:

-- A Anaroma Perfumaria & Cosméticos é uma loja fictícia criada para este trabalho, voltada à venda de perfumes, cosméticos e produtos de cuidados pessoais.
-- A escolha desse tipo de comércio permite trabalhar com situações comuns de uma loja, como o cadastro de produtos, marcas, fornecedores e clientes, além do registro das vendas e dos produtos vendidos em cada uma delas.
-- O objetivo do banco de dados é organizar essas informações, evitar inconsistências e facilitar as consultas necessárias para acompanhar os produtos e as vendas da loja.

SELECT current_database();

-- MARCA: armazena as marcas dos perfumes e cosméticos comercializados
CREATE TABLE marca (
    marca_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    marca_codigo VARCHAR(20) NOT NULL UNIQUE,
    marca_nome VARCHAR(80) NOT NULL UNIQUE,
    marca_descricao VARCHAR(200),
    marca_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    marca_data_criacao TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- FORNECEDOR: armazena as empresas que fornecem produtos a loja
CREATE TABLE fornecedor (
    fornecedor_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fornecedor_codigo VARCHAR(20) NOT NULL UNIQUE,
    fornecedor_nome VARCHAR(100) NOT NULL,
    fornecedor_cnpj VARCHAR(14) NOT NULL UNIQUE,
    fornecedor_telefone VARCHAR(20),
    fornecedor_email VARCHAR(100),
    fornecedor_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    fornecedor_data_criacao TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fornecedor_cnpj_ck CHECK (fornecedor_cnpj ~ '^[0-9]{14}$')
);

-- CATEGORIA: classifica os produtos por tipo
CREATE TABLE categoria (
    categoria_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoria_codigo VARCHAR(20) NOT NULL UNIQUE,
    categoria_nome VARCHAR(60) NOT NULL UNIQUE,
    categoria_descricao VARCHAR(200),
    categoria_ativo BOOLEAN NOT NULL DEFAULT TRUE
);

-- CLIENTE: mantém os dados cadastrais dos consumidores da loja
CREATE TABLE cliente (
    cliente_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cliente_codigo VARCHAR(20) NOT NULL UNIQUE,
    cliente_nome VARCHAR(100) NOT NULL,
    cliente_cpf VARCHAR(11) NOT NULL UNIQUE,
    cliente_email VARCHAR(100) UNIQUE,
    cliente_telefone VARCHAR(20),
    cliente_data_cadastro TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cliente_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT cliente_cpf_ck CHECK (cliente_cpf ~ '^[0-9]{11}$')
);

-- PRODUTO: registra produtos, preços, estoque e seus vínculos comerciais
CREATE TABLE produto (
    produto_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    produto_codigo VARCHAR(20) NOT NULL UNIQUE,
    produto_nome VARCHAR(100) NOT NULL,
    produto_descricao VARCHAR(200),
    produto_valor NUMERIC(10, 2) NOT NULL,
    produto_estoque INTEGER NOT NULL DEFAULT 0,
    produto_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    produto_data_criacao TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    marca_id INTEGER NOT NULL,
    fornecedor_id INTEGER NOT NULL,
    categoria_id INTEGER NOT NULL,
    CONSTRAINT produto_valor_ck CHECK (produto_valor > 0),
    CONSTRAINT produto_estoque_ck CHECK (produto_estoque >= 0),
    CONSTRAINT produto_marca_fk FOREIGN KEY (marca_id)
        REFERENCES marca (marca_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT produto_fornecedor_fk FOREIGN KEY (fornecedor_id)
        REFERENCES fornecedor (fornecedor_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT produto_categoria_fk FOREIGN KEY (categoria_id)
        REFERENCES categoria (categoria_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- VENDA: registra cada compra, seu cliente, data e valor total
CREATE TABLE venda (
    venda_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venda_codigo VARCHAR(20) NOT NULL UNIQUE,
    venda_data TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    venda_valor_total NUMERIC(10, 2) NOT NULL,
    cliente_id INTEGER NOT NULL,
    CONSTRAINT venda_valor_total_ck CHECK (venda_valor_total > 0),
    CONSTRAINT venda_cliente_fk FOREIGN KEY (cliente_id)
        REFERENCES cliente (cliente_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- ITEM_VENDA: detalha os produtos, quantidades e valores de cada venda. Também resolve o relacionamento muitos-para-muitos entre venda e produto
CREATE TABLE item_venda (
    item_venda_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venda_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    item_venda_quantidade INTEGER NOT NULL,
    item_venda_valor_unitario NUMERIC(10, 2) NOT NULL,
    item_venda_subtotal NUMERIC(10, 2) NOT NULL,
    CONSTRAINT item_venda_quantidade_ck CHECK (item_venda_quantidade > 0),
    CONSTRAINT item_venda_valor_ck CHECK (item_venda_valor_unitario > 0),
    CONSTRAINT item_venda_subtotal_ck CHECK (
        item_venda_subtotal = item_venda_quantidade * item_venda_valor_unitario
    ),
    CONSTRAINT item_venda_venda_fk FOREIGN KEY (venda_id)
        REFERENCES venda (venda_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT item_venda_produto_fk FOREIGN KEY (produto_id)
        REFERENCES produto (produto_id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- // INSERÇÃO DE DADOS 
BEGIN;

-- MARCAS (5 registros)
INSERT INTO marca (marca_codigo, marca_nome, marca_descricao) VALUES
('MRC-001', 'Essenciale', 'Marca de perfumes e fragrâncias.'),
('MRC-002', 'Maison Aroma', 'Marca de perfumaria.'),
('MRC-003', 'Bella Pele', 'Marca de produtos para cuidados pessoais.'),
('MRC-004', 'GlamUp', 'Marca de maquiagem.'),
('MRC-005', 'Dermavita', 'Marca de dermocosméticos e cuidados com a pele.');

-- FORNECEDORES -5 registros
INSERT INTO fornecedor
(fornecedor_codigo, fornecedor_nome, fornecedor_cnpj, fornecedor_telefone, fornecedor_email)
VALUES
('FOR-001', 'Distribuidora Aroma Minas', '12345678000101', '(35) 3333-1001', 'contato@aromaminas.com.br'),
('FOR-002', 'Comercial Beleza Brasil', '23456789000102', '(35) 3333-1002', 'vendas@belezabrasil.com.br'),
('FOR-003', 'Atacado Bella Distribuição', '34567890000103', '(35) 3333-1003', 'atendimento@belladistribuicao.com.br'),
('FOR-004', 'Glam Distribuidora', '45678901000104', '(35) 3333-1004', 'contato@glamdistribuidora.com.br'),
('FOR-005', 'Derma Minas Comércio', '56789012000105', '(35) 3333-1005', 'vendas@dermaminas.com.br');

-- CATEGORIAS - 5 registros
INSERT INTO categoria (categoria_codigo, categoria_nome, categoria_descricao) VALUES
('CAT-001', 'Perfumes', 'Perfumes e fragrâncias.'),
('CAT-002', 'Hidratantes', 'Cremes e loções hidratantes.'),
('CAT-003', 'Body Splash', 'Fragrâncias corporais leves.'),
('CAT-004', 'Maquiagem', 'Produtos de maquiagem.'),
('CAT-005', 'Cuidados Pessoais', 'Produtos para higiene e cuidados com pele e cabelo.');

-- CLIENTES -5 registros
INSERT INTO cliente
(cliente_codigo, cliente_nome, cliente_cpf, cliente_email, cliente_telefone)
VALUES
('CLI-001', 'Ana Martins', '12345678901', 'ana.martins@email.com', '(35) 99111-1001'),
('CLI-002', 'Bruno Almeida', '23456789012', 'bruno.almeida@email.com', '(35) 99222-1002'),
('CLI-003', 'Carla Souza', '34567890123', 'carla.souza@email.com', '(35) 99333-1003'),
('CLI-004', 'Diego Ferreira', '45678901234', 'diego.ferreira@email.com', '(35) 99444-1004'),
('CLI-005', 'Elisa Costa', '56789012345', 'elisa.costa@email.com', '(35) 99555-1005');

-- PRODUTOS -10 registros
INSERT INTO produto
(produto_codigo, produto_nome, produto_descricao, produto_valor,
 produto_estoque, marca_id, fornecedor_id, categoria_id)
VALUES
('PROD-001', 'Perfume Aurora Floral', 'Fragrância floral de 100 ml.', 150.00, 20,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-001'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-001'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-001')),
('PROD-002', 'Perfume Intenso Amadeirado', 'Fragrância amadeirada de 100 ml.', 220.00, 12,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-002'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-002'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-001')),
('PROD-003', 'Hidratante Corporal Baunilha', 'Hidratante corporal de 200 g.', 65.00, 25,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-003'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-003'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-002')),
('PROD-004', 'Body Splash Frutas Vermelhas', 'Fragrância corporal de 200 ml.', 79.90, 18,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-001'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-001'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-003')),
('PROD-005', 'Shampoo Nutrição', 'Shampoo para cuidados capilares de 300 ml.', 42.00, 30,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-003'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-003'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-005')),
('PROD-006', 'Máscara de Cílios Volume', 'Máscara para cílios com efeito volume.', 55.00, 15,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-004'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-004'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-004')),
('PROD-007', 'Protetor Solar FPS 50', 'Protetor solar facial FPS 50.', 68.00, 22,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-005'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-005'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-005')),
('PROD-008', 'Sabonete Facial', 'Sabonete facial para limpeza diária.', 18.00, 40,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-005'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-005'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-005')),
('PROD-009', 'Sérum Vitamina C', 'Sérum facial com vitamina C.', 95.00, 16,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-005'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-005'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-005')),
('PROD-010', 'Perfume Cítrico', 'Fragrância cítrica de 100 ml.', 180.00, 10,
 (SELECT marca_id FROM marca WHERE marca_codigo = 'MRC-002'),
 (SELECT fornecedor_id FROM fornecedor WHERE fornecedor_codigo = 'FOR-002'),
 (SELECT categoria_id FROM categoria WHERE categoria_codigo = 'CAT-001'));

-- VENDAS -6 registros
INSERT INTO venda (venda_codigo, venda_data, venda_valor_total, cliente_id) VALUES
('VND-001', '2026-10-01 10:30:00', 215.00,
 (SELECT cliente_id FROM cliente WHERE cliente_codigo = 'CLI-001')),
('VND-002', '2026-10-02 14:15:00', 159.80,
 (SELECT cliente_id FROM cliente WHERE cliente_codigo = 'CLI-002')),
('VND-003', '2026-10-03 11:00:00', 220.00,
 (SELECT cliente_id FROM cliente WHERE cliente_codigo = 'CLI-003')),
('VND-004', '2026-10-04 16:20:00', 115.00,
 (SELECT cliente_id FROM cliente WHERE cliente_codigo = 'CLI-004')),
('VND-005', '2026-10-05 09:45:00', 163.00,
 (SELECT cliente_id FROM cliente WHERE cliente_codigo = 'CLI-005')),
('VND-006', '2026-10-06 13:10:00', 180.00,
 (SELECT cliente_id FROM cliente WHERE cliente_codigo = 'CLI-001'));

-- ITENS DE VENDA -10 registros
INSERT INTO item_venda
(venda_id, produto_id, item_venda_quantidade, item_venda_valor_unitario, item_venda_subtotal)
VALUES
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-001'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-001'), 1, 150.00, 150.00),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-001'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-003'), 1, 65.00, 65.00),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-002'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-004'), 2, 79.90, 159.80),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-003'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-002'), 1, 220.00, 220.00),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-004'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-005'), 1, 42.00, 42.00),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-004'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-006'), 1, 55.00, 55.00),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-004'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-008'), 1, 18.00, 18.00),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-005'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-007'), 1, 68.00, 68.00),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-005'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-009'), 1, 95.00, 95.00),
((SELECT venda_id FROM venda WHERE venda_codigo = 'VND-006'),
 (SELECT produto_id FROM produto WHERE produto_codigo = 'PROD-010'), 1, 180.00, 180.00);

COMMIT;

-- //CONSULTAS SQL

-- Produtos com suas marcas, categorias e fornecedores
SELECT p.produto_codigo, p.produto_nome, m.marca_nome,
       c.categoria_nome, f.fornecedor_nome, p.produto_valor, p.produto_estoque
FROM produto p
INNER JOIN marca m ON p.marca_id = m.marca_id
INNER JOIN categoria c ON p.categoria_id = c.categoria_id
INNER JOIN fornecedor f ON p.fornecedor_id = f.fornecedor_id
ORDER BY p.produto_nome;

-- Produtos ativos com preço acima de R$ 80,00.
SELECT produto_codigo, produto_nome, produto_valor
FROM produto
WHERE produto_ativo = TRUE AND produto_valor > 80.00
ORDER BY produto_valor DESC;

-- Vendas com os nomes dos respectivos clientes
SELECT v.venda_codigo, v.venda_data, cl.cliente_nome, v.venda_valor_total
FROM venda v
INNER JOIN cliente cl ON v.cliente_id = cl.cliente_id
ORDER BY v.venda_data;

-- Detalhamento dos produtos que compõem cada venda
SELECT v.venda_codigo, p.produto_nome, iv.item_venda_quantidade,
       iv.item_venda_valor_unitario, iv.item_venda_subtotal
FROM item_venda iv
INNER JOIN venda v ON iv.venda_id = v.venda_id
INNER JOIN produto p ON iv.produto_id = p.produto_id
ORDER BY v.venda_codigo, p.produto_nome;

-- Quantidade de vendas e total gasto por cliente (GROUP BY)
SELECT cl.cliente_nome, COUNT(v.venda_id) AS quantidade_vendas,
       SUM(v.venda_valor_total) AS total_gasto
FROM cliente cl
INNER JOIN venda v ON cl.cliente_id = v.cliente_id
GROUP BY cl.cliente_id, cl.cliente_nome
ORDER BY total_gasto DESC;

-- Faturamento por categoria (JOIN e GROUP BY)
SELECT c.categoria_nome, SUM(iv.item_venda_subtotal) AS faturamento_categoria
FROM item_venda iv
INNER JOIN produto p ON iv.produto_id = p.produto_id
INNER JOIN categoria c ON p.categoria_id = c.categoria_id
GROUP BY c.categoria_id, c.categoria_nome
ORDER BY faturamento_categoria DESC;

-- Produtos mais vendidos em quantidade
SELECT p.produto_nome, SUM(iv.item_venda_quantidade) AS quantidade_vendida
FROM item_venda iv
INNER JOIN produto p ON iv.produto_id = p.produto_id
GROUP BY p.produto_id, p.produto_nome
ORDER BY quantidade_vendida DESC, p.produto_nome;

-- Clientes que realizaram mais de uma venda (HAVING)
SELECT cl.cliente_nome, COUNT(v.venda_id) AS quantidade_vendas,
       SUM(v.venda_valor_total) AS total_gasto
FROM cliente cl
INNER JOIN venda v ON cl.cliente_id = v.cliente_id
GROUP BY cl.cliente_id, cl.cliente_nome
HAVING COUNT(v.venda_id) > 1
ORDER BY quantidade_vendas DESC;

-- Faturamento agrupado por ano e mês
SELECT EXTRACT(YEAR FROM venda_data) AS ano,
       EXTRACT(MONTH FROM venda_data) AS mes,
       SUM(venda_valor_total) AS faturamento_mensal
FROM venda
GROUP BY EXTRACT(YEAR FROM venda_data), EXTRACT(MONTH FROM venda_data)
ORDER BY ano, mes;
