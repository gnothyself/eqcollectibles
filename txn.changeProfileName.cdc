import EQCollectibles from "./EQCollectibles.cdc"
transaction(artistId: UInt64, newName: String) {
    // let account: AuthAccount

    prepare(account: AuthAccount){
        // let storagePath = StoragePath(identifier: "EQProfile".concat(artistId.toString()).concat("Admin"))
        // let type = account.type(at: storagePath!) ?? panic("No resource stored here")
        let adminResources = account.borrow<&EQCollectibles.AdminCollection>(from: EQCollectibles.ProfileAdminPath)!
        // switch type {
        //     case Type<@EQCollectibles.ProfileAdmin>():
        //         let admin = account.borrow<&EQCollectibles.ProfileAdmin>(from: storagePath!) ?? panic("could not borrow reference")
        //         admin.accessProfile().changeName(newName: newName)
                
        //     case Type<@EQCollectibles.LimitedAdmin>():
        //         let admin = account.borrow<&EQCollectibles.LimitedAdmin>(from: storagePath!)!
        //         admin.accessProfile().changeName(newName: newName)

        //     default: 
        //         log("no matching case")
        // }
        if adminResources.primaryAdmin.keys.contains(artistId) {
            let admin = adminResources.borrowPrimaryAdmin(artistId: artistId)!
            let profile = admin.accessProfile()
            profile.changeName(newName: newName)
        } else if adminResources.secondaryAdmin.keys.contains(artistId) {
            let admin = adminResources.borrowSecondaryAdmin(artistId: artistId)!
            let profile = admin.accessProfile()
            profile.changeName(newName: newName)
        } else {
            panic("This account does not have access to that profile")
        }
    }
    execute {

    }
}