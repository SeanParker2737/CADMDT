local Data = {}

Data.Ranks = {"Constable", "Sergeant", "Inspector", "Chief Inspector", "Dispatcher", "Admin"}
Data.AdminUsers = {"SeanParker2737"} -- Add admin usernames here

function Data.ValidCallsign(callsign)
    return typeof(callsign) == "string" and #callsign > 2
end

function Data.ValidRank(rank)
    for _,r in ipairs(Data.Ranks) do
        if r == rank then return true end
    end
    return false
end

function Data.GetRole(rank)
    if rank == "Dispatcher" then return "Dispatcher"
    elseif rank == "Admin" then return "Admin"
    else return "Officer"
    end
end

function Data.IsAdmin(player)
    for _, name in ipairs(Data.AdminUsers) do
        if player.Name == name then return true end
    end
    return false
end

function Data.PersonLookup(name)
    -- Mock data, expand as needed
    if name == "John Doe" then
        return {found=true, name="John Doe", DOB="01/01/1990", warrants="None"}
    else
        return {found=false}
    end
end

function Data.VehicleLookup(plate)
    -- Mock data, expand as needed
    if plate == "AB12 CDE" then
        return {found=true, plate="AB12 CDE", make="Ford", model="Focus", status="No markers"}
    else
        return {found=false}
    end
end

return Data