/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

with tab as (
			 select DATEFROMPARTS(year(o.OrderDate), month(o.OrderDate), 1) as InvoiceMonth2, c.CustomerName
			 from Sales.Orders o
				 inner join Sales.Customers c on c.CustomerID = o.CustomerID
			 where o.CustomerID in (2,3,4,5,6)
			)
select CONVERT(nvarchar(10), InvoiceMonth2, 104) as InvoiceMonth, 
	  [Tailspin Toys (Gasport, NY)] as 'Gasport, NY', 
	  [Tailspin Toys (Jessie, ND)] as 'Jessie, ND', 
	  [Tailspin Toys (Medicine Lodge, KS)] as 'Medicine Lodge, KS', 
	  [Tailspin Toys (Peeples Valley, AZ)] as 'Peeples Valley, AZ)', 
	  [Tailspin Toys (Sylvanite, MT)] as 'Tailspin Toys (Sylvanite, MT)'
from tab
	 pivot (count(CustomerName) for CustomerName in
													 ([Tailspin Toys (Gasport, NY)], 
													  [Tailspin Toys (Jessie, ND)], 
													  [Tailspin Toys (Medicine Lodge, KS)], 
													  [Tailspin Toys (Peeples Valley, AZ)], 
													  [Tailspin Toys (Sylvanite, MT)]
													 )
		   ) AS PivotTable
order by InvoiceMonth2








/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select CustomerName, AddressLine
from (
		select CustomerName, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2
		from sales.Customers
		where CustomerName like '%Tailspin Toys%'
	 ) t unpivot (AddressLine for Type_address in ([DeliveryAddressLine1],
													  [DeliveryAddressLine2],
													  [PostalAddressLine1],
													  [PostalAddressLine2]
													  )) AS upvt


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select CountryID, CountryName, Code
from (
      select CountryID, CountryName, cast(IsoAlpha3Code as varchar) as IsoAlpha3Code, cast(IsoNumericCode as varchar) as IsoNumericCode
      from Application.Countries
	 ) t unpivot (Code for type_code in (
	                                     IsoAlpha3Code,
										 IsoNumericCode
										)
                 ) as upvt

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

with tab as (select i.CustomerID, il.StockItemID, il.UnitPrice, i.InvoiceDate
			 from sales.Invoices i
				inner join sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
			)
select c.CustomerID, c.CustomerName, tab.StockItemID, tab.UnitPrice, tab.InvoiceDate
from sales.Customers c
	cross apply (select top 2 *
	             from tab
				 where tab.CustomerID = c.CustomerID
				 order by tab.UnitPrice desc
				) tab
order by c.CustomerID
