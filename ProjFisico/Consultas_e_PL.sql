-- Quais jogadores possuem mais de 100 sessões? -- (GROUP BY / HAVING / JUNÇÃO INTERNA) - LUCAS
SELECT J.USERNAME, COUNT(*) AS NUM_SESSOES
FROM SESSAO S
INNER JOIN JOGADOR J ON J.ID = S.IDJ
GROUP BY J.USERNAME
HAVING NUM_SESSOES > 100;

-- Quais itens que são produtos, mas não são matérias primas? -- (ANTI JUNÇÃO / SEMI JUNÇÃO / SUBCONSULTA LINHA) - RIAN
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

-- Quais os IDs dos servos que não preotegem fortalezas -- (JUNÇÃO EXTERNA) - RIAN
SELECT IDC
FROM SERVO LEFT JOIN PROTEGE 
ON SERVO.IDC = PROTEGE.IDCS 
WHERE PROTEGE.IDCS IS NULL;

-- Quais os códigos das estruturas que não são fortaleza nem vila? -- (OPERAÇÃO DE CONJUNTO) - RIAN
SELECT CODIGO
FROM ESTRUTURA EXCEPT (
    SELECT CODIGO_E FROM FORTALEZA 
    UNION 
    SELECT CODIGO_E FROM VILA
);

-- Quais são as coordenadas da estrutura em que o chefe de ID = 129 comanda? -- (SUBCONSULTA ESCALAR) - RIAN
SELECT X, Y, Z
FROM ESTRUTURA
WHERE CODIGO = (
    SELECT CODIGO_EF
    FROM CHEFE
    WHERE IDC = 129
);

-- Quais os usernames dos jogadores não foram punidos em um servidor? -- (JUNÇÃO EXTERNA / SUBCONSULTA TABELA) - JULIANA
SELECT J.USERNAME
FROM JOGADOR J
WHERE NOT EXISTS(SELECT * FROM PUNIDO P WHERE P.IDJA = J.ID);

-- Quais as coordenadas dos chefes que possuem o atributo fogo? -- (JUNÇÃO INTERNA / SUBCONSULTA LINHA) - ANDREY
SELECT C.IDC AS CHEFE, E.x, E.y, E.z
FROM CHEFE C INNER JOIN Estrutura E ON C.Codigo_EF = E.Codigo 
WHERE C.IDC IN (
    SELECT A.IDCC
    FROM ATRIBUTO A
    WHERE A.ATRIBUTO = 'Fogo'
);

-- Quais as quantidades de cada tipo de item que o jogador Gabriel possui? -- (JUNÇÃO INTERNA / SUBCONSULTA LINHA / GROUP BY) - ANDREY
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

-- Quais os nomes e os atributos dos chefes que comandam alguma fortaleza e dropam obsidiana com sua respectiva probabilidade -- (JUNÇÃO INTERNA / GROUP BY) - GABRIEL
SELECT 
    C.NOME, 
    LISTAGG(A.ATRIBUTO, ', ') WITHIN GROUP (ORDER BY A.ATRIBUTO) AS ATRIBUTOS,
    TO_CHAR(B.CODIGO_EF, '000') AS CÓDIGO_MASMORRA, 
    TO_CHAR(D.PROBABILIDADE, '0.99') AS PROBABILIDADE_DROPE
FROM CHEFE B
JOIN CRIATURA C ON C.ID = B.IDC
JOIN ATRIBUTO A ON A.IDCC = B.IDC
JOIN DROPA D ON C.ID = D.IDC
WHERE D.IDI = '10522' AND B.CODIGO_EF IS NOT NULL
GROUP BY C.NOME, B.CODIGO_EF, D.PROBABILIDADE
ORDER BY B.CODIGO_EF ASC, C.NOME ASC;

-- Quais os nomes das criaturas, juntamente com seu atributo e localização, que dropam obsidiana com sua respectiva probabilidade -- (JUNÇÃO INTERNA) - GABRIEL
SELECT C.NOME, S.ATRIBUTO, TO_CHAR(P.CODIGO_EF, '000') AS CÓDIGO_MASMORRA, TO_CHAR(D.PROBABILIDADE, '0.99') AS PROBABILIDADE_DROPE
FROM PROTEGE P 
INNER JOIN SERVO S ON P.IDCS = S.IDC
INNER JOIN CRIATURA C ON C.ID = S.IDC
INNER JOIN DROPA D ON C.ID = D.IDC
WHERE D.IDI = '10522'
ORDER BY P.CODIGO_EF ASC, S.ATRIBUTO ASC;

-- Quais os mundos por servidor? -- (JUNÇÃO EXTERNA / GROUP BY) -- Cleber
SELECT 
    S.ID AS ID_SERVIDOR,
    S.NOME AS NOME_SERVIDOR,
    COUNT(M.INDICE) AS NUMERO_DE_MUNDOS
FROM 
    SERVIDOR S
LEFT JOIN 
    MUNDO M ON S.ID = M.IDS
GROUP BY 
    S.ID, S.NOME
ORDER BY 
    S.ID;

CREATE OR REPLACE TRIGGER TRG_ATUALIZA_TEMPO_ACUMULADO
BEFORE INSERT ON SESSAO
FOR EACH ROW
DECLARE
    V_TEMPO_ANTERIOR NUMBER(6,2);
BEGIN
    -- Soma o tempo de todas as sessões anteriores do mesmo jogador
    SELECT NVL(SUM(DURACAO), 0)
    INTO V_TEMPO_ANTERIOR
    FROM SESSAO
    WHERE IDJ = :NEW.IDJ AND INICIO < :NEW.INICIO;

    -- Atualiza o campo TEMPO_ACUMULADO na nova linha inserida
    :NEW.TEMPO_ACUMULADO := V_TEMPO_ANTERIOR + :NEW.DURACAO;
