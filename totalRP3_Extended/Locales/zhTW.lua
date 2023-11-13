-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

-- THIS FILE IS AUTOMATICALLY GENERATED.
-- ALL MODIFICATIONS TO THIS FILE WILL BE LOST.

TRP3_API.loc:GetLocale("zhTW"):AddTexts({
	["ALL"] = "全部",
	["BINDING_NAME_TRP3_INVENTORY"] = "開啟裝備欄",
	["BINDING_NAME_TRP3_MAIN_CONTAINER"] = "打開容器",
	["BINDING_NAME_TRP3_QUEST_ACTION"] = "執行動作：互動",
	["BINDING_NAME_TRP3_QUEST_LISTEN"] = "執行動作：聆聽",
	["BINDING_NAME_TRP3_QUEST_LOOK"] = "執行動作：觀察",
	["BINDING_NAME_TRP3_QUEST_TALK"] = "執行動作：對話",
	["BINDING_NAME_TRP3_QUESTLOG"] = "開啟 TRP3 任務日誌",
	["BINDING_NAME_TRP3_SEARCH_FOR_ITEMS"] = "搜尋物品",
	["CA_ACTION_CONDI"] = "動作狀態編輯器",
	["CA_ACTION_REMOVE"] = "是否移除此動作？",
	["CA_ACTIONS"] = "動作",
	["CA_ACTIONS_ADD"] = "新增動作",
	["CA_ACTIONS_COND"] = "編輯狀態",
	["CA_ACTIONS_COND_OFF"] = "此動作沒有被編輯任何狀態。",
	["CA_ACTIONS_COND_ON"] = "此動作已編輯。",
	["CA_ACTIONS_COND_REMOVE"] = "移除狀態",
	["CA_ACTIONS_EDITOR"] = "動作編輯器",
	["CA_ACTIONS_NO"] = "無動作",
	["CA_ACTIONS_SELECT"] = "選擇動作種類",
	["CA_DESCRIPTION"] = "活動概要",
	["CA_DESCRIPTION_TT"] = "此概要將顯示於任務日誌內的活動概要中。",
	["CA_ICON"] = "活動圖示",
	["CA_ICON_TT"] = "選擇活動圖示",
	["CA_IMAGE"] = "活動影像",
	["CA_IMAGE_TT"] = "選擇活動影像",
	["CA_LINKS_ON_START"] = "開始活動時",
	["CA_LINKS_ON_START_TT"] = [=[ |cff00ff00當|r 玩家第一次開始或是在任務日誌中重置時觸發。

|cff00ff00建議以此處設置您的第一個任務。]=],
	["CA_NAME"] = "活動名稱",
	["CA_NAME_NEW"] = "新建活動",
	["CA_NAME_TT"] = "為此活動的名稱，並會顯示在任務日誌之中。",
	["CA_NO_NPC"] = "無自定義之非玩家角色（NPC）。",
	["CA_NPC"] = "NPC清單",
	["CA_NPC_ADD"] = "加入自定義非玩家角色（NPC）",
	["CA_NPC_AS"] = "複製",
	["CA_NPC_EDITOR"] = "NPC編輯器",
	["CA_NPC_EDITOR_DESC"] = "NPC介紹",
	["CA_NPC_EDITOR_NAME"] = "NPC姓名",
	["CA_NPC_ID"] = "NPC的ID",
	["CA_NPC_ID_TT"] = "請輸入此NPC的ID來完成自定義步驟。 |cff00ff00 請在對話欄中輸入「/trp3 getID」以擷取目標NPC的ID。",
	["CA_NPC_NAME"] = "默認NPC姓名",
	["CA_NPC_REMOVE"] = "是否移除此NPC之自定義內容？",
	["CA_NPC_TT"] = "您可以自定義NPC的姓名、圖示以及介紹。這些客製化選項將會在玩家進行您的活動時被啟用。",
	["CA_NPC_UNIT"] = "自定義NPC",
	["CA_QE_ID"] = "變更任務ID",
	["CA_QE_ST_ID"] = "變更任務步驟ID",
	["CA_QUEST_ADD"] = "新增任務",
	["CA_QUEST_CREATE"] = "請輸入任務的ID。在同一個活動中無法同時存在兩個相同ID的任務。 |cffff9900注意！任務排序將依照ID的字母順序排列。 |cff00ff00因此建議將您的任務ID格式設定為「quest_#」而「#」即為活動中的任務編號。",
	["CA_QUEST_DD_COPY"] = "複製任務內容",
	["CA_QUEST_DD_PASTE"] = "貼上任務內容",
	["CA_QUEST_DD_REMOVE"] = "移除任務",
	["CA_QUEST_EXIST"] = "已存在一個 ID 為 %s 的任務。",
	["CA_QUEST_NO"] = "沒有任務",
	["CA_QUEST_REMOVE"] = "是否移除此任務？",
	["CL_CAMPAIGN_PROGRESSION"] = "%s 的進展：",
	["CL_IMPORT"] = "匯入資料庫",
	["CL_IMPORT_ITEM_BAG"] = "新增此物品到背包",
	["CL_TOOLTIP"] = "製造聊天室內連結",
	["COM_NPC_ID"] = "擷取目標NPC之ID",
	["COND_EDITOR"] = "條件編輯器",
	["CONF_MAIN"] = "Extended 設置",
	["CONF_MUSIC_ACTIVE"] = "播放本地音樂",
	["CONF_MUSIC_ACTIVE_TT"] = [=[本地音樂是其他玩家在一定距離（以碼為單位）内播放的音樂（例如通過物品。）如果您不想聽到這些音樂，可以將本功能關閉。
	
|cff00ff00你無法聽見被忽略之玩家所播放的音樂。
|cff00ff00所有音樂都可以透過TRP3快捷列中的音樂播放器來終止。]=],
	["CONF_MUSIC_METHOD"] = "本地音樂循環播放",
	["CONF_MUSIC_METHOD_TT"] = "決定當您在範圍內時如何收聽本地音樂。",
	["CONF_SOUNDS"] = "本地音效／音樂",
	["CONF_SOUNDS_ACTIVE"] = "播放本地音效",
	["CONF_SOUNDS_ACTIVE_TT"] = [=[本地音效是其他玩家在一定距離（以碼為單位）内播放的音效（例如通過物品。）如果您不想聽到這些音效，可以將本功能關閉。
	
|cff00ff00你無法聽見被忽略之玩家所播放的音效。
|cff00ff00所有音樂都可以透過TRP3快捷列中的音樂播放器來終止。]=],
	["CONF_SOUNDS_MAXRANGE"] = "最大播放距離",
	["CONF_SOUNDS_MAXRANGE_TT"] = [=[設定本地音樂／音效的最大播放距離。

|cff00ff00能有效避免其他玩家播放範圍巨大的噪音。
	
|cffff9900數值設置為0則代表不限制距離。]=],
	["CONF_SOUNDS_METHOD"] = "本地音效播放模式",
	["CONF_SOUNDS_METHOD_1"] = "自動播放",
	["CONF_SOUNDS_METHOD_1_TT"] = "若您在音樂／音效的設定範圍內，該音樂／音效將不經過您的許可自動播放。",
	["CONF_SOUNDS_METHOD_2"] = "播放前詢問",
	["CONF_SOUNDS_METHOD_2_TT"] = "若您在音樂／音效所設置的播放範圍內，其將透過聊天室內的許可連結來向您確認是否播放。",
	["CONF_SOUNDS_METHOD_TT"] = "決定當您在範圍內時如何收聽本地音效。",
	["CONF_UNIT"] = "單位",
	["CONF_UNIT_WEIGHT"] = "重量單位",
	["CONF_UNIT_WEIGHT_1"] = "公克（g）",
	["CONF_UNIT_WEIGHT_2"] = "磅（pounds）",
	["CONF_UNIT_WEIGHT_3"] = "馬鈴薯",
	["CONF_UNIT_WEIGHT_TT"] = "決定您將以何種計量單位來表示重量。",
	["DB"] = "資料庫",
	["DB_ACTIONS"] = "動作",
	["DB_ADD_COUNT"] = "你想將幾個 %s 放入您的物品欄？",
	["DB_ADD_ITEM"] = "加入物品欄",
	["DB_ADD_ITEM_TT"] = [=[將指定數量的此物件放入您的容器（在角色沒有指定容器時則生成於主要背包）。
]=],
	["DB_BACKERS"] = "後台資料庫 (%s)",
	["DB_BACKERS_LIST"] = "關於作者",
	["DB_BROWSER"] = "物件瀏覽器",
	["DB_COPY_ID_TT"] = "在可以複製／貼上的視窗內顯示物件ID。",
	["DB_COPY_TT"] = "複製此物品（以及其子物品）的資訊並以子物品的方式貼上到其他物品。",
	["DB_CREATE_CAMPAIGN"] = "創建活動",
	["DB_CREATE_CAMPAIGN_TEMPLATES_BLANK"] = "空白活動",
	["DB_CREATE_CAMPAIGN_TEMPLATES_BLANK_TT"] = "完全空白的模板，必須重頭開始設計任務的每個環節。",
	["DB_CREATE_CAMPAIGN_TEMPLATES_FROM"] = "從…創建",
	["DB_CREATE_CAMPAIGN_TEMPLATES_FROM_TT"] = "創建現有活動的副本。",
	["DB_CREATE_CAMPAIGN_TT"] = "開始建立活動",
	["DB_CREATE_ITEM"] = "創建物品",
	["DB_CREATE_ITEM_TEMPLATES"] = "選擇創建模板",
	["DB_CREATE_ITEM_TEMPLATES_BLANK"] = "空白物件",
	["DB_CREATE_ITEM_TEMPLATES_BLANK_TT"] = [=[一個完全空白的模板，
必須從頭開始設計。]=],
	["DB_CREATE_ITEM_TEMPLATES_CONTAINER"] = "容器",
	["DB_CREATE_ITEM_TEMPLATES_CONTAINER_TT"] = [=[一個設計容器物件的模板，
有容納其他物件的基本功能。]=],
	["DB_CREATE_ITEM_TEMPLATES_DOCUMENT"] = "文件",
	["DB_CREATE_ITEM_TEMPLATES_DOCUMENT_TT"] = [=[含有可閱讀子物件的子母物件檔，
可以做為書籍或卷軸等文件類型物件。]=],
	["DB_CREATE_ITEM_TEMPLATES_EXPERT"] = "專家級物品",
	["DB_CREATE_ITEM_TEMPLATES_EXPERT_TT"] = [=[專家級物件有更多的功能與動作選項，
推薦給較為熟練的玩家。]=],
	["DB_CREATE_ITEM_TEMPLATES_FROM"] = "從…創建",
	["DB_CREATE_ITEM_TEMPLATES_FROM_TT"] = "創建一個現有物品的副本。",
	["DB_CREATE_ITEM_TEMPLATES_QUICK"] = "快速生成",
	["DB_CREATE_ITEM_TEMPLATES_QUICK_TT"] = [=[快速創建一個沒有任何功能的簡單物件，
並於創建完成後置入您的主要容器中。]=],
	["DB_CREATE_ITEM_TT"] = "為新物件選擇一個創建模板",
	["DB_DELETE_TT"] = "刪除此物件與其子物件。",
	["DB_EXPERT_TT"] = "將此物件切換置高級模式，容許更多元的自定義選項。",
	["DB_EXPORT"] = "快速匯出物件",
	["DB_EXPORT_DONE"] = [=[您的物件已經被匯出到名為 |cff00ff00totalRP3_Extended_ImpExport.lua|r 的檔案之中，並位於：

World of Warcraft\WTF\
account\YOUR_ACCOUNT\SavedVariables

您可以和朋友們分享這個檔案，
匯入後便可以在 |cff00ff00全資料庫|r內找到。]=],
	["DB_EXPORT_HELP"] = "物品%s 的代碼（容量： %0.1f kB）",
	["DB_EXPORT_MODULE_NOT_ACTIVE"] = "完整匯入／匯出物品：　請先啟用totalRP3_Extended_ImpExport插件。",
	["DB_EXPORT_TOO_LARGE"] = [=[物品因尺寸過大而無法使用此功能，請使用完整匯出功能。

容量： %0.1f kB.]=],
	["DB_EXPORT_TT"] = [=[將目標物品匯出囗可交流的代碼。

僅針對小於20kB的小型物件。大型物件請使用完整匯出。]=],
	["DB_FILTERS"] = "搜尋過濾器",
	["DB_FILTERS_CLEAR"] = "清除",
	["DB_FILTERS_NAME"] = "物件名稱",
	["DB_FILTERS_OWNER"] = "創建者",
	["DB_FULL"] = "全資料庫 (%s)",
	["DB_FULL_EXPORT"] = "完整匯出",
	["DB_FULL_EXPORT_TT"] = "無視檔案尺寸完整匯出此物件，這會使插件重新加載、並強制其儲存檔案。",
	["DB_HARD_SAVE"] = "本機儲存",
	["DB_HARD_SAVE_TT"] = "重置界面來儲存已修改的數據到本地磁碟。",
	["DB_IMPORT"] = "快速匯入物件",
	["DB_IMPORT_CONFIRM"] = [=[此物件和您當前的插件版本不同。

匯入的 TRP3E 版本為： %s
您的 TRP3E 版本為： %s

|cffff9900有可能會有不相容的情況，
是否要繼續匯入？]=],
	["DB_IMPORT_DONE"] = "物件已完全匯入！",
	["DB_IMPORT_EMPTY"] = [=[您的 |cff00ff00totalRP3_Extended_ImpExport.lua|r 檔案裡並沒有任何物件。

該檔案必須在 |cffff9900遊戲啟動前|r便放置在：

World of Warcraft\WTF\
account\YOUR_ACCOUNT\SavedVariables

之中。]=],
	["DB_IMPORT_ERROR1"] = "無法讀取此物件。",
	["DB_IMPORT_FULL"] = "完整匯入物件",
	["DB_IMPORT_FULL_CONFIRM"] = [=[確定要匯入以下物件嗎？

%s
%s
由 |cff00ff00%s|r 所創建
版本為： %s]=],
	["DB_IMPORT_FULL_TT"] = "匯入名稱為 |cff00ff00totalRP3_Extended_ImpExport.lua|r的檔案 。",
	["DB_IMPORT_ITEM"] = "匯入物件",
	["DB_IMPORT_TT"] = "於此處貼上物件代碼",
	["DB_IMPORT_TT_WAGO"] = [=[沒有可以貼上的代碼？WeakAuras網站|cff00ff00[<a href="http://wago.io">wago.io</a>]|r有提供ㄧ些可供其他玩家使用的Total RP 3:Extended物品
	<br/>
您可以瀏覽該網站並將其分享的內容貼上使用。]=],
	["DB_IMPORT_VERSION"] = [=[您正在匯入一個比您現有物件更老舊的版本…

匯入版本： %s
您的版本： %s

|cffff9900確定降轉之後匯入嗎？]=],
	["DB_IMPORT_WORD"] = "匯入",
	["DB_LIST"] = "創建列表",
	["DB_LOCALE"] = "物品語言",
	["DB_MY"] = "我的資料庫",
	["DB_MY_EMPTY"] = [=[您還沒創建任何物件，
使用下方的按鈕來開始您的工匠之旅！]=],
	["DB_OTHERS"] = "其他玩家資料庫",
	["DB_OTHERS_EMPTY"] = "此處的物件皆由其他玩家所創建。",
	["DB_REMOVE_OBJECT_POPUP"] = [=[請確認是否刪除該物品：
	ID：|cff00ffff"%s"|r
	|cff00ff00[%s]|r
	
	|cffff9900警告：刪除後無法復原！]=],
	["DB_RESULTS"] = "搜尋結果",
	["DB_SECURITY_TT"] = "檢視此物件的所有安全性參數，在這裡您可以關閉物件造成的不良影響。",
	["DB_TO_EXPERT"] = "切換至高級模式",
	["DB_WARNING"] = [=[|cffff0000！！！警告！！！

|cffff9900在您切換到資料庫之前別忘了儲存變更！]=],
	["DEBUG_QUEST_START"] = "開始任務",
	["DEBUG_QUEST_START_USAGE"] = "使用： /trp3 debug_quest_start questID",
	["DEBUG_QUEST_STEP"] = "跳至任務步驟",
	["DEBUG_QUEST_STEP_USAGE"] = "使用： /trp3 debug_quest_start questID",
	["DI_BKG"] = "更改背景",
	["DI_BKG_TT"] = [=[此圖會被用於過場動畫的背景，請輸入完整的圖案路徑。

如果您在過場動畫中使用不同的背景，新背景將以淡入方式呈現。]=],
	["DI_CHOICE"] = "選項",
	["DI_CHOICE_CONDI"] = "選項條件",
	["DI_CHOICE_STEP"] = "前往步驟",
	["DI_CHOICE_STEP_TT"] = [=[如果玩家選此一選項，可以輸入ID來播放過場動畫。

|cff00ff00如果輸入空白或是無效的ID，將會結束過場動畫（並觸發「事件完成」事件）。]=],
	["DI_CHOICE_TT"] = "輸入此選項的內容。|cff00ff00若想禁用此選項請留白。",
	["DI_CHOICES"] = "玩家選項",
	["DI_CHOICES_TT"] = "設定此步驟之玩家選項。",
	["DI_CONDI_TT"] = [=[設定該選項的顯示條件。若條件沒有被滿足則不會顯示。

|cff00ff00左鍵：設定條件
右鍵：清除條件]=],
	["DI_DIALOG"] = "對話內容",
	["DI_DISTANCE"] = "最大距離（碼）",
	["DI_DISTANCE_TT"] = [=[設定玩家離開多少距離會中斷過場動畫，以碼為單位。若玩家超出距離則會中斷過場動畫，並觸發「過場動畫取消」的事件。

|cff00ff00零代表無限。

|cffff9900從7.1版本開始在副本、戰場、競技場內無效。]=],
	["DI_END"] = "結束點",
	["DI_END_TT"] = [=[將此步驟設定為結束點，進行到這一步時將會結束過場動畫，並觸發「過場動畫結束」事件。

|cff00ff00適合搭配玩家選項使用。]=],
	["DI_FRAME"] = "裝飾",
	["DI_GET_ID"] = "目標ID",
	["DI_GET_ID_TT"] = "複製目標NPC的ID，僅於當前目標是NPC時才有效。",
	["DI_HISTORY"] = "對話紀錄",
	["DI_HISTORY_TT"] = "點擊以顯示／隱藏過場動畫之對話紀錄。",
	["DI_IMAGE"] = "更改圖片",
	["DI_IMAGE_TT"] = [=[輸入完整的圖片ID於過場動畫視窗中央顯示一張圖片，此圖片會以淡入方式呈現。

若要隱藏圖片則不必輸入任何內容。]=],
	["DI_LEFT_UNIT"] = "更改左側模組",
	["DI_LINKS_ONEND"] = "於過場動畫結束時",
	["DI_LINKS_ONEND_TT"] = [=[於過場動畫結束時觸發。

|cff00ff00可藉由抵達最終、空白或是未知步驟來觸發。
|cffff0000若玩家手動關閉過場動畫則不會觸發。]=],
	["DI_LINKS_ONSTART"] = "於過場動畫開始時",
	["DI_LINKS_ONSTART_TT"] = [=[當過場動畫開始時觸發。
|cffff9900注意！此觸發將置於第一步工作流程之前。]=],
	["DI_LOOT"] = "等待拾取",
	["DI_LOOT_TT"] = "如果選擇左邊的工作流程，將會向玩家顯示拾取列表，您可以藉由勾選此項來限制玩家在完成拾取前無法前往下一步驟。",
	["DI_MODELS"] = "模組",
	["DI_NAME"] = "更改對話者姓名",
	["DI_NAME_DIRECTION"] = "更改對話選項",
	["DI_NAME_DIRECTION_TT"] = [=[决定聊天框和姓名版的位置，以及哪一个模型开始动作。如果想完全隐藏聊天框和姓名版，请留空。

決定對話框與姓名的位置，以及哪一個模組負責主導對話。如果想完全隱藏對話框與姓名請直接留白即可。]=],
	["DI_NAME_TT"] = "對話角色的姓名。僅於更改對話選項不為空時有效。",
	["DI_NEXT"] = "指定下一步",
	["DI_NEXT_TT"] = [=[您可以指定下一步對話前往何處。

	|cff00ff00若僅需要按照順序播放則留空即可。此功能在選項會觸發不同結果時使用。]=],
	["DI_RIGHT_UNIT"] = "更改右側模組",
	["DI_STEP"] = "過場動畫步驟",
	["DI_STEP_ADD"] = "添加步驟",
	["DI_STEP_EDIT"] = "編輯步驟",
	["DI_STEP_TEXT"] = "步驟內容",
	["DI_STEPS"] = "過場動畫步驟",
	["DI_UNIT_TT"] = [=[選擇需要顯示的模組：

	- 如要隱藏模組，請留白
	- 使用玩家模型，選擇「player」
	- 使用目標模組，「target」
	- 也可以輸入ID來使用任意NPC之模組]=],
	["DI_WAIT_LOOT"] = "請拾取所有物品",
	["DISCLAIMER"] = [=[{h1:c}請務必詳閱{/h1}

創造物品和任務的過程非常消耗精力，所以存檔消失總是令人痛心疾首。

這裡可以存儲所有你在wow裡創造的東西，雖然它是有限制的：
※所有附加資料都有一個未知的資料大小限制（取決於運行32或64位用戶端，等等…）
※達到或者超過這個限制會刪除所有資料。
※強制關閉程式（alt+f4／Kill Process）會損壞已經保存的資料。
※即使你正確退出遊戲，但遊戲有時仍不能成功保存資料且損壞資料。
※順便說下這玩意和MyRolePlay（另一個RP外掛程式）衝突。
※存儲機制是一個帳號下所有角色存一個地方，所以精分太多可能容易崩潰，目前存儲限制尚不清楚。

正因如此，我們強烈建議你備份保存所有資料！

資料保存位置參見:
{link*https://github.com/Total-RP/Total-RP-3/wiki/Saved-Variables*Where is my information stored?}
{h2:c}直接備份“WTF\Account\你的角色名\SavedVariables” 下的所有內容就行了。{/h2}
主要是「/totalRP3.lua」
配置存檔「/totalrp3_data.lu」
數據存檔「/totalrp3_storyline.lua」

你可以在以下網址搜尋關於雲端保存的教學：
{link*https://github.com/Total-RP/Total-RP-3/wiki/How-to-backup-and-synchronize-your-add-ons-settings-using-a-cloud-service*How to backup and synchronize your add-ons settings using a cloud service？}

需要一些滿足版本反覆運算的雲端同步例如Google Driver你們上不去我就不管了 O(∩_∩)O~

反正你資料沒了我們不能恢復。
特此感謝︿(￣︶￣)︿。

{p:r} TRP3 小組{/p}
]=],
	["DISCLAIMER_OK"] = "以鮮血與靈魂為代價，我簽署這份契約。",
	["DO_EMPTY"] = "空白文件",
	["DO_LINKS_ONCLOSE"] = "於關閉時",
	["DO_LINKS_ONCLOSE_TT"] = "當事件因為玩家或其他事件或工作安排而關閉時觸發。",
	["DO_LINKS_ONOPEN"] = "於開啟時",
	["DO_LINKS_ONOPEN_TT"] = "當文件被開啟時觸發。",
	["DO_NEW_DOC"] = "文件",
	["DO_PAGE_ADD"] = "新增書頁",
	["DO_PAGE_BORDER"] = "邊界",
	["DO_PAGE_BORDER_1"] = "羊皮紙",
	["DO_PAGE_COUNT"] = "頁數 %s / %s",
	["DO_PAGE_EDITOR"] = "頁面編輯器： 第 %s 頁",
	["DO_PAGE_FIRST"] = "第一頁",
	["DO_PAGE_FONT"] = "%s 字體",
	["DO_PAGE_HEIGHT"] = "頁高",
	["DO_PAGE_HEIGHT_TT"] = "以像素為單位的頁面高度，注意，某些背景圖有大小限制，若是超過可能會讓文件效果不佳。",
	["DO_PAGE_LAST"] = "最後一頁",
	["DO_PAGE_MANAGER"] = "頁面選擇與新增",
	["DO_PAGE_NEXT"] = "下一頁",
	["DO_PAGE_PREVIOUS"] = "上一頁",
	["DO_PAGE_REMOVE"] = "移除此頁",
	["DO_PAGE_REMOVE_POPUP"] = "移除第 %s 頁嗎？",
	["DO_PAGE_RESIZE"] = "調整頁面邊界",
	["DO_PAGE_RESIZE_TT"] = [=[允許讀者自由變更頁面長寬。

|cffff9900建議確認您的文件排版試流暢易讀的。

|cff00ff00就算開放此功能，也可能因為排版不良造成閱讀不易或超過畫面邊界。]=],
	["DO_PAGE_TILING"] = "底圖自動排列",
	["DO_PAGE_TILING_TT"] = "勾選此選項，則底圖和文件尺寸不合時會自動水平及垂直複製排列，如果沒有勾選，則底圖會以拉伸的方式覆蓋文件。（可能造成圖案比例過大。）",
	["DO_PAGE_WIDTH"] = "頁寬",
	["DO_PAGE_WIDTH_TT"] = "以像素為單位的頁面寬度，注意，某些背景圖有大小限制，若是超過可能會讓文件效果不佳。",
	["DO_PARAMS_CUSTOM"] = "頁面自定義參數",
	["DO_PARAMS_GLOBAL"] = "默認參數",
	["DO_PARAMS_GLOBAL_TT"] = "更改文件的默認參數，這些參數會被所有沒有自定義參數的頁面套用。",
	["DO_PREVIEW"] = "點擊以預覽頁面",
	["DOC_UNKNOWN_ALERT"] = "無法開啟此文件。（檔案遺失）",
	["DR_DELETED"] = "銷毀： %s x%d",
	["DR_DROP_ERROR_INSTANCE"] = "無法仍下物品。",
	["DR_DROPED"] = "將 %s x%d 扔到地上。",
	["DR_NOTHING"] = "這裡找不到任何物品。",
	["DR_POPUP"] = "丟在地上",
	["DR_POPUP_ASK"] = [=[Total RP 3

選擇如何處理該物品：
%s]=],
	["DR_POPUP_REMOVE"] = "摧毀",
	["DR_POPUP_REMOVE_TEXT"] = "確定要摧毀這個物品嗎？",
	["DR_RESULTS"] = "找到 %s 。",
	["DR_SEARCH_BUTTON"] = "尋找 |cff00ff00my|r 的物品。",
	["DR_SEARCH_BUTTON_TT"] = "搜尋立足點十五碼內是否有您的物品。",
	["DR_STASHED"] = "藏物處： %s x%d",
	["DR_STASHES"] = "藏物處",
	["DR_STASHES_CREATE"] = "在這裡建立一個藏物處",
	["DR_STASHES_CREATE_TT"] = "在您的角色所站的位置建立一個藏物處，可供其他玩家搜尋。",
	["DR_STASHES_DROP"] = "你不能往其他人的藏物處丟物品。",
	["DR_STASHES_EDIT"] = "編輯藏物處",
	["DR_STASHES_ERROR_INSTANCE"] = "無法在此創建藏物處。",
	["DR_STASHES_ERROR_OUT_SYNC"] = "藏物處同步失敗，請再試一次。",
	["DR_STASHES_ERROR_SYNC"] = "藏物處沒有同步。",
	["DR_STASHES_FOUND"] = "找到藏物處： %s",
	["DR_STASHES_FULL"] = "這個藏物處已經爆滿了！",
	["DR_STASHES_HIDE"] = "無法被掃描",
	["DR_STASHES_HIDE_TT"] = [=[此藏物處不會被其他玩家的地圖掃描給偵測，
但不代表絕對不可能被發現。]=],
	["DR_STASHES_MAX"] = "上限50字元",
	["DR_STASHES_NAME"] = "藏物處",
	["DR_STASHES_NOTHING"] = "沒有在這裡找到任何藏物處",
	["DR_STASHES_OWNER"] = "擁有者",
	["DR_STASHES_OWNERSHIP"] = "接管所有權",
	["DR_STASHES_OWNERSHIP_PP"] = [=[是否要接管此藏物處的所有權？
此角色將會在其他玩家掃描時顯示為藏物處的擁有者。]=],
	["DR_STASHES_REMOVE"] = "移除藏物處",
	["DR_STASHES_REMOVE_PP"] = [=[確定拆除此藏物處嗎？
|cffff9900裡面的所有物品都會遺失！]=],
	["DR_STASHES_REMOVED"] = "已撤除藏物處。",
	["DR_STASHES_RESYNC"] = "重新同步",
	["DR_STASHES_SCAN"] = "搜索其他玩家的藏物處。",
	["DR_STASHES_SCAN_MY"] = "搜尋我的藏物處。",
	["DR_STASHES_SEARCH"] = "搜尋 |cff00ff00其他玩家|r 的藏物處",
	["DR_STASHES_SEARCH_TT"] = "搜尋在此區域十五碼內之藏物處，將會花上你三秒的時間，站穩啦！",
	["DR_STASHES_SYNC"] = "正在同步…",
	["DR_STASHES_TOO_FAR"] = "你距離這個藏物處太遠了。",
	["DR_STASHES_WITHIN"] = "|cff00ff00你|r 在十五碼內的藏物處。",
	["DR_SYSTEM"] = "拾放系統",
	["DR_SYSTEM_TT"] = [=[放下／搜尋你的物品以及創建／存取你的藏物處，
拾放系統無法在地城、競技場與戰場中使用。]=],
	["EDITOR_BOTTOM"] = "底部",
	["EDITOR_CANCEL_TT"] = [=[取消對物品 %s 的所有修改（包含母物件與所有子物件。）

|cffff9900未儲存的修改將會消失！]=],
	["EDITOR_CONFIRM"] = "確認",
	["EDITOR_HEIGHT"] = "高度",
	["EDITOR_ICON"] = "圖示選擇",
	["EDITOR_ICON_SELECT"] = "左鍵以選取圖示",
	["EDITOR_ID_COPY"] = "複製ID",
	["EDITOR_ID_COPY_POPUP"] = "你可以複製下物品的ID以便將其貼上到其他位置。",
	["EDITOR_MAIN"] = "主要",
	["EDITOR_MORE"] = "更多",
	["EDITOR_NOTES"] = "記事本",
	["EDITOR_PREVIEW"] = "預覽",
	["EDITOR_SAVE_TT"] = "保存對物品 %s 的所有修改（包括母物件與所有子物件。）並設置版本號碼。",
	["EDITOR_TOP"] = "頂部",
	["EDITOR_WARNINGS"] = [=[發現 %s 個錯誤。

|cffff9900%s|r

確定要保存嗎？]=],
	["EDITOR_WIDTH"] = "寬度",
	["EFFECT_CAT_CAMERA"] = "視角",
	["EFFECT_CAT_CAMERA_LOAD"] = "載入視角",
	["EFFECT_CAT_CAMERA_LOAD_TT"] = "將玩家的視角設定在預先設定好的位置。",
	["EFFECT_CAT_CAMERA_SAVE"] = "保存此視角",
	["EFFECT_CAT_CAMERA_SAVE_TT"] = "將玩家目前的視角保存在五個欄位中的一個。",
	["EFFECT_CAT_CAMERA_SLOT"] = "欄位編號",
	["EFFECT_CAT_CAMERA_SLOT_TT"] = "欄位的編號：由１至５。",
	["EFFECT_CAT_CAMERA_ZOOM_DISTANCE"] = "縮放距離",
	["EFFECT_CAT_CAMERA_ZOOM_IN"] = "鏡頭拉近",
	["EFFECT_CAT_CAMERA_ZOOM_IN_TT"] = "將視角放大一定距離。",
	["EFFECT_CAT_CAMERA_ZOOM_OUT"] = "鏡頭拖遠",
	["EFFECT_CAT_CAMERA_ZOOM_OUT_TT"] = "將視角縮小一定距離。",
	["EFFECT_CAT_CAMPAIGN"] = "活動與任務",
	["EFFECT_CAT_SOUND"] = "音效與音樂",
	["EFFECT_CAT_SPEECH"] = "交談與表情",
	["EFFECT_COOLDOWN_DURATION"] = "冷卻時間",
	["EFFECT_COOLDOWN_DURATION_TT"] = "以秒計算的冷卻時間。",
	["EFFECT_DIALOG_ID"] = "過場動畫ID",
	["EFFECT_DIALOG_QUICK"] = "快速過場動畫",
	["EFFECT_DIALOG_QUICK_TT"] = "快速生成一個只有一個步驟的過場動畫，且自動選擇玩家目標作為對象。",
	["EFFECT_DIALOG_START"] = "開始過場動畫",
	["EFFECT_DIALOG_START_PREVIEW"] = "開始過場動畫 %s。",
	["EFFECT_DIALOG_START_TT"] = "開始過場動畫。若已經有其他過場動畫正在進行，則該動畫會被終止並開始當前的過場動畫。",
	["EFFECT_DISMOUNT"] = "解除坐騎",
	["EFFECT_DISMOUNT_TT"] = "解除角色當前的坐騎。",
	["EFFECT_DISPET"] = "解散戰寵",
	["EFFECT_DISPET_TT"] = "解散當前被召喚的戰寵。",
	["EFFECT_DO_EMOTE"] = "做表情",
	["EFFECT_DO_EMOTE_ANIMATED"] = "動作",
	["EFFECT_DO_EMOTE_OTHER"] = "其它",
	["EFFECT_DO_EMOTE_SPOKEN"] = "說話",
	["EFFECT_DO_EMOTE_TT"] = "使玩家做出一個遊戲內建的表情或動作。",
	["EFFECT_DOC_CLOSE"] = "關閉文件檔",
	["EFFECT_DOC_CLOSE_TT"] = "關閉當前開啟的文件檔。如果當前沒有顯示的文件則不會動作。",
	["EFFECT_DOC_DISPLAY"] = "顯示文件檔",
	["EFFECT_DOC_DISPLAY_TT"] = "對玩家顯示特定的文件檔，如果已經有開啟的文件檔則會取代其顯示。",
	["EFFECT_DOC_ID"] = "文件檔 ID",
	["EFFECT_DOC_ID_TT"] = [=[顯示文件檔

|cffffff00請輸入文件檔的完整ID（母物件和子物件ID）

|cff00ff00H小提醒：用複製貼上比較不容易出錯。]=],
	["EFFECT_ITEM_ADD"] = "添加物品",
	["EFFECT_ITEM_ADD_CRAFTED"] = "製造",
	["EFFECT_ITEM_ADD_CRAFTED_TT"] = "如果勾選此項，且被添加物品是可製造的物品（屬性欄顯示「製造」。）時，物品欄訊息中將顯示「由XXX製造」。XXX便是製造玩家的姓名。",
	["EFFECT_ITEM_ADD_ID"] = "物件ID",
	["EFFECT_ITEM_ADD_ID_TT"] = [=[要添加的物品。

|cffffff00請輸入完整的物品ID（母物件和子物件ID）。

|cff00ff00小提醒：使用複製貼上避免出錯。]=],
	["EFFECT_ITEM_ADD_PREVIEW"] = "添加了 %s 個 %s",
	["EFFECT_ITEM_ADD_QT"] = "數量",
	["EFFECT_ITEM_ADD_QT_TT"] = [=[添加該數量的物品。

|cff00ff00插件會試圖給你該數量的物品，除非包包已滿、或物品本身有特殊限制。]=],
	["EFFECT_ITEM_ADD_TT"] = "將物品放入你的背包。",
	["EFFECT_ITEM_BAG_DURABILITY"] = "損壞／維修容器",
	["EFFECT_ITEM_BAG_DURABILITY_METHOD"] = "類型",
	["EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE"] = "損壞",
	["EFFECT_ITEM_BAG_DURABILITY_METHOD_DAMAGE_TT"] = "損壞母容器，容器的耐久度不能低於零。",
	["EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL"] = "修補",
	["EFFECT_ITEM_BAG_DURABILITY_METHOD_HEAL_TT"] = "修補母容器。容器的耐久度不能高於最大值。",
	["EFFECT_ITEM_BAG_DURABILITY_PREVIEW_1"] = "|cff00ff00修補|cffffff00 容器，使其獲得 %s 點耐久度。",
	["EFFECT_ITEM_BAG_DURABILITY_PREVIEW_2"] = "|cffff0000損壞|cffffff00 容器，使其失去 %s 點耐久度。",
	["EFFECT_ITEM_BAG_DURABILITY_TT"] = [=[損壞或修補母容器的耐久度。

|cff00ff00只有在容器有設置耐久度時才有效。]=],
	["EFFECT_ITEM_BAG_DURABILITY_VALUE"] = "耐久度",
	["EFFECT_ITEM_BAG_DURABILITY_VALUE_TT"] = "損壞／修補母容器耐久度的點數。",
	["EFFECT_ITEM_CONSUME"] = "消耗物品",
	["EFFECT_ITEM_CONSUME_TT"] = "使用物品並將其銷毀。",
	["EFFECT_ITEM_COOLDOWN"] = "開始冷卻時間",
	["EFFECT_ITEM_COOLDOWN_PREVIEW"] = "冷卻時間： %s 秒",
	["EFFECT_ITEM_COOLDOWN_TT"] = "啟動物品設置的冷卻時間。",
	["EFFECT_ITEM_DICE"] = "搖骰",
	["EFFECT_ITEM_DICE_PREVIEW"] = "搖出 %s ",
	["EFFECT_ITEM_DICE_PREVIEW_STORED"] = "搖出 %s 點並保存結果數據為 %s",
	["EFFECT_ITEM_DICE_ROLL"] = "搖骰",
	["EFFECT_ITEM_DICE_ROLL_TT"] = [=[輸入一個如 /trp3 roll 的指令。

|cff00ff00例如：1d20、3d6…]=],
	["EFFECT_ITEM_DICE_ROLL_VAR"] = "變數名稱設定（選填）",
	["EFFECT_ITEM_DICE_ROLL_VAR_TT"] = "用來儲存骰子結果的變數名稱，若不需要則留白即可。",
	["EFFECT_ITEM_DICE_TT"] = "They see me rollin'～they hating～　- Chamillionaire",
	["EFFECT_ITEM_LOOT"] = "顯示／丟下可拾取物品",
	["EFFECT_ITEM_LOOT_DROP"] = "丟下物品",
	["EFFECT_ITEM_LOOT_DROP_TT"] = "把物品落在地上而不是顯示拾取窗口，玩家可以透過「搜索物品」來拾取該物品。",
	["EFFECT_ITEM_LOOT_NAME"] = "來源名稱",
	["EFFECT_ITEM_LOOT_NAME_TT"] = "此為可拾取物品容器之名稱。",
	["EFFECT_ITEM_LOOT_PREVIEW_1"] = "將 %s 落到地上。",
	["EFFECT_ITEM_LOOT_PREVIEW_2"] = "顯示 %s 為可拾取物品。",
	["EFFECT_ITEM_LOOT_SLOT"] = "點擊欄位以設定。",
	["EFFECT_ITEM_LOOT_TT"] = "向玩家顯示一個可拾取物的容器，或在當前位至放下可拾取物。",
	["EFFECT_ITEM_REMOVE"] = "摧毀物品",
	["EFFECT_ITEM_REMOVE_ID_TT"] = [=[要摧毀的物品。

|cffffff00請輸入完整的物品ID（母物件和子物件ID）。

|cff00ff00小提醒：使用複製貼上避免出錯。]=],
	["EFFECT_ITEM_REMOVE_PREVIEW"] = "摧毀了 %s 個 %s",
	["EFFECT_ITEM_REMOVE_QT_TT"] = "摧毁指定數量的物品。",
	["EFFECT_ITEM_REMOVE_TT"] = "從你的背包中摧毀該物品。",
	["EFFECT_ITEM_SOURCE"] = "搜尋",
	["EFFECT_ITEM_SOURCE_1"] = "所有背包",
	["EFFECT_ITEM_SOURCE_1_ADD_TT"] = "向所有角色的背包添加物品。（從主要背包開始。）",
	["EFFECT_ITEM_SOURCE_1_SEARCH_TT"] = "從角色身上的所有容器裡搜索物品。",
	["EFFECT_ITEM_SOURCE_1_TT"] = "從角色身上的所有容器裡搜索物品。",
	["EFFECT_ITEM_SOURCE_2"] = "母容器",
	["EFFECT_ITEM_SOURCE_2_ADD_TT"] = [=[僅能在此物件之母容器（與其任何子容器）之中添加物件。

 | cffff9900 僅作用於此物件於項目中有屬種關係時。]=],
	["EFFECT_ITEM_SOURCE_2_SEARCH_TT"] = [=[僅能在此物件之母容器（與其任何子容器）之中搜索物件。

 | cffff9900 僅作用於此物件於項目中有屬種關係時。]=],
	["EFFECT_ITEM_SOURCE_2_TT"] = [=[僅能在此物件之母容器（與其任何子容器）之中搜索物件。

 | cffff9900 僅作用於此物件於項目中有屬種關係時。]=],
	["EFFECT_ITEM_SOURCE_3"] = "此物件",
	["EFFECT_ITEM_SOURCE_3_ADD_TT"] = [=[僅能在此物件之母容器（與其任何子容器）之中添加物件。

 | cffff9900 僅作用於此物件於項目中有屬種關係、且目標物件為容器時。]=],
	["EFFECT_ITEM_SOURCE_ADD"] = "添加到",
	["EFFECT_ITEM_SOURCE_ID"] = "您可以選擇您想搜索的物品ID，或留白來搜尋所有種類的物件。",
	["EFFECT_ITEM_SOURCE_SEARCH"] = "在…之中搜索",
	["EFFECT_ITEM_USE"] = "容器：使用物件",
	["EFFECT_ITEM_USE_PREVIEW"] = "使用 %s欄位的物品",
	["EFFECT_ITEM_USE_TT"] = [=[使用容器中指定欄位的物品。

|cffff9900僅在工作流程被容器觸發時作用。]=],
	["EFFECT_ITEM_WORKFLOW"] = "運行物件工作流程",
	["EFFECT_ITEM_WORKFLOW_PREVIEW_C"] = "觸發位於子物件 %s 欄位的  %s 工作流程。",
	["EFFECT_ITEM_WORKFLOW_PREVIEW_P"] = "觸發母容器中的 %s 工作流程。",
	["EFFECT_ITEM_WORKFLOW_PREVIEW_S"] = "觸發位於同位物件 %s 欄位的  %s 工作流程。",
	["EFFECT_ITEM_WORKFLOW_TT"] = "對母容器或其特定子物件當中的物品（僅作用於容器。）執行工作流程。",
	["EFFECT_MISSING"] = "此效 (%s) 無法判讀，您應該刪除它。",
	["EFFECT_OPERATION"] = "運算",
	["EFFECT_OPERATION_TYPE"] = "運算方式",
	["EFFECT_OPERATION_TYPE_ADD"] = "加",
	["EFFECT_OPERATION_TYPE_DIV"] = "除以",
	["EFFECT_OPERATION_TYPE_INIT"] = "初始值",
	["EFFECT_OPERATION_TYPE_INIT_TT"] = "在變數沒有值的情況下，設定一個初始值給該變數。",
	["EFFECT_OPERATION_TYPE_MULTIPLY"] = "乘以",
	["EFFECT_OPERATION_TYPE_SET"] = "設定值",
	["EFFECT_OPERATION_TYPE_SET_TT"] = "賦予變數一個值，變數已有當前值也無妨。",
	["EFFECT_OPERATION_TYPE_SUB"] = "減",
	["EFFECT_OPERATION_VALUE"] = "運算值",
	["EFFECT_PROMPT"] = "輸入提示",
	["EFFECT_SHEATH"] = "切換武器",
	["EFFECT_SHEATH_TT"] = "拿出或收起角色的武器。",
	["EFFECT_SOUND_ID_FADEOUT"] = "淡出時間（可選）",
	["EFFECT_SOUND_ID_FADEOUT_TT"] = "音效在停止前會使用幾秒來淡出，留白則音效會立即停止。",
	["EFFECT_SOUND_ID_LOCAL"] = "播放本地音效",
	["EFFECT_SOUND_ID_LOCAL_PREVIEW"] = "播放本地音效 %s，使用頻道 %s ，範圍為 %s 碼半徑圓。",
	["EFFECT_SOUND_ID_LOCAL_STOP"] = "停止播放本地音效",
	["EFFECT_SOUND_ID_LOCAL_STOP_TT"] = "停止角色周遭所有指定頻道內播送的音效。",
	["IT_PU_SOUND"] = "拾取音效",
	["IT_PU_SOUND_1183"] = "背包",
	["IT_PU_SOUND_1184"] = "書本",
	["IT_PU_SOUND_1185"] = "布料",
	["IT_PU_SOUND_1186"] = "食物",
	["IT_PU_SOUND_1187"] = "草藥",
	["IT_PU_SOUND_1188"] = "鍊條",
	["IT_PU_SOUND_1189"] = "食物",
	["IT_PU_SOUND_1190"] = "大型金屬",
	["IT_PU_SOUND_1191"] = "小型金屬",
	["IT_PU_SOUND_1192"] = "紙張",
	["IT_PU_SOUND_1193"] = "指環",
	["IT_PU_SOUND_1194"] = "石頭",
	["IT_PU_SOUND_1195"] = "小型鍊條",
	["IT_PU_SOUND_1196"] = "棍棒",
	["IT_PU_SOUND_1197"] = "液體",
	["IT_PU_SOUND_1198"] = "小型木料",
	["IT_PU_SOUND_1199"] = "大型木料",
	["IT_PU_SOUND_1221"] = "寶石",
	["IT_QUEST"] = "任務道具",
	["IT_QUEST_TT"] = [=[當此物品設計為可以開啟任務的功能時，建議勾選此項在圖示上標示為任務道具。

|cffff7700但就跟其他的外型選項一樣，此選項只是在圖示上的改變，要將此物品真正設定為任務道具仍然必須由物品內部的作業流程來設計。]=],
	["IT_SOULBOUND_TT"] = "此物品放置在道具欄時和玩家綁定，無法交易或放在地上。",
	["IT_STACK"] = "可堆疊",
	["IT_STACK_COUNT"] = "堆疊上限",
	["IT_STACK_COUNT_TT"] = "容器內容一物品欄可堆疊之物品上限，數值必須大於１。",
	["IT_STACK_TT"] = "允許物品被堆疊在同個物品欄。",
	["IT_TRIGGER_ON_DESTROY"] = "摧毀時觸發",
	["IT_TRIGGER_ON_DESTROY_TT"] = [=[當玩家摧毀此疊物品時觸發動作。（將物品拖曳出物品欄並點選銷毀。）

]=],
	["IT_TRIGGER_ON_USE"] = "使用時觸發",
	["IT_TRIGGER_ON_USE_TT"] = [=[當每次玩家使用物品時便觸發。

|cff00ff00別忘了在物品設計主頁勾選物品為可使用。]=],
	["IT_UNIQUE_COUNT"] = "可持有最大數量",
	["IT_UNIQUE_COUNT_TT"] = "每個角色所能持有該物品的最大值，應要大於０。",
	["IT_UNIQUE_TT"] = "當此項啟動時，角色持有此物品的數量就會受到限制。",
	["IT_USE"] = "可使用",
	["IT_USE_TEXT"] = "使用訊息",
	["IT_USE_TEXT_TT"] = "此訊息可用來解釋使用此物品的效果，會顯示在道具提示。（例：閱讀書本、舉起寶石、釋放龍息…等等。）",
	["IT_USE_TT"] = [=[允許此物品被使用。
|cff00ff00您可以在動作流程的頁面編輯使用此物品的效果。]=],
	["IT_WEARABLE"] = "可穿戴",
	["IT_WEARABLE_TT"] = [=[允許此物品被他人觀察並穿戴在角色身上指定的裝備欄位。

|cffff9900若此欄位打勾，則其他玩家在檢視您的角色時將被允許觀察到此物品，即使您沒有將其放置在裝備欄位。]=],
	["ITEM_ID"] = "物品 ID",
	["LOOT"] = "搜刮",
	["LOOT_CONTAINER"] = "搜刮容器",
	["LOOT_DISTANCE"] = "您距離蒐集點太遠了。",
	["MODE_EXPERT"] = "高級",
	["MODE_NORMAL"] = "正常",
	["MODE_QUICK"] = "快速",
	["NPC_EMOTES"] = "表情",
	["NPC_SAYS"] = "說",
	["NPC_WHISPERS"] = "悄悄話",
	["NPC_YELLS"] = "大喊",
	["OP_COMP_GREATER"] = "大於",
	["OP_COMP_GREATER_OR_EQUALS"] = "大於等於",
	["OP_COMP_LESSER"] = "小於",
	["OP_COMP_LESSER_OR_EQUALS"] = "小於等於",
	["OP_COMP_NEQUALS"] = "不等於",
	["OP_CURRENT"] = "當前數值",
	["OP_FAIL"] = "失敗訊息",
	["OP_NUMERIC"] = "數值"
});
