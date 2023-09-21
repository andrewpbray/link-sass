
-- Replaces references to sass variables with their values found in the scss file.

--===================--
-- Utility Functions --
--===================--

local function string_to_table(str)
  local lines = {}
  
  for line in str:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  
  return(lines)
end

-- recursive function to resolve variables that reference other variables
local function resolve_ref(v, tab)
  local v_out = nil
  local var_ref = string.match(v, '%$[%w%-_]+')
    
  for tab_k,tab_v in pairs(tab) do
    if var_ref == tab_k then
      v_out = tab_v
    end
  end
    
  if v_out == nil then
    error("Your scss file has a variable that references another variable that cannot be found.")
  end
    
  if string.sub(v_out, 1, 1) == "$" then
    v_out = resolve_ref(v_out, tab)
  end
  return(v_out)
end


--================--
-- Core Functions --
--================--

local sass_tab = {}

function fetch_sass(meta)
  
  local theme_path = meta.theme[1].text
  local scss_tab = string_to_table(io.open(theme_path, "r"):read("*all"))
  
  local is_sass_sec = false
  
  sass_vars = {}
  
  -- create table of sass variables as they exist in the theme file
  for _,line_text in ipairs(scss_tab) do
    if string.match(line_text, "scss:rules") ~= nil then
      is_sass_sec = false
    end
    if is_sass_sec then
        local var_part = string.match(line_text, '(%$[^:]+)')
        local val_part = string.match(line_text, ": (.+)")
        local val_part = string.gsub(val_part, '"', "'")
        if var_part ~= nil and val_part ~= nil then
          sass_vars[var_part] = val_part    
        end
    end
    if string.match(line_text, "scss:defaults") ~= nil then
      is_sass_sec = true
    end
  end
  
  -- remove CSS declarations
  for k,v in pairs(sass_vars) do
    no_default = string.gsub(v, "%s*!default", "")
    sass_vars[k] = string.gsub(no_default, "%s*!important", "")
  end
  
  -- resolve all relative references (i.e. no $theme-blue: $blue)
  for k,v in pairs(sass_vars) do
    if string.sub(v, 1, 1) == "$" then
      sass_tab[k] = resolve_ref(v, sass_vars)
    else
      sass_tab[k] = v
    end
  end 
  
  return meta
end

function replace_with_sass(block_or_inline)
  
  -- scan through doc for attributes that look like sass variables
  for _,el in ipairs(block_or_inline) do
    if el.attributes ~= nil then
      
      for k,v in pairs(el.attributes) do
        sass_var = string.match(v, "(%$[%w_%-]+)")
        
        -- if attribute is sassy, swap with the value of the var from the scss file
        if sass_var ~= nil then
          el.attr.attributes[k] = string.gsub(v, "(%$[%w_%-]+)", sass_tab[sass_var])
        end
      end
      
    end
  end
  
  return(block_or_inline)
end


return {
  {Meta = fetch_sass},
  {Inlines = replace_with_sass},
  {Blocks = replace_with_sass}
}
