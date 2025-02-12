-- Create Tables

CREATE TABLE Places (
    IdPlace VARCHAR(50) PRIMARY KEY,
    PlaceName VARCHAR(75)
);

CREATE TABLE Zones (
    IdZone VARCHAR(50) PRIMARY KEY,
    ZoneName VARCHAR(75),
    FK_IdPlace VARCHAR(50),
    FOREIGN KEY (FK_IdPlace) REFERENCES Places(IdPlace)
);

CREATE TABLE Items (
    IdItem VARCHAR(50) PRIMARY KEY,
    ItemName VARCHAR(75),
    FK_IdZone VARCHAR(50),
    FOREIGN KEY (FK_IdZone) REFERENCES Zones(IdZone)    
);

CREATE TABLE Details (
    IdDetails INT PRIMARY KEY auto_increment,
    DetailsName VARCHAR(75),
    Details VARCHAR(75),
    FK_IdItem VARCHAR(50),
    FOREIGN KEY (FK_IdItem) REFERENCES Items(IdItem)
);

CREATE TABLE Events (
    IdEvent VARCHAR(50) PRIMARY KEY,
    EventName VARCHAR(75),
    EventPlace VARCHAR(75),
    NameRep VARCHAR(75),
    EmailRep VARCHAR(75),
    TecExt VARCHAR(75),
    Date DATE
);

CREATE TABLE Item_Event (
    IdIE INT PRIMARY KEY auto_increment,
    FK_IdEvent VARCHAR(50),
    FK_IdItem VARCHAR(50),
    FOREIGN KEY (FK_IdItem) REFERENCES Items(IdItem),
    FOREIGN KEY (FK_IdEvent) REFERENCES Events(IdEvent)
);

-- Insert into Places
INSERT INTO Places (IdPlace, PlaceName) VALUES
('P001', 'Regie'),  -- Updated to Regie
('P002', 'Palco'),
('P003', 'Sala Dimmers'),
('P004', 'Sala Entrada'),
('P005', 'Corredor'),
('P006', 'Sala Espelhos'),
('P007', 'Sala Espetáculos'),
('P008', 'Entrada'),
('P009', 'Outros');



-- Insert into Zones for Regie
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z005', 'Armário', 'P001'),  -- Zone for Regie
('Z006', 'Gaveta', 'P001'),   -- Zone for Regie
('Z007', 'Mesa', 'P001'),     -- Zone for Regie
('Z008', 'Chão', 'P001'),     -- Zone for Regie
('Z009', 'Parede', 'P001');   -- Zone for Regie

-- Insert into Zones for Palco
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z010', 'Lateral Esquerda', 'P002'),  -- Zone for Palco
('Z011', 'Lateral Direita', 'P002'),   -- Zone for Palco
('Z012', 'Atrás Chão', 'P002'),        -- Zone for Palco
('Z013', 'Atrás Caixa', 'P002'),       -- Zone for Palco
('Z014', 'Atrás Armário', 'P002');     -- Zone for Palco

-- Insert into Zones for SalaDimmers
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z015', 'Parede', 'P003'),  -- Zone for SalaDimmers
('Z016', 'Caixas', 'P003');  -- Zone for SalaDimmers

-- Insert into Zones for SalaEntrada
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z017', 'Chão', 'P004'),    -- Zone for SalaEntrada
('Z018', 'Caixas', 'P004');  -- Zone for SalaEntrada

-- Insert into Zones for Corredor
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z019', 'Chão', 'P005');  -- Zone for Corredor

-- Insert into Zones for SalaEspelhos
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z020', 'Chão', 'P006');  -- Zone for SalaEspelhos

-- Insert into Zones for SalaEspetáculos
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z021', 'Chão', 'P007'),           -- Zone for SalaEspetáculos
('Z022', 'Parede Esquerda', 'P007'), -- Zone for SalaEspetáculos
('Z023', 'Parede Direita', 'P007'),  -- Zone for SalaEspetáculos
('Z024', 'Parede Trás', 'P007');     -- Zone for SalaEspetáculos

-- Insert into Zones for Entrada (P008)
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z025', 'Bar', 'P008'),      -- Zone for Entrada
('Z026', 'Receção', 'P008'),  -- Zone for Entrada
('Z027', 'Mesas', 'P008'),    -- Zone for Entrada
('Z028', 'Entrada', 'P008'),  -- Zone for Entrada
('Z029', 'Palco', 'P008');    -- Zone for Entrada

-- Insert into Zones for Outros
INSERT INTO Zones (IdZone, ZoneName, FK_IdPlace) VALUES
('Z030', 'Por Arrumar', 'P009'),  -- Zone for Outros
('Z031', 'Perdido', 'P009'),      -- Zone for Outros
('Z032', 'Não Presente', 'P009'); -- Zone for Outros





