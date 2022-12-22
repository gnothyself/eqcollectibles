import EQCollectibles from "./EQCollectibles.cdc"
transaction(artistId: UInt64, newName: String) {
    // let account: AuthAccount


    prepare(account: AuthAccount){
        let storagePath = StoragePath(identifier: "EQProfile".concat(artistId.toString()).concat("Admin_Limited"))

        let admin = account.borrow<&EQCollectibles.LimitedAdmin>(from: storagePath!)!
        // let capability = account.getCapability<&EQCollectibles.ProfileAdmin>(/private/EQProfile2AdminFor0x01cf0e2f2f715450)
        // let admin = capability
        //let profile = admin.accessProfile()
        let profile = admin.accessProfile().changeName(newName: newName)
    //log(profile)
    }
    pre {
    }

    execute {

    }
}