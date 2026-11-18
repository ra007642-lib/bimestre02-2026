-- quant. registros tabelas (conferindo)
SELECT 'marca' AS tabela, COUNT(*) AS quantidade FROM marca
UNION ALL
SELECT 'fornecedor', COUNT(*) FROM fornecedor
UNION ALL
SELECT 'categoria', COUNT(*) FROM categoria
UNION ALL
SELECT 'cliente', COUNT(*) FROM cliente
UNION ALL
SELECT 'produto', COUNT(*) FROM produto
UNION ALL
SELECT 'venda', COUNT(*) FROM venda
UNION ALL
SELECT 'item_venda', COUNT(*) FROM item_venda;

SELECT current_database();

-- TRABALHO 03 - Operadores e funções SQL
-- Projeto: Anaroma Perfumaria & Cosméticos

-- Complemento de dados
-- Cria um fornecedor sem e-mail para demonstrar IS NULL e garante uma venda recente para a consulta que utiliza NOW() e INTERVAL. Os comandos podem ser executados novamente sem duplicar esses registros

INSERT INTO fornecedor
    (fornecedor_codigo, fornecedor_nome, fornecedor_cnpj,
     fornecedor_telefone, fornecedor_email)
VALUES
    ('FOR-006', 'Fornecedor Complementar Anaroma', '67890123000106',
     '(35) 3333-1006', NULL)
ON CONFLICT (fornecedor_codigo)
DO UPDATE SET fornecedor_email = NULL;

INSERT INTO venda
    (venda_codigo, venda_data, venda_valor_total, cliente_id)
SELECT
    'VND-007',
    NOW() - INTERVAL '2 hours',
    79.90,
    c.cliente_id
FROM cliente c
WHERE c.cliente_codigo = 'CLI-002'
  AND NOT EXISTS (
      SELECT 1
      FROM venda v
      WHERE v.venda_codigo = 'VND-007'
  );

-- Atualiza data e valor da venda complementar caso ela já exista
UPDATE venda
SET venda_data = NOW() - INTERVAL '2 hours',
    venda_valor_total = 79.90
WHERE venda_codigo = 'VND-007';

-- Adiciona o item da venda complementar somente se ainda não existir
INSERT INTO item_venda
    (venda_id, produto_id, item_venda_quantidade,
     item_venda_valor_unitario, item_venda_subtotal)
SELECT
    v.venda_id,
    p.produto_id,
    1,
    79.90,
    79.90
FROM venda v
INNER JOIN produto p
    ON p.produto_codigo = 'PROD-004'
WHERE v.venda_codigo = 'VND-007'
  AND NOT EXISTS (
      SELECT 1
      FROM item_venda iv
      WHERE iv.venda_id = v.venda_id
        AND iv.produto_id = p.produto_id
  );

-- QUESTÃO 1 - AND, OR E PARÊNTESES
-- Regra de negócio: listar produtos ativos de Perfumes ou Maquiagem, com preço a partir de R$ 50,00. Sem os parênteses, o AND tem precedência sobre o OR: produtos da categoria Perfumes poderiam aparecer mesmo sem atender aos outros filtros

SELECT
    p.produto_codigo AS codigo_produto,
    p.produto_nome AS nome_produto,
    c.categoria_nome AS categoria,
    p.produto_valor AS preco
FROM produto p
INNER JOIN categoria c
    ON c.categoria_id = p.categoria_id
WHERE
    (c.categoria_nome = 'Perfumes' OR c.categoria_nome = 'Maquiagem')
    AND p.produto_ativo = TRUE
    AND p.produto_valor >= 50.00
ORDER BY p.produto_valor DESC;


-- QUESTÃO 2A - NOT E IS NULL
-- Regra de negócio: localizar fornecedores ativos que ainda não informaram e-mail para contato

SELECT
    fornecedor_codigo AS codigo_fornecedor,
    fornecedor_nome AS nome_fornecedor,
    fornecedor_telefone AS telefone
FROM fornecedor
WHERE fornecedor_ativo = TRUE
  AND NOT (fornecedor_email IS NOT NULL)
ORDER BY fornecedor_nome;

-- QUESTÃO 2B - IS NOT NULL
-- Regra de negócio: listar fornecedores ativos que possuem e-mail cadastrado, permitindo identificar contatos disponíveis

SELECT
    fornecedor_codigo AS codigo_fornecedor,
    fornecedor_nome AS nome_fornecedor,
    fornecedor_email AS email
FROM fornecedor
WHERE fornecedor_ativo = TRUE
  AND fornecedor_email IS NOT NULL
ORDER BY fornecedor_nome;

-- QUESTÃO 3 - BETWEEN E IN
-- Regra de negócio: encontrar produtos com preço entre R$ 40,00 e R$ 180,00, pertencentes a uma das categorias informadas. BETWEEN inclui os dois limites da faixa de preço

SELECT
    p.produto_codigo AS codigo_produto,
    p.produto_nome AS nome_produto,
    c.categoria_nome AS categoria,
    p.produto_valor AS preco
FROM produto p
INNER JOIN categoria c
    ON c.categoria_id = p.categoria_id
WHERE p.produto_valor BETWEEN 40.00 AND 180.00
  AND c.categoria_nome IN ('Perfumes', 'Hidratantes', 'Body Splash')
ORDER BY p.produto_valor;

