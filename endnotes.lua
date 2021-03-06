SILE.require("packages/footnotes")
SILE.scratch.endnotes = {}

SILE.registerCommand("endnote", function (options, content)
  SILE.call("footnotemark")
  local material = function ()
    SILE.process(content)
  end
  local counter = SILE.formatCounter(SILE.scratch.counters.footnote)
  SILE.scratch.endnotes[#SILE.scratch.endnotes+1] = function ()
    return counter, material
  end
  SILE.scratch.counters.footnote.value = SILE.scratch.counters.footnote.value + 1
end)

SILE.registerCommand("endnote:counter", function (options, content)
  SILE.call("noindent")
  SILE.typesetter:typeset(options.value..".")
end)

SILE.registerCommand("endnotes", function (options, content)
  local indent = "1.5em"
  SILE.settings.temporarily(function ()
    SILE.settings.set("document.lskip", SILE.nodefactory.newGlue(indent))
    for i = 1, #SILE.scratch.endnotes do
      local counter, material = SILE.scratch.endnotes[i]()
      SILE.Commands["footnote:font"]({}, function ()
        SILE.typesetter:pushGlue({ width = 0 - SILE.length.parse(indent) })
        SILE.Commands["rebox"]({ width = indent }, function ()
          SILE.call("endnote:counter", { value = counter })
        end)
        SILE.call("raggedright", {}, function ()
          material()
        end)
      end)
    end
  end)
  SILE.scratch.endnotes = {}
  SILE.scratch.counters.footnote.value = 1
end)

local class = SILE.documentState.documentClass
local originalfinish = class.finish
class.finish = function ()
  if #SILE.scratch.endnotes >= 1 then
    SILE.call("endnotes")
  end
  return originalfinish(class)
end
