if FORMAT:match 'html' then
  function Note(el)
    return el
  end
  
  function Div(el)
    if el.classes:includes('footnotes') then
      -- Process footnote numbers in the footnote list
      return pandoc.walk_block(el, {
        Str = function(str)
          local num = str.text:match('^(%d+)%.$')
          if num then
            local letter = string.char(96 + tonumber(num))
            return pandoc.Str(letter .. '.')
          end
          return str
        end
      })
    end
    return el
  end
end
