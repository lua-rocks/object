--[[ Öбъект - Базовый суперкласс, реализующиий Ö𑫁𐩨 ]]
local Object = {
  classname = 'Object', -- имя класса
  super = {} -- прото-класс
}


--[[ Добавляет все метаметоды из себя и всех родителей в указанную таблицу
Соблюдает порядок иерархии: Rect > Point > Object.
> self (Object) откуда применять
> apply_here (table) куда применять
]]
local function applyMetaFromParents(self, apply_here)
  local applied = {}
  self:each('meta', function(key, value)
    if not applied[key] then
      apply_here[key] = value
      applied[key] = true
    end
  end)
end


--[[ Добавляет метаметоды __index из себя или ближайшего родителя в таблицу
> self (Object) откуда применять
> apply_here (table) куда применять
]]
local function applyMetaIndexFromParents(self, apply_here)
  if self.__index == nil then apply_here.__index = self return end

  apply_here.__index = function(instance, key)
    local t = type(self.__index)
    local v
    if t == 'function' then v = self.__index(instance, key)
      elseif t == 'table' then v = self.__index[key]
      else error("'__index' must be a function or table", 2)
    end
    if v ~= nil then return v end
    return self[key]
  end
end


--[[ Создаёт экземпляр класса
Простой вызов класса как функции делает то же самое.
> ... (any) [] аргументы, передаваемые в init
]]
function Object:new(...)
  local obj_mt = {
    __index = self,
    __tostring = function() return 'instance of ' .. self.classname end
  }
  local obj = setmetatable({}, obj_mt)
  obj:init(...)
  applyMetaFromParents(self, obj_mt)
  applyMetaIndexFromParents(self, obj_mt)
  return setmetatable(obj, obj_mt)
end


--[[ Инициализирует класс
По умолчанию объект принимает таблицу с полями и применяет их к себе,
но предпологается, что потомки заменят этот метод на другой.
> fields (table) [] новые поля
]]
function Object:init(fields)
  local t = type(fields)
  if t ~= 'table' then
    error("'Object:init()' expected a table, but got " .. t, 3)
  end
  for key, value in pairs(fields) do self[key] = value end
end


--[[ Создаёт новый класс путём наследования
> name (string) имя нового класса
> ... (table|Object) [] дополнительные свойства
< cls (Object)
]]
function Object:extend(name, ...)
  if type(name) ~= 'string' then error('class must have a name', 2) end

  local cls, cls_mt = {}, {}
  for key, value in pairs(getmetatable(self)) do cls_mt[key] = value end
  for _, extra in ipairs{...} do
    for key, value in pairs(extra) do cls[key] = value end
  end

  cls.classname = name
  cls.super = self
  cls_mt.__index = self
  cls_mt.__tostring = function() return 'class ' .. name end
  setmetatable(cls, cls_mt)
  return cls
end


--[[ Устанавливает себе чужие методы
> ... (table|Object) методы
]]
function Object:implement(...)
  for _, cls in pairs({...}) do
    for key, value in pairs(cls) do
      if self[key] == nil and type(value) == 'function' then
        self[key] = value
      end
    end
  end
end


--[[ Возвращает дальность родства между собой и проверочным классом
Вернёт `0` если сам к нему принадлежит или `false`, если родства нет.
> Test (string|Object) проверочный класс
> limit (integer) [] глубина проверки (по умолчанию без ограничений)
< kinship (integer|boolean)
]]
function Object:has(Test, limit)
  local t = type(Test)
  local searchedName
  if t == 'string' then
    searchedName = Test
  else
    searchedName = Test.classname
    if t ~= 'table' then return false end
  end

  local i = 0
  while self.super do
    if self.classname == searchedName then return i end
    if i == limit then return false end
    i = i + 1
    self = self.super
  end
  return false
end


--[[ Определяет принадлежность себя к классу
> Test (string|Object) класс для проверки
< result (boolean) результат проверки
]]
function Object:is(Test)
  return self:has(Test, 0) == 0
end


--[[ Перебирает все свои и унаследованные элементы, выполняя действие над каждым
Может останавливаться на полях, метаполях, методах или всём.
Всегда пропускает базовые поля и методы, присущие классу Object.
> etype ("field(s)"|"method(s)"|"meta"|"all") тип элемента
> action (function:key,value,...) действие над каждым элементом
> ... [] дополнительные аргументы для действия
< result (integer=table}) результаты всех действий
]]
function Object:each(etype, action, ...)
  local results, checks = {}, {}
  local function meta(key) return key:find('__') == 1 end
  local function func(value) return type(value) == 'function' end
  function checks.all() return true end
  function checks.meta(key) return meta(key) end
  function checks.method(key, value) return func(value) and not meta(key) end
  function checks.field(key, value) return not func(value) and not meta(key) end
  checks.methods = checks.method
  checks.fields = checks.field
  if not checks[etype] then error('wrong etype: ' .. tostring(etype)) end
  while self ~= Object do
    for key, value in pairs(self) do
      if not Object[key] and checks[etype](key, value) then
        table.insert(results, { action(key, value, ...) })
      end
    end
    self = self.super
  end
  return results
end


return setmetatable(Object, {
  __tostring = function(self) return 'class ' .. self.classname end,
  __call = Object.new
})
