--========================================================================================================================================--
--                                                            -- Consultas --                                                              --
--========================================================================================================================================--

-- Quais jogadores possuem mais de 100 sessões? --
SELECT J.USERNAME, COUNT(*) AS NUM_SESSOES
FROM SESSAO S
INNER JOIN JOGADOR J ON J.ID = S.IDJ
GROUP BY J.USERNAME
HAVING COUNT(*) > 100;

--========================================================================================================================================--

-- Quais itens que são produtos, mas não são matérias primas? --
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

-- Quais os IDs dos servos que não preotegem fortalezas --
SELECT IDC
FROM SERVO S 
LEFT JOIN PROTEGE P ON S.IDC = P.IDCS 
WHERE P.IDCS IS NULL;

--========================================================================================================================================--

-- Quais os códigos das estruturas que não são fortaleza nem vila? --
SELECT TO_CHAR(CODIGO, '000')
FROM ESTRUTURA
MINUS (
    SELECT TO_CHAR(CODIGO_E, '000') FROM FORTALEZA 
    UNION 
    SELECT TO_CHAR(CODIGO_E, '000') FROM VILA
);

--========================================================================================================================================--

-- Quais são as coordenadas da estrutura em que o chefe de ID = 129 comanda? --
SELECT X, Y, Z
FROM ESTRUTURA
WHERE CODIGO = (
    SELECT CODIGO_EF
    FROM CHEFE
    WHERE IDC = 129
);

--========================================================================================================================================--

-- Quais os usernames dos jogadores não foram punidos em um servidor? --
SELECT J.USERNAME
FROM JOGADOR J
WHERE NOT EXISTS(SELECT * FROM PUNIDO P WHERE P.IDJA = J.ID);

--========================================================================================================================================--

-- Quais as coordenadas dos chefes que possuem o atributo fogo? --
SELECT TO_CHAR(C.IDC, '000') AS CHEFE, E.x, E.y, E.z
FROM CHEFE C INNER JOIN Estrutura E ON C.Codigo_EF = E.Codigo 
WHERE C.IDC IN (
    SELECT A.IDCC
    FROM ATRIBUTO A
    WHERE A.ATRIBUTO = 'Fogo'
);

--========================================================================================================================================--

-- Quais as quantidades de cada tipo de item que o jogador Gabriel possui? --
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

-- Quais os nomes das criaturas, juntamente com seu atributo e localização, que dropam obsidiana com sua respectiva probabilidade --
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

-- Quais os nomes e os atributos dos chefes que comandam alguma fortaleza e dropam obsidiana com sua respectiva probabilidade --
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

-- Quais os mundos por servidor? --
SELECT 
    S.ID AS ID_SERVIDOR,
    S.NOME AS NOME_SERVIDOR,
    COUNT(M.INDICE) AS NUMERO_DE_MUNDOS
FROM SERVIDOR S
LEFT JOIN MUNDO M ON S.ID = M.IDS
GROUP BY  S.ID, S.NOME
ORDER BY S.ID;

--========================================================================================================================================--

-- Quais os IDs dos jogadores e as durações de suas sessões que foram maiores que a média geral?
SELECT S1.IDJ, S1.DURACAO
FROM SESSAO S1
WHERE S1.DURACAO > (
    SELECT AVG(S2.DURACAO)
    FROM SESSAO S2    
);

--========================================================================================================================================--

-- Quais as sessões cujas durações foram maiores que a média de seu jogador?
SELECT *
FROM SESSAO S1
WHERE S1.DURACAO > (
    SELECT AVG(S2.DURACAO)
    FROM SESSAO S2
    WHERE S1.IDJ = S2.IDJ
);

--========================================================================================================================================--

-- Quais os usernames dos jogadores que possuem ao menos uma sessão com mais de 27 horas?
SELECT J.USERNAME
FROM JOGADOR J
WHERE EXISTS (
    SELECT *
    FROM SESSAO S
    WHERE J.ID = S.IDJ AND S.DURACAO > 27
);

--========================================================================================================================================--

-- Quais são os jogadores com a amizade mais antiga?
SELECT J1.USERNAME AS NOME1, J2.USERNAME AS NOME2
FROM JOGADOR J1, JOGADOR J2 
WHERE (J1.ID, J2.ID) = (
    SELECT IDJ1, IDJ2
    FROM AMIZADE
    WHERE DATA_DE_INICIO = (
        SELECT MIN(DATA_DE_INICIO)
        FROM AMIZADE
    )
);

--========================================================================================================================================--

-- Exemplo de uso da função --
DECLARE
    distancia NUMBER;
BEGIN
    -- Calcula a distância entre as estruturas
    distancia := DISTANCIA_ESTRUTURAS(001, 002);

    -- Exibe o resultado
    IF distancia IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Impossível calcular distância: as estruturas estão em seeds diferentes!!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Distância calculada: ' || TO_CHAR(distancia, '999999.99'));
    END IF;
END;
/

--========================================================================================================================================--
