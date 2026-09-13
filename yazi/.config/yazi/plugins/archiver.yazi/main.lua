return {
    entry = function(self, args)
        local files = ya.selected_files()
        if #files == 0 then
            ya.notify { title = "Archiver", content = "No files selected", timeout = 3 }
            return
        end

        local format = args[1] or "zip"
        local output = ya.input {
            title = "Archive name (." .. format .. ")",
            value = "archive." .. format,
        }

        if not output then return end

        local cmd = string.format("ouch c '%s' %s", 
            output,
            table.concat(files, " "))
        
        local success = os.execute(cmd)
        if success then
            ya.notify { title = "Archiver", content = "Created " .. output, timeout = 3 }
        else
            ya.notify { title = "Archiver", content = "Failed to create archive", timeout = 5 }
        end
        
        ya.manager_emit("refresh", {})
    end,
}
