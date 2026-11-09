local _, A = ...
function A.Rank(crates, readPrice, includeExpert, level)
  local rows = {}
  for _, crate in ipairs(crates) do
    if not crate.provisional or includeExpert then
      local row = {crate=crate, price=readPrice(crate.id), options={}, missing=0}
      for _, option in ipairs(crate.options) do
        local price = readPrice(option.id)
        local bundle = {item=option, price=price, total=price and price.value * option.quantity}
        row.options[#row.options+1] = bundle
        if not price then row.missing = row.missing+1 end
        if bundle.total and (not row.best or bundle.total < row.best.total or
          (bundle.total == row.best.total and option.id < row.best.item.id)) then row.best = bundle end
      end
      table.sort(row.options, function(a,b)
        if a.total ~= b.total then return (a.total or math.huge) < (b.total or math.huge) end
        return a.item.id < b.item.id
      end)
      if level and level < crate.level then row.reason = "Requires level " .. crate.level
      elseif not crate.favor then row.reason = "Favor reward unknown"
      elseif not row.price then row.reason = "Crate price missing"
      elseif not row.best then row.reason = "Filling prices missing"
      else
        row.gross = row.price.value + row.best.total
        row.silver = crate.favor * 50 -- documented 0.5 silver per base Favor
        row.net = row.gross - row.silver
        row.ratio = row.net / crate.favor
      end
      rows[#rows+1] = row
    end
  end
  table.sort(rows, function(a,b)
    if a.ratio ~= b.ratio then return (a.ratio or math.huge) < (b.ratio or math.huge) end
    return a.crate.id < b.crate.id
  end)
  return rows
end
function A.Money(copper,colored)
  if copper == nil then return "--" end
  local sign = copper < 0 and "-" or ""
  copper = math.floor(math.abs(copper)+0.5)
  local gold, silver, coin = math.floor(copper/10000), math.floor(copper/100)%100, copper%100
  if colored then
   local parts={}
   if gold>0 then parts[#parts+1]=gold..'|cffffd700g|r'end
   if gold>0 or silver>0 then parts[#parts+1]=(gold>0 and string.format('%02d',silver)or tostring(silver))..'|cffc7c7cfs|r'end
   parts[#parts+1]=(gold>0 or silver>0)and(string.format('%02d',coin)..'|cffeda55fc|r')or(coin..'|cffeda55fc|r')
   return sign..table.concat(parts,' ')
  end
  if gold > 0 then return string.format("%s%dg %ds %dc",sign,gold,silver,coin) end
  return string.format("%s%ds %dc",sign,silver,coin)
end
