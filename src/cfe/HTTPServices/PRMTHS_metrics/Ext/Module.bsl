﻿
Функция MetricsGET(Запрос)
	
	Ответ = Новый HTTPСервисОтвет(200);
	
	НачалоЗамера = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ДатаЗаписиНачалоЧасаПараметр = ВРЕГ(Запрос.ПараметрыЗапроса.Получить("bucket"));
	Если ЗначениеЗаполнено(ДатаЗаписиНачалоЧасаПараметр) Тогда
		Если ДатаЗаписиНачалоЧасаПараметр = "RANDOM" Тогда
			ТекстЗапросаВыборДатаЗаписиНачалоЧаса = "ВЫБРАТЬ
			|	ЗамерыВремени.ДатаЗаписиНачалоЧаса КАК ДатаЗаписиНачалоЧаса
			|ИЗ
			|	РегистрСведений.ЗамерыВремени КАК ЗамерыВремени
			|
			|СГРУППИРОВАТЬ ПО
			|	ЗамерыВремени.ДатаЗаписиНачалоЧаса";
			ЗапросВыборДатаЗаписиНачалоЧаса = Новый Запрос(ТекстЗапросаВыборДатаЗаписиНачалоЧаса);
			МассивДляВыбора = ЗапросВыборДатаЗаписиНачалоЧаса.Выполнить().Выгрузить().ВыгрузитьКолонку("ДатаЗаписиНачалоЧаса");
			ГенераторСлучайныхЧисел = Новый ГенераторСлучайныхЧисел(ТекущаяУниверсальнаяДатаВМиллисекундах());
			Индекс = ГенераторСлучайныхЧисел.СлучайноеЧисло(0,МассивДляВыбора.Количество()-1);
			
			ДатаЗаписиНачалоЧаса = МассивДляВыбора[Индекс];
			
		Иначе
			ДатаЗаписиНачалоЧаса = ПрочитатьДатуJSON(ДатаЗаписиНачалоЧасаПараметр,ФорматДатыJSON.ISO);
		КонецЕсли;
	Иначе
		ДатаЗаписиНачалоЧаса = НачалоЧаса(ТекущаяДатаСеанса());
	КонецЕсли;
	
	ТекстЗапроса = "ВЫБРАТЬ
	|	ЗамерыВремени.КлючеваяОперация КАК КлючеваяОперация,
	|	ЗамерыВремени.Комментарий КАК Комментарий,
	|	МАКСИМУМ(ЗамерыВремени.ДатаЗаписи) КАК ДатаЗаписи,
	|	ЗамерыВремени.Пользователь КАК Пользователь,
	|	КОЛИЧЕСТВО(*) КАК КоличествоЗамеров,
	|	СУММА(ЗамерыВремени.ВремяВыполнения) КАК ВремяВыполнения
	|ПОМЕСТИТЬ ВтЗамеры
	|ИЗ
	|	РегистрСведений.ЗамерыВремени КАК ЗамерыВремени
	|ГДЕ
	|	ЗамерыВремени.ДатаЗаписиНачалоЧаса = &ДатаЗаписиНачалоЧаса
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗамерыВремени.КлючеваяОперация,
	|	ЗамерыВремени.Пользователь,
	|	ЗамерыВремени.Комментарий
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВтЗамеры.КлючеваяОперация КАК КлючеваяОперация,
	|	ВтЗамеры.Комментарий КАК Комментарий,
	|	ВтЗамеры.ДатаЗаписи КАК ДатаЗаписи,
	|	ВтЗамеры.Пользователь КАК Пользователь,
	|	ВтЗамеры.КоличествоЗамеров КАК КоличествоЗамеров,
	|	ВтЗамеры.ВремяВыполнения КАК ВремяВыполнения,
	|	ЗамерыВремени.ВремяВыполнения КАК ВремяВыполненияПоследнейОперации
	|ИЗ
	|	ВтЗамеры КАК ВтЗамеры
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЗамерыВремени КАК ЗамерыВремени
	|		ПО ВтЗамеры.КлючеваяОперация = ЗамерыВремени.КлючеваяОперация
	|			И ВтЗамеры.Пользователь = ЗамерыВремени.Пользователь
	|			И ВтЗамеры.Комментарий = ЗамерыВремени.Комментарий
	|			И ВтЗамеры.ДатаЗаписи = ЗамерыВремени.ДатаЗаписи";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ДатаЗаписиНачалоЧаса",ДатаЗаписиНачалоЧаса);
	
	ВыборкаРезультат = Запрос.Выполнить().Выбрать();
	
	ВремяВыполненияЗапроса = ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоЗамера;
	
	ДанныеСоединения = Новый Соответствие;
	МассивЭлементов = СтрРазделить(СтрокаСоединенияИнформационнойБазы(),";",Ложь);
	Для каждого Элемент Из МассивЭлементов Цикл
		КлючИЗначение = СтрРазделить(Элемент,"=");
		ДанныеСоединения[КлючИЗначение[0]] = СтрЗаменить(КлючИЗначение[1],"""","");
	КонецЦикла;
	
	Метки = Новый Соответствие;
	Метки["host"] = ДанныеСоединения["Srvr"];
	Метки["ib"] = ДанныеСоединения["Ref"];
	
	Результат = Новый Соответствие;
	
	Пока ВыборкаРезультат.Следующий() Цикл
		
		ДополнительныеДанные = ОбъектИзJSON(ВыборкаРезультат.Комментарий);
		Если ТипЗнч(ДополнительныеДанные) <> Тип("Соответствие") Тогда
			ДополнительныеДанные = Новый Соответствие;
		КонецЕсли;
		
		Метки["user"] = ВыборкаРезультат.Пользователь;
		Метки["platform"] = ДополнительныеДанные["Платф"];
		Метки["client"] = ДополнительныеДанные["ИнфКл"];
		Метки["oper"] = ВыборкаРезультат.КлючеваяОперация;
		
		ДобавитьМетрику(Результат, Метки,
		"onec_apdex_lastoperation_runtime",	"{user=""$(user)"",platform=""$(platform)"",client=""$(client)"",oper=""$(oper)"",host=""$(host)"",ib=""$(ib)""}",
		
			Формат(ВыборкаРезультат.ВремяВыполненияПоследнейОперации,"ЧРД=.; ЧН=0; ЧГ=0"));
		
		ДобавитьМетрику(Результат, Метки,
		"onec_apdex_runtime",				"{user=""$(user)"",platform=""$(platform)"",client=""$(client)"",oper=""$(oper)"",host=""$(host)"",ib=""$(ib)""}",
		
			Формат(ВыборкаРезультат.ВремяВыполнения,"ЧРД=.; ЧН=0; ЧГ=0"));
		
		
		ДобавитьМетрику(Результат, Метки,
		"onec_apdex_measurements_total",	"{user=""$(user)"",platform=""$(platform)"",client=""$(client)"",oper=""$(oper)"",host=""$(host)"",ib=""$(ib)""}",
		
			Формат(ВыборкаРезультат.КоличествоЗамеров,"ЧРД=.; ЧН=0; ЧГ=0"));
				
	КонецЦикла;
	
	ДобавитьМетрику(Результат, Метки,
	"onec_info_connection_status",	"{host=""$(host)"",ib=""$(ib)""}", "1");
	
	ДобавитьМетрику(Результат, Метки,
	"onec_apdex_request_time_total","{host=""$(host)"",ib=""$(ib)""}", Формат(ВремяВыполненияЗапроса,"ЧРД=.; ЧН=0; ЧГ=0"));
	
	ВремяОбработки = ТекущаяУниверсальнаяДатаВМиллисекундах() - НачалоЗамера;
	
	ДобавитьМетрику(Результат, Метки,
	"onec_apdex_time_total","{host=""$(host)"",ib=""$(ib)""}", Формат(ВремяОбработки,"ЧРД=.; ЧН=0; ЧГ=0"));
	
	Если Результат["onec_apdex_measurements_total"] <> Неопределено Тогда
		Результат["onec_apdex_measurements_total"].Вставить(0,
		"# HELP onec_apdex_measurements_total Cumulative count of measurements for one hour.
		|# TYPE onec_apdex_measurements_total counter");
	КонецЕсли;
	
	МассивОтветов = Новый Массив;
	Для каждого КлючИЗначение Из Результат Цикл
		МассивОтветов.Добавить(СтрСоединить(КлючИЗначение.Значение,Символы.ПС));
	КонецЦикла;
	ОтветСтрокой = СтрСоединить(МассивОтветов,Символы.ПС);
		
	Ответ.УстановитьТелоИзСтроки(ОтветСтрокой,"UTF8");
	Ответ.Заголовки["Content-Type"] = "text/plain; version=0.0.4; charset=utf-8";
	
	Возврат Ответ;
	
КонецФункции

Процедура ДобавитьМетрику(Результат,Метки,НазваниеМетрики,Знач СтрокаМеток,Значение)
	
	Для каждого КлючИЗначение Из Метки Цикл
		СтрокаМеток = СтрЗаменить(СтрокаМеток,СтрШаблон("$(%1)",КлючИЗначение.Ключ),КлючИЗначение.Значение);
	КонецЦикла;
	
	Если Результат[НазваниеМетрики] = Неопределено Тогда
		Результат[НазваниеМетрики] = Новый Массив;
	КонецЕсли;
	
	Результат[НазваниеМетрики].Добавить(НазваниеМетрики+СтрокаМеток+" "+Значение);
	
КонецПроцедуры

Функция ОбъектИзJSON(JSON,ПрочитатьВСоответствие=Истина)
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(JSON);
	Возврат ПрочитатьJSON(ЧтениеJSON,ПрочитатьВСоответствие);
	
КонецФункции
