
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Объект.Ссылка.Пустая() Тогда
		Объект.Ответственный = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	
	ДокОбъект = РеквизитФормыВЗначение("Объект");	
	
	СКД = ДокОбъект.ПолучитьМакет("СхемаИзвлеченияДанных");
	
	АдресСхемы = ПоместитьВоВременноеХранилище(СКД,  УникальныйИдентификатор)
	
КонецПроцедуры

&НаКлиенте
Процедура Подбор(Команда)
	
	пОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьТаблицуЗначенийВТабличнуюЧастьПосле", ЭтаФорма);
		
	ПараметрыОткрытия = Новый Структура("АдресСхемы, БанковскийСчет, ЗакрыватьПриВыборе", АдресСхемы, Объект.БанковскийСчет, Истина);	
	ОткрытьФорму("Документ.укбп_СведенияУФК.Форма.ФормаПодбора", ПараметрыОткрытия, ЭтаФорма,,,,пОписаниеОповещения);	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьТаблицуЗначенийВТабличнуюЧастьПосле(РезультатЗакрытия, ДополнительныеПараметры) Экспорт

	Если РезультатЗакрытия = Неопределено Тогда	   	
		Возврат;
	КонецЕсли;
	
	ЗагрузитьТабличнуюЧасть(РезультатЗакрытия);
	
КонецПроцедуры // ЗагрузитьТаблицуЗначенийВТабличнуюЧастьПосле()

&НаСервере
Процедура ЗагрузитьТабличнуюЧасть(РезультатЗакрытия)

	Объект.СтатьиСведений.Загрузить(РезультатЗакрытия);

КонецПроцедуры // ЗагрузитьТабличнуюЧасть()
