CREATE TABLE Cliente(
    P_iva VARCHAR(11) NOT NULL CHECK (LENGTH(P_iva)=11),
    Nome VARCHAR(30) NOT NULL,
    Tipo VARCHAR(10) NOT NULL CHECK (Tipo = 'azienda' OR Tipo = 'persona'),
    Res_Sede VARCHAR(30) NOT NULL,
    PRIMARY KEY (P_iva)
);

CREATE TABLE Servizi(
    Id INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(30) NOT NULL,
    Descrizione VARCHAR(150) NOT NULL,
    Costo INT NOT NULL,
    PRIMARY KEY(Id)
);

CREATE TABLE Contratto(
    Id INT NOT NULL AUTO_INCREMENT,
    Data_firma DATE NOT NULL,
    Data_scadenza DATE NOT NULL,
    Canone INT NOT NULL,
    Costo_pagina_extra INT,
    PRIMARY KEY (Id)
);

CREATE TABLE Fotocopiatrice(
    Modello VARCHAR(30) NOT NULL,
    Colore BOOLEAN NOT NULL,
    Costo INT NOT NULL,
    Disponbilità INT NOT NULL,
    PRIMARY KEY (Modello)
);

CREATE TABLE Fattura(
    Codice INT NOT NULL AUTO_INCREMENT,
    Data_emissione DATE NOT NULL,
    Imponibile INT NOT NULL,
    Emessa_per VARCHAR(11) NOT NULL,
    Prodotto VARCHAR(150) NOT NULL,
    Incassata BOOLEAN NOT NULL,
    PRIMARY KEY (Codice),
    FOREIGN KEY (Emessa_per) REFERENCES Cliente (P_iva) ON DELETE CASCADE
);

CREATE TABLE ServizioAssistenza (
    Codice INT NOT NULL AUTO_INCREMENT,
    Problema VARCHAR(150) NOT NULL,
    Costo INT NOT NULL,
    PRIMARY KEY (Codice)
);

CREATE TABLE RichiestaAssistenza (
    Cliente VARCHAR(11) NOT NULL,
    Data_richiesta DATE NOT NULL,
    Codice_problema INT NOT NULL,
    Risolto BOOLEAN NOT NULL,
    PRIMARY KEY (Cliente, Data_richiesta, Codice_problema),
    FOREIGN KEY (Cliente) REFERENCES Cliente (P_iva) ON DELETE CASCADE,
    FOREIGN KEY (Codice_problema) REFERENCES ServizioAssistenza (Codice)
);

CREATE TABLE Firma(
    Cliente VARCHAR(11) NOT NULL,
    Contratto INT NOT NULL,
    PRIMARY KEY (Cliente, Contratto),
    FOREIGN KEY (Cliente) REFERENCES Cliente (P_iva) ON DELETE CASCADE,
    FOREIGN KEY (Contratto) REFERENCES Contratto (Id)
);

CREATE TABLE ServiziAggiunti (
    Contratto INT NOT NULL,
    Servizio INT NOT NULL,
    PRIMARY KEY (Contratto, Servizio),
    FOREIGN KEY (Contratto) REFERENCES Contratto (Id),
    FOREIGN KEY (Servizio) REFERENCES Servizi (Id)
);

CREATE TABLE Noleggi (
    Contratto INT NOT NULL,
    Fotocopiatrice VARCHAR(30) NOT NULL,
    PRIMARY KEY (Contratto, Fotocopiatrice),
    FOREIGN KEY (Fotocopiatrice) REFERENCES Fotocopiatrice (Modello) ON DELETE CASCADE,
    FOREIGN KEY (Contratto) REFERENCES Contratto (Id)
);

CREATE TABLE Acquisti (
    Cliente VARCHAR(11) NOT NULL,
    Fotocopiatrice VARCHAR(30) NOT NULL,
    Fattura INT NOT NULL,
    PRIMARY KEY (Cliente, Fotocopiatrice, Fattura),
    FOREIGN KEY (Cliente) REFERENCES Cliente (P_iva),
    FOREIGN KEY (Fotocopiatrice) REFERENCES Fotocopiatrice (Modello) ON DELETE CASCADE,
    FOREIGN KEY (Fattura) REFERENCES Fattura (Codice)
);

CREATE TABLE FattureContrattuali (
    Contratto INT NOT NULL,
    Fattura INT NOT NULL,
    PRIMARY KEY (Contratto, Fattura),
    FOREIGN KEY (Contratto) REFERENCES Contratto (Id),
    FOREIGN KEY (Fattura) REFERENCES Fattura (Codice)
);

CREATE TABLE FattureAssistenza (
    Cliente VARCHAR(11) NOT NULL,
    Data_richiesta DATE NOT NULL,
    Codice_problema INT NOT NULL,
    Fattura INT NOT NULL,
    PRIMARY KEY (Cliente, Data_richiesta, Codice_problema, Fattura),
    FOREIGN KEY (Cliente) REFERENCES Cliente (P_iva),
    FOREIGN KEY (Fattura) REFERENCES Fattura (Codice),
    FOREIGN KEY (Codice_problema) REFERENCES ServizioAssistenza (Codice),
    FOREIGN KEY (Cliente, Data_richiesta, Codice_problema) REFERENCES RichiestaAssistenza (Cliente, Data_richiesta, Codice_problema)
);

-- Non si implementa volutamente la relazione tra cliente e richiesta assistenza in quanto risulterebbe totalmente ridondante 