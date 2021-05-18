# Öbject - Base superclass that implements Ö𑫁𐊯

**Object:new** (...)

> Creates an instance of the class
>
> &rarr; **...** (any) *[optional]* `arguments passed to init`

**Object:init** (fields)

> Initializes the class
>
> &rarr; **fields** (table) *[optional]* `new fields`

**Object:extend** (name\*, ...) : cls

> Creates a new class by inheritance
>
> &rarr; **name** (string) `new class name`
> &rarr; **...** (table|Object) *[optional]* `additional properties`
>
> &larr; **cls** (Object)

**Object:implement** (...\*)

> Sets someone else's methods
>
> &rarr; **...** (table|Object) `methods`

**Object:has** (Test\*, limit) : kinship

> Returns the range of kinship between itself and the checking class
>
> &rarr; **Test** (string|Object) `test class`
> &rarr; **limit** (integer) *[optional]* `check depth (default unlimited)`
>
> &larr; **kinship** (integer|boolean)

**Object:is** (Test\*) : result

> Identifies affiliation to class
>
> &rarr; **Test** (string|Object)
>
> &larr; **result** (boolean)

**Object:each** (etype\*, action\*, ...) : result

> Loops through all elements, performing an action on each
>
> &rarr; **etype** ("field(s) `"|"method(s)"|"meta"|"all") item type`
> &rarr; **action** (function:key,value,...) `action on each element`
> &rarr; **...** *[optional]* `additional arguments for the action`
>
> &larr; **result** (integer=table}) `results of all actions`

<details>
  <summary>Internal fields</summary>

  **applyMetaFromParents** (Point\*, self\*, apply_here\*)

  > Adds all metamethods from itself and all parents to the specified table
  >
  > &rarr; **Point** `> Object.`
  > &rarr; **self** (Object) `apply from`
  > &rarr; **apply_here** (table) `apply to`

  **applyMetaIndexFromParents** (self\*, apply_here\*)

  > Adds __index metamethods from itself or closest parent to the table
  >
  > &rarr; **self** (Object) `apply from`
  > &rarr; **apply_here** (table) `apply to`

</details>
