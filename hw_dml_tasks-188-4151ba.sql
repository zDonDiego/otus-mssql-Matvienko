/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO Sales.Customers
		 (CustomerName,
		  BillToCustomerID, 
		  CustomerCategoryID, 
		  PrimaryContactPersonID, 
		  DeliveryMethodID, 
		  DeliveryCityID, 
		  PostalCityID, 
		  AccountOpenedDate,
		  StandardDiscountPercentage,
		  IsStatementSent,
		  IsOnCreditHold,
		  PaymentDays,
		  PhoneNumber,
		  FaxNumber,
		  WebsiteURL,
		  DeliveryAddressLine1,
		  DeliveryPostalCode,
		  PostalAddressLine1,
		  PostalPostalCode,
		  LastEditedBy
		 )
	VALUES
		('Тест1', 1, 3, 1001, 3, 19586, 19586, '20130101', 0, 0, 0, 7, '(308) 555-0100', '(308) 555-0100', 'http://www.tailspintoys.com', 'Shop 38', 90410, 'PO Box 8975', 90410, 1), 
		('Тест2', 1, 3, 1001, 3, 19586, 19586, '20130101', 0, 0, 0, 7, '(308) 555-0100', '(308) 555-0100', 'http://www.tailspintoys.com', 'Shop 38', 90410, 'PO Box 8975', 90410, 1),
		('Тест3', 1, 3, 1001, 3, 19586, 19586, '20130101', 0, 0, 0, 7, '(308) 555-0100', '(308) 555-0100', 'http://www.tailspintoys.com', 'Shop 38', 90410, 'PO Box 8975', 90410, 1), 
		('Тест4', 1, 3, 1001, 3, 19586, 19586, '20130101', 0, 0, 0, 7, '(308) 555-0100', '(308) 555-0100', 'http://www.tailspintoys.com', 'Shop 38', 90410, 'PO Box 8975', 90410, 1), 
		('Тест5', 1, 3, 1001, 3, 19586, 19586, '20130101', 0, 0, 0, 7, '(308) 555-0100', '(308) 555-0100', 'http://www.tailspintoys.com', 'Shop 38', 90410, 'PO Box 8975', 90410, 1)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Sales.Customers
WHERE CustomerName = 'Тест5';


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

Update Sales.Customers
SET 
	CustomerName = 'АпдейтТест4'
WHERE CustomerName = 'Тест4';


/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
select * from Sales.Customers
MERGE Sales.Customers AS target 
	USING (select 'АпдейтТест4' as CustomerName2)
	AS source (CustomerName2) ON target.CustomerName = source.CustomerName2 
	WHEN MATCHED
		THEN UPDATE SET CustomerName = 'Тест4'
	WHEN NOT MATCHED 
		THEN INSERT  (CustomerName,
					  BillToCustomerID, 
					  CustomerCategoryID, 
					  PrimaryContactPersonID, 
					  DeliveryMethodID, 
					  DeliveryCityID, 
					  PostalCityID, 
					  AccountOpenedDate,
					  StandardDiscountPercentage,
					  IsStatementSent,
					  IsOnCreditHold,
					  PaymentDays,
					  PhoneNumber,
					  FaxNumber,
					  WebsiteURL,
					  DeliveryAddressLine1,
					  DeliveryPostalCode,
					  PostalAddressLine1,
					  PostalPostalCode,
					  LastEditedBy
					  ) 
			 VALUES ('Тест4', 1, 3, 1001, 3, 19586, 19586, '20130101', 0, 0, 0, 7, '(308) 555-0100', '(308) 555-0100', 'http://www.tailspintoys.com', 'Shop 38', 90410, 'PO Box 8975', 90410, 1);

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out  "D:\downloads\Sales.Customers.txt" -T -w -t"@eu&$1&" -S DESKTOP-LLMLIFL\SQL2017'



BULK INSERT [WideWorldImporters].[Sales].[Customers]
				   FROM "D:\downloads\Sales.Customers.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '@eu&$1&',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );