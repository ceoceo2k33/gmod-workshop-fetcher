module("WorkshopFetcher", package.seeall)

do
    ---@class SteamWorkshopChild
    ---@field publishedfileid string
    ---@field sortorder number
    ---@field filetype number

    ---@class SteamCollectionDetail
    ---@field publishedfileid string
    ---@field result number
    ---@field children SteamWorkshopChild[]

    ---@class SteamCollectionResponse
    ---@field result number
    ---@field resultcount number
    ---@field collectiondetails SteamCollectionDetail[]

    ---@class SteamAPIResponse
    ---@field response SteamCollectionResponse

    ---@class WorkshopFetcher
    ---@field STEAM_API_URL string
    ---@field ParseResponse fun(steam: SteamAPIResponse): string[]?
    ---@field BuildRequestBody fun(count: number, collectionID: number): table
    ---@field OnAPISuccess fun(tbl: SteamAPIResponse)
    ---@field OnAPIError fun(err: any)
    ---@field AddCollection fun(collectionID: number)
end

local ipairs = ipairs
local tInsert = table.insert
local tostring = tostring
local Post = http.Post
local JSONToTable = util.JSONToTable
local print = print
local resource_AddWorkshop = resource.AddWorkshop

STEAM_API_URL =
    "https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/"

---@param steam SteamAPIResponse
---@return string[]?
function ParseResponse(steam)
    assert(steam.response ~= nil, "cannot find required field response!")

    local workshopIDs = {}
    for _, collection in ipairs(steam.response.collectiondetails) do
        if collection.children then
            for _, child in ipairs(collection.children) do
                tInsert(workshopIDs, child.publishedfileid)
            end
        end
    end

    if #workshopIDs ~= 0 then
        return workshopIDs
    else
        ErrorNoHalt("[WorkshopFetcher] Parse returned empty table\n")
        return nil
    end
end

---@param collectionCount number
---@param workshopID number
---@return table body
function BuildRequestBody(collectionCount, workshopID)
    return {
        ["collectioncount"] = tostring(collectionCount),
        ["publishedfileids[0]"] = tostring(workshopID),
    }
end

---@param apiResponse SteamAPIResponse
function OnAPISuccess(apiResponse)
    local ids = ParseResponse(apiResponse)

    if ids then
        print("[WorkshopFetcher] Loaded " .. #ids .. " addons")
        for _, id in ipairs(ids) do
            resource_AddWorkshop(id)
            print("[WorkshopFetcher] Added workshop ID: " .. id)
        end
    end
end

---@param err string
function OnAPIError(err)
    ErrorNoHalt("[WorkshopFetcher] Error: " .. tostring(err) .. "\n")
end

---@param collectionID number
function AddCollection(collectionID)
    local body = BuildRequestBody(1, collectionID)

    Post(STEAM_API_URL, body, function(apiResponse)
        OnAPISuccess(JSONToTable(apiResponse))
    end, function(err)
        OnAPIError(err)
    end, { ["Content-Type"] = "application/x-www-form-urlencoded" })
end
