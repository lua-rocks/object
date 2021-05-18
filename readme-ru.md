# Öbject - Базовый суперкласс, реализующиий Ö𑫁𐩨

**Object:new** (...)

> Создаёт экземпляр класса
>
> &rarr; **...** (any) *[optional]* `аргументы, передаваемые в init`

**Object:init** (fields)

> Инициализирует класс
>
> &rarr; **fields** (table) *[optional]* `новые поля`

**Object:extend** (name\*, ...) : cls

> Создаёт новый класс путём наследования
>
> &rarr; **name** (string) `имя нового класса`
> &rarr; **...** (table|Object) *[optional]* `дополнительные свойства`
>
> &larr; **cls** (Object)

**Object:implement** (...\*)

> Устанавливает себе чужие методы
>
> &rarr; **...** (table|Object) `методы`

**Object:has** (Test\*, limit) : kinship

> Возвращает дальность родства между собой и проверочным классом
>
> &rarr; **Test** (string|Object) `проверочный класс`
> &rarr; **limit** (integer) *[optional]* `глубина проверки (по умолчанию без ограничений)`
>
> &larr; **kinship** (integer|boolean)

**Object:is** (Test\*) : result

> Определяет принадлежность себя к классу
>
> &rarr; **Test** (string|Object) `класс для проверки`
>
> &larr; **result** (boolean) `результат проверки`

**Object:each** (etype\*, action\*, ...) : result

> Перебирает все свои и унаследованные элементы, выполняя действие над каждым
>
> &rarr; **etype** ("field(s) `"|"method(s)"|"meta"|"all") тип элемента`
> &rarr; **action** (function:key,value,...) `действие над каждым элементом`
> &rarr; **...** *[optional]* `дополнительные аргументы для действия`
>
> &larr; **result** (integer=table}) `результаты всех действий`

<details>
  <summary>Внутренние поля</summary>

  **applyMetaFromParents** (Point\*, self\*, apply_here\*)

  > Добавляет все метаметоды из себя и всех родителей в указанную таблицу
  >
  > &rarr; **Point** `> Object.`
  > &rarr; **self** (Object) `откуда применять`
  > &rarr; **apply_here** (table) `куда применять`

  **applyMetaIndexFromParents** (self\*, apply_here\*)

  > Добавляет метаметоды __index из себя или ближайшего родителя в таблицу
  >
  > &rarr; **self** (Object) `откуда применять`
  > &rarr; **apply_here** (table) `куда применять`

</details>
