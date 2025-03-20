--=========================================================================================================--
-- Testados e Funcionais (tem que inserir um a um no oracle e setar 280 para todos no 'execution sequence' --
--=========================================================================================================--

--=========================================================================================================--
-- OK --
-- Atualiza o valor de tempo acumulado após cada insert e insere na tabela sessão -- 

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
/

--=========================================================================================================--
-- Fazer para Jog4 pediu Jog1 em amizade, guardar IDJ1 = jogador1 e IDJ2 = jogador4 --
-- Trigger para exemplificar o log de erro. Se um jogador for amigo dele mesmo, a inserção é bloqueada - Cleber

CREATE OR REPLACE TRIGGER TRG_EVITAR_AMIZADE_CONSIGO_MESMO
BEFORE INSERT ON AMIZADE
FOR EACH ROW
BEGIN
    IF :NEW.IDJ1 = :NEW.IDJ2 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Um jogador não pode ser amigo de si mesmo.');
    END IF;
END;
/

--=========================================================================================================--
-- OK --
-- Verifica o tempo acumulado para acrescentar uma conquista em desbloqueia --

CREATE OR REPLACE TRIGGER trg_check_tempo_acumulado
AFTER INSERT OR UPDATE OF TEMPO_ACUMULADO ON SESSAO
FOR EACH ROW
DECLARE
  t_check NUMBER := 0; 
BEGIN
  -- Conquista 100 horas
  IF :NEW.TEMPO_ACUMULADO >= 100 THEN
    SELECT COUNT(*) INTO t_check
    FROM DESBLOQUEIA
    WHERE IDJ = :NEW.IDJ AND CODIGO_C = 33331;

    IF t_check = 0 THEN
      INSERT INTO DESBLOQUEIA (IDJ, CODIGO_C, DATA_DESB)
      VALUES (:NEW.IDJ, 33331, :NEW.INICIO);
    END IF;
  END IF;

  -- Conquista 400 horas
  IF :NEW.TEMPO_ACUMULADO >= 400 THEN
    SELECT COUNT(*) INTO t_check
    FROM DESBLOQUEIA
    WHERE IDJ = :NEW.IDJ AND CODIGO_C = 33332;

    IF t_check = 0 THEN
      INSERT INTO DESBLOQUEIA (IDJ, CODIGO_C, DATA_DESB)
      VALUES (:NEW.IDJ, 33332, :NEM.INICIO);
    END IF;
  END IF;

  -- Conquista 2000 horas
  IF :NEW.TEMPO_ACUMULADO >= 2000 THEN
    SELECT COUNT(*) INTO t_check
    FROM DESBLOQUEIA
    WHERE IDJ = :NEW.IDJ AND CODIGO_C = 33333;

    IF t_check = 0 THEN
      INSERT INTO DESBLOQUEIA (IDJ, CODIGO_C, DATA_DESB)
      VALUES (:NEW.IDJ, 33333, :NEW.INICIO);
    END IF;
  END IF;
END;
/

--=========================================================================================================--
-- OK --
-- Trabalha a inserção de baús e estabelece a obrigatoriedade --

CREATE OR REPLACE PROCEDURE INSERIR_BAU  
( 
    new_codigo NUMBER, 
    new_raridade VARCHAR, 
    new_capacidade NUMBER, 
    new_vila NUMBER 
)  
IS 
    vila_existe INT; 
    bau_existe  INT; 
BEGIN 
 
    SELECT COUNT(*) 
    INTO vila_existe 
    FROM vila  
    WHERE vila.codigo_e = new_vila AND vila.codigo_b IS NULL; 

    SELECT COUNT(*) 
    INTO bau_existe  
    FROM bau  
    WHERE bau.codigo = new_codigo; 
 
    IF vila_existe = 1 THEN 
        IF bau_existe = 0 THEN 
            INSERT INTO bau (CODIGO, RARIDADE, CAPACIDADE) VALUES (new_codigo, new_raridade, new_capacidade); 
        END IF; 
 
        UPDATE vila  
            SET codigo_b = new_codigo 
        WHERE codigo_e = new_vila; 
    ELSE 
        RAISE_APPLICATION_ERROR(-20002, 'Vila inválida'); 
    END IF; 
END;
/


-- 'execution sequence' = 12760
BEGIN
    -- Inserir múltiplos baús
    INSERIR_BAU(00001, 'Madeira',  15, 001);
    INSERIR_BAU(00002, 'Cobre',    15, 011);
    INSERIR_BAU(00002, 'Cobre',    15, 101);
    INSERIR_BAU(00003, 'Bronze',   15, 121);
    INSERIR_BAU(00003, 'Bronze',   15, 241);
    INSERIR_BAU(00004, 'Ferro',    15, 031);
    INSERIR_BAU(00004, 'Ferro',    15, 231);
    INSERIR_BAU(00005, 'Ouro',     15, 131);
    INSERIR_BAU(00005, 'Ouro',     15, 211);
    INSERIR_BAU(00006, 'Diamante', 16, 051);
    INSERIR_BAU(00006, 'Diamante', 16, 141);
    INSERIR_BAU(00016, 'Diamante', 16, 061);
    INSERIR_BAU(00016, 'Diamante', 16, 111);
    INSERIR_BAU(00026, 'Diamante', 16, 021);
    INSERIR_BAU(00026, 'Diamante', 16, 221);
    INSERIR_BAU(00036, 'Diamante', 16, 041);
    INSERIR_BAU(00036, 'Diamante', 16, 201);
    INSERIR_BAU(00007, 'Lendário', 16, 106);

    DBMS_OUTPUT.PUT_LINE('Todos os baús foram inseridos com sucesso!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao inserir um ou mais baús: ' || SQLERRM);
END;
/

--=========================================================================================================--
-- Cálcula a distância entre duas estruturas --

CREATE OR REPLACE FUNCTION DISTANCIA_ESTRUTURAS (
    cod1 NUMBER, 
    cod2 NUMBER
) 
RETURN NUMBER IS 
    dif_x NUMBER; 
    dif_y NUMBER; 
    dif_z NUMBER; 
    distance NUMBER; 
    seed1 CHAR(50);
    seed2 CHAR(50);
BEGIN 

    SELECT SEED_M
    INTO seed1
    FROM ESTRUTURA
    WHERE CODIGO = cod1;

    SELECT SEED_M
    INTO seed2
    FROM ESTRUTURA
    WHERE CODIGO = cod2;

    IF seed1 <> seed2 THEN
        RETURN NULL;
    END IF;
    
    -- Obtém as diferenças nas coordenadas X, Y e Z em uma única consulta
    SELECT E1.X - E2.X, 
           E1.Y - E2.Y, 
           E1.Z - E2.Z 
    INTO dif_x, dif_y, dif_z 
    FROM ESTRUTURA E1, ESTRUTURA E2 
    WHERE E1.CODIGO = cod1 
      AND E2.CODIGO = cod2;

    -- Calcula a distância usando a fórmula da distância euclidiana
    distance := SQRT(POWER(dif_x, 2) + POWER(dif_y, 2) + POWER(dif_z, 2)); 

    -- Retorna a distância calculada 
    RETURN distance;         
END;
/

-- Exemplo de uso da função --
DECLARE
    distancia NUMBER;
BEGIN
    -- Calcula a distância entre as estruturas com códigos 1 e 2
    distancia := DISTANCIA_ESTRUTURAS(001, 002);

    -- Exibe o resultado
    IF distancia IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('As estruturas estão em seeds diferentes!.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Distância calculada: ' || TO_CHAR(distancia, '999999.99'));
    END IF;
END;
/
--=========================================================================================================--
