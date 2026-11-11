-- PROJETO ANAROMA 

-- 1: consultar produto pelo ID
CREATE OR REPLACE FUNCTION consultar_produto(p_produto_id INT)
RETURNS TEXT AS $$
DECLARE
    v_nome TEXT;
    v_preco NUMERIC(10, 2);
    v_estoque INTEGER;
BEGIN
    SELECT produto_nome, produto_valor, produto_estoque
    INTO v_nome, v_preco, v_estoque
    FROM produto
    WHERE produto_id = p_produto_id;

    IF NOT FOUND THEN
        RETURN 'Produto não encontrado!';
    END IF;

    RETURN 'Produto: ' || v_nome ||
           ' | Preço: R$ ' || v_preco::TEXT ||
           ' | Estoque: ' || v_estoque::TEXT;
END;
$$ LANGUAGE plpgsql;


-- 2: calc. total de uma venda
CREATE OR REPLACE FUNCTION calcular_total_venda(p_venda_id INT)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    v_total NUMERIC(10, 2);
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM venda
        WHERE venda_id = p_venda_id
    ) THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(SUM(item_venda_subtotal), 0)
    INTO v_total
    FROM item_venda
    WHERE venda_id = p_venda_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;


-- 3: calc. faturamento por categoria
CREATE OR REPLACE FUNCTION faturamento_categoria(p_categoria_id INT)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    v_faturamento NUMERIC(10, 2);
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM categoria
        WHERE categoria_id = p_categoria_id
    ) THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(SUM(iv.item_venda_subtotal), 0)
    INTO v_faturamento
    FROM item_venda iv
    INNER JOIN produto p
        ON iv.produto_id = p.produto_id
    WHERE p.categoria_id = p_categoria_id;

    RETURN v_faturamento;
END;
$$ LANGUAGE plpgsql;

SELECT current_database();
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION' AND routine_name IN ('consultar_produto','calcular_total_venda','faturamento_categoria'
  );

SELECT consultar_produto(1);

SELECT calcular_total_venda(1);

SELECT faturamento_categoria(1);

