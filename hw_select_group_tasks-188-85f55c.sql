/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

TODO:
select StockItemID, StockItemName
from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

TODO: 
select s.SupplierID, s.SupplierName
from Purchasing.Suppliers s
	left join Purchasing.PurchaseOrders p on p.SupplierID = s.SupplierID
where p.PurchaseOrderID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

TODO:
select distinct o.OrderID
			   , convert(varchar(16), o.OrderDate, 104) as OrderDate
			   , datename(month, o.OrderDate) as Month
			   , datename(quarter, o.OrderDate) as Quarter
			   , ceiling(month(o.OrderDate)/4) as ThirdYear -- почему то некоторые значение округляются до нуля, не понимаю в чем дело.
			   , c.CustomerName
from Sales.Orders o
	inner join Sales.OrderLines ol on ol.OrderID = o.OrderID
	inner join Sales.Customers c on c.CustomerID = o.CustomerID
where ol.UnitPrice > 100 or ol.Quantity > 20
order by Quarter, ThirdYear, OrderDate --Сортировка работает не правильно, я так понял, что проблема в функции convert и дата теперь воспринимается как текст, но как это обойти?
OFFSET 10 ROWS FETCH FIRST 5 ROWS ONLY --При необходимости закомментить



/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

TODO:
select dm.DeliveryMethodName
	   ,po.ExpectedDeliveryDate
	   ,s.SupplierName
	   ,cp.FullName
from Purchasing.PurchaseOrders po
	inner join Application.DeliveryMethods dm on dm.DeliveryMethodID = po.DeliveryMethodID
	inner join Purchasing.Suppliers s on s.SupplierID = po.SupplierID
	inner join Application.People cp on cp.PersonID = po.ContactPersonID
where dm.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight') and po.ExpectedDeliveryDate between '20130101' and '20130131' and po.IsOrderFinalized = 1


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

TODO:
select top 10 c.CustomerName
	   , p.FullName
	   , o.*
from Sales.Orders o
	inner join Sales.Customers c on c.CustomerID = o.CustomerID
	inner join application.People p on p.PersonID = o.SalespersonPersonID
order by o.OrderDate desc


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

TODO:
select distinct 
		 c.CustomerID
	   , c.CustomerName
	   , c.PhoneNumber
	   , c.FaxNumber
from Sales.Customers c
	inner join Sales.orders o on o.CustomerID = c.CustomerID
	inner join Sales.OrderLines ol on ol.OrderID = o.OrderID
	inner join Warehouse.StockItems si on si.StockItemID = ol.StockItemID
where si.StockItemName = 'Chocolate frogs 250g'


