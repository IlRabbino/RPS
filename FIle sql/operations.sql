--Aquisto fotocopiatrice
DELIMITER //
CREATE PROCEDURE InsertAcquisto(IN modello VARCHAR(30), cliente VARCHAR(11), data_acquisto DATE)
BEGIN
    SET @imponibile = (SELECT Costo FROM Fotocopiatrice WHERE Modello = modello);
    INSERT INTO Fattura VALUES (data_acquisto, @imponibile, cliente,'Vendita fotocopiatrice', 0);
    SET @fattura = LAST_INSERT_ID();
    INSERT INTO Acquisti VALUES (cliente, modello, @fattura);
END //
DELIMITER ;

--Noleggio fotocopiatrice
DELIMITER //
CREATE PROCEDURE InsertNoleggio(IN modello VARCHAR(30), cliente VARCHAR(11), canone INT)
BEGIN
    SET @data_inizio = CURRENT_DATE();
    SET @data_fine = DATE_ADD(@data_, INTERVAL 1 YEAR);
    INSERT INTO Contratto VALUES (@data_inizio, @data_fine , canone, 0.005);
    SET @contrattoID = LAST_INSERT_ID();
    INSERT INTO Firma VALUES (cliente, @contrattoID);
    INSERT INTO Noleggi VALUES (@contrattoID, modello);
END //
DELIMITER ;

--Inserimento di un nuovo modello di fotocopiatrice
DELIMITER //
CREATE PROCEDURE InsertFotocopiatrice(IN modello VARCHAR(30), colore BOOLEAN, costo INT, disponbilità BOOLEAN)
BEGIN
    INSERT INTO Fotocopiatrice VALUES (modello, colore, costo, disponbilità);
END //
DELIMITER ;

--Rimozione di un modello di fotocopiatrice obsoleto
DELIMITER //
CREATE PROCEDURE DeleteFotocopiatrice(IN modello VARCHAR(30))
BEGIN
    DELETE FROM Fotocopiatrice WHERE Modello = modello;
END //
DELIMITER ;

--Inserimento di un nuovo cliente
DELIMITER //
CREATE PROCEDURE InsertCliente(IN p_iva VARCHAR(11), nome VARCHAR(30), tipo VARCHAR(10), sede VARCHAR(30))
BEGIN
    INSERT INTO Cliente VALUES (p_iva, nome, tipo, sede);
END //
DELIMITER ;

--Inserimento Richiesta assistenza di un nuovo cliente
DELIMITER //
CREATE PROCEDURE InsertRichiestaAssistenza(IN cliente VARCHAR(11), data_richiesta DATE, codice INT)
BEGIN
    INSERT INTO RichiestaAssistenza VALUES (cliente, data_richiesta, codice, 0);
END //
DELIMITER ;

--Risoluzione di una richiesta di assistenza
DELIMITER //
CREATE PROCEDURE ResolveRichiestaAssistenza(IN cliente VARCHAR(11), data_richiesta DATE, codice INT)
BEGIN
    UPDATE RichiestaAssistenza SET Risolto = 1 WHERE Cliente = cliente AND Data_richiesta = data_richiesta AND Codice_problema = codice;
    SET @costo = (SELECT Costo FROM ServizioAssistenza WHERE Codice = codice);
    SET @data_ = CURRENT_DATE();
    INSERT INTO Fattura VALUES (@data_, @costo, cliente, 'Servizio di assistenza', 0);
    SET @fattura =  LAST_INSERT_ID();
    INSERT INTO FattureAssistenza VALUES (cliente, @data_, codice, fattura);
END //
DELIMITER ;

--Conteggio mensile del fatturato
DELIMITER //
CREATE PROCEDURE ConteggioFatturato(OUT fatturato INT)
BEGIN
    SELECT SUM(Imponibile) FROM Fattura WHERE Incassata = 1 AND MONTH(Data_emissione) = MONTH(CURRENT_DATE()) AND YEAR(Data_emissione) = YEAR(CURRENT_DATE());
END //
DELIMITER ;

--Generazione mensile delle fatture derivate dai contratti di noleggio
DELIMITER //
CREATE PROCEDURE FatturazioneContratti()
BEGIN

    DECLARE cursor_List_isdone BOOLEAN DEFAULT FALSE;
    DECLARE costo INT;
    DECLARE cliente VARCHAR(11) DEFAULT '';
    
    DECLARE cursor_List CURSOR FOR 
        SELECT Cliente, Canone
        FROM Contratto JOIN Firma ON Id = Contratto
        WHERE Data_scadenza>CURRENT_DATE();

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET cursor_List_isdone = TRUE;

    OPEN cursor_List;

    loop_List: LOOP
        FETCH cursor_List INTO cliente, costo;
        IF cursor_List_isdone THEN
            LEAVE loop_List;
        END IF;

        INSERT INTO Fattura VALUES (CURRENT_DATE(), costo, cliente, 'Fatturazione mensile noleggio', 0);
    END LOOP loop_List;

    CLOSE cursor_List;
END //
DELIMITER ;


--Pagamento di una fattura
CREATE PROCEDURE PagamentoFattura(IN fattura)
BEGIN
    UPDATE Fattura SET Incassata = 1 WHERE Codice = fattura;    
END //
DELIMITER ;