END;

-- Quais os nomes das criaturas, juntamente com seu atributo e localização, que dropam um certo item com sua respectiva probabilidade 
CREATE OR REPLACE PROCEDURE obter_drope_por_idi_proc(
    p_idi IN VARCHAR2
) IS
BEGIN
    FOR r IN 
    (SELECT C.NOME, 
            S.ATRIBUTO, 
            TO_CHAR(P.CODIGO_EF, '000') AS CÓDIGO_MASMORRA, 
            TO_CHAR(D.PROBABILIDADE, '0.99') AS PROBABILIDADE_DROPE
     FROM PROTEGE P 
     INNER JOIN SERVO S ON P.IDCS = S.IDC
     INNER JOIN CRIATURA C ON C.ID = S.IDC
     INNER JOIN DROPA D ON C.ID = D.IDC
     WHERE D.IDI = p_idi
     ORDER BY P.CODIGO_EF ASC, S.ATRIBUTO ASC)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Nome: '  r.NOME  ', Atributo: '  r.ATRIBUTO  
                             ', Código: '  r.CÓDIGO_MASMORRA  ', Probabilidade: ' || r.PROBABILIDADE_DROPE);
    END LOOP;
END obter_drope_por_idi_proc;

-- Checa se um jogador possui 10 amigos. Se sim, desbloqueia a conquista - LUCAS
CREATE OR REPLACE TRIGGER TRIG_DESBLOQUEAR_CONQUISTA
AFTER INSERT ON AMIZADE
FOR EACH ROW
DECLARE
    num_amigos NUMBER;
BEGIN
    SELECT COUNT(*) INTO num_amigos
    FROM AMIZADE
    WHERE IDJ1 = :NEW.IDJ1 OR IDJ2 = :NEW.IDJ1;

    IF num_amigos = 10 THEN
        INSERT INTO DESBLOQUEIA (IDJ, CODIGO_C, DATA_DESB) VALUES (:NEW.IDJ1, 22223, SYSDATE);
    END IF;
END;
/

-- Verifica o tempo acumulado para acrescentar uma conquista em desbloqueia - Juliana
CREATE OR REPLACE TRIGGER trg_check_tempo_acumulado
AFTER INSERT OR UPDATE OF TEMPO_ACUMULADO ON SESSAO
FOR EACH ROW
DECLARE
  t_check NUMBER := 0; 
BEGIN
  -- Conquista 100 horas
  IF :NEW.TEMPO_ACUMULADO >= 100 THEN
    SELECT COUNT() INTO t_check
    FROM DESBLOQUEIA
    WHERE IDJ = :NEW.IDJ AND CODIGO_C = 33331;

    IF t_check = 0 THEN
      INSERT INTO DESBLOQUEIA (IDJ, CODIGO_C, DATA_DESB)
      VALUES (:NEW.IDJ, 33331, SYSDATE);
    END IF;
  END IF;

  -- Conquista 400 horas
  IF :NEW.TEMPO_ACUMULADO >= 400 THEN
    SELECT COUNT() INTO t_check
    FROM DESBLOQUEIA
    WHERE IDJ = :NEW.IDJ AND CODIGO_C = 33332;

    IF t_check = 0 THEN
      INSERT INTO DESBLOQUEIA (IDJ, CODIGO_C, DATA_DESB)
      VALUES (:NEW.IDJ, 33332, SYSDATE);
    END IF;
  END IF;

  -- Conquista 2000 horas
  IF :NEW.TEMPO_ACUMULADO >= 2000 THEN
    SELECT COUNT(*) INTO t_check
    FROM DESBLOQUEIA
    WHERE IDJ = :NEW.IDJ AND CODIGO_C = 33333;

    IF t_check = 0 THEN
      INSERT INTO DESBLOQUEIA (IDJ, CODIGO_C, DATA_DESB)
      VALUES (:NEW.IDJ, 33333, SYSDATE);
    END IF;
  END IF;
END;

-- Verifica se um jogador conseguiu pegar 8 itens diferentes para obter uma conquista - Cleber
CREATE OR REPLACE TRIGGER TRG_CONQUISTA_20_ITENS
AFTER INSERT OR UPDATE ON POSSUI
FOR EACH ROW
DECLARE
    v_count_itens NUMBER;
    v_codigo_conquista NUMBER := 1; -- Código da conquista que será concedida, pode colocar qualquer NUMBER aqui
BEGIN
    -- Conta quantos itens diferentes o jogador possui
    SELECT COUNT(DISTINCT IDI)
    INTO v_count_itens
    FROM POSSUI
    WHERE IDJ = :NEW.IDJ;

    -- Se o jogador possuir 8 itens diferentes, concede a conquista
    IF v_count_itens >= 8 THEN
        -- Verifica se o jogador já não possui essa conquista
        BEGIN
            INSERT INTO DESBLOQUEIA (IDJ, CODIGO_C, DATA_DESB)
            VALUES (:NEW.IDJ, v_codigo_conquista, SYSDATE);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
    END IF;
END;

-- Trigger para exemplificar o log de erro. Se um jogador for amigo dele mesmo, a inserção é bloqueada - Cleber
CREATE OR REPLACE TRIGGER TRG_EVITAR_AMIZADE_CONSIGO_MESMO
BEFORE INSERT ON AMIZADE
FOR EACH ROW
BEGIN
    IF :NEW.IDJ1 = :NEW.IDJ2 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Um jogador não pode ser amigo de si mesmo.');
    END IF;
END;