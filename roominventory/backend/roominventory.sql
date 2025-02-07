-- Create Tables

CREATE TABLE Places (
    IdPlace VARCHAR(10) PRIMARY KEY,
    PlaceName VARCHAR(75)
);

CREATE TABLE Zones (
    IdZone VARCHAR(10) PRIMARY KEY,
    ZoneName VARCHAR(75),
    FK_IdPlace VARCHAR(10),
    FOREIGN KEY (FK_IdPlace) REFERENCES Places(IdPlace)
);

CREATE TABLE Items (
    IdItem VARCHAR(10) PRIMARY KEY,
    ItemName VARCHAR(75),
    FK_IdZone VARCHAR(10),
    FOREIGN KEY (FK_IdZone) REFERENCES Zones(IdZone)    
);

CREATE TABLE Details (
    IdDetails INT PRIMARY KEY,
    DetailsName VARCHAR(75),
    Details VARCHAR(75),
    FK_IdItem VARCHAR(10),
    FOREIGN KEY (FK_IdItem) REFERENCES Items(IdItem)
);

CREATE TABLE Events (
    IdEvent VARCHAR(10) PRIMARY KEY,
    EventName VARCHAR(75),
    EventPlace VARCHAR(75),
    NameRep VARCHAR(75),
    EmailRep VARCHAR(75),
    TecExt VARCHAR(75),
    Date DATE
);

CREATE TABLE Item_Event (
    IdIE INT PRIMARY KEY,
    FK_IdEvent VARCHAR(10),
    FK_IdItem VARCHAR(10),
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

-- Regie Items (Mesa, Armário, Gaveta)
('XRL3_16', 'CCO XRL M/F', 'Z007'),          -- Mesa
('XLR_2_01', 'CCO XLR F/F', 'Z005'),         -- Armário
('VGA_04', 'CCO VGA M/M', 'Z006'),           -- Gaveta
('HDMI_01', 'CCO HDMI M/M', 'Z006'),         -- Gaveta
('RJ45_01', 'CCO Cabo Rede', 'Z006'),        -- Gaveta
('RJ45_02', 'CCO Cabo Rede', 'Z006'),        -- Gaveta
('RJ45_03', 'CCO Cabo Rede', 'Z006'),        -- Gaveta
('TRPL_02', 'CCO Tripla Parede', 'Z005'),    -- Armário
('PWRD_01', 'CCO Corrente PC', 'Z006');      -- Gaveta



-- Insert into Items
INSERT INTO Items (IdItem, ItemName, FK_IdZone) VALUES
-- Regie Items
('MSCH_14A', 'Shure 14A', 'Z005'),       -- Armário
('D_01', 'Desconhecido', 'Z005'),        -- Armário
('AUDT_1', 'Audio Technica', 'Z005'),    -- Armário

-- Regie Items (Gaveta)
('MSCH_SM58', 'Shure SM58', 'Z006'),        -- Gaveta
('BST_9V_01', 'Pilha Boost', 'Z006'),       -- Gaveta
('BST_9V_02', 'Pilha Auchan', 'Z006'),      -- Gaveta
('BST_9V_03', 'Pilha Duracell', 'Z006'),    -- Gaveta
('BST_15V_01', 'Pilha Boost', 'Z006'),      -- Gaveta
('BST_15V_02', 'Pilha Panasonic', 'Z006'),  -- Gaveta
('CDCX_01', 'CD com Caixa', 'Z006'),        -- Gaveta
('CDBX_01', 'Caixa com CD', 'Z006'),        -- Gaveta
('DSKT_01', 'Disquete', 'Z006'),            -- Gaveta
('CSST_01', 'Cassete', 'Z006'),             -- Gaveta
('PXLR_01', 'Pontas XLR M/F', 'Z006'),      -- Gaveta

('SMNS07_01', 'Samson 07', 'Z005'),         -- Armário

('SPRT_02', 'Spirit FX16', 'Z007'),         -- Mesa
('CNST_01', 'Contest', 'Z007'),             -- Mesa
('JBST_01', 'JBSystems', 'Z007'),           -- Mesa

('DIBH_01', 'Behringer Ultra-DI', 'Z005'),  -- Armário
('DIBH_02', 'Behringer Ultra-DI', 'Z005'),  -- Armário
('WTST_01', 'ScramTalk-808', 'Z005'),       -- Armário
('WTST_02', 'ScramTalk-808', 'Z005'),       -- Armário
('WTST_03', 'ScramTalk-808', 'Z005'),       -- Armário
('WTST_04', 'ScramTalk-808', 'Z005'),       -- Armário
('WTCH_01', 'Carregador Scram-Talk-808', 'Z005'), -- Armário
('TRSF_USBA_01', 'Transformadr USB-A', 'Z005'), -- Armário

('VNTO_01', 'Ventoinha', 'Z008'),           -- Chão
('VNTO_02', 'Ventoinha', 'Z008'),           -- Chão

-- SalaEspelhos Items
('SPRT_01', 'Spirit Powerstation 600', 'Z020'), -- Chão
('JBLT_01', 'JBL TR Series', 'Z020'),       -- Chão
('JBLT_02', 'JBL TR Series', 'Z020')        -- Chão




-- Outros Items (Não Presente)
('AVGA_MM1', 'VGA Macho-Macho', 'Z027');    -- Não Presente



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
(177, 'Notas', 'Nada a Apontar', 'PXLR_01');