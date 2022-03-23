/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO:
select p.PersonID, p.fullName 
from Application.People p
where p.IsSalesperson = 1 and p.PersonID not in (select SalespersonPersonID from Sales.Invoices where InvoiceDate = '20150704')
;
with t as (select distinct SalespersonPersonID from Sales.Invoices where InvoiceDate = '20150704')
select p.PersonID, p.fullName
from Application.People p
	left join t on t.SalespersonPersonID = p.PersonID
where p.IsSalesperson = 1 and t.SalespersonPersonID is null


/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO:
--Цены брать какие? UnitPrice?
select StockItemID, StockItemName, UnitPrice 
from warehouse.StockItems
where UnitPrice in (select min(UnitPrice) from warehouse.StockItems)

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

TODO:
select distinct c.CustomerID, c.CustomerName
from Sales.CustomerTransactions ct
	inner join Sales.Customers c on c.CustomerID = ct.CustomerID
where TransactionAmount in (
							select top 5 TransactionAmount
							from Sales.CustomerTransactions
							order by TransactionAmount desc
						   )
;
with t as (select top 5 TransactionAmount
		   from Sales.CustomerTransactions
		   order by TransactionAmount desc
		  )
select distinct c.CustomerID, c.CustomerName
from Sales.CustomerTransactions ct
	inner join Sales.Customers c on c.CustomerID = ct.CustomerID
	inner join t on t.TransactionAmount = ct.TransactionAmount

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO:
select distinct ct.CityID, ct.CityName, o.PickedByPersonID
from Sales.Orders o
	inner join Sales.Customers c on c.CustomerID = o.CustomerID
	inner join Application.Cities ct on ct.CityID = c.DeliveryCityID
where o.OrderID in (
				  select OrderID
				  from Sales.OrderLines 
				  where StockItemID in (select top 3 StockItemID 
										from Warehouse.StockItems 
										order by UnitPrice desc
									   )
				 )
;
with tab as (select OrderID
			 from Sales.OrderLines 
			 where StockItemID in (select top 3 StockItemID 
								   from Warehouse.StockItems 
								   order by UnitPrice desc
								  )
			)
select distinct ct.CityID, ct.CityName, o.PickedByPersonID
from Sales.Orders o
	inner join Sales.Customers c on c.CustomerID = o.CustomerID
	inner join Application.Cities ct on ct.CityID = c.DeliveryCityID
where o.OrderID in (Select OrderID from tab)

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
