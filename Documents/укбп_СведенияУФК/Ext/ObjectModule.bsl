﻿

////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ

Перем КонтрольнаяСумма Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

// Предоставляет информацию о действующим статусе для банковского счета
//
// Возвращаемое значение:
//   <Перечисления.укбп_СтатусыСведенийУФК>   - текущий статус для банковского счета
//
Функция ПолучитьТекущийСтатусБанковскогоСчета()

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	укбп_СтатусыБанковскихСчетовДляСведенийУФКСрезПоследних.Статус
	|ИЗ
	|	РегистрСведений.укбп_СтатусыБанковскихСчетовДляСведенийУФК.СрезПоследних(, БанковскийСчет = &БанковскийСчет) КАК укбп_СтатусыБанковскихСчетовДляСведенийУФКСрезПоследних";
	
	Запрос.УстановитьПараметр("БанковскийСчет", БанковскийСчет);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	
	Если Выборка.Следующий() Тогда			
		ТекущийСтатус = Выборка.Статус;			
	Иначе
		ТекущийСтатус = Перечисления.укбп_СтатусыСведенийУФК.ПустаяСсылка();
	КонецЕсли;
	
	Возврат ТекущийСтатус;
	
КонецФункции // ПолучитьТекущийСтатусБанковскогоСчета()

// Выполняется проверка суммы по табличной части для колонки "СуммаСведения" и начального остатка и прихода из РН Денежные средства
//
// Возвращаемое значение:
//   Булево.Истина   - если прошла проверка, суммы равны.
//
Функция ВыполненКонтрольСуммыПоТабличнойЧасти()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВЫРАЗИТЬ(ДенежныеСредстваОстаткиИОбороты.БанковскийСчетКасса КАК Справочник.БанковскиеСчета) КАК БанковскиеСчета,
	|	ДенежныеСредстваОстаткиИОбороты.СуммаПриход + ДенежныеСредстваОстаткиИОбороты.СуммаНачальныйОстаток КАК Сумма,
	|	ДенежныеСредстваОстаткиИОбороты.СуммаНачальныйОстаток,
	|	ДенежныеСредстваОстаткиИОбороты.СуммаПриход
	|ИЗ
	|	РегистрНакопления.ДенежныеСредства.ОстаткиИОбороты(, &Период, , , БанковскийСчетКасса = &БанковскийСчет) КАК ДенежныеСредстваОстаткиИОбороты";
	
	Запрос.УстановитьПараметр("БанковскийСчет", БанковскийСчет);
	Запрос.УстановитьПараметр("Период", Дата);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		КонтрольнаяСумма = Выборка.Сумма;
	Иначе
		КонтрольнаяСумма = 0;
	КонецЕсли;
	
	СуммаТЧ = СтатьиСведений.Итог("СуммаСведения");
	
	//Выполняем проверку, только если есть деньги на счете
	Если КонтрольнаяСумма <> 0 Тогда
		
		//Сумма по табличной части должна быть равна сумме на счете
		Если КонтрольнаяСумма <> СуммаТЧ Тогда	
			Возврат Ложь;
		Иначе
			Возврат Истина;
		КонецЕсли;		
	//Выполнять проверку не надо	
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции // ВыполненКонтрольСуммыПоТабличнойЧасти()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	#Область Инициализация_переменных
	
	// регистр укбп_СтатусыБанковскихСчетовДляСведенийУФК
	Движения.укбп_СтатусыБанковскихСчетовДляСведенийУФК.Записывать = Истина;
	Движения.укбп_СтатусыБанковскихСчетовДляСведенийУФК.Очистить();
	Движения.укбп_СтатусыБанковскихСчетовДляСведенийУФК.Записать();
	
	ТекущийСтатус = ПолучитьТекущийСтатусБанковскогоСчета();	

	#КонецОбласти
	
	#Область Контроль
	
	//1. Согласовано
	Если Статус = Перечисления.укбп_СтатусыСведенийУФК.Согласовано Тогда
		
		Если ТекущийСтатус = Перечисления.укбп_СтатусыСведенийУФК.Согласовано Тогда	
			
			Сообщить(СтрШаблон("Для банковского счета %1 уже существуют сведения. Переведите существующие документы в статус ""Неактуально""", Строка(БанковскийСчет)));
			
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Если Не ВыполненКонтрольСуммыПоТабличнойЧасти() Тогда	
		
		Сообщить(СтрШаблон("Контроль суммы по счету и суммы по табличной части не пройден. Сумма на счете %1, сумма табличной части %2", КонтрольнаяСумма, СтатьиСведений.Итог("СуммаСведения")));
		
	КонецЕсли;
	
	#КонецОбласти
	
	#Область РН_Остатки_лимитов_по_сведениям_УФК
	
	Движения.укбп_ОстаткиЛимитовПоСведениямУФК.Записывать = Истина;
	Движения.укбп_ОстаткиЛимитовПоСведениямУФК.Очистить();
	
	Если Статус = Перечисления.укбп_СтатусыСведенийУФК.Согласовано Тогда
		
		// регистр укбп_ОстаткиЛимитовПоСведениямУФК Приход
		Для Каждого ТекСтрокаСтатьиСведений Из СтатьиСведений Цикл
			Движение = Движения.укбп_ОстаткиЛимитовПоСведениямУФК.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.БанковскийСчет = БанковскийСчет;
			Движение.ДетализированныйКодСведений = ТекСтрокаСтатьиСведений.СтатьяСведений;
			Движение.УкрупненныйКодСведений = ТекСтрокаСтатьиСведений.СтатьяСведений.УкрупненныйКодСведений;
			Движение.СуммаСведения = ТекСтрокаСтатьиСведений.СуммаСведения;
			Движение.ЛимитРасходаПоСведениям = ТекСтрокаСтатьиСведений.ЛимитРасходаПоСведениям;		
		КонецЦикла;	
		
	КонецЕсли;
	
	#КонецОбласти	
	
	#Область РС_Статусы_банковских_счетов_для_сведений_УФК   	
	
	// регистр укбп_СтатусыБанковскихСчетовДляСведенийУФК
	
	Движения.укбп_СтатусыБанковскихСчетовДляСведенийУФК.Записывать = Истина;
	Движения.укбп_СтатусыБанковскихСчетовДляСведенийУФК.Очистить();

	Если Статус = Перечисления.укбп_СтатусыСведенийУФК.Согласовано Тогда
		
		Движение = Движения.укбп_СтатусыБанковскихСчетовДляСведенийУФК.Добавить();
		Движение.Период = Дата;
		Движение.БанковскийСчет = БанковскийСчет;
		Движение.Статус = Статус;		
		
	КонецЕсли;	
	#КонецОбласти

КонецПроцедуры
