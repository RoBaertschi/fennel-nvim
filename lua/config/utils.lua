local function change_extension(file_path, new_ext)
  local pattern = "%.%w+$"
  if file_path:match(pattern) then
    return file_path:gsub(pattern, ("." .. new_ext))
  else
    return (file_path .. new_ext)
  end
end
return {["change-extension"] = change_extension}
