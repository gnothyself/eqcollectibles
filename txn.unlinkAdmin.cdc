import EQCollectibles from "./EQCollectibles.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

transaction(artistId: UInt64, unlinkId: UInt64) {
    // let account: AuthAccount
    prepare(admin: AuthAccount){
        // let storagePath = "EQProfile".concat(artistId.toString()).concat("Admin")
        // let adminProfile = admin.borrow<&EQCollectibles.ProfileAdmin>(from: /storage/EQProfileAdmin) ?? panic("could not borrow reference")
        let adminResources = admin.borrow<&EQCollectibles.AdminCollection>(from: EQCollectibles.ProfileAdminPath) ?? panic("could not borrow reference")

        let res = adminResources.borrowPrimaryAdmin(artistId: artistId)!

        res.unlinkAdmin(admin: admin, unlinkId: unlinkId)
        
    }
    execute {
        
    }
}
 