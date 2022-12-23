import EQCollectibles from "./EQCollectibles.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

transaction(artistId: UInt64, relinkId: UInt64) {
    // let account: AuthAccount
    prepare(admin: AuthAccount){
        let storagePath = "EQProfile".concat(artistId.toString()).concat("Admin")
        let adminProfile = admin.borrow<&EQCollectibles.ProfileAdmin>(from: StoragePath(identifier: storagePath)!) ?? panic("could not borrow reference")
        log(admin)
        adminProfile.relinkAdmin(admin: admin, relinkId: relinkId)
    }
    execute {
        
    }
}
  