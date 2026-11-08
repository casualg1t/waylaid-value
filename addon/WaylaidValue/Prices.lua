local _, A = ...
local function valid(value)
  return type(value) == "number" and value > 0 and value < math.huge and value == value
end
function A.PriceReader(mode)
  local cache, errors, stats = {}, {}, {}
  local function tsm(id)
    if not (TSM_API and type(TSM_API.GetCustomPriceValue) == "function") then return end
    local ok, value = pcall(TSM_API.GetCustomPriceValue, "dbminbuyout", "i:" .. id)
    if not ok then errors.TSM = true end
    if ok and valid(value) then return {value=value, source="TSM minimum buyout", age=nil} end
  end
  local function auctionator(id)
    local api = Auctionator and Auctionator.API and Auctionator.API.v1
    if not (api and type(api.GetAuctionPriceByItemID) == "function") then return end
    local ok, value = pcall(api.GetAuctionPriceByItemID, "WaylaidValue", id)
    if not ok then errors.Auctionator = true end
    if ok and valid(value) then
      local age
      if type(api.GetAuctionAgeByItemID) == "function" then
        local ageOK, days = pcall(api.GetAuctionAgeByItemID, "WaylaidValue", id)
        if ageOK and type(days) == "number" and days >= 0 and days < math.huge then age = days end
      end
      return {value=value, source="Auctionator last scan", age=age}
    end
  end
  return function(id)
    if cache[id] == nil then
      local price
      if mode == "TSM" then price = tsm(id)
      elseif mode == "Auctionator" then price = auctionator(id)
      else price = tsm(id) or auctionator(id) end
      cache[id] = price or false
      if price then
        if price.source=="TSM minimum buyout" then stats.tsm=true else stats.auctionator=true end
        if price.age then stats.maxAge=math.max(stats.maxAge or 0,price.age)end
      end
    end
    return cache[id] or nil
  end, errors, stats
end
function A.ProviderStatus()
  local tsm = TSM_API and type(TSM_API.GetCustomPriceValue) == "function"
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  local atr = api and type(api.GetAuctionPriceByItemID) == "function"
  return tsm, atr
end
