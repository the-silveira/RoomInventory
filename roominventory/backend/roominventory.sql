create table Places(
    IdPlace VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(75)
);



create table Zones(
    IdZone VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(75),
    FK_IdPlace VARCHAR(75),
    FOREIGN KEY(FK_IdPlace) REFERENCES Places(IdPlace)
);



create table Items(
    IdItem VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(75),
     FK_IdZone VARCHAR(10),
    FOREIGN KEY(FK_IdZone) REFERENCES Zones(IdZone)    
);



create table Detalhes(
    IdDetalhe INT(10) PRIMARY KEY,
    Name VARCHAR(75),
    Details VARCHAR(75),
    FK_IdItem VARCHAR(75),
    FOREIGN KEY(FK_IdItem) REFERENCES Items(IdItem)

);



create table Events(
    IdEvent VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(75),
    EventPlace VARCHAR(75),
    NameRep VARCHAR(75),
    EmailRep VARCHAR(75),
    TecExt VARCHAR(75),
    Date DATE
);



create table Item_Evento(
    IdIE INT(10) PRIMARY KEY,
    FK_IdEvent VARCHAR(10),
    FK_IdItem VARCHAR(10),
    FOREIGN KEY(FK_IdItem) REFERENCES Items(IdItem),
    FOREIGN KEY(FK_IdEvent) REFERENCES Events(IdEvent)
);