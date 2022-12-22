import EQCollectibles from "./EQCollectibles.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

transaction() {
    // let account: AuthAccount
    prepare(newAdmin: AuthAccount, admin: AuthAccount){
        let storagePath = "EQProfile".concat("2").concat("Admin")
        // let adminProfile = admin.borrow<&EQCollectibles.ProfileAdmin>(from: /storage/EQProfileAdmin) ?? panic("could not borrow reference")
        let adminProfile = admin.borrow<&EQCollectibles.ProfileAdmin>(from: StoragePath(identifier: storagePath)!) ?? panic("could not borrow reference")
        log(admin)

        adminProfile.addAdmin(admin: admin, newAdmin: newAdmin)
    }
    execute {
        
    }
}
 