
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
    Pandoc = function(doc)
      if not quarto.doc.isFormat("latex") then
        return doc
      end
      for i, el in pairs(doc.blocks) do
        if el.t == "Header" and pandoc.utils.stringify(el.content) == "References" then
          local bibname = "sample-base"
          local bibliography = pandoc.RawBlock("latex", "\\bibliographystyle{ACM-Reference-Format}\n\\bibliography{" .. bibname .. "}")
          -- latex inserts the new section anyway
          table.remove(doc.blocks, i)
          table.insert(doc.blocks, i, bibliography)
          break
        end
      end
      for i, el in pairs(doc.blocks) do
        if el.t == "Header" and pandoc.utils.stringify(el.content) == "Appendix" then
          local appendix = pandoc.RawBlock("latex", "\\appendix")
          table.remove(doc.blocks, i)
          table.insert(doc.blocks, i, appendix)
          break
        end
      end
      return doc
    end
  }
}
