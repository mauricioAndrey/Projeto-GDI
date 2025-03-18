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

-- 
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


