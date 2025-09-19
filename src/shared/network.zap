event RequestSessionState = {
    from: Client,
    type: Reliable,
    call: ManyAsync
}

event PlayerSessionSync = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: map { [string.binary]: unknown },   
}

event WeaponSessionSync = {
    from: Server,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        name: string.binary,
        payload: map { [string.binary]: unknown }
    }
}

funct CreateWeapon = {
    call: Async,
    args: ( name: string.binary ),
    rets: enum { success, fail }
}

funct EquipWeapon = {  
    call: Async,
    args: ( name: string.binary ),
    rets: enum { success, fail }
}

event FireWeapon = {
    from: Client,
    type: Reliable,
    call: ManyAsync,
    data: struct {
        unit: struct {
            Origin: Vector3,
            Direction: Vector3,
            Unit: unknown
        },

        fire_point: Vector3
    }
}

event ReloadWeapon = {
    from: Client,
    type: Unreliable,
    call: ManyAsync
}