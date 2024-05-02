local loc = TRP3_API.loc;

-------------

local CAMERA_MIN_ZOOM_DISTANCE = 1;
local CAMERA_MAX_ZOOM_DISTANCE = 10;

local CAMERA_DEFAULT_ZOOM_DISTANCE = 3.8;
local CAMERA_DEFAULT_DISTANCE = 4;
local CAMERA_DEFAULT_ORIENTATION = {
    Yaw = math.pi,
    Pitch = 0,
    Roll = 0,
};
local CAMERA_DEFAULT_FOV_VERTICAL = 0.6;
local CAMERA_DEFAULT_FOV_DIAGONAL = CAMERA_DEFAULT_FOV_VERTICAL * math.sqrt(1 + (1/1)^2);

-------------

local function debugassert(condition, message)
    if TRP3_API.globals.DEBUG_MODE then
        assert(condition, message);
    end
end

-------------

TRP3_InventoryActorMixin = CreateFromMixins(ModelSceneActorMixin);

function TRP3_InventoryActorMixin:GetScaledActiveBoundingBox()
    local scale = self:GetScale();
    local x1, y1, z1, x2, y2, z2 = self:GetActiveBoundingBox();
    if x1 ~= nil then
        return x1 * scale, y1 * scale, z1 * scale, x2 * scale, y2 * scale, z2 * scale;
    end
end

------------

TRP3_InventorySceneMixin = {};

TRP3_InventorySceneMixin.DefaultRaceActorOffsets = {
    Default = {
        x = 0,
        y = 0,
        z = 0.15 -- TODO: scale this based on model height
    },
};

TRP3_InventorySceneMixin.PlayerActorDefaults = {
    Scale = 1,
    Yaw = -0.5,
};

TRP3_InventorySceneMixin.StaticTags = {
    PLAYER_SELF = "player-self",
    PLAYER_OTHER = "player-other",
};

function TRP3_InventorySceneMixin:OnLoad()
    self.Cameras = {};
    self.TagToActor = {};
    self.TagToCamera = {};
    self.ActorTemplate = "TRP3_InventoryActorTemplate";
    self.ActiveCamera = nil;

    self.FocusedActorTag = nil;

    self:SetViewInsets(0, 0, 0, 0);
end

function TRP3_InventorySceneMixin:OnShow()
end

function TRP3_InventorySceneMixin:OnEnter()
end

function TRP3_InventorySceneMixin:OnLeave()
end

function TRP3_InventorySceneMixin:OnMouseDown(button)
    local camera = self:GetActiveCamera();
    if camera then
        camera:OnMouseDown(button);
    end
end

function TRP3_InventorySceneMixin:OnMouseUp(button)
    local camera = self:GetActiveCamera();
    if camera then
        camera:OnMouseUp(button);
    end
end

function TRP3_InventorySceneMixin:OnUpdate(deltaTime)
    local camera = self:GetActiveCamera();
    if camera then
        camera:OnUpdate(deltaTime);
    end
end

function TRP3_InventorySceneMixin:OnActorAdded()
    if not self:GetActiveCamera() then
        self:GetOrCreateCameraByTag("primary");
        self:ResetActiveCamera();
    end
end

function TRP3_InventorySceneMixin:IsLeftMouseButtonDown()
    return false;
end

function TRP3_InventorySceneMixin:IsRightMouseButtonDown()
    return false;
end

------

function TRP3_InventorySceneMixin:SetWeightText(text)
    self.WeightText:SetText(text);
end

function TRP3_InventorySceneMixin:SetValueText(text)
    self.ValueText:SetText(text);
end

function TRP3_InventorySceneMixin:SetLoading(isLoading)
    self.IsLoading = isLoading;

    if self.IsLoading then
        self.Loading:SetText("..." .. loc.INV_PAGE_WAIT .. "...");
        self.Loading:Show();
    end
end

------

function TRP3_InventorySceneMixin:CreateCamera()
    local modelSceneCameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(1);
	if modelSceneCameraInfo then
		local camera = CameraRegistry:CreateCameraByType("OrbitCamera");
		if camera then
            self:AddCamera(camera);
			camera:ApplyFromModelSceneCameraInfo(modelSceneCameraInfo, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD);
            if not self:HasActiveCamera() then
                self:SetActiveCamera(camera);
            end
            camera.panningXOffset, camera.panningYOffset = 0, 0;
            return camera;
		end
	end
end

function TRP3_InventorySceneMixin:GetOrCreateCameraByTag(tag)
    debugassert(tag, "Camera tag is required");

    local camera = self.TagToCamera[tag];
    if not camera then
        camera = self:CreateCamera();
    end

    self.TagToCamera[tag] = camera;
    return camera;
end

function TRP3_InventorySceneMixin:AddCamera(camera)
    table.insert(self.Cameras, camera);

    camera:SetOwningScene(self);
    return camera;
end

function TRP3_InventorySceneMixin:HasActiveCamera()
    return self:GetActiveCamera() ~= nil;
end

function TRP3_InventorySceneMixin:GetActiveCamera()
    return self.ActiveCamera;
end

function TRP3_InventorySceneMixin:SetActiveCamera(camera)
    local oldCamera = self:GetActiveCamera();
    if camera ~= oldCamera then
        if oldCamera then
            oldCamera:OnDeactivated();
        end

        self.ActiveCamera = camera;

        if self.ActiveCamera then
            self.ActiveCamera:OnActivated();
            self.ActiveCamera:SetRightMouseButtonXMode(ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL, false);
            self.ActiveCamera:SetRightMouseButtonYMode(ORBIT_CAMERA_MOUSE_PAN_VERTICAL, false);
        end
    end
end

