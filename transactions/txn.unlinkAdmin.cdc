import EQCollectibles from "../EQCollectibles.cdc"
import NonFungibleToken from "../NonFungibleToken.cdc"

transaction(artistId: UInt64, unlinkId: UInt64) {

    let adminResource: &EQCollectibles.PrimaryAdmin
    let admin: AuthAccount

    prepare(admin: AuthAccount){
        let adminResources = admin.borrow<&EQCollectibles.AdminResources>(from: EQCollectibles.AdminResourcesPath) ?? panic("could not borrow reference")
        self.adminResource = adminResources.borrowPrimaryAdmin(artistId: artistId)!
        self.admin = admin
    }

    execute {
        self.adminResource.unlinkAdmin(admin: self.admin, unlinkId: unlinkId)
    }
}
 