/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

CREATE FUNCTION Sales.NameCustomerMaxInvoice () 
RETURNS varchar(100)
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @nm varchar(100);  
     SET @nm = (select tab.CustomerName
				from (
					  select top 1 c.CustomerID, c.CustomerName, sum(il.UnitPrice*il.Quantity) as Summa
					  from sales.customers c
							left join sales.Invoices i on i.CustomerID = c.CustomerID
							left join sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
					  group by c.CustomerID, c.CustomerName
					  order by Summa desc
					  ) as tab
				)
     RETURN(@nm);  
END;  
GO

select Sales.NameCustomerMaxInvoice ()



/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

CREATE PROCEDURE Sales.SummaSales
	@CustomerID int 
AS
	select sum(il.UnitPrice*il.Quantity)
	from Sales.InvoiceLines il
	where il.InvoiceID in (select InvoiceID from Sales.Invoices where CustomerID = @CustomerID);
GO

exec Sales.SummaSales @CustomerID = 1


/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

CREATE FUNCTION Sales.SummaSalesF (@CustomerID int)
RETURNS int
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @Summa int;  
     SET @Summa = ( select sum(il.UnitPrice*il.Quantity)
					from Sales.InvoiceLines il
					where il.InvoiceID in (select InvoiceID from Sales.Invoices where CustomerID = @CustomerID)
				  )
     RETURN(@Summa);  
END;  
GO

drop procedure Sales.SummaSales;

CREATE PROCEDURE Sales.SummaSales
	@CustomerID int 
AS
	select sum(il.UnitPrice*il.Quantity)
	from Sales.InvoiceLines il
	where il.InvoiceID in (select InvoiceID from Sales.Invoices where CustomerID = @CustomerID);
GO

select Sales.SummaSalesF(1)
exec Sales.SummaSales @CustomerID = 1

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

CREATE FUNCTION Sales.SummaSalesF2 (@CustomerID int)  
RETURNS TABLE  
AS  
RETURN   
(  
    select il.Description, il.Quantity, il.UnitPrice
	from Sales.InvoiceLines il
	where il.InvoiceID in (select InvoiceID from Sales.Invoices where @CustomerID = 1) 
);  
GO

select * from Sales.SummaSalesF2(1)


/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
