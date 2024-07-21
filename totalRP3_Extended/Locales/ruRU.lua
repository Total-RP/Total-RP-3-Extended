-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

-- THIS FILE IS AUTOMATICALLY GENERATED.
-- ALL MODIFICATIONS TO THIS FILE WILL BE LOST.

local L;

L = {
	["ALL"] = "Все",
	["AU_PRESET"] = "Шаблон",
	["AU_PRESET_BUFF"] = "Бафф",
	["AU_PRESET_CURSE"] = "Проклятие",
	["AU_PRESET_DISEASE"] = "Болезнь",
	["AU_PRESET_MAGIC"] = "Магия",
	["AU_PRESET_OTHER"] = "Другой дебафф",
	["AU_PRESET_POISON"] = "Яд",
	["AURA_FRAME_TITLE"] = "Total RP 3 Расширенные Ауры",
	["AURA_ID"] = "ID ауры",
	["BINDING_NAME_TRP3_INVENTORY"] = "Открыть инвентарь персонажа",
	["BINDING_NAME_TRP3_MAIN_CONTAINER"] = "Открыть главную сумку",
	["BINDING_NAME_TRP3_QUEST_ACTION"] = "Действие квеста: взаимодействовать",
	["BINDING_NAME_TRP3_QUEST_LISTEN"] = "Действие квеста: слушать",
	["BINDING_NAME_TRP3_QUEST_LOOK"] = "Действие квеста: исследовать",
	["BINDING_NAME_TRP3_QUEST_TALK"] = "Действие квеста: говорить",
	["BINDING_NAME_TRP3_QUESTLOG"] = "Открыть журнал квестов TRP3",
	["BINDING_NAME_TRP3_SEARCH_FOR_ITEMS"] = "Поиск предметов",
	["CA_ACTION_CONDI"] = "Редактор условий действия",
	["CA_ACTION_REMOVE"] = "Удалить это действие?",
	["CA_ACTIONS"] = "Действия",
	["CA_ACTIONS_ADD"] = "Добавить действие",
	["CA_ACTIONS_COND"] = "Изменить условие",
	["CA_ACTIONS_COND_OFF"] = "Это действие не обусловлено.",
	["CA_ACTIONS_COND_ON"] = "Это действие обусловлено.",
	["CA_ACTIONS_COND_REMOVE"] = "Удалить условиe",
	["CA_ACTIONS_EDITOR"] = "Редактор действий",
	["CA_ACTIONS_NO"] = "Нет действий",
	["CA_ACTIONS_SELECT"] = "Выберите тип действия",
	["CA_DESCRIPTION"] = "Сводка по кампании",
	["CA_DESCRIPTION_TT"] = "Эта краткая сводка будет видна на странице кампании в журнале заданий.",
	["CA_ICON"] = "Значок кампании",
	["CA_ICON_TT"] = "Выберите значок кампании",
	["CA_IMAGE"] = "Портрет кампании",
	["CA_IMAGE_TT"] = "Выберите значок кампании",
	["CA_LINKS_ON_START"] = "На старте кампании",
	["CA_LINKS_ON_START_TT"] = [=[Срабатывает |cff00ff00один|r раз, когда игрок начал кампанию, так что активация кампании в первый раз, или сбросить его в журнале квестов.

|cff00ff00Это хорошее место, чтобы активировать ваш первый квест.]=],
	["CA_NAME"] = "Название кампании",
	["CA_NAME_NEW"] = "Новая кампания",
	["CA_NAME_TT"] = "Это название Вашей кампании. Он появляется в журнале квестов.",
	["CA_NO_NPC"] = "Нет кастомных НПС",
	["CA_NPC"] = "Список НПС в кампании",
	["CA_NPC_ADD"] = "Добавить кастомизированного НПС",
	["CA_NPC_AS"] = "Дубликат",
	["CA_NPC_EDITOR"] = "НПС редактор",
	["CA_NPC_EDITOR_DESC"] = "Описание НПС",
	["CA_NPC_EDITOR_NAME"] = "Имя НПС",
	["CA_NPC_ID"] = "ID НПС",
	["CA_NPC_ID_TT"] = [=[Пожалуйста, введите ID НПС, чтобы настроить.

|cff00ff00Чтобы получить ID НПС, введите эту команду в чате:/trp3 getID]=],
	["CA_NPC_NAME"] = "Стандартное имя НИП",
	["CA_NPC_REMOVE"] = "Удалить изменения для этого НИП?",
	["CA_NPC_TT"] = [=[Вы можете настраивать НИПов давая им имя, иконку и описание.
Эта кастомизация будет видна когда ваша кампания активна у игрока.]=],
	["CA_NPC_UNIT"] = "Настренный НИП",
	["CA_QE_ID"] = "Изменить ID задания",
	["CA_QE_ST_ID"] = "Изменить ID этапа задания",
	["CA_QUEST_ADD"] = "Добавить задание",
	["CA_QUEST_CREATE"] = [=[Пожалуйста, введите ID задания. У Вас может быть два задания с одинаковым ID в рамках одной кампании.

|cffff9900Обратите внимание: задания будут сортированы в алфавитном порядке их ID в логах заданий.

|cff00ff00Совет: старайтесь всегда записывать ID  в виде "Задание_#",где # - это номер задания в кампании.]=],
	["CA_QUEST_DD_COPY"] = "Скопировать содержимое задания",
	["CA_QUEST_DD_PASTE"] = "Вставить содержимое задания",
	["CA_QUEST_DD_REMOVE"] = "Удалить задание",
	["CA_QUEST_EXIST"] = "Задание с ID %s уже существует.",
	["CA_QUEST_NO"] = "Нет задания",
	["CA_QUEST_REMOVE"] = "Убрать это задание?",
	["CL_CAMPAIGN_PROGRESSION"] = "Прогресс для %s:",
	["CL_CREATION"] = "Расширенное создание",
	["CL_EXTENDED_CAMPAIGN"] = "Расширенная кампания",
	["CL_EXTENDED_ITEM"] = "Расширенный предмет",
	["CL_IMPORT"] = "Импортировать в базу данных",
	["CL_IMPORT_ITEM_BAG"] = "Добавить предмет в вашу сумку",
	["CL_TOOLTIP"] = "Создать ссылку в чат",
	["COM_NPC_ID"] = "получить id выбранного нип",
	["COND_COMPLETE"] = "Полное логическое выражение",
	["COND_CONDITIONED"] = "С условием",
	["COND_EDITOR"] = "Редактор условий",
	["COND_EDITOR_EFFECT"] = "Редактор эффектов условий",
	["COND_LITT_COMP"] = "Все виды уравнений",
	["COND_NUM_COMP"] = "Только численные уравнения",
	["COND_NUM_FAIL"] = "Вы должны иметь два численных значения если вы хотите использовать численное уравнение.",
	["COND_PREVIEW_TEST"] = "Проврека условия",
	["COND_PREVIEW_TEST_TT"] = "Печатает в чат результат данного теста основываясь на текущей ситуации.",
	["COND_TEST_EDITOR"] = "Редактор тестов",
	["COND_TESTS"] = "Тесты условий",
	["CONF_MAIN"] = "Extended",
	["CONF_MUSIC_ACTIVE"] = "Играть локальную музыку",
	["CONF_MUSIC_ACTIVE_TT"] = [=[Локальная музыка это музыка играемая другими игроками (например через предмет) в определённом радиусе.

Отключите данную опцию если вы не хотите слышать эту музыку вовсе.

|cnWARNING_FONT_COLOR:Учтите что вы никогда не услышите музыку от игнорируемых игроков.|r

|cnGREEN_FONT_COLOR:Учтите что вся музыка прерываема через Историю Звуков в панели быстрого доступа TRP3.|r]=],
	["CONF_MUSIC_METHOD"] = "Образ воспроизведения локальной музыки",
	["CONF_MUSIC_METHOD_TT"] = "Выберите как вы будете слышать локальную музыку когда вы в радиусе.",
	["CONF_SOUNDS"] = "Локальные звуки / музыка",
	["CONF_SOUNDS_ACTIVE"] = "Играть локальные звуки",
	["CONF_SOUNDS_ACTIVE_TT"] = [=[Локальны звуки это звуки играемые другими игроками (например через предмет) в определённом радиусе.

Отключите данную опцию если вы не хотите слышать эти звуки вовсе.

|cnWARNING_FONT_COLOR:Учтите что вы никогда не услышите звуки от игнорируемых игроков.|r

|cnGREEN_FONT_COLOR:Учтите что все звуки прерываемы через Историю Звуков в панели быстрого доступа TRP3.|r]=],
	["CONF_SOUNDS_MAXRANGE"] = "Максимальный радиус воспроизведения",
	["CONF_SOUNDS_MAXRANGE_TT"] = [=[Выберите максимальный радиус (в мать их ярдах, чёртовы американцы) в которым вы будете слышать локальные звуки/музыку.

|cnGREEN_FONT_COLOR:Полезно чтобы избегать людей играющих звуки через весь континент.|r

|cnWARNING_FONT_COLOR:Ноль означает без ограничения!|r]=],
	["CONF_SOUNDS_METHOD"] = "Способ воспроизведения локальных звуков",
	["CONF_SOUNDS_METHOD_1"] = "Воспроизводить автоматически",
	["CONF_SOUNDS_METHOD_1_TT"] = "Если вы в радиусе, оно воспроизведёт звук/музыку без запроса вашего разрешения.",
	["CONF_SOUNDS_METHOD_2"] = "Запросить разрешение",
	["CONF_SOUNDS_METHOD_2_TT"] = "Если вы в радиусе, в окне чате будет размещена ссылка для запроса вашего подтверждения чтобы воспроизвести музыку/звук.",
	["CONF_SOUNDS_METHOD_TT"] = "Выберите как вы будете слышать локальный звук когда вы в радиусе.",
	["CONF_UNIT"] = "Единицы",
	["CONF_UNIT_WEIGHT"] = "Вес единицы",
	["CONF_UNIT_WEIGHT_1"] = "Граммы",
	["CONF_UNIT_WEIGHT_2"] = "Фунты",
	["CONF_UNIT_WEIGHT_3"] = "Картошки",
	["CONF_UNIT_WEIGHT_TT"] = "Определяет как весовые значения будут отображаться",
	["DB"] = "База Данных",
	["DB_ACTIONS"] = "Действия",
	["DB_ADD_COUNT"] = "Сколько единиц %s вы хотите добавить в ваш инвентарь?",
	["DB_ADD_ITEM"] = "Добавить в главный инвентарь",
	["DB_ADD_ITEM_TT"] = "Добавляет единицы этого предмета в ваш основной контейнер (или главный инвентарь если у вашего персонажа не выбран основной контейнер).",
	["DB_BACKERS"] = "Заготовленная база данных (%s)",
	["DB_BACKERS_LIST"] = "Создатели",
	["DB_BROWSER"] = "Открыть браузер",
	["DB_COPY_ID_TT"] = "Отобразить ID объекта во всплывающем окне для копирования.",
	["DB_COPY_TT"] = "Скопировать информацию об этом объекте (и дочерних объектах) чтобы вставить его как внутренние объекты в другом объекте.",
	["DB_CREATE_CAMPAIGN"] = "Создать кампанию",
	["DB_CREATE_CAMPAIGN_TEMPLATES_BLANK"] = "Пустая кампания",
	["DB_CREATE_CAMPAIGN_TEMPLATES_BLANK_TT"] = [=[Пустой шаблон.
Для тех кто желает начинать с нуля.]=],
	["DB_CREATE_CAMPAIGN_TEMPLATES_FROM"] = "Создать из ...",
	["DB_CREATE_CAMPAIGN_TEMPLATES_FROM_TT"] = "Создать копию существующей кампании.",
	["DB_CREATE_CAMPAIGN_TT"] = "Начать создание кампании",
	["DB_CREATE_ITEM"] = "Создать предмет",
	["DB_CREATE_ITEM_TEMPLATES"] = "Или выбрать шаблон",
	["DB_CREATE_ITEM_TEMPLATES_AURA"] = "Предмет Аура",
	["DB_CREATE_ITEM_TEMPLATES_AURA_TT"] = "Шаблон предмета дающего вам бафф.",
	["DB_CREATE_ITEM_TEMPLATES_BLANK"] = "Пустой предмет",
	["DB_CREATE_ITEM_TEMPLATES_BLANK_TT"] = [=[Пустой шаблон.
Для тех кто желает начинать с нуля.]=],
	["DB_CREATE_ITEM_TEMPLATES_CONTAINER"] = "Предмет-контейнер",
	["DB_CREATE_ITEM_TEMPLATES_CONTAINER_TT"] = [=[Шаблон контейнера.
Контейнеры могут держать в себе другие предметы.]=],
	["DB_CREATE_ITEM_TEMPLATES_DOCUMENT"] = "Предмет-документ",
	["DB_CREATE_ITEM_TEMPLATES_DOCUMENT_TT"] = [=[Шаблон предмета с внутренним объектом доукментом.
Полезно для быстрого создания книги или свитка.]=],
	["DB_CREATE_ITEM_TEMPLATES_EXPERT"] = "Экспертный предмет",
	["DB_CREATE_ITEM_TEMPLATES_EXPERT_TT"] = [=[Пустой шаблон для экспертов.
Для пользователей с опытом творения.]=],
	["DB_CREATE_ITEM_TEMPLATES_FROM"] = "Создать из ...",
	["DB_CREATE_ITEM_TEMPLATES_FROM_TT"] = "Создать копию существующего предмета.",
	["DB_CREATE_ITEM_TEMPLATES_QUICK"] = "Быстрое создание",
	["DB_CREATE_ITEM_TEMPLATES_QUICK_TT"] = [=[Быстро создаёт простой предмет без какого-либо эффекта.
Потом добавляет одну единицу этого предмета в вашу основную сумку.]=],
	["DB_CREATE_ITEM_TT"] = "Выбрать шаблон для нового предмета",
	["DB_DELETE_TT"] = "Удаляет этот объект и все его дочерние объекты.",
	["DB_EXPERT_TT"] = "Переводит этот объект в экспертный режим, позволяя более сложные настройки.",
	["DB_EXPORT"] = "Быстрое экспортирование объекта",
	["DB_EXPORT_DONE"] = [=[Ваш объект был экспортирован в файл под названием
|cff00ff00totalRP3_Extended_ImpExport.lua|r в эту игровую папку:

World of Warcraft\WTF\
account\ВАШ_АККАУНТ\SavedVariables

Вы можете поделиться этим файлом со своими друзьями!

Они могут выполнить процесс импортирования в |cff00ff00Полную Вкладку Базы Данных|r.]=],
	["DB_EXPORT_HELP"] = "Код для объекта %s (размер: %0.1f кБ)",
	["DB_EXPORT_MODULE_NOT_ACTIVE"] = "Полное экспортирование/импортирование объекта: Пожалуйста сперва включите аддон  totalRP3_Extended_ImpExport.",
	["DB_EXPORT_TOO_LARGE"] = [=[Этот объект слишком большой при сериализации чтобы быть экспортирован данным способом. Пожалуйста используйте опцию полного экспортирования.

Размер: %0.1f кБ.]=],
	["DB_EXPORT_TT"] = [=[Сериализует содержание объекта для обмена вне игры.

Работает лишь на малых объектах (меньше 20-ти кБ после сериализации). Для более крупных объектов, используйте опцию полного экспортирования.]=],
	["DB_FILTERS"] = "Поисковые фильтры",
	["DB_FILTERS_CLEAR"] = "Очистить",
	["DB_FILTERS_NAME"] = "Название объекта",
	["DB_FILTERS_OWNER"] = "Автор",
	["DB_FULL"] = "Полная база данных (%s)",
	["DB_FULL_EXPORT"] = "Полное экспортирование",
	["DB_FULL_EXPORT_TT"] = [=[Совершить полное экспортирование этого объекта вне зависимости от его размера.

Применение этой функции запустит перезагрушку игрового интерфейса ради записи файла сохранения аддона. ]=],
	["DB_HARD_SAVE"] = "Сохранить на диске",
	["DB_HARD_SAVE_TT"] = "Перезапустить интерфейс игры дабы запустить сохранение переменных на диск.",
	["DB_IMPORT"] = "Быстрый импорт базы данных",
	["DB_IMPORT_CONFIRM"] = [=[Этот объект был сериализован в отличной от вашей версии Total RP 3 Extended.

Версия импортированного TRP3E: %s
Ваша версия TRP3E: %s

|cffff9900Это может привести к несовместимостям.
Продолжить импортирование в любом случае?]=],
	["DB_IMPORT_DONE"] = "Объект успешно импортирован!",
	["DB_IMPORT_EMPTY"] = [=[Не существует объекта в вашем файле
|cff00ff00totalRP3_Extended_ImpExport.lua|r.

Этот файл должен быть помещён в эту директорию игры |cffff9900до запуска игры|r:

World of Warcraft\WTF\
account\ВАШ_АККАУНТ\SavedVariables]=],
	["DB_IMPORT_ERROR1"] = "Объект не может быть десериализован.",
	["DB_IMPORT_FULL"] = "Полное импортирование объектов",
	["DB_IMPORT_FULL_CONFIRM"] = [=[Вы хотите импортировать следующий объект?

%s
%s
От |cff00ff00%s|r
Версия %s]=],
	["DB_IMPORT_FULL_TT"] = "Импортировать файл |cff00ff00totalRP3_Extended_ImpExport.lua|r.",
	["DB_IMPORT_ITEM"] = "Импортировать предмет",
	["DB_IMPORT_TT"] = "Вставьте прежде сериализованный объект сюда",
	["DB_IMPORT_VERSION"] = [=[Вы импортируете более старую версию этого объекта чем версия которую вы уже имеете.

Импортированная версия: %s
Ваша версия: %s

|cffff9900Вы желаете подтвердить что вы хотите откатить?]=],
	["DB_IMPORT_WORD"] = "Импортировать",
	["DB_LIST"] = "Список творений",
	["DB_LOCALE"] = "Локация объекта",
	["DB_MY"] = "Моя база данных (%s)",
	["DB_MY_EMPTY"] = [=[Вы ещё не создавали никаких объектов.
Используйте одну из кнопок внизу чтобы высвободить свою креативность!]=],
	["DB_OTHERS"] = "База данных игроков (%s)",
	["DB_OTHERS_EMPTY"] = "Здесь будут помещены все объекты созданные другими игроками.",
	["DB_REMOVE_OBJECT_POPUP"] = [=[Пожалуйста подтвердите удаление объекта:
ID: |cff00ffff"%s"|r
|cff00ff00[%s]|r

|cffff9900Предупреждение: Данное действие необратимо!.]=],
	["DB_RESULTS"] = "Результаты поиска",
	["DB_SECURITY_TT"] = "Показывает все параметры безопасности для этого объекта. Отсюда вы можете позволить или предотвратить некоторые нежелаемые эффекты.",
	["DB_TO_EXPERT"] = "Перевести в экспертный режим",
	["DB_WARNING"] = [=[
|cffff0000!!! Предупреждение !!!

|cffff9900Не забывайте сохранять ваши изменения прежде чем вернуться к списку базы данных!]=],
	["DEBUG_QUEST_START"] = "Начать задание",
	["DEBUG_QUEST_START_USAGE"] = "Использование: /trp3 debug_quest_start questID",
	["DEBUG_QUEST_STEP"] = "Перейти к этапу задания.",
	["DEBUG_QUEST_STEP_USAGE"] = "Использование: /trp3 debug_quest_step questID stepID",
	["DI_ATTR_TT"] = "Используйте это, если желаете сменить атрибут относительно фазы прошлой катсцены",
	["DI_ATTRIBUTE"] = "Модификация этапа",
	["DI_BKG"] = "Изменить фоновую картинку",
	["DI_BKG_TT"] = [=[Будет использоваться как фоновое изображение кат-сцены. Пожалуйста, введите полный путь к изображению.

Если изменить фон во время кат-сцены, между двумя изображениями произойдет затухание.]=],
	["DI_CHOICE"] = "Вариант",
	["DI_CHOICE_CONDI"] = "Условие варианта",
	["DI_CHOICE_STEP"] = "Перейти к фазе",
	["DI_DIALOG"] = "Диалог",
	["DI_FRAME"] = "Декорация",
	["DI_GET_ID"] = "ID цели",
	["DI_HISTORY"] = "История катсцен",
	["DI_MODELS"] = "Модели",
	["DI_STEPS"] = "Этапы катсцены",
	["DO_EMPTY"] = "Пустой документ",
	["DO_LINKS_ONCLOSE"] = "При закрытии",
	["DO_LINKS_ONOPEN"] = "При открытии",
	["DO_NEW_DOC"] = "Документ",
	["DO_PAGE_ADD"] = "Добавить страницу",
	["DO_PAGE_BORDER"] = "Граница",
	["DO_PAGE_BORDER_1"] = "Пергамент",
	["DO_PAGE_COUNT"] = "Страница %s / %s",
	["DO_PAGE_EDITOR"] = "Редактор страниц: страница %s",
	["DO_PAGE_FIRST"] = "Первая страница",
	["DO_PAGE_FONT"] = "%s фонт",
	["DO_PAGE_HEIGHT"] = "Высота страницы",
	["DO_PAGE_LAST"] = "Последняя страница",
	["DO_PAGE_MANAGER"] = "Менеджер страниц",
	["DO_PAGE_NEXT"] = "Следующая страница",
	["DO_PAGE_PREVIOUS"] = "Предыдущая страница",
	["DO_PAGE_REMOVE"] = "Удалить страницу",
	["DO_PAGE_REMOVE_POPUP"] = "Удалить страницу %s ?",
	["DO_PREVIEW"] = "Нажмите чтобы увидеть предварительный просмотр",
	["DR_DROP_ERROR_INSTANCE"] = "Невозможно бросить предметы в подземелье",
	["DR_DROPED"] = "Брошено на землю: %s x%d",
	["DR_NOTHING"] = "Предметы в этой области не найдены.",
	["DR_POPUP"] = "Бросить здесь",
	["DR_SEARCH_BUTTON"] = "Искать |cff00ff00мои|r предметы",
	["DR_SEARCH_BUTTON_TT"] = "Ищет ваши предметы в радиусе 15 метров.",
	["DR_STASHES"] = "Тайники",
	["DR_STASHES_CREATE"] = "Создать тайник здесь",
	["DR_STASHES_DROP"] = "Вы не можете бросить предмет в чужой тайник",
	["DR_STASHES_FOUND"] = "Тайников найдено: %s",
	["DR_STASHES_FULL"] = "Этот тайник полон.",
	["DR_STASHES_HIDE"] = "Спрятать от сканирования",
	["DR_STASHES_MAX"] = "максимум 50 символов",
	["DR_STASHES_NAME"] = "Тайник",
	["DR_STASHES_OWNER"] = "Владелец",
	["DR_STASHES_REMOVE"] = "Удалить тайник",
	["DR_STASHES_REMOVED"] = "Тайник удалён.",
	["DR_STASHES_RESYNC"] = "Ресинхронизировать",
	["DR_STASHES_SCAN"] = "Поиск тайников игроков",
	["DR_STASHES_SCAN_MY"] = "Поиск моих тайников",
	["DR_STASHES_SEARCH"] = "Искать тайники |cff00ff00игроков|r",
	["DR_SYSTEM"] = "Система добычи",
	["DR_SYSTEM_TT"] = "Ронять / искать предметы и создавать / обращаться к вашим тайникам. Система добычи не работает в подземельях/аренах/полях боя.",
	["EDITOR_BOTTOM"] = "Низ",
	["EDITOR_CONFIRM"] = "Подтвердить",
	["EDITOR_HEIGHT"] = "Высота",
	["EDITOR_ICON"] = "Выбрать значок",
	["EDITOR_ICON_SELECT"] = "Нажмите чтобы выбрать значок.",
	["EDITOR_ID_COPY"] = "Скопировать ID",
	["EDITOR_MAIN"] = "Главная",
	["EDITOR_NOTES"] = "Свободные заметки",
	["EDITOR_PREVIEW"] = "Предварительный просмотр",
	["EDITOR_TOP"] = "Верх",
	["EDITOR_WIDTH"] = "Ширина",
	["EFFECT_AURA_APPLY"] = "Применить ауру",
	["EFFECT_AURA_APPLY_DO_NOTHING"] = "ничего не делать",
	["EFFECT_AURA_APPLY_EXTEND"] = "продлить",
	["EFFECT_CAT_CAMERA"] = "Камера",
	["EFFECT_CAT_CAMERA_LOAD"] = "Загрузить камеру",
	["EFFECT_CAT_CAMERA_SAVE"] = "Сохранить камеру",
	["EFFECT_CAT_CAMERA_SLOT"] = "Номер слота",
	["EFFECT_CAT_CAMERA_ZOOM_DISTANCE"] = "Расстояние зума",
	["EFFECT_CAT_CAMERA_ZOOM_IN"] = "Приблизить камеру",
	["EFFECT_CAT_CAMERA_ZOOM_OUT"] = "Отдалить камеру",
	["EFFECT_CAT_CAMPAIGN"] = "Кампания и задание",
	["EFFECT_CAT_SOUND"] = "Звук и музыка",
	["EFFECT_CAT_SPEECH"] = "Речь и эмоции",
	["EFFECT_DIALOG_QUICK"] = "Быстрая кат-сцена",
	["EFFECT_DIALOG_START"] = "Начать кат-сцену",
	["EFFECT_DIALOG_START_PREVIEW"] = "Начать катсцену %s.",
	["EFFECT_DOC_ID"] = "ID документа",
	["EFFECT_ITEM_ADD"] = "Добавить предмет",
	["EFFECT_ITEM_ADD_ID"] = "ID предмета",
	["EFFECT_ITEM_ADD_QT"] = "Количество",
	["EFFECT_ITEM_ADD_TT"] = "Добавляет предметы в вашу сумку.",
	["EFFECT_ITEM_BAG_DURABILITY"] = "Повредить/починить контейнер",
	["EFFECT_ITEM_BAG_DURABILITY_METHOD"] = "Тип",
	["EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE"] = "Повредить",
	["EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL"] = "Починить",
	["EFFECT_ITEM_CONSUME"] = "Поглотить предмет",
	["EFFECT_ITEM_CONSUME_TT"] = "Поглощает использованный предмет и уничтожает его.",
	["EFFECT_ITEM_COOLDOWN"] = "Начать восстановление",
	["EFFECT_ITEM_DICE"] = "Кинуть кости",
	["EFFECT_ITEM_LOOT"] = "Показать/уронить добычу",
	["EFFECT_ITEM_LOOT_DROP"] = "Бросить предметы",
	["EFFECT_ITEM_REMOVE"] = "Уничтожить предмет",
	["EFFECT_ITEM_SOURCE_SEARCH"] = "Искать в",
	["EFFECT_OPERATION_TYPE_ADD"] = "Прибавление",
	["EFFECT_OPERATION_TYPE_DIV"] = "Деление",
	["EFFECT_OPERATION_TYPE_MULTIPLY"] = "Умножение",
	["EFFECT_OPERATION_TYPE_SUB"] = "Вычитание",
	["EFFECT_PROMPT_DEFAULT"] = "Значение по-умолчанию",
	["EFFECT_RUN_WORKFLOW_SLOT"] = "ID слота",
	["EFFECT_SOUND_ID_LOCAL"] = "Проиграть локальный звук",
	["EFFECT_SOUND_ID_LOCAL_STOP"] = "Остановить локальный звук",
	["EFFECT_SOUND_ID_LOCAL_TT"] = "Проигрывает звук для игроков вокруг вас.",
	["EFFECT_SOUND_ID_SELF_CHANNEL"] = "Канал",
	["EFFECT_SOUND_PLAY"] = "Воспроизвести",
	["EFFECT_SOURCE"] = "Источник",
	["EFFECT_SOURCE_CAMPAIGN"] = "Активная кампания",
	["EFFECT_SOURCE_OBJECT"] = "Объект",
	["EFFECT_SPEECH_NAR_DEFAULT"] = "Метель укроет склоны горных вершин ...",
	["EFFECT_SPEECH_NPC"] = "Речь: НИП",
	["EFFECT_SPEECH_NPC_DEFAULT"] = "За окном уже сугробы ...",
	["EFFECT_SPEECH_PLAYER_DEFAULT"] = "Позволь дракону поглотить тебя!",
	["EFFECT_TEXT_TEXT_DEFAULT"] = "Привет. Как дела?",
	["EFFECT_TEXT_TYPE"] = "Тип текста",
	["EFFECT_VAR"] = "Название переменной",
	["EFFECT_VAR_VALUE"] = "Значение переменной",
	["EX_SOUND_HISTORY"] = "История звуков",
	["EX_SOUND_HISTORY_CLEAR"] = "Очистить",
	["EX_SOUND_HISTORY_EMPTY"] = "Не было проиграно никаких звуков.",
	["EX_SOUND_HISTORY_STOP"] = "Остановить",
	["EX_SOUND_HISTORY_STOP_ALL"] = "Остановить все",
	["EX_SOUND_HISTORY_TT"] = "Узнайте какие звуки были проиграны, посмотрите откуда они и остановите их если они до сих пор играют.",
	["EX_SOUND_HISTORY_ACTION_OPEN"] = "Открыть историю звуков",
	["EX_SOUND_HISTORY_ACTION_STOP"] = "Остановить все звуки/музыку",
	["IN_INNER"] = "Внутренние объекты",
	["IN_INNER_ADD"] = "Добавить внутренний объект",
	["IN_INNER_ADD_COPY"] = "Добавить копию существующего объекта",
	["IN_INNER_ADD_NEW"] = "Создать новый объект",
	["IN_INNER_COPY_ACTION"] = "Скопировать содержимое объекта",
	["IN_INNER_ID_ACTION"] = "Изменить ID",
	["IN_INNER_ID_COPY"] = "Скопировать",
	["IN_INNER_S"] = "Внутренний объект",
	["INV_PAGE_CAMERA_CONFIG"] = "Параметры камеры: Поворот: %.2f",
	["INV_PAGE_CHARACTER_INSPECTION"] = "Осмотр персонажа",
	["INV_PAGE_CHARACTER_INSPECTION_TT"] = "Осмотрите инвентарь этого персонажа.",
	["INV_PAGE_CHARACTER_INV"] = "Инвентарь",
	["INV_PAGE_EDIT_ERROR1"] = "Вы должны являться автором этого предмета чтобы его отредактировать.",
	["INV_PAGE_EDIT_ERROR2"] = "Этот предмет не в Быстром режиме.",
	["INV_PAGE_INV_OPEN"] = "Открыть инвентарь",
	["INV_PAGE_ITEM_LOCATION"] = "Расположение предмета на персонаже",
	["INV_PAGE_MARKER"] = "Позиция маркера: x: %.2f y: %.2f",
	["INV_PAGE_PLAYER_INV"] = "Инвентарь %s",
	["INV_PAGE_QUICK_SLOT"] = "Быстрый слот",
	["INV_PAGE_QUICK_SLOT_TT"] = "Этот слот будет использован в качестве основного контейнера.",
	["INV_PAGE_SEQUENCE"] = "ID анимации",
	["INV_PAGE_SEQUENCE_PRESET"] = "Вы можете выбрать ID анимации соответствующей эмоции.",
	["INV_PAGE_TOTAL_VALUE"] = "Общая стоимость предметов",
	["INV_PAGE_WEAR_TT"] = "Этот предмет надеваемый. Зелёная зона показывает местонахождение предмета на персонаже.",
	["IT_CO_DURABILITY"] = "Прочность",
	["IT_CO_MAX"] = "Максимальный вес (в граммах)",
	["IT_CO_SIZE"] = "Размер контейнера",
	["IT_CON"] = "Контейнер",
	["IT_CRAFTED"] = "Создан",
	["IT_DISPLAY_ATT"] = "Аттрибуты отображения",
	["IT_DOC_ACTION"] = "Прочитать документ",
	["IT_DR_SOUND"] = "Звук падения",
	["IT_EX_DOWNLOAD"] = "Скачать",
	["IT_EX_EMPTY"] = "Нечего обменивать",
	["IT_EX_EMPTY_DRAG"] = "Вы можете перетаскивать и отпускать предметы сюда.",
	["IT_EX_TRADE_BUTTON"] = "Открыть обмен",
	["IT_EX_TRADE_BUTTON_TT"] = "Открыть окно обмена чтобы начать торговаться предметами с этим игроком.",
	["IT_FIELD_NAME"] = "Название предмета",
	["IT_FIELD_QUALITY"] = "Качество предмета",
	["IT_GAMEPLAY_ATT"] = "Игровые аттрибуты",
	["IT_INV_GOT"] = "Получено: %s x%d",
	["IT_INV_SCAN_MY_ITEMS"] = "Поиск моих предметов.",
	["IT_INV_SHOW_ALL"] = "Показать весь инвентарь",
	["IT_NEW_NAME"] = "Новый предмет",
	["IT_NEW_NAME_CO"] = "Новый контейнер",
	["IT_NO_ADD"] = "Предотвратить ручное добавление",
	["IT_ON_USE"] = "При использовании",
	["IT_PU_SOUND"] = "Звук подбора",
	["IT_PU_SOUND_1183"] = "Рюкзак",
	["IT_PU_SOUND_1184"] = "Книга",
	["IT_PU_SOUND_1185"] = "Ткань",
	["IT_PU_SOUND_1186"] = "Еда",
	["IT_PU_SOUND_1187"] = "Трава",
	["IT_PU_SOUND_1188"] = "Цепь",
	["IT_PU_SOUND_1189"] = "Мясо",
	["IT_PU_SOUND_1190"] = "Большой металлический",
	["IT_PU_SOUND_1191"] = "Малый металлический",
	["IT_PU_SOUND_1192"] = "Бумага",
	["IT_PU_SOUND_1193"] = "Кольцо",
	["IT_PU_SOUND_1194"] = "Камень",
	["IT_PU_SOUND_1195"] = "Малая цепь",
	["IT_PU_SOUND_1196"] = "Жезл",
	["IT_PU_SOUND_1197"] = "Жидкость",
	["IT_PU_SOUND_1198"] = "Малый древесный",
	["IT_PU_SOUND_1199"] = "Большой древесный",
	["IT_PU_SOUND_1221"] = "Драгоценные камни",
	["IT_QUEST"] = "Флажок задания",
	["IT_QUICK_EDITOR"] = "Быстрое создание предмета",
	["IT_QUICK_EDITOR_EDIT"] = "Быстрое редактирование предмета",
	["IT_STACK"] = "Стакуемый",
	["IT_STACK_COUNT"] = "Максимальное число единиц в складке",
	["IT_TRIGGER_ON_DESTROY"] = "При уничтожении стопки",
	["IT_TRIGGER_ON_USE"] = "При применении",
	["IT_TT_LEFT"] = "Текст левой подсказки",
	["IT_TT_REAGENT"] = "Флажок реагента",
	["IT_TT_RIGHT"] = "Текст правой подсказки",
	["IT_TT_VALUE"] = "Значение предмета",
	["IT_TT_VALUE_FORMAT"] = "Стоимость предмета (в %s)",
	["IT_TT_WEIGHT"] = "Вес предмета",
	["IT_TT_WEIGHT_FORMAT"] = "Вес предмета (в граммах)",
	["IT_UNIQUE_COUNT"] = "Максимальное количество единиц",
	["IT_USE"] = "Используемый",
	["IT_USE_TEXT"] = "Текст использования",
	["IT_WEARABLE"] = "Надеваемый",
	["ITEM_ID"] = "ID предмета",
	["LOOT"] = "Добыть",
	["LOOT_CONTAINER"] = "Контейнер добычи",
	["MODE_EXPERT"] = "Экспертный",
	["MODE_NORMAL"] = "Нормальный",
	["MODE_QUICK"] = "Быстрый",
	["NPC_SAYS"] = "говорит",
	["NPC_WHISPERS"] = "шепчет",
	["NPC_YELLS"] = "кричит",
	["OP_ADD_TEST"] = "Добавить проверку",
	["OP_AND"] = "AND",
	["OP_AND_SWITCH"] = "Изменить на AND",
	["OP_BOOL"] = "Булеанское значение",
	["OP_BOOL_FALSE"] = "FALSE",
	["OP_BOOL_TRUE"] = "TRUE",
	["OP_COMP_EQUALS"] = "равняется",
	["OP_COMP_GREATER"] = "больше чем",
	["OP_COMP_GREATER_OR_EQUALS"] = "больше чем или равняется",
	["OP_COMP_LESSER"] = "меньше чем",
	["OP_COMP_LESSER_OR_EQUALS"] = "меньше чем или равняется",
	["OP_COMP_NEQUALS"] = "не равняется",
	["OP_CONFIGURE"] = "Настроить",
	["OP_CURRENT"] = "Текущее значение",
	["OP_NUMERIC"] = "Численное значение",
	["OP_OP_CHAR_ACHIEVEMENT"] = "Достижение",
	["OP_OP_CHAR_ACHIEVEMENT_ACC"] = "Аккаунт",
	["OP_OP_CHAR_ACHIEVEMENT_CHAR"] = "Персонаж",
	["OP_OP_CHAR_ACHIEVEMENT_ID"] = "ID достижения",
	["OP_OP_CHAR_ZONE"] = "Название локации",
	["OP_OP_DATE_DAY"] = "Дата: День",
	["OP_OP_DATE_DAY_OF_WEEK"] = "Дата: День недели",
	["OP_OP_DATE_MONTH"] = "Дата: Месяц",
	["OP_OP_DATE_YEAR"] = "Дата: Год",
	["OP_OP_DISTANCE_CURRENT"] = "Использовать текущую позицию",
	["OP_OP_DISTANCE_X"] = "Координата X",
	["OP_OP_DISTANCE_Y"] = "Координата Y",
	["OP_OP_INV_CONTAINER_SLOT_ID"] = "ID слота контейнера",
	["OP_OP_INV_CONTAINER_SLOT_ID_PREVIEW"] = "ID предмета в слоте %s",
	["OP_OP_INV_COUNT"] = "Количество единиц предмета",
	["OP_OP_INV_COUNT_ANY"] = "Любой предмет",
	["OP_OP_INV_COUNT_PREVIEW"] = [=[%s единиц в |cffff9900%s

]=],
	["OP_OP_INV_ICON"] = "Значок предмета",
	["OP_OP_INV_ICON_PREVIEW"] = "Значок %s",
	["OP_OP_INV_ICON_TT"] = [=[|cff00ff00Иконка предмета с данным ID.

]=],
	["OP_OP_INV_ITEM_WEIGHT"] = "Вес предмета",
	["OP_OP_INV_ITEM_WEIGHT_PREVIEW"] = "Вес %s",
	["OP_OP_INV_ITEM_WEIGHT_TT"] = [=[|cff00ff00Вес предмета с данным ID.

]=],
	["OP_OP_INV_NAME"] = "Название предмета",
	["OP_OP_INV_NAME_PREVIEW"] = "Имя %s",
	["OP_OP_INV_NAME_TT"] = [=[|cff00ff00Имя предмета с данным ID.

]=],
	["OP_OP_INV_QUALITY"] = "Качество предмета",
	["OP_OP_INV_QUALITY_PREVIEW"] = "Качество %s",
	["OP_OP_INV_QUALITY_TT"] = "|cff00ff00Качество предмета с данным ID.",
	["OP_OP_INV_VALUE"] = "Стоимость предмета",
	["OP_OP_INV_VALUE_PREVIEW"] = "Стоимость %s",
	["OP_OP_INV_VALUE_TT"] = "|cff00ff00Стоимость предмета с данным ID.",
	["OP_OP_INV_WEIGHT"] = "Общий вес контейнера",
	["OP_OP_INV_WEIGHT_PREVIEW"] = "Общий вес |cffff9900%s",
	["OP_OP_INV_WEIGHT_TT"] = [=[|cff00ff00Текущий общий вес контейнера (его собственный вес плюс содержимое).

]=],
	["OP_OP_QUEST_ACTIVE_CAMPAIGN"] = "Активная кампания",
	["OP_OP_QUEST_OBJ"] = "Цель задания",
	["OP_OP_QUEST_OBJ_CURRENT"] = "Текущие цели задания",
	["OP_OP_QUEST_OBJ_PREVIEW"] = "Цель %s из %s",
	["OP_OP_QUEST_STEP"] = "Текущий этап задания",
	["OP_OP_RANDOM_FROM"] = "От",
	["OP_OP_RANDOM_TO"] = "Для",
	["OP_OP_UNIT_CLASS"] = "Класс единицы",
	["OP_OP_UNIT_CLASSIFICATION"] = "Классификация единицы",
	["OP_OP_UNIT_CREATURE_TYPE"] = "Тип существа единицы",
	["OP_OP_UNIT_DEAD"] = "Единица мертва",
	["OP_OP_UNIT_EXISTS"] = "Единица существует",
	["OP_OP_UNIT_FACTION"] = "Фракция единицы",
	["OP_OP_UNIT_FACTION_TT"] = "|cff00ff00Фракция единицы АНГЛИЙСКИМИ ПРОПИСНЫМИ БУКВАМИ.",
	["OP_OP_UNIT_GUILD"] = "Название гильдии единицы",
	["OP_OP_UNIT_HEALTH"] = "Здоровье единицы",
	["OP_OP_UNIT_ID"] = "ID единицы",
	["OP_OP_UNIT_ISPLAYER"] = "Единица игрок",
	["OP_OP_UNIT_LEVEL"] = "Уровень единицы",
	["OP_OP_UNIT_NAME"] = "Имя единицы",
	["OP_OP_UNIT_RACE"] = "Раса единицы",
	["OP_OP_UNIT_SEX"] = "Пол единицы",
	["OP_OP_UNIT_SPEED"] = "Скорость единицы",
	["OP_UNIT"] = "Тип единицы",
	["OP_UNIT_NPC"] = "НИП",
	["OP_UNIT_PLAYER"] = "Игрок",
	["OP_UNIT_TARGET"] = "Цель",
	["OP_UNIT_VALUE"] = "Значение единицы",
	["QE_BUTTON"] = "Открыть журнал заданий",
	["QE_CAMPAIGN"] = "Кампания",
	["QE_CAMPAIGN_CURRENT"] = "Текущая кампания",
	["QE_CAMPAIGN_LIST"] = "%s доступных кампаний",
	["QE_CAMPAIGN_RESET"] = "Сбросить кампанию",
	["QE_CAMPAIGN_START_BUTTON"] = "Начать или продолжить кампанию",
	["QE_CAMPAIGNS"] = "Кампании",
	["QE_PROGRESS"] = "Прогрессия",
	["QE_QUEST"] = "Задание",
	["QE_QUEST_LIST"] = "Задания для этой кампании",
	["QE_QUESTS"] = "Задания",
	["QUEST_ID"] = "ID задания",
	["ROOT_CREATED"] = "Создано %s %s",
	["ROOT_CREATED_BY"] = "Создано",
	["ROOT_CREATED_ON"] = "Создано",
	["ROOT_GEN_ID"] = "Сгенерированный ID",
	["ROOT_ID"] = "ID объекта",
	["ROOT_SAVED"] = "Последнее изменение %s %s",
	["ROOT_TITLE"] = "Коренной объект",
	["ROOT_VERSION"] = "Версия",
	["SPECIFIC_INNER_ID"] = "Внутренний ID",
	["SPECIFIC_MODE"] = "Режим",
	["TB_TOOLS"] = "База данных расширенных объектов",
	["TB_TOOLS_TT"] = "Создавайте свои собственные предметы и задания",
	["TU_IT_2"] = "Аттрибуты отображения",
	["TU_IT_3"] = "Свободные заметки",
	["TU_WO_2"] = "Список процессов",
	["TU_WO_4"] = "Добавить эффект",
	["TU_WO_5"] = "Добавить условие",
	["TU_WO_6"] = "Добавить задержку",
	["TU_WO_ERROR_1"] = "Пожалуйста создайте процесс прежде чем продолжите это обучение.",
	["TYPE"] = "Тип",
	["TYPE_DIALOG"] = "Кат-сцена",
	["TYPE_ITEM"] = "Предмет",
	["TYPE_ITEMS"] = "Предмет(ы)",
	["TYPE_QUEST"] = "Задание",
	["TYPE_QUEST_STEP"] = "Этап задания",
	["WO_ADD"] = "Создать процесс",
	["WO_ADD_ID_NO_AVAILABLE"] = "Этот ID процесса недоступен.",
	["WO_COMMON_EFFECT"] = "Общие эффекты",
	["WO_CONDITION"] = "Условие",
	["WO_CONDITION_TT"] = "Проверяет условие. Останавливает процесс если условие провалено.",
	["WO_CONTEXT"] = "Контекст",
	["WO_COPY"] = "Скопировать содержимое процесса",
	["WO_DELAY"] = "Задержка",
	["WO_DELAY_CAST"] = "Применение",
	["WO_DELAY_DURATION"] = "Длительность",
	["WO_DELAY_SECONDS"] = "секунда(ы)",
	["WO_DELAY_TYPE"] = "Тип задержки",
	["WO_DELAY_TYPE_1"] = "Обычная задержка",
	["WO_EFFECT"] = "Эффект",
	["WO_EFFECT_CAT_COMMON"] = "Общие",
	["WO_EFFECT_SELECT"] = "Выберите эффект",
	["WO_ELEMENT"] = "Редактирование элемента",
	["WO_ELEMENT_ADD"] = "Добавить элемент к процессу",
	["WO_ELEMENT_COPY"] = "Скопировать содержимое элемента",
	["WO_ELEMENT_EDIT"] = "Нажмите чтобы редактировать элемент",
	["WO_ELEMENT_EDIT_RIGHT"] = "ПКМ для дополнительных операций",
	["WO_ELEMENT_PASTE"] = "Вставить содержимое элемента",
	["WO_ELEMENT_TYPE"] = "Выберите тип элемента",
	["WO_END"] = "Конец процесса",
	["WO_EVENT_EX_ADD"] = "Добавить привязку к события",
	["WO_EVENT_ID"] = "ID события",
	["WO_EVENT_LINKS"] = "Объект привязок к событиям",
	["WO_EXECUTION"] = "Исполнение процесса",
	["WO_EXPERT"] = "Экспертный режим",
	["WO_EXPERT_EFFECT"] = "Экспертные эффекты",
	["WO_LINKS"] = "Привязки к событиям",
	["WO_LINKS_NO_LINKS"] = "Без привязок",
	["WO_LINKS_NO_LINKS_TT"] = "Не привязывать это действие/событие к процессу.",
	["WO_LINKS_SELECT"] = "Выберите процесс для привязки",
	["WO_LINKS_TO"] = "Привязано к процессу",
	["WO_LINKS_TRIGGERS"] = "Здесь вы можете привязать ваши процесс к конкретным событиям для этого объекта.",
	["WO_PASTE"] = "Вставить содержимое процесса",
	["WO_SECURITY"] = "Уровень безопасности",
	["WO_SECURITY_HIGH"] = "Высокий",
	["WO_SECURITY_LOW"] = "Низкий",
	["WO_SECURITY_NORMAL"] = "Средний",
	["WO_WO_SECURITY"] = "Безопасность процесса",
	["WO_WORKFLOW"] = "Процессы"
};

TRP3_API.loc:GetLocale("ruRU"):AddTexts(L);