function TRP3_InventorySceneMixin:ResetActiveCamera()
    local camera = self:GetActiveCamera();
    if camera then
        camera:SetMinZoomDistance(CAMERA_MIN_ZOOM_DISTANCE);
        camera:SetMaxZoomDistance(CAMERA_MAX_ZOOM_DISTANCE);
        camera:SetZoomDistance(CAMERA_DEFAULT_ZOOM_DISTANCE);

        local cameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(1);
        camera:SetTarget(cameraInfo.target.x, cameraInfo.target.y, cameraInfo.target.z);

        self:SetCameraPosition(CAMERA_DEFAULT_DISTANCE, 0, 0);
        self:SetCameraOrientationByYawPitchRoll(CAMERA_DEFAULT_ORIENTATION.Yaw, CAMERA_DEFAULT_ORIENTATION.Pitch, CAMERA_DEFAULT_ORIENTATION.Roll);
        self:SetCameraFieldOfView(CAMERA_DEFAULT_FOV_DIAGONAL);

        camera:SnapAllInterpolatedValues();
        camera:UpdateCameraOrientationAndPosition();
    end
end

function TRP3_InventorySceneMixin:ReleaseAllCameras()
    self:SetActiveCamera(nil);
    for i = #self.Cameras, 1, -1 do
        self.Cameras[i]:SetOwningScene(nil);
        self.Cameras[i] = nil;
    end
    self.TagToCamera = {};
end

function TRP3_InventorySceneMixin:SetCameraZoom(zoom)
    local camera = self:GetActiveCamera();
    debugassert(camera, "No active camera");
    if camera then
        camera:SetZoomDistance(zoom);
        camera:SnapToTargetInterpolationZoom();
    end
end

------

local function OnReleaseActor(actorPool, actor)
    ActorPool_HideAndClearModel(actorPool, actor);
end

function TRP3_InventorySceneMixin:AcquireActor()
    if not self.ActorPool then
        self.ActorPool = CreateActorPool(self, self.ActorTemplate, OnReleaseActor);
    end

    local actor = self.ActorPool:Acquire();
    debugassert(actor, "Unable to create actor from ActorPool");
    return actor;
end

function TRP3_InventorySceneMixin:ReleaseActor(actor)
    if not self.ActorPool then
        return;
    end

    self.TagToActor[actor.Tag] = nil;
    return self.ActorPool:Release(actor);
end

function TRP3_InventorySceneMixin:ReleaseAllActors()
    if self.ActorPool then
        self.ActorPool:ReleaseAll();
        self.TagToActor = {};
    end
end

function TRP3_InventorySceneMixin:GetActorByTag(tag)
    return self.TagToActor[tag];
end

function TRP3_InventorySceneMixin:GetOrCreateActorByTag(tag)
    debugassert(tag, "Actor tag required");

    local actor = self:GetActorByTag(tag);
    if not actor then
        actor = self:AcquireActor();
        self.TagToActor[tag] = actor;
    end

    actor.Tag = tag;

    self:SetFocusedActorTag(tag);

    return actor;
end

function TRP3_InventorySceneMixin:GetTagForUnitToken(unitToken)
    local tag = unitToken == "player" and self.StaticTags.PLAYER_SELF or self.StaticTags.PLAYER_OTHER;
    return tag;
end

function TRP3_InventorySceneMixin:SetFocusedActorTag(tag)
    self.FocusedActorTag = tag;
end

function TRP3_InventorySceneMixin:GetFocusedActor()
    return self:GetActorByTag(self.FocusedActorTag);
end

------

function TRP3_InventorySceneMixin:GetActorStartPosition()
    return self.DefaultRaceActorOffsets.Default;
end

------

function TRP3_InventorySceneMixin:ShouldUsePlayerNativeForm()
    local useNativeForm = true
    local _, inAlterateForm = C_PlayerInfo.GetAlternateFormInfo();
    local _, raceFileName = UnitRace("player");
    if raceFileName == "Dracthyr" or raceFileName == "Worgen" then
        useNativeForm = not inAlterateForm;
    end
    return useNativeForm;
end

---@param unitToken UnitToken
---@param sheatheWeapons boolean
---@param autoDress boolean
---@param hideWeapons boolean
---@param useNativeForm boolean
---@param holdBowString boolean
function TRP3_InventorySceneMixin:SetUnit(unitToken, sheatheWeapons, autoDress, hideWeapons, useNativeForm, holdBowString)
    local tag = self:GetTagForUnitToken(unitToken);
    local actor = self:GetOrCreateActorByTag(tag);
    debugassert(actor, "Missing actor");

    if unitToken == "player" and useNativeForm == nil then
        useNativeForm = self:ShouldUsePlayerNativeForm();
    end

    actor:SetModelByUnit(unitToken, sheatheWeapons, autoDress, hideWeapons, useNativeForm, holdBowString);
    actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);

    self:ResetModel(actor);
    self:OnActorAdded();

    actor:Show();
    return actor;
end

function TRP3_InventorySceneMixin:ResetModel(actor)
    actor = actor or self:GetFocusedActor();
    debugassert(actor, "Missing actor");

    actor:SetYaw(self.PlayerActorDefaults.Yaw);
    actor:SetScale(self.PlayerActorDefaults.Scale);
    actor:SetAnimation(0, 0);

    local offsets = self:GetActorStartPosition();
    actor:SetPosition(offsets.x, offsets.y, offsets.z);
    actor:MarkScaleDirty();
end

function TRP3_InventorySceneMixin:ClearScene()
    self:ReleaseAllCameras();
    self:ReleaseAllActors();
end

function TRP3_InventorySceneMixin:InspectUnit(unitToken, ...)
    self:ClearScene();
    self:SetUnit(unitToken, ...);

    if unitToken == "player" then
        self.Title:Hide();
        self.Loading:Hide();
    end
end