-- Insert into Items
INSERT INTO Items (IdItem, ItemName, FK_IdZone) VALUES
-- SalaDimmers Items (Parede)
('XLR3_01', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_02', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_03', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_04', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_05', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_06', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_07', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_08', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_09', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_10', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_11', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_12', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_13', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_14', 'EMELEC XLR M/F', 'Z015'),       -- Parede
('XLR3_15', 'EMELEC XLR M/F', 'Z015'),       -- Parede

('XLRJ_01', 'CCO XLR F Jack 6.3mm M', 'Z015'), -- Parede
('XLRJ_02', 'Thomann XLR F Jack 6.3mm M', 'Z015'), -- Parede

('JCK63_01', 'CCO Jack 6.3mm M/M', 'Z015'),   -- Parede
('JSTR_01', 'CCO Stereo M Jack 3.5mm M', 'Z015'), -- Parede
('JCKM_01', 'Proel Jach 6.3 M Mono M', 'Z015'), -- Parede
('STRO_01', 'CCO Stero M/M', 'Z015'),         -- Parede
('VGA_01', 'Vitecom VGA M/F', 'Z015'),        -- Parede
('VGA_02', 'CCO VGA M/M', 'Z015'),            -- Parede
('VGA_03', 'CCO VGA M/M', 'Z015'),            -- Parede
('SCRT_01', 'CCO SCART M/M', 'Z015'),         -- Parede
('RCAA_01', 'CCO RCA Video', 'Z015'),         -- Parede
('PWR_01', 'CCO Corrente M/M', 'Z015'),       -- Parede
('PWR_02', 'CCO Corrente M/F', 'Z015'),       -- Parede
('PWR_IP44_01', 'CCO Corrente F IP44 M', 'Z015'), -- Parede
('PWR_IP44_02', 'CCO Corrente F IP44 M', 'Z015'), -- Parede
('PWR_IP44_03', 'CCO Corrente F IP44 M', 'Z015'), -- Parede
('PWR_IP44_04', 'CCO Corrente F IP44 M', 'Z015'), -- Parede
('PCHD_01', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_02', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_03', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_04', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_05', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_06', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_07', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_08', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_09', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_10', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_11', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_12', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_13', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_14', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_15', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_16', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_17', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_18', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_19', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_20', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_21', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_22', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_23', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_24', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_25', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_26', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_27', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_28', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_29', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_30', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_31', 'Alcobre Patch Dimmers', 'Z015'), -- Parede
('PCHD_32', 'Alcobre Patch Dimmers', 'Z015'), -- Parede

-- Regie Items (Armário, Gaveta, Mesa, Chão)
('XLR_2_01', 'CCO XLR F/F', 'Z005'),          -- Armário
('TRPL_02', 'CCO Tripla Parede', 'Z005'),     -- Armário
('SMNS07_01', 'Samson 07', 'Z005'),           -- Armário
('MSCH_14A', 'Shure 14A', 'Z005'),            -- Armário
('D_01', 'Desconhecido', 'Z005'),             -- Armário
('AUDT_1', 'Audio Technica', 'Z005'),         -- Armário
('DIBH_01', 'Behringer Ultra-DI', 'Z005'),    -- Armário
('DIBH_02', 'Behringer Ultra-DI', 'Z005'),    -- Armário
('WTST_01', 'ScramTalk-808', 'Z005'),         -- Armário
('WTST_02', 'ScramTalk-808', 'Z005'),         -- Armário
('WTST_03', 'ScramTalk-808', 'Z005'),         -- Armário
('WTST_04', 'ScramTalk-808', 'Z005'),         -- Armário
('WTCH_01', 'Carregador Scram-Talk-808', 'Z005'), -- Armário
('TRSF_USBA_01', 'Transformadr USB-A', 'Z005'), -- Armário

('PWRD_01', 'CCO Corrente PC', 'Z006'),       -- Gaveta
('VGA_04', 'CCO VGA M/M', 'Z006'),            -- Gaveta
('HDMI_01', 'CCO HDMI M/M', 'Z006'),          -- Gaveta
('RJ45_01', 'CCO Cabo Rede', 'Z006'),         -- Gaveta
('RJ45_02', 'CCO Cabo Rede', 'Z006'),         -- Gaveta
('RJ45_03', 'CCO Cabo Rede', 'Z006'),         -- Gaveta
('MSCH_SM58', 'Shure SM58', 'Z006'),          -- Gaveta
('BST_9V_01', 'Pilha Boost', 'Z006'),         -- Gaveta
('BST_9V_02', 'Pilha Auchan', 'Z006'),        -- Gaveta
('BST_9V_03', 'Pilha Duracell', 'Z006'),      -- Gaveta
('BST_15V_01', 'Pilha Boost', 'Z006'),        -- Gaveta
('BST_15V_02', 'Pilha Panasonic', 'Z006'),    -- Gaveta
('CDCX_01', 'CD com Caixa', 'Z006'),          -- Gaveta
('CDBX_01', 'Caixa com CD', 'Z006'),          -- Gaveta
('DSKT_01', 'Disquete', 'Z006'),              -- Gaveta
('CSST_01', 'Cassete', 'Z006'),               -- Gaveta
('PXLR_01', 'Pontas XLR M/F', 'Z006'),        -- Gaveta

('XLR3_16', 'CCO XRL M/F', 'Z007'),           -- Mesa
('SPRT_02', 'Spirit FX16', 'Z007'),           -- Mesa
('CNST_01', 'Contest', 'Z007'),               -- Mesa
('JBST_01', 'JBSystems', 'Z007'),             -- Mesa
('BNCR', 'Banco Regie', 'Z007'),              -- Mesa

('VNTO_01', 'Ventoinha', 'Z008'),             -- Chão
('VNTO_02', 'Ventoinha', 'Z008'),             -- Chão

-- Palco Items (Lateral Esquerda)
('TRPL_01', 'Tripla ON/OFF', 'Z010'),         -- Lateral Esquerda
('PIAN_01', 'Piano Yamaha CPL-154S', 'Z010'), -- Lateral Esquerda
("CDRB_01", "Cadeira Milenium DT-903", "Z010"),-- Lateral Esquerda


-- Corredor Items (Chão)
('PLTF_01', 'Plataforma Azul', 'Z019'),        -- Chão


-- SalaEspelhos Items
('SPRT_01', 'Spirit Powerstation 600', 'Z020'), -- Chão
('JBLT_01', 'JBL TR Series', 'Z020'),       -- Chão
('JBLT_02', 'JBL TR Series', 'Z020'),        -- Chão



-- Entrada Items (Bar, Mesas, Entrada)
('BNCB', 'Banco Bar', 'Z028'),                 -- Bar
('MSAC', 'Mesas Convivo', 'Z030'),             -- Mesas
('PTRC', 'Poltronas Convivo', 'Z030'),         -- Mesas
('PLTD', 'Plantas Decorativas', 'Z030'),       -- Mesas
('ARVD', 'Árvores Decorativas', 'Z030'),       -- Mesas
('CRDE', 'Cadeirões Entrada', 'Z031'),         -- Entrada
('MSAR', 'Mesa Receção', 'Z031'),              -- Entrada


-- SalaEspetáculos Items (Chão)
('CDRP_01', 'Cadeira Plateia Tipo 1', 'Z021'), -- Chão
('CDRP_02', 'Cadeira Plateia Tipo 2', 'Z021'), -- Chão
('CDRP_03', 'Cadeira Plateia Tipo 3', 'Z021'), -- Chão


-- Outros Items (Não Presente)
('AVGA_MM1', 'VGA Macho-Macho', 'Z032');    -- Não Presente


-- Insert into Details
INSERT INTO Details (IdDetails, DetailsName, Details, FK_IdItem) VALUES
-- MSCH_14A Details
(13, 'Tipo', 'Fio', 'MSCH_14A'),
(14, 'Quantidade', '1', 'MSCH_14A'),
(15, 'Condição', 'Avariado', 'MSCH_14A'),
(16, 'Ultima Verificação', '27/09/2024', 'MSCH_14A'),
(17, 'Notas', 'Nada a Apontar', 'MSCH_14A'),

-- D_01 Details
(18, 'Tipo', 'Fio', 'D_01'),
(19, 'Quantidade', '1', 'D_01'),
(20, 'Condição', 'Avariado', 'D_01'),
(21, 'Ultima Verificação', '27/09/2024', 'D_01'),
(22, 'Notas', 'Nada a Apontar', 'D_01'),

-- AUDT_1 Details
(23, 'Tipo', 'Base', 'AUDT_1'),
(24, 'Quantidade', '1', 'AUDT_1'),
(25, 'Condição', 'Funciona', 'AUDT_1'),
(26, 'Ultima Verificação', '27/09/2024', 'AUDT_1'),
(27, 'Notas', 'Nada a Apontar', 'AUDT_1'),

-- MSCH_SM58 Details
(28, 'Tipo', 'Wireless', 'MSCH_SM58'),
(29, 'Quantidade', '1', 'MSCH_SM58'),
(30, 'Condição', 'Funciona', 'MSCH_SM58'),
(31, 'Ultima Verificação', '27/09/2024', 'MSCH_SM58'),
(32, 'Notas', 'Nada a Apontar', 'MSCH_SM58'),

-- SMNS07_01 Details
(33, 'Tipo', 'Fio', 'SMNS07_01'),
(34, 'Quantidade', '1', 'SMNS07_01'),
(35, 'Condição', 'Morto', 'SMNS07_01'),
(36, 'Ultima Verificação', '10/17/2024', 'SMNS07_01'),
(37, 'Notas', 'Morto', 'SMNS07_01'),

-- SPRT_01 Details
(38, 'Tipo', 'Mesa Som', 'SPRT_01'),
(39, 'Quantidade', '1', 'SPRT_01'),
(40, 'Condição', 'Funciona', 'SPRT_01'),
(41, 'Ultima Verificação', '29/09/2024', 'SPRT_01'),
(42, 'Notas', 'Nada a Apontar', 'SPRT_01'),

-- SPRT_02 Details
(43, 'Tipo', 'Mesa Som', 'SPRT_02'),
(44, 'Quantidade', '1', 'SPRT_02'),
(45, 'Condição', 'Funciona', 'SPRT_02'),
(46, 'Ultima Verificação', '29/09/2024', 'SPRT_02'),
(47, 'Notas', 'Nada a Apontar', 'SPRT_02'),

-- CNST_01 Details
(48, 'Tipo', 'Mesa Dimmers', 'CNST_01'),
(49, 'Quantidade', '1', 'CNST_01'),
(50, 'Condição', 'Funciona', 'CNST_01'),
(51, 'Ultima Verificação', '29/09/2024', 'CNST_01'),
(52, 'Notas', 'Nada a Apontar', 'CNST_01'),

-- JBST_01 Details
(53, 'Tipo', 'Mesa LED', 'JBST_01'),
(54, 'Quantidade', '1', 'JBST_01'),
(55, 'Condição', 'Funciona', 'JBST_01'),
(56, 'Ultima Verificação', '29/09/2024', 'JBST_01'),
(57, 'Notas', 'Nada a Apontar', 'JBST_01'),

-- JBLT_01 Details
(58, 'Tipo', 'Coluna', 'JBLT_01'),
(59, 'Quantidade', '1', 'JBLT_01'),
(60, 'Condição', 'Funciona', 'JBLT_01'),
(61, 'Ultima Verificação', '29/09/2024', 'JBLT_01'),
(62, 'Notas', 'Nada a Apontar', 'JBLT_01'),

-- JBLT_02 Details
(63, 'Tipo', 'Coluna', 'JBLT_02'),
(64, 'Quantidade', '1', 'JBLT_02'),
(65, 'Condição', 'Funciona', 'JBLT_02'),
(66, 'Ultima Verificação', '29/09/2024', 'JBLT_02'),
(67, 'Notas', 'Nada a Apontar', 'JBLT_02'),

-- DIBH_01 Details
(68, 'Tipo', 'DI', 'DIBH_01'),
(69, 'Quantidade', '1', 'DIBH_01'),
(70, 'Condição', 'Funciona', 'DIBH_01'),
(71, 'Ultima Verificação', '29/09/2024', 'DIBH_01'),
(72, 'Notas', 'Nada a Apontar', 'DIBH_01'),

-- DIBH_02 Details
(73, 'Tipo', 'DI', 'DIBH_02'),
(74, 'Quantidade', '1', 'DIBH_02'),
(75, 'Condição', 'Funciona', 'DIBH_02'),
(76, 'Ultima Verificação', '29/09/2024', 'DIBH_02'),
(77, 'Notas', 'Nada a Apontar', 'DIBH_02'),

-- WTST_01 Details
(78, 'Tipo', 'Walkie-Talkie', 'WTST_01'),
(79, 'Quantidade', '1', 'WTST_01'),
(80, 'Condição', 'Desconhecido', 'WTST_01'),
(81, 'Ultima Verificação', '29/09/2024', 'WTST_01'),
(82, 'Notas', 'Nada a Apontar', 'WTST_01'),

-- WTST_02 Details
(83, 'Tipo', 'Walkie-Talkie', 'WTST_02'),
(84, 'Quantidade', '1', 'WTST_02'),
(85, 'Condição', 'Desconhecido', 'WTST_02'),
(86, 'Ultima Verificação', '29/09/2024', 'WTST_02'),
(87, 'Notas', 'Nada a Apontar', 'WTST_02'),

-- WTST_03 Details
(88, 'Tipo', 'Walkie-Talkie', 'WTST_03'),
(89, 'Quantidade', '1', 'WTST_03'),
(90, 'Condição', 'Desconhecido', 'WTST_03'),
(91, 'Ultima Verificação', '29/09/2024', 'WTST_03'),
(92, 'Notas', 'Nada a Apontar', 'WTST_03'),

-- WTST_04 Details
(93, 'Tipo', 'Walkie-Talkie', 'WTST_04'),
(94, 'Quantidade', '1', 'WTST_04'),
(95, 'Condição', 'Desconhecido', 'WTST_04'),
(96, 'Ultima Verificação', '29/09/2024', 'WTST_04'),
(97, 'Notas', 'Ponta Partida', 'WTST_04'),

-- WTCH_01 Details
(98, 'Tipo', 'Carregador', 'WTCH_01'),
(99, 'Quantidade', '1', 'WTCH_01'),
(100, 'Condição', 'Desconhecido', 'WTCH_01'),
(101, 'Ultima Verificação', '29/09/2024', 'WTCH_01'),
(102, 'Notas', 'Nada a Apontar', 'WTCH_01'),

-- TRSF_USBA_01 Details
(103, 'Tipo', 'Transformador', 'TRSF_USBA_01'),
(104, 'Quantidade', '1', 'TRSF_USBA_01'),
(105, 'Condição', 'Desconhecido', 'TRSF_USBA_01'),
(106, 'Ultima Verificação', '29/09/2024', 'TRSF_USBA_01'),
(107, 'Notas', 'Nada a Apontar', 'TRSF_USBA_01'),

-- VNTO_01 Details
(108, 'Tipo', 'Ventoinha', 'VNTO_01'),
(109, 'Quantidade', '1', 'VNTO_01'),
(110, 'Condição', 'Funciona', 'VNTO_01'),
(111, 'Ultima Verificação', '29/09/2024', 'VNTO_01'),
(112, 'Notas', 'Nada a Apontar', 'VNTO_01'),

-- VNTO_02 Details
(113, 'Tipo', 'Ventoinha', 'VNTO_02'),
(114, 'Quantidade', '1', 'VNTO_02'),
(115, 'Condição', 'Funciona', 'VNTO_02'),
(116, 'Ultima Verificação', '29/09/2024', 'VNTO_02'),
(117, 'Notas', 'Nada a Apontar', 'VNTO_02'),
-- Insert into Details


-- BST_9V_01 Details
(118, 'Tipo', 'Pilha', 'BST_9V_01'),
(119, 'Quantidade', '2', 'BST_9V_01'),
(120, 'Condição', 'Novo', 'BST_9V_01'),
(121, 'Tamanho', '9V', 'BST_9V_01'),
(122, 'Ultima Verificação', '27/09/2024', 'BST_9V_01'),
(123, 'Notas', 'Nada a Apontar', 'BST_9V_01'),

-- BST_9V_02 Details
(124, 'Tipo', 'Pilha', 'BST_9V_02'),
(125, 'Quantidade', '2', 'BST_9V_02'),
(126, 'Condição', 'Usado', 'BST_9V_02'),
(127, 'Tamanho', '9V', 'BST_9V_02'),
(128, 'Ultima Verificação', '27/09/2024', 'BST_9V_02'),
(129, 'Notas', 'Nada a Apontar', 'BST_9V_02'),

-- BST_9V_03 Details
(130, 'Tipo', 'Pilha', 'BST_9V_03'),
(131, 'Quantidade', '1', 'BST_9V_03'),
(132, 'Condição', 'Morta', 'BST_9V_03'),
(133, 'Tamanho', '9V', 'BST_9V_03'),
(134, 'Ultima Verificação', '27/09/2024', 'BST_9V_03'),
(135, 'Notas', 'Mede 3V', 'BST_9V_03'),

-- BST_15V_01 Details
(136, 'Tipo', 'Pilha', 'BST_15V_01'),
(137, 'Quantidade', '4', 'BST_15V_01'),
(138, 'Condição', 'Novo', 'BST_15V_01'),
(139, 'Tamanho', '1.5V', 'BST_15V_01'),
(140, 'Ultima Verificação', '27/09/2024', 'BST_15V_01'),
(141, 'Notas', 'Ainda na Caixa', 'BST_15V_01'),

-- BST_15V_02 Details
(142, 'Tipo', 'Pilha', 'BST_15V_02'),
(143, 'Quantidade', '1', 'BST_15V_02'),
(144, 'Condição', 'Usado', 'BST_15V_02'),
(145, 'Tamanho', '1.5V', 'BST_15V_02'),
(146, 'Ultima Verificação', '10/17/2024', 'BST_15V_02'),
(147, 'Notas', 'Pilha Solta', 'BST_15V_02'),

-- AVGA_MM1 Details
(148, 'Tipo', 'Adaptador', 'AVGA_MM1'),
(149, 'Quantidade', '1', 'AVGA_MM1'),
(150, 'Condição', 'Usado', 'AVGA_MM1'),
(151, 'Ultima Verificação', '27/09/2024', 'AVGA_MM1'),
(152, 'Notas', 'Nada a Apontar', 'AVGA_MM1'),

-- CDCX_01 Details
(153, 'Tipo', 'CD', 'CDCX_01'),
(154, 'Quantidade', '13', 'CDCX_01'),
(155, 'Condição', 'Usado', 'CDCX_01'),
(156, 'Ultima Verificação', '10/12/2024', 'CDCX_01'),
(157, 'Notas', 'Nada a Apontar', 'CDCX_01'),

-- CDBX_01 Details
(158, 'Tipo', 'CD', 'CDBX_01'),
(159, 'Quantidade', '1', 'CDBX_01'),
(160, 'Condição', 'Usado', 'CDBX_01'),
(161, 'Ultima Verificação', '10/12/2024', 'CDBX_01'),
(162, 'Notas', 'Nada a Apontar', 'CDBX_01'),

-- DSKT_01 Details
(163, 'Tipo', 'Disquete', 'DSKT_01'),
(164, 'Quantidade', '1', 'DSKT_01'),
(165, 'Condição', 'Usado', 'DSKT_01'),
(166, 'Ultima Verificação', '10/12/2024', 'DSKT_01'),
(167, 'Notas', 'Nada a Apontar', 'DSKT_01'),

-- CSST_01 Details
(168, 'Tipo', 'Cassete', 'CSST_01'),
(169, 'Quantidade', '1', 'CSST_01'),
(170, 'Condição', 'Usado', 'CSST_01'),
(171, 'Ultima Verificação', '10/12/2024', 'CSST_01'),
(172, 'Notas', 'Nada a Apontar', 'CSST_01'),

-- PXLR_01 Details
(173, 'Tipo', 'Pontas', 'PXLR_01'),
(174, 'Quantidade', '1', 'PXLR_01'),
(175, 'Condição', 'Usado', 'PXLR_01'),
(176, 'Ultima Verificação', '10/12/2024', 'PXLR_01'),
(177, 'Notas', 'Nada a Apontar', 'PXLR_01'),

-- XLR3_01 Details
(178, 'Marca', 'EMELEC', 'XLR3_01'),
(179, 'Tipo', 'XLR M/F', 'XLR3_01'),
(180, 'Quantidade', '1', 'XLR3_01'),
(181, 'Condição', 'Novo', 'XLR3_01'),
(182, 'Tamanho', '9.60m', 'XLR3_01'),
(183, 'Ultima Verificação', '27/09/2024', 'XLR3_01'),
(184, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_01'),

-- XLR3_02 Details
(185, 'Marca', 'EMELEC', 'XLR3_02'),
(186, 'Tipo', 'XLR M/F', 'XLR3_02'),
(187, 'Quantidade', '1', 'XLR3_02'),
(188, 'Condição', 'Novo', 'XLR3_02'),
(189, 'Tamanho', '9.70m', 'XLR3_02'),
(190, 'Ultima Verificação', '27/09/2024', 'XLR3_02'),
(191, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_02'),

-- XLR3_03 Details
(192, 'Marca', 'EMELEC', 'XLR3_03'),
(193, 'Tipo', 'XLR M/F', 'XLR3_03'),
(194, 'Quantidade', '1', 'XLR3_03'),
(195, 'Condição', 'Novo', 'XLR3_03'),
(196, 'Tamanho', '9.70m', 'XLR3_03'),
(197, 'Ultima Verificação', '27/09/2024', 'XLR3_03'),
(198, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_03'),

-- XLR3_04 Details
(199, 'Marca', 'EMELEC', 'XLR3_04'),
(200, 'Tipo', 'XLR M/F', 'XLR3_04'),
(201, 'Quantidade', '1', 'XLR3_04'),
(202, 'Condição', 'Novo', 'XLR3_04'),
(203, 'Tamanho', '9.70m', 'XLR3_04'),
(204, 'Ultima Verificação', '27/09/2024', 'XLR3_04'),
(205, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_04'),

-- XLR3_05 Details
(206, 'Marca', 'EMELEC', 'XLR3_05'),
(207, 'Tipo', 'XLR M/F', 'XLR3_05'),
(208, 'Quantidade', '1', 'XLR3_05'),
(209, 'Condição', 'Novo', 'XLR3_05'),
(210, 'Tamanho', '9.80m', 'XLR3_05'),
(211, 'Ultima Verificação', '27/09/2024', 'XLR3_05'),
(212, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_05'),

-- XLR3_06 Details
(213, 'Marca', 'EMELEC', 'XLR3_06'),
(214, 'Tipo', 'XLR M/F', 'XLR3_06'),
(215, 'Quantidade', '1', 'XLR3_06'),
(216, 'Condição', 'Novo', 'XLR3_06'),
(217, 'Tamanho', '9.80m', 'XLR3_06'),
(218, 'Ultima Verificação', '27/09/2024', 'XLR3_06'),
(219, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_06'),

-- XLR3_07 Details
(220, 'Marca', 'EMELEC', 'XLR3_07'),
(221, 'Tipo', 'XLR M/F', 'XLR3_07'),
(222, 'Quantidade', '1', 'XLR3_07'),
(223, 'Condição', 'Novo', 'XLR3_07'),
(224, 'Tamanho', '9.80m', 'XLR3_07'),
(225, 'Ultima Verificação', '27/09/2024', 'XLR3_07'),
(226, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_07'),

-- XLR3_08 Details
(227, 'Marca', 'EMELEC', 'XLR3_08'),
(228, 'Tipo', 'XLR M/F', 'XLR3_08'),
(229, 'Quantidade', '1', 'XLR3_08'),
(230, 'Condição', 'Novo', 'XLR3_08'),
(231, 'Tamanho', '9.80m', 'XLR3_08'),
(232, 'Ultima Verificação', '27/09/2024', 'XLR3_08'),
(233, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_08'),

-- XLR3_09 Details
(234, 'Marca', 'EMELEC', 'XLR3_09'),
(235, 'Tipo', 'XLR M/F', 'XLR3_09'),
(236, 'Quantidade', '1', 'XLR3_09'),
(237, 'Condição', 'Novo', 'XLR3_09'),
(238, 'Tamanho', '9.80m', 'XLR3_09'),
(239, 'Ultima Verificação', '27/09/2024', 'XLR3_09'),
(240, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_09'),

-- XLR3_10 Details
(241, 'Marca', 'EMELEC', 'XLR3_10'),
(242, 'Tipo', 'XLR M/F', 'XLR3_10'),
(243, 'Quantidade', '1', 'XLR3_10'),
(244, 'Condição', 'Novo', 'XLR3_10'),
(245, 'Tamanho', '9.90m', 'XLR3_10'),
(246, 'Ultima Verificação', '27/09/2024', 'XLR3_10'),
(247, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_10'),

-- XLR3_11 Details
(248, 'Marca', 'EMELEC', 'XLR3_11'),
(249, 'Tipo', 'XLR M/F', 'XLR3_11'),
(250, 'Quantidade', '1', 'XLR3_11'),
(251, 'Condição', 'Novo', 'XLR3_11'),
(252, 'Tamanho', '10.00m', 'XLR3_11'),
(253, 'Ultima Verificação', '27/09/2024', 'XLR3_11'),
(254, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_11'),

-- XLR3_12 Details
(255, 'Marca', 'EMELEC', 'XLR3_12'),
(256, 'Tipo', 'XLR M/F', 'XLR3_12'),
(257, 'Quantidade', '1', 'XLR3_12'),
(258, 'Condição', 'Novo', 'XLR3_12'),
(259, 'Tamanho', '10.00m', 'XLR3_12'),
(260, 'Ultima Verificação', '27/09/2024', 'XLR3_12'),
(261, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_12'),

-- XLR3_13 Details
(262, 'Marca', 'EMELEC', 'XLR3_13'),
(263, 'Tipo', 'XLR M/F', 'XLR3_13'),
(264, 'Quantidade', '1', 'XLR3_13'),
(265, 'Condição', 'Novo', 'XLR3_13'),
(266, 'Tamanho', '10.00m', 'XLR3_13'),
(267, 'Ultima Verificação', '27/09/2024', 'XLR3_13'),
(268, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_13'),

-- XLR3_14 Details
(269, 'Marca', 'EMELEC', 'XLR3_14'),
(270, 'Tipo', 'XLR M/F', 'XLR3_14'),
(271, 'Quantidade', '1', 'XLR3_14'),
(272, 'Condição', 'Novo', 'XLR3_14'),
(273, 'Tamanho', '10.10m', 'XLR3_14'),
(274, 'Ultima Verificação', '27/09/2024', 'XLR3_14'),
(275, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_14'),

-- XLR3_15 Details
(276, 'Marca', 'EMELEC', 'XLR3_15'),
(277, 'Tipo', 'XLR M/F', 'XLR3_15'),
(278, 'Quantidade', '1', 'XLR3_15'),
(279, 'Condição', 'Novo', 'XLR3_15'),
(280, 'Tamanho', '10.10m', 'XLR3_15'),
(281, 'Ultima Verificação', '27/09/2024', 'XLR3_15'),
(282, 'Notas', 'Etiqueta em ambas as pontas.', 'XLR3_15'),

-- XLR3_16 Details
(283, 'Marca', 'CCO', 'XLR3_16'),
(284, 'Tipo', 'XLR M/F', 'XLR3_16'),
(285, 'Quantidade', '1', 'XLR3_16'),
(286, 'Condição', 'Novo', 'XLR3_16'),
(287, 'Tamanho', '0.10m', 'XLR3_16'),
(288, 'Ultima Verificação', '27/09/2024', 'XLR3_16'),
(289, 'Notas', 'Nada a Apontar', 'XLR3_16'),

-- XLRJ_01 Details
(290, 'Marca', 'CCO', 'XLRJ_01'),
(291, 'Tipo', 'XLR F Jack 6.3mm M', 'XLRJ_01'),
(292, 'Quantidade', '1', 'XLRJ_01'),
(293, 'Condição', 'Usado', 'XLRJ_01'),
(294, 'Tamanho', '3.00m', 'XLRJ_01'),
(295, 'Ultima Verificação', '27/09/2024', 'XLRJ_01'),
(296, 'Notas', 'Sem Etiqueta', 'XLRJ_01'),

-- XLRJ_02 Details
(297, 'Marca', 'Thomann', 'XLRJ_02'),
(298, 'Tipo', 'XLR F Jack 6.3mm M', 'XLRJ_02'),
(299, 'Quantidade', '1', 'XLRJ_02'),
(300, 'Condição', 'Não Operacional', 'XLRJ_02'),
(301, 'Tamanho', '7.20m', 'XLRJ_02'),
(302, 'Ultima Verificação', '27/09/2024', 'XLRJ_02'),
(303, 'Notas', 'Sem Etiqueta', 'XLRJ_02'),

-- XLR_2_01 Details
(304, 'Marca', 'CCO', 'XLR_2_01'),
(305, 'Tipo', 'XLR F/F', 'XLR_2_01'),
(306, 'Quantidade', '1', 'XLR_2_01'),
(307, 'Condição', 'Usado', 'XLR_2_01'),
(308, 'Tamanho', '1.00m', 'XLR_2_01'),
(309, 'Ultima Verificação', '27/09/2024', 'XLR_2_01'),
(310, 'Notas', 'Sem Etiqueta', 'XLR_2_01'),

(311, 'Marca', 'CCO', 'JCK63_01'),
(312, 'Tipo', 'Jack 6.3mm M/M', 'JCK63_01'),
(313, 'Quantidade', '1', 'JCK63_01'),
(314, 'Condição', 'Usado', 'JCK63_01'),
(315, 'Tamanho', '10.00m', 'JCK63_01'),
(316, 'Ultima Verificação', '27/09/2024', 'JCK63_01'),
(317, 'Notas', 'Sem Etiqueta.', 'JCK63_01'),

-- JSTR_01 Details
(318, 'Marca', 'CCO', 'JSTR_01'),
(319, 'Tipo', 'Stereo M Jack 3.5mm M', 'JSTR_01'),
(320, 'Quantidade', '1', 'JSTR_01'),
(321, 'Condição', 'Usado', 'JSTR_01'),
(322, 'Tamanho', '1.25m', 'JSTR_01'),
(323, 'Ultima Verificação', '27/09/2024', 'JSTR_01'),
(324, 'Notas', 'Sem Etiqueta.', 'JSTR_01'),

-- JCKM_01 Details
(325, 'Marca', 'Proel', 'JCKM_01'),
(326, 'Tipo', 'Jach 6.3 M Mono M', 'JCKM_01'),
(327, 'Quantidade', '1', 'JCKM_01'),
(328, 'Condição', 'Usado', 'JCKM_01'),
(329, 'Tamanho', '1.25m', 'JCKM_01'),
(330, 'Ultima Verificação', '27/09/2024', 'JCKM_01'),
(331, 'Notas', 'Sem Etiqueta.', 'JCKM_01'),

-- STRO_01 Details
(332, 'Marca', 'CCO', 'STRO_01'),
(333, 'Tipo', 'Stero M/M', 'STRO_01'),
(334, 'Quantidade', '1', 'STRO_01'),
(335, 'Condição', 'Usado', 'STRO_01'),
(336, 'Tamanho', '1.50m', 'STRO_01'),
(337, 'Ultima Verificação', '27/09/2024', 'STRO_01'),
(338, 'Notas', 'Sem Etiqueta.', 'STRO_01'),

-- VGA_01 Details
(339, 'Marca', 'Vitecom', 'VGA_01'),
(340, 'Tipo', 'VGA M/F', 'VGA_01'),
(341, 'Quantidade', '1', 'VGA_01'),
(342, 'Condição', 'Usado', 'VGA_01'),
(343, 'Tamanho', '3.00m', 'VGA_01'),
(344, 'Ultima Verificação', '27/09/2024', 'VGA_01'),
(345, 'Notas', 'Sem Etiqueta.', 'VGA_01'),

-- VGA_02 Details
(346, 'Marca', 'CCO', 'VGA_02'),
(347, 'Tipo', 'VGA M/M', 'VGA_02'),
(348, 'Quantidade', '1', 'VGA_02'),
(349, 'Condição', 'Usado', 'VGA_02'),
(350, 'Tamanho', '4.50m', 'VGA_02'),
(351, 'Ultima Verificação', '27/09/2024', 'VGA_02'),
(352, 'Notas', 'Sem Etiqueta.', 'VGA_02'),

-- VGA_03 Details
(353, 'Marca', 'CCO', 'VGA_03'),
(354, 'Tipo', 'VGA M/M', 'VGA_03'),
(355, 'Quantidade', '1', 'VGA_03'),
(356, 'Condição', 'Usado', 'VGA_03'),
(357, 'Tamanho', '7.00m', 'VGA_03'),
(358, 'Ultima Verificação', '27/09/2024', 'VGA_03'),
(359, 'Notas', 'Sem Etiqueta.', 'VGA_03'),

-- VGA_04 Details
(360, 'Marca', 'CCO', 'VGA_04'),
(361, 'Tipo', 'VGA M/M', 'VGA_04'),
(362, 'Quantidade', '1', 'VGA_04'),
(363, 'Condição', 'Usado', 'VGA_04'),
(364, 'Tamanho', '1.50m', 'VGA_04'),
(365, 'Ultima Verificação', '10/12/2024', 'VGA_04'),
(366, 'Notas', 'Sem Etiqueta.', 'VGA_04'),

-- SCRT_01 Details
(367, 'Marca', 'CCO', 'SCRT_01'),
(368, 'Tipo', 'SCART M/M', 'SCRT_01'),
(369, 'Quantidade', '1', 'SCRT_01'),
(370, 'Condição', 'Usado', 'SCRT_01'),
(371, 'Tamanho', '1.50m', 'SCRT_01'),
(372, 'Ultima Verificação', '27/09/2024', 'SCRT_01'),
(373, 'Notas', 'Sem Etiqueta.', 'SCRT_01'),

-- RCAA_01 Details
(374, 'Marca', 'CCO', 'RCAA_01'),
(375, 'Tipo', 'RCA Video', 'RCAA_01'),
(376, 'Quantidade', '1', 'RCAA_01'),
(377, 'Condição', 'Usado', 'RCAA_01'),
(378, 'Tamanho', '1.00m', 'RCAA_01'),
(379, 'Ultima Verificação', '27/09/2024', 'RCAA_01'),
(380, 'Notas', 'Sem Etiqueta.', 'RCAA_01'),

-- HDMI_01 Details
(381, 'Marca', 'CCO', 'HDMI_01'),
(382, 'Tipo', 'HDMI M/M', 'HDMI_01'),
(383, 'Quantidade', '1', 'HDMI_01'),
(384, 'Condição', 'Usado', 'HDMI_01'),
(385, 'Tamanho', '1.50m', 'HDMI_01'),
(386, 'Ultima Verificação', '27/09/2024', 'HDMI_01'),
(387, 'Notas', 'Sem Etiqueta.', 'HDMI_01'),

-- RJ45_01 Details
(388, 'Marca', 'CCO', 'RJ45_01'),
(389, 'Tipo', 'Cabo Rede', 'RJ45_01'),
(390, 'Quantidade', '1', 'RJ45_01'),
(391, 'Condição', 'Usado', 'RJ45_01'),
(392, 'Tamanho', '12.00m', 'RJ45_01'),
(393, 'Ultima Verificação', '27/09/2024', 'RJ45_01'),
(394, 'Notas', 'Sem Etiqueta.', 'RJ45_01'),

-- RJ45_02 Details
(395, 'Marca', 'CCO', 'RJ45_02'),
(396, 'Tipo', 'Cabo Rede', 'RJ45_02'),
(397, 'Quantidade', '1', 'RJ45_02'),
(398, 'Condição', 'Usado', 'RJ45_02'),
(399, 'Tamanho', '5.00m', 'RJ45_02'),
(400, 'Ultima Verificação', '27/09/2024', 'RJ45_02'),
(401, 'Notas', 'Sem Etiqueta.', 'RJ45_02'),

-- RJ45_03 Details
(402, 'Marca', 'CCO', 'RJ45_03'),
(403, 'Tipo', 'Cabo Rede', 'RJ45_03'),
(404, 'Quantidade', '1', 'RJ45_03'),
(405, 'Condição', 'Usado', 'RJ45_03'),
(406, 'Tamanho', '2.75m', 'RJ45_03'),
(407, 'Ultima Verificação', '27/09/2024', 'RJ45_03'),
(408, 'Notas', 'Sem Etiqueta.', 'RJ45_03'),

-- PWR_01 Details
(409, 'Marca', 'CCO', 'PWR_01'),
(410, 'Tipo', 'Corrente M/M', 'PWR_01'),
(411, 'Quantidade', '1', 'PWR_01'),
(412, 'Condição', 'Usado', 'PWR_01'),
(413, 'Tamanho', '3.50m', 'PWR_01'),
(414, 'Ultima Verificação', '27/09/2024', 'PWR_01'),
(415, 'Notas', 'Sem Etiqueta.', 'PWR_01'),

-- PWR_02 Details
(416, 'Marca', 'CCO', 'PWR_02'),
(417, 'Tipo', 'Corrente M/F', 'PWR_02'),
(418, 'Quantidade', '1', 'PWR_02'),
(419, 'Condição', 'Usado', 'PWR_02'),
(420, 'Tamanho', '5.20m', 'PWR_02'),
(421, 'Ultima Verificação', '27/09/2024', 'PWR_02'),
(422, 'Notas', 'Sem Etiqueta.', 'PWR_02'),

-- PWR_IP44_01 Details
(423, 'Marca', 'CCO', 'PWR_IP44_01'),
(424, 'Tipo', 'Corrente F IP44 M', 'PWR_IP44_01'),
(425, 'Quantidade', '1', 'PWR_IP44_01'),
(426, 'Condição', 'Usado', 'PWR_IP44_01'),
(427, 'Tamanho', '6.00m', 'PWR_IP44_01'),
(428, 'Ultima Verificação', '27/09/2024', 'PWR_IP44_01'),
(429, 'Notas', 'Sem Etiqueta.', 'PWR_IP44_01'),

-- PWR_IP44_02 Details
(430, 'Marca', 'CCO', 'PWR_IP44_02'),
(431, 'Tipo', 'Corrente F IP44 M', 'PWR_IP44_02'),
(432, 'Quantidade', '1', 'PWR_IP44_02'),
(433, 'Condição', 'Usado', 'PWR_IP44_02'),
(434, 'Tamanho', '1.00m', 'PWR_IP44_02'),
(435, 'Ultima Verificação', '27/09/2024', 'PWR_IP44_02'),
(436, 'Notas', 'Sem Etiqueta.', 'PWR_IP44_02'),

-- PWR_IP44_03 Details
(437, 'Marca', 'CCO', 'PWR_IP44_03'),
(438, 'Tipo', 'Corrente F IP44 M', 'PWR_IP44_03'),
(439, 'Quantidade', '1', 'PWR_IP44_03'),
(440, 'Condição', 'Usado', 'PWR_IP44_03'),
(441, 'Tamanho', '1.00m', 'PWR_IP44_03'),
(442, 'Ultima Verificação', '27/09/2024', 'PWR_IP44_03'),
(443, 'Notas', 'Sem Etiqueta.', 'PWR_IP44_03'),

-- PWR_IP44_04 Details
(444, 'Marca', 'CCO', 'PWR_IP44_04'),
(445, 'Tipo', 'Corrente F IP44 M', 'PWR_IP44_04'),
(446, 'Quantidade', '1', 'PWR_IP44_04'),
(447, 'Condição', 'Usado', 'PWR_IP44_04'),
(448, 'Tamanho', '1.20m', 'PWR_IP44_04'),
(449, 'Ultima Verificação', '27/09/2024', 'PWR_IP44_04'),
(450, 'Notas', 'Sem Etiqueta.', 'PWR_IP44_04'),

-- TRPL_01 Details
(451, 'Marca', 'CCO', 'TRPL_01'),
(452, 'Tipo', 'Tripla ON/OFF', 'TRPL_01'),
(453, 'Quantidade', '1', 'TRPL_01'),
(454, 'Condição', 'Usado', 'TRPL_01'),
(455, 'Tamanho', '14.50m', 'TRPL_01'),
(456, 'Ultima Verificação', '27/09/2024', 'TRPL_01'),
(457, 'Notas', 'Sem Etiqueta.', 'TRPL_01'),

-- TRPL_02 Details
(458, 'Marca', 'CCO', 'TRPL_02'),
(459, 'Tipo', 'Tripla Parede', 'TRPL_02'),
(460, 'Quantidade', '1', 'TRPL_02'),
(461, 'Condição', 'Usado', 'TRPL_02'),
(462, 'Ultima Verificação', '10/12/2024', 'TRPL_02'),
(463, 'Notas', 'Nada a Apontar', 'TRPL_02'),

-- PWRD_01 Details
(464, 'Marca', 'CCO', 'PWRD_01'),
(465, 'Tipo', 'Corrente PC', 'PWRD_01'),
(466, 'Quantidade', '1', 'PWRD_01'),
(467, 'Condição', 'Usado', 'PWRD_01'),
(468, 'Tamanho', '1.00m', 'PWRD_01'),
(469, 'Ultima Verificação', '27/09/2024', 'PWRD_01'),
(470, 'Notas', 'Sem Etiqueta.', 'PWRD_01'),

-- PCHD_01 Details
(471, 'Marca', 'Alcobre', 'PCHD_01'),
(472, 'Tipo', 'Patch Dimmers', 'PCHD_01'),
(473, 'Quantidade', '1', 'PCHD_01'),
(474, 'Condição', 'Usado', 'PCHD_01'),
(475, 'Tamanho', '1.00m', 'PCHD_01'),
(476, 'Ultima Verificação', '27/09/2024', 'PCHD_01'),
(477, 'Notas', 'Sem Etiqueta.', 'PCHD_01'),

-- PCHD_02 Details
(478, 'Marca', 'Alcobre', 'PCHD_02'),
(479, 'Tipo', 'Patch Dimmers', 'PCHD_02'),
(480, 'Quantidade', '1', 'PCHD_02'),
(481, 'Condição', 'Usado', 'PCHD_02'),
(482, 'Tamanho', '1.00m', 'PCHD_02'),
(483, 'Ultima Verificação', '27/09/2024', 'PCHD_02'),
(484, 'Notas', 'Sem Etiqueta.', 'PCHD_02'),

-- PCHD_03 Details
(485, 'Marca', 'Alcobre', 'PCHD_03'),
(486, 'Tipo', 'Patch Dimmers', 'PCHD_03'),
(487, 'Quantidade', '1', 'PCHD_03'),
(488, 'Condição', 'Usado', 'PCHD_03'),
(489, 'Tamanho', '1.00m', 'PCHD_03'),
(490, 'Ultima Verificação', '27/09/2024', 'PCHD_03'),
(491, 'Notas', 'Sem Etiqueta.', 'PCHD_03'),

-- PCHD_04 Details
(492, 'Marca', 'Alcobre', 'PCHD_04'),
(493, 'Tipo', 'Patch Dimmers', 'PCHD_04'),
(494, 'Quantidade', '1', 'PCHD_04'),
(495, 'Condição', 'Usado', 'PCHD_04'),
(496, 'Tamanho', '1.00m', 'PCHD_04'),
(497, 'Ultima Verificação', '27/09/2024', 'PCHD_04'),
(498, 'Notas', 'Sem Etiqueta.', 'PCHD_04'),


-- PCHD_05 Details
(499, 'Marca', 'Alcobre', 'PCHD_05'),
(500, 'Tipo', 'Patch Dimmers', 'PCHD_05'),
(501, 'Quantidade', '1', 'PCHD_05'),
(502, 'Condição', 'Usado', 'PCHD_05'),
(503, 'Tamanho', '1.00m', 'PCHD_05'),
(504, 'Ultima Verificação', '27/09/2024', 'PCHD_05'),
(505, 'Notas', 'Sem Etiqueta.', 'PCHD_05'),

-- PCHD_06 Details
(506, 'Marca', 'Alcobre', 'PCHD_06'),
(507, 'Tipo', 'Patch Dimmers', 'PCHD_06'),
(508, 'Quantidade', '1', 'PCHD_06'),
(509, 'Condição', 'Usado', 'PCHD_06'),
(510, 'Tamanho', '1.00m', 'PCHD_06'),
(511, 'Ultima Verificação', '27/09/2024', 'PCHD_06'),
(512, 'Notas', 'Sem Etiqueta.', 'PCHD_06'),

-- PCHD_07 Details
(513, 'Marca', 'Alcobre', 'PCHD_07'),
(514, 'Tipo', 'Patch Dimmers', 'PCHD_07'),
(515, 'Quantidade', '1', 'PCHD_07'),
(516, 'Condição', 'Usado', 'PCHD_07'),
(517, 'Tamanho', '1.00m', 'PCHD_07'),
(518, 'Ultima Verificação', '27/09/2024', 'PCHD_07'),
(519, 'Notas', 'Sem Etiqueta.', 'PCHD_07'),

-- PCHD_08 Details
(520, 'Marca', 'Alcobre', 'PCHD_08'),
(521, 'Tipo', 'Patch Dimmers', 'PCHD_08'),
(522, 'Quantidade', '1', 'PCHD_08'),
(523, 'Condição', 'Usado', 'PCHD_08'),
(524, 'Tamanho', '1.00m', 'PCHD_08'),
(525, 'Ultima Verificação', '27/09/2024', 'PCHD_08'),
(526, 'Notas', 'Sem Etiqueta.', 'PCHD_08'),

-- PCHD_09 Details
(527, 'Marca', 'Alcobre', 'PCHD_09'),
(528, 'Tipo', 'Patch Dimmers', 'PCHD_09'),
(529, 'Quantidade', '1', 'PCHD_09'),
(530, 'Condição', 'Usado', 'PCHD_09'),
(531, 'Tamanho', '1.00m', 'PCHD_09'),
(532, 'Ultima Verificação', '27/09/2024', 'PCHD_09'),
(533, 'Notas', 'Sem Etiqueta.', 'PCHD_09'),

-- PCHD_10 Details
(534, 'Marca', 'Alcobre', 'PCHD_10'),
(535, 'Tipo', 'Patch Dimmers', 'PCHD_10'),
(536, 'Quantidade', '1', 'PCHD_10'),
(537, 'Condição', 'Usado', 'PCHD_10'),
(538, 'Tamanho', '1.00m', 'PCHD_10'),
(539, 'Ultima Verificação', '27/09/2024', 'PCHD_10'),
(540, 'Notas', 'Sem Etiqueta.', 'PCHD_10'),

-- PCHD_11 Details
(541, 'Marca', 'Alcobre', 'PCHD_11'),
(542, 'Tipo', 'Patch Dimmers', 'PCHD_11'),
(543, 'Quantidade', '1', 'PCHD_11'),
(544, 'Condição', 'Usado', 'PCHD_11'),
(545, 'Tamanho', '1.00m', 'PCHD_11'),
(546, 'Ultima Verificação', '27/09/2024', 'PCHD_11'),
(547, 'Notas', 'Sem Etiqueta.', 'PCHD_11'),

-- PCHD_12 Details
(548, 'Marca', 'Alcobre', 'PCHD_12'),
(549, 'Tipo', 'Patch Dimmers', 'PCHD_12'),
(550, 'Quantidade', '1', 'PCHD_12'),
(551, 'Condição', 'Usado', 'PCHD_12'),
(552, 'Tamanho', '1.00m', 'PCHD_12'),
(553, 'Ultima Verificação', '27/09/2024', 'PCHD_12'),
(554, 'Notas', 'Sem Etiqueta.', 'PCHD_12'),

-- PCHD_13 Details
(555, 'Marca', 'Alcobre', 'PCHD_13'),
(556, 'Tipo', 'Patch Dimmers', 'PCHD_13'),
(557, 'Quantidade', '1', 'PCHD_13'),
(558, 'Condição', 'Usado', 'PCHD_13'),
(559, 'Tamanho', '1.00m', 'PCHD_13'),
(560, 'Ultima Verificação', '27/09/2024', 'PCHD_13'),
(561, 'Notas', 'Sem Etiqueta.', 'PCHD_13'),

-- PCHD_14 Details
(562, 'Marca', 'Alcobre', 'PCHD_14'),
(563, 'Tipo', 'Patch Dimmers', 'PCHD_14'),
(564, 'Quantidade', '1', 'PCHD_14'),
(565, 'Condição', 'Usado', 'PCHD_14'),
(566, 'Tamanho', '1.00m', 'PCHD_14'),
(567, 'Ultima Verificação', '27/09/2024', 'PCHD_14'),
(568, 'Notas', 'Sem Etiqueta.', 'PCHD_14'),

-- PCHD_15 Details
(569, 'Marca', 'Alcobre', 'PCHD_15'),
(570, 'Tipo', 'Patch Dimmers', 'PCHD_15'),
(571, 'Quantidade', '1', 'PCHD_15'),
(572, 'Condição', 'Usado', 'PCHD_15'),
(573, 'Tamanho', '1.00m', 'PCHD_15'),
(574, 'Ultima Verificação', '27/09/2024', 'PCHD_15'),
(575, 'Notas', 'Sem Etiqueta.', 'PCHD_15'),

-- PCHD_16 Details
(576, 'Marca', 'Alcobre', 'PCHD_16'),
(577, 'Tipo', 'Patch Dimmers', 'PCHD_16'),
(578, 'Quantidade', '1', 'PCHD_16'),
(579, 'Condição', 'Usado', 'PCHD_16'),
(580, 'Tamanho', '1.00m', 'PCHD_16'),
(581, 'Ultima Verificação', '27/09/2024', 'PCHD_16'),
(582, 'Notas', 'Sem Etiqueta.', 'PCHD_16'),

-- PCHD_17 Details
(583, 'Marca', 'Alcobre', 'PCHD_17'),
(584, 'Tipo', 'Patch Dimmers', 'PCHD_17'),
(585, 'Quantidade', '1', 'PCHD_17'),
(586, 'Condição', 'Usado', 'PCHD_17'),
(587, 'Tamanho', '1.00m', 'PCHD_17'),
(588, 'Ultima Verificação', '27/09/2024', 'PCHD_17'),
(589, 'Notas', 'Sem Etiqueta.', 'PCHD_17'),

-- PCHD_18 Details
(590, 'Marca', 'Alcobre', 'PCHD_18'),
(591, 'Tipo', 'Patch Dimmers', 'PCHD_18'),
(592, 'Quantidade', '1', 'PCHD_18'),
(593, 'Condição', 'Usado', 'PCHD_18'),
(594, 'Tamanho', '1.00m', 'PCHD_18'),
(595, 'Ultima Verificação', '27/09/2024', 'PCHD_18'),
(596, 'Notas', 'Sem Etiqueta.', 'PCHD_18'),

-- PCHD_19 Details
(597, 'Marca', 'Alcobre', 'PCHD_19'),
(598, 'Tipo', 'Patch Dimmers', 'PCHD_19'),
(599, 'Quantidade', '1', 'PCHD_19'),
(600, 'Condição', 'Usado', 'PCHD_19'),
(601, 'Tamanho', '1.00m', 'PCHD_19'),
(602, 'Ultima Verificação', '27/09/2024', 'PCHD_19'),
(603, 'Notas', 'Sem Etiqueta.', 'PCHD_19'),

-- PCHD_20 Details
(604, 'Marca', 'Alcobre', 'PCHD_20'),
(605, 'Tipo', 'Patch Dimmers', 'PCHD_20'),
(606, 'Quantidade', '1', 'PCHD_20'),
(607, 'Condição', 'Usado', 'PCHD_20'),
(608, 'Tamanho', '1.00m', 'PCHD_20'),
(609, 'Ultima Verificação', '27/09/2024', 'PCHD_20'),
(610, 'Notas', 'Sem Etiqueta.', 'PCHD_20'),

-- PCHD_21 Details
(611, 'Marca', 'Alcobre', 'PCHD_21'),
(612, 'Tipo', 'Patch Dimmers', 'PCHD_21'),
(613, 'Quantidade', '1', 'PCHD_21'),
(614, 'Condição', 'Usado', 'PCHD_21'),
(615, 'Tamanho', '1.00m', 'PCHD_21'),
(616, 'Ultima Verificação', '27/09/2024', 'PCHD_21'),
(617, 'Notas', 'Sem Etiqueta.', 'PCHD_21'),

-- PCHD_22 Details
(618, 'Marca', 'Alcobre', 'PCHD_22'),
(619, 'Tipo', 'Patch Dimmers', 'PCHD_22'),
(620, 'Quantidade', '1', 'PCHD_22'),
(621, 'Condição', 'Usado', 'PCHD_22'),
(622, 'Tamanho', '1.00m', 'PCHD_22'),
(623, 'Ultima Verificação', '27/09/2024', 'PCHD_22'),
(624, 'Notas', 'Sem Etiqueta.', 'PCHD_22'),

-- PCHD_23 Details
(625, 'Marca', 'Alcobre', 'PCHD_23'),
(626, 'Tipo', 'Patch Dimmers', 'PCHD_23'),
(627, 'Quantidade', '1', 'PCHD_23'),
(628, 'Condição', 'Usado', 'PCHD_23'),
(629, 'Tamanho', '1.00m', 'PCHD_23'),
(630, 'Ultima Verificação', '27/09/2024', 'PCHD_23'),
(631, 'Notas', 'Sem Etiqueta.', 'PCHD_23'),

-- PCHD_24 Details
(632, 'Marca', 'Alcobre', 'PCHD_24'),
(633, 'Tipo', 'Patch Dimmers', 'PCHD_24'),
(634, 'Quantidade', '1', 'PCHD_24'),
(635, 'Condição', 'Usado', 'PCHD_24'),
(636, 'Tamanho', '1.00m', 'PCHD_24'),
(637, 'Ultima Verificação', '27/09/2024', 'PCHD_24'),
(638, 'Notas', 'Sem Etiqueta.', 'PCHD_24'),

-- PCHD_25 Details
(639, 'Marca', 'Alcobre', 'PCHD_25'),
(640, 'Tipo', 'Patch Dimmers', 'PCHD_25'),
(641, 'Quantidade', '1', 'PCHD_25'),
(642, 'Condição', 'Usado', 'PCHD_25'),
(643, 'Tamanho', '1.00m', 'PCHD_25'),
(644, 'Ultima Verificação', '27/09/2024', 'PCHD_25'),
(645, 'Notas', 'Sem Etiqueta.', 'PCHD_25'),

-- PCHD_26 Details
(646, 'Marca', 'Alcobre', 'PCHD_26'),
(647, 'Tipo', 'Patch Dimmers', 'PCHD_26'),
(648, 'Quantidade', '1', 'PCHD_26'),
(649, 'Condição', 'Usado', 'PCHD_26'),
(650, 'Tamanho', '1.00m', 'PCHD_26'),
(651, 'Ultima Verificação', '27/09/2024', 'PCHD_26'),
(652, 'Notas', 'Sem Etiqueta.', 'PCHD_26'),

-- PCHD_27 Details
(653, 'Marca', 'Alcobre', 'PCHD_27'),
(654, 'Tipo', 'Patch Dimmers', 'PCHD_27'),
(655, 'Quantidade', '1', 'PCHD_27'),
(656, 'Condição', 'Usado', 'PCHD_27'),
(657, 'Tamanho', '1.00m', 'PCHD_27'),
(658, 'Ultima Verificação', '27/09/2024', 'PCHD_27'),
(659, 'Notas', 'Sem Etiqueta.', 'PCHD_27'),

-- PCHD_28 Details
(660, 'Marca', 'Alcobre', 'PCHD_28'),
(661, 'Tipo', 'Patch Dimmers', 'PCHD_28'),
(662, 'Quantidade', '1', 'PCHD_28'),
(663, 'Condição', 'Usado', 'PCHD_28'),
(664, 'Tamanho', '1.00m', 'PCHD_28'),
(665, 'Ultima Verificação', '27/09/2024', 'PCHD_28'),
(666, 'Notas', 'Sem Etiqueta.', 'PCHD_28'),

-- PCHD_29 Details
(667, 'Marca', 'Alcobre', 'PCHD_29'),
(668, 'Tipo', 'Patch Dimmers', 'PCHD_29'),
(669, 'Quantidade', '1', 'PCHD_29'),
(670, 'Condição', 'Usado', 'PCHD_29'),
(671, 'Tamanho', '1.00m', 'PCHD_29'),
(672, 'Ultima Verificação', '27/09/2024', 'PCHD_29'),
(673, 'Notas', 'Sem Etiqueta.', 'PCHD_29'),

-- PCHD_30 Details
(674, 'Marca', 'Alcobre', 'PCHD_30'),
(675, 'Tipo', 'Patch Dimmers', 'PCHD_30'),
(676, 'Quantidade', '1', 'PCHD_30'),
(677, 'Condição', 'Usado', 'PCHD_30'),
(678, 'Tamanho', '1.00m', 'PCHD_30'),
(679, 'Ultima Verificação', '27/09/2024', 'PCHD_30'),
(680, 'Notas', 'Sem Etiqueta.', 'PCHD_30'),

-- PCHD_31 Details
(681, 'Marca', 'Alcobre', 'PCHD_31'),
(682, 'Tipo', 'Patch Dimmers', 'PCHD_31'),
(683, 'Quantidade', '1', 'PCHD_31'),
(684, 'Condição', 'Usado', 'PCHD_31'),
(685, 'Tamanho', '1.00m', 'PCHD_31'),
(686, 'Ultima Verificação', '27/09/2024', 'PCHD_31'),
(687, 'Notas', 'Sem Etiqueta.', 'PCHD_31'),

-- PCHD_32 Details
(688, 'Marca', 'Alcobre', 'PCHD_32'),
(689, 'Tipo', 'Patch Dimmers', 'PCHD_32'),
(690, 'Quantidade', '1', 'PCHD_32'),
(691, 'Condição', 'Usado', 'PCHD_32'),
(692, 'Tamanho', '1.00m', 'PCHD_32'),
(693, 'Ultima Verificação', '27/09/2024', 'PCHD_32'),
(694, 'Notas', 'Sem Etiqueta.', 'PCHD_32'),

-- BNCR Details
(695, 'Tipo', 'Banco', 'BNCR'),
(696, 'Quantidade', '2', 'BNCR'),
(697, 'Condição', 'Novo', 'BNCR'),
(698, 'Tamanho', 'Alto', 'BNCR'),
(699, 'Ultima Verificação', '27/09/2024', 'BNCR'),
(700, 'Notas', 'Nada a Apontar', 'BNCR'),

-- BNCB Details
(701, 'Tipo', 'Banco', 'BNCB'),
(702, 'Quantidade', '3', 'BNCB'),
(703, 'Condição', 'Novo', 'BNCB'),
(704, 'Tamanho', 'Alto', 'BNCB'),
(705, 'Ultima Verificação', '27/09/2024', 'BNCB'),
(706, 'Notas', 'Nada a Apontar', 'BNCB'),

-- MSAC Details
(707, 'Tipo', 'Mesa', 'MSAC'),
(708, 'Quantidade', '5', 'MSAC'),
(709, 'Condição', 'Novo', 'MSAC'),
(710, 'Tamanho', 'Médio', 'MSAC'),
(711, 'Ultima Verificação', '27/09/2024', 'MSAC'),
(712, 'Notas', 'Nada a Apontar', 'MSAC'),

-- PTRC Details
(713, 'Tipo', 'Cadeira', 'PTRC'),
(714, 'Quantidade', '10', 'PTRC'),
(715, 'Condição', 'Novo', 'PTRC'),
(716, 'Tamanho', 'Médio', 'PTRC'),
(717, 'Ultima Verificação', '27/09/2024', 'PTRC'),
(718, 'Notas', 'Nada a Apontar', 'PTRC'),

-- PLTD Details
(719, 'Tipo', 'Planta', 'PLTD'),
(720, 'Quantidade', '5', 'PLTD'),
(721, 'Condição', 'Novo', 'PLTD'),
(722, 'Tamanho', 'Pequeno', 'PLTD'),
(723, 'Ultima Verificação', '27/09/2024', 'PLTD'),
(724, 'Notas', 'Nada a Apontar', 'PLTD'),

-- ARVD Details
(725, 'Tipo', 'Vaso', 'ARVD'),
(726, 'Quantidade', '5', 'ARVD'),
(727, 'Condição', 'Novo', 'ARVD'),
(728, 'Tamanho', 'Grande', 'ARVD'),
(729, 'Ultima Verificação', '27/09/2024', 'ARVD'),
(730, 'Notas', 'Nada a Apontar', 'ARVD'),

-- CRDE Details
(731, 'Tipo', 'Cadeira', 'CRDE'),
(732, 'Quantidade', '2', 'CRDE'),
(733, 'Condição', 'Novo', 'CRDE'),
(734, 'Tamanho', 'Médio', 'CRDE'),
(735, 'Ultima Verificação', '27/09/2024', 'CRDE'),
(736, 'Notas', 'Nada a Apontar', 'CRDE'),

-- MSAR Details
(737, 'Tipo', 'Mesa', 'MSAR'),
(738, 'Quantidade', '1', 'MSAR'),
(739, 'Condição', 'Novo', 'MSAR'),
(740, 'Tamanho', 'Grande', 'MSAR'),
(741, 'Ultima Verificação', '27/09/2024', 'MSAR'),
(742, 'Notas', 'Nada a Apontar', 'MSAR'),

-- PLTF_01 Details
(743, 'Tipo', 'Adereço Palco', 'PLTF_01'),
(744, 'Quantidade', '1', 'PLTF_01'),
(745, 'Condição', 'Novo', 'PLTF_01'),
(746, 'Tamanho', 'Grande', 'PLTF_01'),
(747, 'Ultima Verificação', '27/09/2024', 'PLTF_01'),
(748, 'Notas', 'Nada a Apontar', 'PLTF_01'),

-- CDRP_01 Details
(749, 'Tipo', 'Cadeira', 'CDRP_01'),
(750, 'Quantidade', '116', 'CDRP_01'),
(751, 'Condição', 'Usado', 'CDRP_01'),
(752, 'Tamanho', 'Normal', 'CDRP_01'),
(753, 'Ultima Verificação', '10/4/2024', 'CDRP_01'),
(754, 'Notas', 'A cadeira a mais está na última fila', 'CDRP_01'),

-- CDRP_02 Details
(755, 'Tipo', 'Cadeira', 'CDRP_02'),
(756, 'Quantidade', '70', 'CDRP_02'),
(757, 'Condição', 'Usado', 'CDRP_02'),
(758, 'Tamanho', 'Normal', 'CDRP_02'),
(759, 'Ultima Verificação', '10/4/2024', 'CDRP_02'),
(760, 'Notas', 'As 4 cadeiras a mais estão na última fila, 1 avariada', 'CDRP_02'),

-- CDRP_03 Details
(761, 'Tipo', 'Cadeira', 'CDRP_03'),
(762, 'Quantidade', '1', 'CDRP_03'),
(763, 'Condição', 'Usado', 'CDRP_03'),
(764, 'Tamanho', 'Normal', 'CDRP_03'),
(765, 'Ultima Verificação', '10/4/2024', 'CDRP_03'),
(766, 'Notas', 'A cadeira está na última fila', 'CDRP_03'),

(767, "Tipo", "Piano", "PIAN_01"),
(768, "Quantidade", "1", "PIAN_01"),
(769, "Condição", "Desgastado", "PIAN_01"),
(770, "Tamanho", "Grande", "PIAN_01"),
(771, "Ultima Verificação", "2024-04-10", "PIAN_01"),
(772, "Notas", "Base separada do piano. Cuidado ao transportar", "PIAN_01"),

(773, "Tipo", "Cadeira Bateria", "CDRB_01"),
(774, "Quantidade", "1", "CDRB_01"),
(775, "Condição", "Novo", "CDRB_01"),
(776, "Tamanho", "Normal", "CDRB_01"),
(777, "Ultima Verificação", "2024-04-10", "CDRB_01"),
(778, "Notas", "Nada a Apontar", "CDRB_01");




CREATE TABLE Events (
    IdEvent VARCHAR(50) PRIMARY KEY,
    EventName VARCHAR(75),
    EventPlace VARCHAR(75),
    NameRep VARCHAR(75),
    EmailRep VARCHAR(75),
    TecExt VARCHAR(75),
    Date DATE
);

CREATE TABLE Item_Event (
    IdIE INT PRIMARY KEY auto_increment,
    FK_IdEvent VARCHAR(50),
    FK_IdItem VARCHAR(50),
    FOREIGN KEY (FK_IdItem) REFERENCES Items(IdItem),
    FOREIGN KEY (FK_IdEvent) REFERENCES Events(IdEvent)
);

INSERT INTO Events VALUES 
("VCCS_1", "Vila do Conde Comedy Sessions", "Auditório CCO", "Nuno Lacerda, Roberto Correia", "-", "CCO", "2024-09-27"),
("VCCS_2", "Vila do Conde Comedy Sessions", "Auditório CCO", "Nuno Lacerda, Roberto Correia", "-", "CCO", "2024-10-18"),
("VCCS_3", "Vila do Conde Comedy Sessions", "Auditório CCO", "Nuno Lacerda, Roberto Correia", "-", "CCO", "2024-11-02"),
("VCCS_4", "Vila do Conde Comedy Sessions, Matiné de Natal", "Auditório CCO", "Nuno Lacerda, Roberto Correia", "-", "CCO", "2024-12-15"),
("VCCS_5", "Vila do Conde Comedy Sessions", "Auditório CCO", "Nuno Lacerda, Roberto Correia", "-", "CCO", "2025-01-18"),
("ORF_01", "Orfeão: Relembrar Itália", "Auditório CCO", "Maestro Samuel Santos", "-", "CCO", "2024-09-29"),

("TEAT_01", "Pandora", "Auditório CCO", "ErrorTeatro", "-", "CCO", "2024-10-12");


INSERT INTO Item_Event (FK_IdEvent, FK_IdItem) VALUES
("VCCS_1", "MSCH_SM58"),
("VCCS_1", "BNCR"),
("VCCS_1", "BST_9V_01"),
("VCCS_1", "XLR3_01"),
("VCCS_1", "JBLT_01"),
("VCCS_1", "SPRT_01"),
("VCCS_1", "PWR_02"),
("VCCS_1", "TRPL_01"),
("VCCS_1", "PLTF_01"),

("VCCS_2", "MSCH_SM58"),
("VCCS_2", "BNCR"),
("VCCS_2", "BST_9V_01"),
("VCCS_2", "XLR3_01"),
("VCCS_2", "JBLT_01"),
("VCCS_2", "SPRT_01"),
("VCCS_2", "PWR_02"),
("VCCS_2", "TRPL_01"),
("VCCS_2", "PLTF_01"),

("VCCS_3", "MSCH_SM58"),
("VCCS_3", "BNCR"),
("VCCS_3", "BST_9V_01"),
("VCCS_3", "XLR3_01"),
("VCCS_3", "XLR3_02"),
("VCCS_3", "JBLT_01"),
("VCCS_3", "SPRT_01"),
("VCCS_3", "PWR_02"),
("VCCS_3", "TRPL_01"),
("VCCS_3", "PLTF_01"),
("VCCS_3", "DIBH_01"),

("VCCS_4", "MSCH_SM58"),
("VCCS_4", "BNCR"),
("VCCS_4", "BST_9V_01"),
("VCCS_4", "XLR3_01"),
("VCCS_4", "SPRT_02"),
("VCCS_4", "CNST_01"),

("VCCS_5", "MSCH_SM58"),
("VCCS_5", "MSCH_14A"),
("VCCS_5", "BNCR"),
("VCCS_5", "BST_9V_01"),
("VCCS_5", "XLR3_01"),
("VCCS_5", "XLR3_02"),
("VCCS_5", "SPRT_02"),
("VCCS_5", "CNST_01"),
("VCCS_5", "DIBH_01");

("ORF_01", "MSCH_SM58"),
("ORF_01", "BST_9V_01"),
("ORF_01", "TRPL_01"),
("ORF_01", "SPRT_02"),
("ORF_01", "JBST_01"),
("ORF_01", "PIAN_01"),
("ORF_01", "CDBR_01"),

("TEAT_01", "SPRT_02"),
("TEAT_01", "CNST_01"),
("TEAT_01", "JBST_01"),
("TEAT_01", "XLR3_16"),
("TEAT_01", "MSCH_14A"),
("TEAT_01", "MSCH_SM58"),
("TEAT_01", "DIBH_01"),
("TEAT_01", "DIBH_02");
