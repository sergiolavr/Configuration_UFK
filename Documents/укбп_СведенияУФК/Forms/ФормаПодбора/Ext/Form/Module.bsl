﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	АдресСхемы = Параметры.АдресСхемы;
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСхемы));
	
	СКД = ПолучитьИзВременногоХранилища(Параметры.АдресСхемы);
	Настройки = СКД.НастройкиПоУмолчанию;
	
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
	
КонецПроцедуры
