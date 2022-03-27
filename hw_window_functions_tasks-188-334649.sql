/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

select i.InvoiceID, c.CustomerName, i.InvoiceDate, sum(il.Quantity*il.UnitPrice) as Summa,
       (select sum(il2.Quantity*il2.UnitPrice)
	    from Sales.Invoices i2
			inner join Sales.InvoiceLines il2 on il2.InvoiceID = i2.InvoiceID
		where i2.InvoiceDate between '20150101' and EOMONTH(i.invoiceDate)
	   ) as СumulativeTotal
from Sales.Invoices i
	inner join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
	inner join Sales.Customers c on c.CustomerID = i.CustomerID
where i.InvoiceDate >= '20150101'
group by i.InvoiceID, c.CustomerName, i.InvoiceDate
order by i.invoiceDate


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

select i.InvoiceID, c.CustomerName, i.InvoiceDate,
	   sum(il.Quantity*il.UnitPrice) over(order by EOMONTH(i.invoiceDate)) as СumulativeTotal
from Sales.Invoices i
	inner join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
	inner join Sales.Customers c on c.CustomerID = i.CustomerID
where i.InvoiceDate >= '20150101'
order by i.invoiceDate


/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

select *
from 
	(select si.StockItemName, MONTH(i.InvoiceDate) as m, sum(il.quantity) as summa,
		   row_number() over(partition by MONTH(i.InvoiceDate) order by sum(il.quantity) desc) as nm
	from Sales.Invoices i
		inner join Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
		inner join Warehouse.StockItems si on si.StockItemID = il.StockItemID
	where i.InvoiceDate between '20160101' and '20161231'
	group by si.StockItemName, MONTH(i.InvoiceDate)
	) as t
where nm < 3
order by m


/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select StockItemID, StockItemName, Brand, UnitPrice,
	row_number() over(partition by left(StockItemName,1) order by StockItemName),
	count(*) over(),
	count(*) over(partition by left(StockItemName,1)),
	lead(StockItemID) over(order by StockItemName),
	lag(StockItemID) over(order by StockItemName),
	lag(StockItemName, 2, 'No items') over(order By StockItemName),
	NTILE(30) over(order by TypicalWeightPerUnit)
from Warehouse.StockItems
order by StockItemName


/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

select *
from 
	(select p.PersonID, p.FullName, c.CustomerID, c.CustomerName, o.OrderDate, sum(ol.Quantity*ol.UnitPrice) as Summa,
		   row_number() over(partition by p.PersonID order by FullName, OrderDate, c.CustomerName desc) as nm
	from application.People p
		inner join sales.Orders o on o.SalespersonPersonID = p.PersonID
		inner join sales.Customers c on c.CustomerID = o.CustomerID
		inner join sales.OrderLines ol on ol.OrderID = o.OrderID
	group by p.PersonID, p.FullName, c.CustomerID, c.CustomerName, o.OrderDate, c.CustomerName
	) t
where nm = 1


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select *
from
	(select *, row_number() over(partition by t.CustomerName order by t.UnitPrice desc) as nm
	from
		(select distinct c.CustomerName, si.StockItemName, si.UnitPrice
		from sales.Orders o
			inner join sales.OrderLines ol on ol.OrderID = o.OrderID
			inner join warehouse.StockItems si on si.StockItemID = ol.StockItemID
			inner join sales.Customers c on c.CustomerID = o.CustomerID
		) t
	) t2
where nm in (1,2)

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 