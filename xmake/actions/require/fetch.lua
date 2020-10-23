--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-2020, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        fetch.lua
--

-- imports
import("core.base.option")
import("core.base.hashset")
import("core.project.project")
import("core.package.package", {alias = "core_package"})
import("impl.package")
import("impl.repository")
import("impl.utils.get_requires")

-- fetch the given package info
function main(requires_raw)

    -- get requires and extra config
    local requires_extra = nil
    local requires, requires_extra = get_requires(requires_raw)
    if not requires or #requires == 0 then
        return
    end

    -- get the fetching modes
    local fetchmodes = option.get("fetch_modes")
    if fetchmodes then
        fetchmodes = hashset.from(fetchmodes:split(',', {plain = true}))
    end

    -- fetch all packages
    local fetchinfos = {}
    for _, instance in ipairs(package.load_packages(requires, {requires_extra = requires_extra})) do
        local fetchinfo
        if fetchmodes and fetchmodes:has("deps") then
            fetchinfo = instance:fetchdeps()
        else
            fetchinfo = instance:fetch()
        end
        if fetchinfo then
            table.insert(fetchinfos, fetchinfo)
        end
    end

    -- show results
    if #fetchinfos > 0 then
        local flags = {}
        if fetchmodes:has("cflags") then
            for _, fetchinfo in ipairs(fetchinfos) do
                for _, includedir in ipairs(fetchinfo.includedirs) do
                    table.insert(flags, "-I" .. os.args(includedir))
                end
                for _, define in ipairs(fetchinfo.defines) do
                    table.insert(flags, "-D" .. define)
                end
                for _, cflag in ipairs(fetchinfo.cflags) do
                    table.insert(flags, cflag)
                end
                for _, cxflag in ipairs(fetchinfo.cxflags) do
                    table.insert(flags, cxflag)
                end
                for _, cxxflag in ipairs(fetchinfo.cxxflags) do
                    table.insert(flags, cxxflag)
                end
            end
        end
        if fetchmodes:has("ldflags") then
            for _, fetchinfo in ipairs(fetchinfos) do
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(flags, "-L" .. os.args(linkdir))
                end
                for _, link in ipairs(fetchinfo.links) do
                    table.insert(flags, "-l" .. link)
                end
                for _, ldflag in ipairs(fetchinfo.ldflags) do
                    table.insert(flags, ldflags)
                end
            end
        end
        if #flags > 0 then
            print(table.concat(flags, " "))
        else
            print(fetchinfos)
        end
    end
end