-- QUESTÃO 4 A - ILIKE E CURINGA %
-- Regra de negócio: localizar, sem diferenciar maiúsculas e minúsculas, produtos cujo nome contenha a palavra "perfume". O % representa zero ou mais caracteres antes ou depois do termo

SELECT
    produto_codigo AS codigo_produto,
    produto_nome AS nome_produto
FROM produto
WHERE produto_nome ILIKE '%perfume%'
ORDER BY produto_nome;

-- QUESTÃO 4 B - LIKE E CURINGA _
-- Regra de negócio: localizar códigos no padrão PROD- seguido de três caracteres. O _ representa um único caractere


SELECT
    produto_codigo AS codigo_produto,
    produto_nome AS nome_produto
FROM produto
WHERE produto_codigo LIKE 'PROD-___'
ORDER BY produto_codigo;

-- QUESTÃO 5 - ROUND, TRUNC, CEIL E FLOOR
-- Regra de negócio: comparar o preço com acréscimo de 7%, mostrando arredondamento para duas casas, truncamento e arredondamentos inteiro para cima e para baixo

SELECT
    produto_codigo AS codigo_produto,
    produto_nome AS nome_produto,
    produto_valor AS preco_original,
    ROUND(produto_valor * 1.07, 2) AS preco_com_acrescimo_arredondado,
    TRUNC(produto_valor * 1.07, 2) AS preco_com_acrescimo_truncado,
    CEIL(produto_valor * 1.07) AS preco_arredondado_para_cima,
    FLOOR(produto_valor * 1.07) AS preco_arredondado_para_baixo
FROM produto
ORDER BY produto_codigo;

-- QUESTÃO 6A - MOD
-- Regra de negócio: identificar se o identificador de cada produto é par ou ímpar, usando o resto da divisão por 2

SELECT
    produto_codigo AS codigo_produto,
    produto_nome AS nome_produto,
    MOD(produto_id, 2) AS resto_divisao,
    CASE
        WHEN MOD(produto_id, 2) = 0 THEN 'Par'
        ELSE 'Ímpar'
    END AS classificacao_identificador
FROM produto
ORDER BY produto_id;

-- QUESTÃO 6B - RANDOM E ORDER BY RANDOM()
-- Regra de negócio: selecionar aleatoriamente um produto ativo para uma ação promocional ou destaque na loja

SELECT
    produto_codigo AS codigo_produto,
    produto_nome AS nome_produto,
    produto_valor AS preco
FROM produto
WHERE produto_ativo = TRUE
ORDER BY RANDOM()
LIMIT 1;

-- QUESTÃO 7 - CONCAT, UPPER, INITCAP E SPLIT_PART
-- Regra de negócio: gerar uma identificação textual dos produtos, padronizar o nome para apresentação e extrair a parte numérica do código

SELECT
    CONCAT(produto_codigo, ' - ', produto_nome) AS identificacao_produto,
    UPPER(produto_codigo) AS codigo_em_maiusculas,
    INITCAP(produto_nome) AS nome_formatado,
    SPLIT_PART(produto_codigo, '-', 2) AS numero_codigo
FROM produto
ORDER BY produto_codigo;


-- QUESTÃO 8 - EXTRACT, DATE_TRUNC, INTERVAL E NOW()
-- Regra de negócio: consultar vendas realizadas nos últimos 30 dias, exibindo ano, mês e o início do mês correspondente. A venda VND-007, inserida no início do script, garante resultado recente

SELECT
    venda_codigo AS codigo_venda,
    venda_data AS data_venda,
    EXTRACT(YEAR FROM venda_data) AS ano_venda,
    EXTRACT(MONTH FROM venda_data) AS mes_venda,
    DATE_TRUNC('month', venda_data) AS inicio_mes
FROM venda
WHERE venda_data >= NOW() - INTERVAL '30 days'
ORDER BY venda_data DESC;

-- QUESTÃO 9 - AGE, NOW() E PROJEÇÃO COM INTERVAL
-- Regra de negócio: exibir o tempo desde o cadastro de cada cliente e projetar a data de renovação cadastral para um ano após o cadastro

SELECT
    cliente_codigo AS codigo_cliente,
    cliente_nome AS nome_cliente,
    cliente_data_cadastro AS data_cadastro,
    AGE(NOW(), cliente_data_cadastro) AS tempo_desde_cadastro,
    cliente_data_cadastro + INTERVAL '1 year' AS data_projecao_renovacao
FROM cliente
ORDER BY cliente_nome;

-- QUESTÃO 10 - INNER JOIN, TO_CHAR E LPAD
-- Regra de negócio: gerar um relatório gerencial de vendas com o nome do cliente, data em formato brasileiro, valor monetário formatado e identificador numérico preenchido com zeros à esquerda
-- A substituição do ponto por vírgula evita depender do LC_NUMERIC do servidor para exibir o separador decimal em padrão brasileiro

SELECT
    v.venda_codigo AS codigo_venda,
    LPAD(v.venda_id::TEXT, 5, '0') AS identificador_formatado,
    cl.cliente_nome AS nome_cliente,
    TO_CHAR(v.venda_data, 'DD/MM/YYYY') AS data_formatada,
    'R$ ' || REPLACE(
        TO_CHAR(v.venda_valor_total, 'FM999999990.00'),
        '.',
        ','
    ) AS valor_formatado
FROM venda v
INNER JOIN cliente cl
    ON cl.cliente_id = v.cliente_id
ORDER BY v.venda_data DESC;

