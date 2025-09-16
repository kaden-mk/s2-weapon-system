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
    data: map { [string.binary]: unknown }
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
    type: Unreliable,
    call: ManyAsync
}