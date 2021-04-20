

////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ

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
		Движение.ЛимитРасходаПоСведениям = ТекСтрокаСтатьиСведений.ЛимитРасходаПоСведениям;		
			Движение.ЛимитРасходаПоСведениям = ТекСтрокаСтатьиСведений.ЛимитРасходаПоСведениям;		
		КонецЦикла;	
	КонецЦикла;
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
