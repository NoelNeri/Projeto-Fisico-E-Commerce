-- --------------------------------------------------------------------------------------------------------------------------------------------Criando banco de dados de Ecommerce

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
create database ecomm;
show databases;
use ecomm;

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela pessoaFisica
create table pessoaFisica(
	pfId int primary key not null,
	pfNome varchar(50) not null,
	CPF char(11) not null unique,
    dataNasc date not null,
    pfTel varchar(20) not null,
    pfEmail varchar(50) not null,
    pfLogradouro varchar (50) not null,
    pfComplemento varchar (30) not null,
    pfCEP char(8) not null,
    pfCidade varchar (50) not null,
    pfUF char(2) not null,
    pfPais varchar(30) not null
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela pessoaJuridica
create table pessoaJuridica(
	pjId int primary key not null,
	pjRazaoSocial varchar(50) not null,
    pjNomeFantasia varchar(50) default (pjRazaoSocial),
	CNPJ char(15) not null unique,
    dataFund date not null,
    pjTel varchar(20) not null,
    pjEmail varchar(50) not null,
    pjContato varchar(50),
    pjTelContato varchar(20),
    pjLogradouro varchar (50) not null,
    pjComplemento varchar (30) not null,
    pjCEP char(8) not null,
    pjCidade varchar (50) not null,
    pjUF char(2) not null,
    pjPais varchar(50) not null
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Tabela cliente depende de pessoafisica e pessoajuridica
-- Criar tabela cliente
create table cliente(
	cliId int primary key not null unique,
	cliNome varchar(50) not null,
    cliTipo varchar(20),
    cliDataInicio date not null,
    cliDataFim date default('1900-01-01'),
    idpfcli int,
    constraint fk_pf_cli foreign key (idpfcli) references pessoaFisica(pfId),
    idpjcli int, 
    constraint fk_pj_cli foreign key (idpjcli) references pessoaJuridica(pjId)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela clienteCartao
create table clienteCartao(
	cardId int primary key not null,
	cardTitular varchar(50) not null,
    cardValidade date not null,
    cardBandeira varchar(50) not null,
    cardNum varchar (16) not null
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela clienteCarteira
create table carteiraDigital(
	cdigId int primary key not null,
	cdigNum varchar(50) not null,
    cdigDtAdesao date not null,
    cdigSaldo decimal(12,2) not null,
    cdigCashBack decimal(12,2) not null
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx tabela formaPagto depende da clienteCartao e carteiraDigital
-- Criar tabela formaPagto
create table formaPagto(
	pagId int primary key not null,
    idclipag int not null,
    constraint fk_cli_pag foreign key (idclipag) references cliente(cliId),
    idcardpag int,
    constraint fk_card_pag foreign key (idcardpag) references clienteCartao(cardId),
    idcdigpag int,
    constraint fk_cdig_pag foreign key (idcdigpag) references carteiraDigital(cdigId),
    pix varchar(50),
    bolbanc varchar(50),
    transfBanc varchar(50),
    valPago decimal(12,2)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx tabela de pedido depende da formaPagto, cliente
-- Criar tabela pedido
create table pedido(
	pedId int primary key not null,
	pedStatus enum("Processando", "Pago", "Enviado a transportadora", "Em trânsito", "Entregue", "Devolvido", "Recusado") default("Processando"),
    pedDescricao varchar(50) not null,
	pedData date not null,
    pedDataLimDev date not null,
    pedDataSolDev date,
    pedValorTotal decimal(12,2),
    idpagped int,
    constraint fk_pag_ped foreign key (idpagped) references formaPagto(pagId),
    idcliped int not null,
    constraint fk_cli_ped foreign key (idcliped) references cliente(cliId)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela produto
create table produto(
	prodId int primary key not null,
	prodCat varchar(20) not null,
    prodDesc varchar(50) not null,
    prodValUnit decimal(9,3)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx tabela de item de pedido depende da pedido e produto
-- Criar tabela itemPedido
create table itemPedido(
	itemId int primary key not null,
	idpeditem int not null,
    constraint fk_ped_item foreign key (idpeditem) references pedido(pedId),
    idproditem int,
    constraint fk_prod_item foreign key (idproditem) references produto(prodId),
  	itemQtd decimal(9,3) not null,
    itemPreco decimal(9,2)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela tranportador
create table transportador(
	traId int primary key not null,
    idpjtra int not null,
    constraint fk_pj_tra foreign key (idpjtra) references pessoaJuridica(pjId)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela Entrega
create table entrega(
	entId int primary key not null,
    entStatus enum("Autorizada","Em atendimento","Em transito","Entregue","Devolvida") default("Em atendimento"),
    entCodMonit int,
    entFrete decimal (12,2) not null,
    entDtentrega date,
    entDtentregaPrev date not null,
    idpedent int not null,
    constraint fk_ped_ent foreign key (idpedent) references pedido(pedId),
    idtraent int not null,
    constraint fk_trans_ent foreign key (idtraent) references transportador(traId)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela VendTerceiro
create table vendTerceiro(
	vendId int primary key not null,
    idpjvend int not null,
    constraint fk_pj_vend foreign key (idpjvend) references pessoaJuridica(pjId),
    idpedvend int not null,
    constraint fk_ped_vend foreign key (idpedvend) references pedido(pedId)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela fornecedor
create table fornecedor(
	forId int primary key not null,
    idpjfor int not null,
    constraint fk_pj_for foreign key (idpjfor) references pessoaJuridica(pjId)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela aquisicaoProd
create table aquisicaoProd(
	aqiId int primary key not null,
    idpjaqi int not null,
    constraint fk_pj_aqui foreign key (idpjaqi) references pessoaJuridica(pjId),
    idprodaqu int not null,
    constraint fk_prod_aqui foreign key (idprodaqu) references produto(prodId)
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela estoque
create table estoque(
	estId int primary key not null,
    estLocal varchar(50) not null
);

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Criar tabela quantidadeEstoque
create table quantidadeEstoque(
	qtdId int primary key not null,
    qtdQuat decimal(9,3) not null,
    idestqtd int not null,
    constraint fk_est_qtd foreign key (idestqtd) references estoque(estId),
    idprodqtd int not null,
    constraint fk_prod_qtd foreign key (idprodqtd) references produto(prodId)
);

-- --------------------------------------------------------------------------------------------------------------------------------------------inserindo dados nas tabelas
desc pessoafisica;
insert into pessoafisica values
	( 1, 'João Roberto x1', '11111111111', '1965-09-03', '5511999112233', 'jrx1@gmail.com', 'Rua dos Lobos, Nº Dois', 'Bloco 1 - Sala 111', '12344321', 'São  Paulo', 'SP', 'Brasil'),
	( 2, 'João Roberto x2', '11111111112', '1968-10-20', '5511999112234', 'jrx2@gmail.com', 'Rua dos Bobos, Nº Tres', 'Bloco 2 - Apto 111', '12344322', 'São  Paulo', 'SP', 'Brasil'),
	( 3, 'João Roberto x3', '11111111113', '1995-09-03', '5511999112235', 'jrx3@gmail.com', 'Rua dos Bobos, Nº Um', 'Bloco 1 - Apto 111', '12344323', 'Salvador', 'BA', 'Brasil'),
	( 4, 'João Roberto x4', '11111111114', '1988-10-20', '5511999112237', 'jrx4@gmail.com', 'Rua dos Bobosa, Nº Tres', 'Bloco 2 - Apto 111', '12344324', 'Pouso Alegre', 'MG', 'Brasil');

desc pessoajuridica;
insert into pessoajuridica values
( 199, 'Casas João Roberto xx', 'Casão x', '211111111111111', '1935-09-03', '7711999112233', 'cas1@gmail.com', 'Zézinho', '3311999112237', 'Rua dos Lobos, Nº Dois', 'Bloco 1 - Sala 111', '12344321', 'São  Paulo', 'SP', 'Brasil'),
( 21, 'Casas João Roberto x5', 'Casão 5', '211111111111115', '1935-09-05', '7711999112235', 'cas5@gmail.com', 'Zézinho', '3311999112237', 'Rua dos Lobos, Nº Oito', 'Bloco 1 - Sala 111', '12344325', 'São  Paulo', 'SP', 'Brasil'),	
( 22, 'Casas João Roberto x2', 'Casão 2', '211111111111112', '1935-09-10', '7711999112232', 'cas2@gmail.com', 'Zézinho', '3311999112231', 'Rua dos Lobos, Nº Três', 'Bloco 1 - Sala 111', '99344321', 'FORTALEZA', 'CE', 'Brasil'),
( 23, 'Casas João Roberto x3', 'Casão 3', '211111111111113', '1935-09-13', '7711999112243', 'cas3@gmail.com', 'Zézinho', '3311999112231', 'Rua dos Lobos, Nº Onze', 'Bloco 1 - Sala 111', '99344321', 'Salvador', 'BA', 'Brasil');


desc cliente;
insert into cliente values
	( 1001, 'João Roberto x1', 'Master', '2001-09-03', null, '1', null),
    ( 1002, 'João Roberto x3', 'Premium', '2002-09-03', null, '3', null),
    ( 1003, 'João Roberto x4', 'Master', '2003-09-03', null, '4', null),
    ( 1004, 'João Roberto x2', 'Master', '2005-11-03', null, '2', null),
    ( 2011, 'Casas João Roberto x2', 'Master PJ', '2005-03-03', null, null, '22'),
    ( 2012, 'Casas João Roberto x3', 'Holding', '2006-03-03', null, null, '23'),
	( 2013, 'Casas João Roberto x5', 'Holding', '2007-03-03', null, null, '21');
    

desc clienteCartao;
insert into clienteCartao values
	( 3001, 'João Roberto x1', '2030-09-03', 'VISA', '1111222233334444'),
    ( 3002, 'João Roberto x2', '2030-09-03', 'MASTERCARD', '5555222233334444'),
    ( 3003, 'Casas João Roberto x3', '2030-09-03', 'MASTERCARD', '5555222233334441'),
    ( 3004, 'Casas João Roberto x5', '2030-09-03', 'VISA', '1111222233334441');
    
DESC carteiraDigital;
insert into carteiraDigital values
	( 4001, 'Pode ser numero ou letras. João Roberto x1', '2018-09-03', 10000000.67, 54321.33),
    ( 4002, 'Pode ser numero ou letras. João Roberto x2', '2018-09-03', 9999999.67, 66321.33),
    ( 4003, 'Pode ser numero ou letras. Casas João Roberto x3', '2018-09-03', 9998999.67, 66311.33),
    ( 4004, 'Pode ser numero ou letras. Casas João Roberto x5', '2018-09-03', 9999799.67, 66322.33);


desc formaPagto;
insert into formaPagto values
	( 5001, 1001, 3001, null, 'Aqui vai dados de PIX', 'Aqui vai o código numérico do boleto', 'Aqui vai dados da transferencia.', 123.45),
	( 5002, 1001, null, 4001, 'Aqui vai dados de PIX', 'Aqui vai o código numérico do boleto', 'Aqui vai dados da transferencia.', 2123.45),
    ( 5003, 1004, null, 4002, 'Aqui vai dados de PIX', 'Aqui vai o código numérico do boleto', 'Aqui vai dados da transferencia.', 3123.45),
    ( 5004, 1004, 3002, null, 'Aqui vai dados de PIX', 'Aqui vai o código numérico do boleto', 'Aqui vai dados da transferencia.', 3130.88),
    ( 5005, 2012, 3003, null, 'Aqui vai dados de PIX', 'Aqui vai o código numérico do boleto', 'Aqui vai dados da transferencia.', 13123.45),
    ( 5006, 2012, null, 4003, 'Aqui vai dados de PIX', 'Aqui vai o código numérico do boleto', 'Aqui vai dados da transferencia.', 23123.45),
	( 5007, 2013, 3004, null, 'Aqui vai dados de PIX', 'Aqui vai o código numérico do boleto', 'Aqui vai dados da transferencia.', 63123.45),
    ( 5008, 2013, null, 4004, 'Aqui vai dados de PIX', 'Aqui vai o código numérico do boleto', 'Aqui vai dados da transferencia.', 63123.45);

desc pedido;
insert into pedido values
	( 6001, 'Entregue', 'Pedido do João X1', '2022-01-24', '2022-02-01', null, 123.45, 5001, 1001),
	( 6002, 'Entregue', 'Pedido do João X1', '2022-03-24', '2022-04-01', null, 2123.45, 5002, 1001),
	( 6003, 'Entregue', 'Pedido do João X2', '2022-01-24', '2022-02-01', null, 3123.45, 5003, 1004),
	( 6004, 'Entregue', 'Pedido do João X2', '2022-03-24', '2022-04-01', null, 3130.88, 5004, 1004),
	( 6005, 'Entregue', 'Pedido da Casas João Roberto x3', '2022-04-24', '2022-05-01', null, 13123.45, 5005, 2012),
	( 6006, 'Entregue', 'Pedido da Casas João Roberto x3', '2022-05-24', '2022-06-01', null, 23123.45, 5006, 2012),
    ( 6007, 'Entregue', 'Pedido da Casas João Roberto x5', '2022-06-24', '2022-07-01', null, 63123.45, 5007, 2013),
	( 6008, 'Entregue', 'Pedido da Casas João Roberto x5', '2022-07-24', '2022-08-01', null, 63123.45, 5008, 2013);

desc produto;
insert into produto values
	( 7001, 'PROD01', 'Produto do tipo 01 - Vendido em unidades de 1 KG', 3.520),
    ( 7002, 'PROD02', 'Produto do tipo 02 - Vendido em unidades de 1 KG', 4.520),
    ( 7003, 'PROD03', 'Produto do tipo 03 - Vendido em unidades de 1 KG', 13.520),
    ( 7004, 'PROD04', 'Produto do tipo 04 - Vendido em unidades de 1 KG', 14.520),
    ( 7005, 'PROD05', 'Produto do tipo 05 - Vendido em unidades de 1 KG', 23.520),
    ( 7006, 'PROD06', 'Produto do tipo 06 - Vendido em unidades de 1 KG', 33.520),
    ( 7007, 'PROD07', 'Produto do tipo 07 - Vendido em unidades de 1 KG', 54.520);

desc itemPedido;
insert into itemPedido values
	( 8001, 6001, 7001, 10.000, 35.20),
    ( 8002, 6001, 7002, 10.000, 45.20),
    ( 8003, 6001, 7003, 10.000, 135.20),
    
    ( 8004, 6002, 7004, 10.000, 145.20),
    ( 8005, 6002, 7005, 10.000, 235.20),
    ( 8006, 6002, 7006, 10.000, 335.20),
    
    ( 8007, 6003, 7007, 10.000, 145.20),
    ( 8008, 6003, 7001, 10.000, 35.20),
    ( 8009, 6003, 7002, 10.000, 45.20),
    
	( 8010, 6004, 7003, 10.000, 135.20),
    ( 8011, 6004, 7004, 10.000, 145.20),
    ( 8012, 6004, 7005, 10.000, 235.20),
     
	( 8013, 6005, 7006, 10.000, 335.20),
    ( 8014, 6005, 7007, 10.000, 145.20),
    ( 8015, 6005, 7001, 10.000, 35.20),

	( 8016, 6006, 7002, 10.000, 45.20),
    ( 8017, 6006, 7003, 10.000, 135.20),
    ( 8018, 6006, 7004, 10.000, 145.20),
    
    ( 8019, 6007, 7001, 10.000, 35.20),
    ( 8020, 6007, 7002, 10.000, 45.20),
    ( 8021, 6007, 7003, 10.000, 135.20),
    ( 8022, 6007, 7004, 10.000, 145.20),
    ( 8023, 6007, 7005, 10.000, 235.20),
    ( 8024, 6007, 7006, 10.000, 335.20),
    ( 8025, 6007, 7007, 10.000, 145.20),
    
	( 8026, 6008, 7001, 10.000, 35.20),
    ( 8027, 6008, 7002, 10.000, 45.20),
    ( 8028, 6008, 7003, 10.000, 135.20),
    ( 8029, 6008, 7004, 10.000, 145.20),
    ( 8030, 6008, 7005, 10.000, 235.20);
    
desc transportador;
insert into transportador values 
( 9001, 22),
( 9002, 199);

desc entrega;
insert into entrega values 
	( 1101, 'Entregue', 333441, 13.33, '2022-01-28', '2022-01-30', 6001,9001),
	( 1102, 'Entregue', 333442, 23.33, '2022-03-28', '2022-03-30', 6002,9002),
	( 1103, 'Entregue', 333443, 33.33, '2022-01-28', '2022-01-30', 6003,9001),
	( 1104, 'Entregue', 333444, 43.33, '2022-03-28', '2022-03-30', 6004,9002),
	( 1105, 'Entregue', 333445, 53.33, '2022-04-28', '2022-04-30', 6005,9001),
	( 1106, 'Entregue', 333446, 63.33, '2022-05-28', '2022-05-30', 6006,9002),
	( 1107, 'Entregue', 333447, 73.33, '2022-06-28', '2022-06-30', 6007,9001),
	( 1108, 'Entregue', 333441, 83.33, '2022-07-28', '2022-07-30', 6008,9002);


desc vendTerceiro;
insert into vendTerceiro values 
( 1201, 21, 6002),
( 1202, 22, 6004),
( 1203, 23, 6006),
( 1204, 199, 6008);


desc fornecedor;
insert into fornecedor values 
( 1301, 21),
( 1302, 23);

desc aquisicaoProd;
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Tirando a constraint que obrigava só adquirir produtos de PJs cadasrados. Posso comprar de qualquer um em caso de urgência
alter table aquisicaoProd
	drop constraint fk_pj_aqui;


insert into aquisicaoProd values 
( 1401, 21, 7001),
( 1402, 22, 7002),
( 1403, 23, 7003),
( 1404, 22, 7004),
( 1405, 299, 7005),
( 1406, 23, 7006),
( 1407, 199, 7007);


desc estoque;
insert into estoque values 
	( 1501, 'Porto Seco - Rua das Mimosas, 345'),
    ( 1502, 'Garagem do Zé - Rua das Muquioada S/N'),
	( 1503, 'Comunidade do Alemão - Rua 3 S/N');

desc quantidadeEstoque;
insert into quantidadeEstoque values
	( 1601, 234321.333, 1501, 7001),
    ( 1602, 1002.000, 1501, 7002),
    ( 1603, 403.000, 1502, 7003),
    ( 1604, 100.000, 1502, 7004),
	( 1605, 23403.000, 1503, 7005),
    ( 1606, 999100.000, 1503, 7006),
    ( 1607, 999199.000, 1503, 7007),
    ( 1608, 23403.000, 1503, 7001),
    ( 1609, 999100.000, 1503, 7002),
    ( 1610, 999199.000, 1503, 7003);

show tables;

SELECT * FROM pessoajuridica;
SELECT * FROM pessoafisica;
select * from cliente;
select * from clienteCartao;
select * from carteiraDigital;
select * from formaPagto;
select * from pedido;
select * from produto;
select * from itemPedido;
select * from transportador;
select * from entrega;
select * from vendTerceiro;
select * from fornecedor;
select * from aquisicaoProd;
select * from estoque;
select * from quantidadeEstoque;


-- ****************************************************************************Quantos pedidos foram feitos por cada cliente? As duas queries abaixo são semelhantes e trazem o mesmo resultado

select cliNome, count(*) as Pedidos 
	from pedido ped, cliente cli
	where idcliped = cliId
	group by cliNome;

select cliNome, count(*) as pedido2 
	from pedido ped JOIN cliente cli
    on idcliped = cliId
	group by cliNome;



-- *******************************************************************************************Algum vendedor também é fornecedor? As duas queries abaixo são semelhantes e trazem o mesmo resultado

select pjRazaoSocial, pjNomeFantasia, CNPJ 
	from fornecedor f, vendTerceiro v, pessoaJuridica p
	where idpjfor = idpjvend and idpjvend = pjId;

SELECT pjRazaoSocial, pjNomeFantasia, CNPJ 
	FROM pessoaJuridica p 
    JOIN (select * from fornecedor f 
				join vendTerceiro v
				on idpjfor = idpjvend) as der
    ON idpjvend = pjId;


-- *********************************************************Relação de produtos, fornecedores e estoques - No meu caso o mesmo tipo de produto pode estar em mais de um estoque e ter mais de um fornecedor

select prodCat produto, prodDesc Descrição , prodValUnit ValorUnitario, pjrazaosocial Fornecedor 
	from pessoaJuridica pj, (select * from aquisicaoProd) as a, produto p
	where idpjaqi = pjId and a.idprodaqu = prodId;
    
select estLocal 'Nome do Local', prodDesc Descrição, qtdQuat Quantidade, prodValUnit 'Valor Unitário', (prodValUnit * qtdQuat) as 'ValContabil - Atributo derivado'
	from estoque e, (select * from quantidadeEstoque) as xx, produto p
	where idestqtd = estId and idprodqtd = prodId
    order by estLocal, prodDesc;

select estLocal, count(*) as 'Quantidade de Produtos', Sum(qtdQuat) Quantidade
	from estoque e, (select * from quantidadeEstoque) as xx, produto p
	where idestqtd = estId and idprodqtd = prodId
    group by estLocal;

select estLocal, count(*) as 'Quantidade de Produtos', Sum(qtdQuat) Quantidade
	from estoque e, (select * from quantidadeEstoque) as xx, produto p
	where idestqtd = estId and idprodqtd = prodId
    group by estLocal
    having count(*) < 6;


-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Operações de inclusão de colunas, dados, exclusão de colunas e dados.

select * from entrega;

insert into entrega values 
	( 1100, null, 333444, 13.33, null, '2022-01-30', '6001','9001');

select * from entrega;

alter table entrega
	add column entXX varchar(50);

select * from entrega;

update entrega
	set entXX = 'teste de atualização'
    where entId = 1100;

select * from entrega;

alter table entrega
	drop column entXX;
    
select * from entrega;

delete from entrega where entId = 1100;

select * from entrega;

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Operações de inclusão de colunas, dados, exclusão de colunas e dados.

-- destroi tudo o que foi feito
show tables;
drop table aquisicaoProd;
drop table quantidadeEstoque;
drop table estoque;
drop table vendTerceiro;
drop table fornecedor;
drop table entrega;
drop table transportador;
drop table itempedido;
drop table produto;
drop table pedido;
drop table formapagto;
drop table carteiradigital;
drop table clientecartao;
drop table cliente;
drop table pessoafisica;
drop table pessoajuridica;

drop database ecomm;
