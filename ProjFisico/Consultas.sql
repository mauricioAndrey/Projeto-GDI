--========================================================================================================================================--
--                                                            -- Consultas --                                                              --
--========================================================================================================================================--

-- Quais jogadores possuem mais de 100 sessões? -- (GROUP BY / HAVING / JUNÇÃO INTERNA) --
SELECT J.USERNAME, COUNT(*) AS NUM_SESSOES
FROM SESSAO S
INNER JOIN JOGADOR J ON J.ID = S.IDJ
GROUP BY J.USERNAME
HAVING NUM_SESSOES > 100;

--========================================================================================================================================--

-- Quais itens que são produtos, mas não são matérias primas? -- (ANTI JUNÇÃO / SEMI JUNÇÃO / SUBCONSULTA LINHA) --
SELECT * 
FROM ITEM 
WHERE ID NOT IN (
    SELECT IDMP
    FROM COMPOE 
) AND 
ID IN (
    SELECT IDP 
    FROM COMPOE
);

--========================================================================================================================================--

-- Quais os IDs dos servos que não preotegem fortalezas -- (JUNÇÃO EXTERNA) --
SELECT IDC
FROM SERVO LEFT JOIN PROTEGE 
ON SERVO.IDC = PROTEGE.IDCS 
WHERE PROTEGE.IDCS IS NULL;

--========================================================================================================================================--

-- Quais os códigos das estruturas que não são fortaleza nem vila? -- (OPERAÇÃO DE CONJUNTO) --
SELECT CODIGO
FROM ESTRUTURA EXCEPT (
    SELECT CODIGO_E FROM FORTALEZA 
    UNION 
    SELECT CODIGO_E FROM VILA
);

--========================================================================================================================================--

-- Quais são as coordenadas da estrutura em que o chefe de ID = 129 comanda? -- (SUBCONSULTA ESCALAR) --
SELECT X, Y, Z
FROM ESTRUTURA
WHERE CODIGO = (
    SELECT CODIGO_EF
    FROM CHEFE
    WHERE IDC = 129
);

--========================================================================================================================================--

-- Quais os usernames dos jogadores não foram punidos em um servidor? -- (JUNÇÃO EXTERNA / SUBCONSULTA TABELA) --
SELECT J.USERNAME
FROM JOGADOR J
WHERE NOT EXISTS(SELECT * FROM PUNIDO P WHERE P.IDJA = J.ID);

--========================================================================================================================================--

-- Quais as coordenadas dos chefes que possuem o atributo fogo? -- (JUNÇÃO INTERNA / SUBCONSULTA LINHA) --
SELECT C.IDC AS CHEFE, E.x, E.y, E.z
FROM CHEFE C INNER JOIN Estrutura E ON C.Codigo_EF = E.Codigo 
WHERE C.IDC IN (
    SELECT A.IDCC
    FROM ATRIBUTO A
    WHERE A.ATRIBUTO = 'Fogo'
);

--========================================================================================================================================--

-- Quais as quantidades de cada tipo de item que o jogador Gabriel possui? -- (JUNÇÃO INTERNA / SUBCONSULTA LINHA / GROUP BY) --
SELECT I.TIPO AS TIPO, SUM(P.QUANTIDADE) AS Total
FROM POSSUI P
INNER JOIN ITEM I ON P.IDI = I.ID
WHERE P.IDJ IN ( 
    SELECT J.ID
    FROM JOGADOR J
    WHERE J.USERNAME = 'Gabriel'
)
GROUP BY I.TIPO 
ORDER BY Total DESC;

--========================================================================================================================================--

-- Quais os nomes das criaturas, juntamente com seu atributo e localização, que dropam obsidiana com sua respectiva probabilidade -- (JUNÇÃO INTERNA) --
SELECT
    C.NOME,
    S.ATRIBUTO,
    TO_CHAR(P.CODIGO_EF, '000') AS CÓDIGO_MASMORRA,
    TO_CHAR(D.PROBABILIDADE, '0.99') AS PROBABILIDADE_DROPE
FROM PROTEGE P 
INNER JOIN SERVO S ON P.IDCS = S.IDC
INNER JOIN CRIATURA C ON C.ID = S.IDC
INNER JOIN DROPA D ON C.ID = D.IDC
WHERE D.IDI = '10522'
ORDER BY P.CODIGO_EF ASC, S.ATRIBUTO ASC;

--========================================================================================================================================--

-- Quais os nomes e os atributos dos chefes que comandam alguma fortaleza e dropam obsidiana com sua respectiva probabilidade -- (JUNÇÃO INTERNA / GROUP BY) --
SELECT 
    C.NOME, 
    LISTAGG(A.ATRIBUTO, ', ') WITHIN GROUP (ORDER BY A.ATRIBUTO) AS ATRIBUTOS,
    TO_CHAR(B.CODIGO_EF, '000') AS CÓDIGO_MASMORRA, 
    TO_CHAR(D.PROBABILIDADE, '0.99') AS PROBABILIDADE_DROPE
FROM CHEFE B
INNER JOIN CRIATURA C ON C.ID = B.IDC
INNER JOIN ATRIBUTO A ON A.IDCC = B.IDC
INNER JOIN DROPA D ON C.ID = D.IDC
WHERE D.IDI = '10522' AND B.CODIGO_EF IS NOT NULL
GROUP BY C.NOME, B.CODIGO_EF, D.PROBABILIDADE
ORDER BY B.CODIGO_EF ASC, C.NOME ASC;

--========================================================================================================================================--

-- Quais os mundos por servidor? -- (JUNÇÃO EXTERNA / GROUP BY) --
SELECT 
    S.ID AS ID_SERVIDOR,
    S.NOME AS NOME_SERVIDOR,
    COUNT(M.INDICE) AS NUMERO_DE_MUNDOS
FROM SERVIDOR S
LEFT JOIN MUNDO M ON S.ID = M.IDS
GROUP BY  S.ID, S.NOME
ORDER BY S.ID;

--========================================================================================================================================--

-- Exemplo de uso da função --
DECLARE
    distancia NUMBER;
BEGIN
    -- Calcula a distância entre as estruturas
    distancia := DISTANCIA_ESTRUTURAS(001, 002);

    -- Exibe o resultado
    IF distancia IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('As estruturas são iguais.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Distância calculada: ' || TO_CHAR(distancia, '999999.99'));
    END IF;
END;
/

--========================================================================================================================================--
