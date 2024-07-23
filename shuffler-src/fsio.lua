local fsio = {}

-- determine os based on file extension of native modules
local platforms = { dll = "WIN", so = "LINUX", dylib = "MAC" }
local platform = platforms[(package.cpath .. ";"):match("%.(%a+);")]
fsio.platform = platform
if not platform and log_quiet then
	log_quiet('Unable to determine platform. cpath is "%s"', package.cpath)
end

local dotnet_path = luanet and luanet.import_type("System.IO.Path")
local dotnet_directory = luanet and luanet.import_type("System.IO.Directory")
local dotnet_file = luanet and luanet.import_type("System.IO.File")
local dotnet_environment = luanet and luanet.import_type("System.Environment")
fsio.use_luanet = dotnet_path and dotnet_directory and dotnet_file and dotnet_environment and true
if not fsio.use_luanet and log_quiet then
	log_quiet("luanet unavailable (luanet=%s, System.IO=%s, System.Environment=%s)",
		luanet ~= nil, (dotnet_path and dotnet_directory and dotnet_file) ~= nil, dotnet_environment ~= nil)
end

local function execute_cmd(win_cmd, unix_cmd, error_msg, ...)
	local cmd = platform == "WIN" and win_cmd or unix_cmd or win_cmd
	local success, condition, code = os.execute(string.format(cmd, ...))
	if not success then
		error(string.format(error_msg, ...) .. string.format(" (%s %i)", condition, code))
	end
end

---@param path string
---@return boolean
function fsio.directory_exists(path)
	if fsio.use_luanet then
		return dotnet_directory.Exists(path)
	else
		local ok, _, code = os.rename(path, path)
		-- code 13 is permission denied, but it's there
		return (ok or code == 13) and not fsio.file_exists(path)
	end
end

---@param path string
---@return boolean
function fsio.file_exists(path)
	if fsio.use_luanet then
		return dotnet_file.Exists(path)
	else
		local file = io.open(path, "r")
		if file then io.close(file) end
		return file ~= nil
	end
end

---Create directory if it doesn't already exist, as well as missing parent directories
---@param path string
function fsio.create_directory(path)
	if fsio.use_luanet then
		dotnet_directory.CreateDirectory(path)
	elseif not fsio.directory_exists(path) then
		execute_cmd('mkdir "%s"', nil, 'Failed to create directory "%s"', path)
	end
end

---@param path string
function fsio.delete_directory(path)
	if fsio.use_luanet then
		dotnet_directory.Delete(path, true)
	elseif fsio.directory_exists(path) then
		execute_cmd('rmdir "%s" /S /Q', 'rm -rf "%s"', 'Failed to delete directory "%s"', path)
	end
end

---Get files in directory. Not recursive.
---@param path string
---@return string[]
function fsio.get_files(path)
	local files = {}

	if fsio.use_luanet then
		local fullpath_files = dotnet_directory.GetFiles(path)
		for i = 0, fullpath_files.Length - 1 do -- can't use ipairs here
			files[i] = dotnet_path.GetFileName(fullpath_files[i])
		end
	else
		local cmd = platform == "WIN" and
			string.format('dir "%s" /B /A-D', path) or
			string.format('ls "%s" -p | grep -v /', path)
		local proc = assert(io.popen(cmd, "r"))
		for file in proc:lines() do
			table.insert(files, file)
		end
		proc:close()
	end

	return files
end

---Copies files from one directory to another
---@param source string
---@param destination string
function fsio.copy_files(source, destination)
	if fsio.use_luanet then
		dotnet_directory.CreateDirectory(destination)
		local files = dotnet_directory.GetFiles(source)
		for i = 0, files.Length - 1 do -- can't use ipairs here
			local file = files[i]
			dotnet_file.Copy(file, dotnet_path.Combine(destination, dotnet_path.GetFileName(file)))
		end
	else
		execute_cmd('xcopy "%s" "%s\\" /E /H', 'cp -r "%s" "%s"', 'Failed to copy files from "%s" to "%s"', source,
			destination)
	end
end

---@return string
function fsio.get_working_directory()
	if fsio.use_luanet then
		return dotnet_environment.GetCurrentDirectory()
	else
		local cmd = platform == "WIN" and "cd" or "pwd"
		local proc = assert(io.popen(cmd, "r"))
		local result = proc:read("*all")
		proc:close()
		return result:match("^%s*(%g+)%s*$")
	end
end

---@param name string Relative paths only, no leading slash or dots
---@return string
function fsio.get_absolute_path(name)
	if fsio.use_luanet then
		return dotnet_path.GetFullPath(name)
	else
		local sep = platform == 'WIN' and "\\" or "/"
		return fsio.get_working_directory() .. sep .. name
	end
end

return fsio
