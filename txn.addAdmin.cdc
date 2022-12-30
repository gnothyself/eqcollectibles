import EQCollectibles from "./EQCollectibles.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

transaction(artistId: UInt64, newAdmin: Address) {
    // let account: AuthAccount
    prepare(admin: AuthAccount){
        // let storagePath = "EQProfile".concat("2").concat("Admin")
        // let adminProfile = admin.borrow<&EQCollectibles.ProfileAdmin>(from: /storage/EQProfileAdmin) ?? panic("could not borrow reference")
        let resourceCollection = admin.borrow<&EQCollectibles.AdminCollection>(from: EQCollectibles.ProfileAdminPath)!
        //let adminProfile = admin.borrow<&EQCollectibles.ProfileAdmin>(from: StoragePath(identifier: storagePath)!) ?? panic("could not borrow reference")
        let adminResource = resourceCollection.borrowPrimaryAdmin(artistId: artistId)!
        log(admin)

        adminResource.addAdmin(admin: admin, newAdmin: newAdmin)
    }
        
}
