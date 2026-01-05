(fn change-extension [file-path new-ext]
  (let [pattern "%.%w+$"]
    (if (file-path:match pattern)
        (file-path:gsub pattern (.. "." new-ext))
        (.. file-path new-ext)
        )))

{
 : change-extension
}
