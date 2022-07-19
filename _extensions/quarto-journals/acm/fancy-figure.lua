function has_class(el, class)
  if el.attr == nil then
    return nil
  end
  for i,v in ipairs(el.attr.classes) do
    if v == class then
      return true
    end
  end
  return false
end

function find_node(el, predicate)
  if el.content == nil then
    return nil
  end
  for i, v in ipairs(el.content) do
    if predicate(v) then
      return v
    end
    if v.content ~= nil then
      local r = find_node(v, predicate)
      if r ~= nil then
        return r
      end
    end
  end
  return nil
end

function get_block_with_class(el, class)
  return find_node(el, function(el)
    return has_class(el, class)
  end)
end

function get_image(el)
  return find_node(el, function (v)
    return v.t == "Image"
  end)
end

function attribute(el, name, default)
  for k,v in pairs(el.attr.attributes) do
    if k == name then
      return v
    end
  end
  return default
end

return {
  {
    Image = function(image)
      local description = attribute(image, "fig-alt", nil)
      if description == nil then
        return image
      end
      description = pandoc.write(pandoc.Pandoc({description}), "latex")
      if quarto.doc.isFormat("latex") then
        local caption = pandoc.write(pandoc.Pandoc({image.caption}), "latex")
        print("Here")
        local blockStr = "\\begin{figure}\n" ..
          "{\\centering \\includegraphics{" .. image.src .. "}}\n" ..
          "\\caption{" .. caption .. "}\n\\Description{"
          .. description .. "}\n\\end{figure}\n"
        print(blockStr)
        return {pandoc.RawInline("latex", blockStr)}
      else
        image.attr.attributes["alt"] = description
        image.attr.attributes["fig-alt"] = nil
        return image
      end
    end
--    Div = function(div)
--      print("Found a div")
--      if not has_class(div, "figure-with-description") then
--        return div
--      end
--      local description = get_block_with_class(div, "description")
--      local image = get_image(div)
--      if description == nil then
--        return image
--      end
--      local caption = pandoc.write(pandoc.Pandoc({image.caption}), "latex")
--      description = pandoc.write(pandoc.Pandoc({description}), "latex")
--      if quarto.doc.isFormat("latex") then
--        return pandoc.RawBlock("latex",
--          "\\begin{figure}\n" ..
--          "{\\centering \\includegraphics{" .. image.src .. "}}\n" ..
--          "\\caption{" .. caption .. "}\n\\Description{"
--          .. description .. "}\n\\end{figure}\n")
--      elseif quarto.doc.isFormat("html") then
--        return pandoc.RawBlock("html", "<img alt=\"" .. description .. "\" src=\"" .. image.src .. "\"/>")
--      end
--    end
  }
}
