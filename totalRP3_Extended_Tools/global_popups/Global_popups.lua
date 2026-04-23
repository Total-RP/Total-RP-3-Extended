local _, addon = ...
local loc = TRP3_API.loc;

addon.global_popups = {};

function addon.global_popups.initialize()
	TRP3_Tools_ObjectsBrowser:Initialize();
	TRP3_Tools_EmotesBrowser:Initialize();
	TRP3_Tools_VariableInspector:Initialize();
	TRP3_Tools_TextEditor:Initialize();
	TRP3_Tools_NoteEditor:Initialize();
end
