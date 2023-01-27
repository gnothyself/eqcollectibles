import EQCollectibles from "../EQCollectibles.cdc"
import FungibleToken from "../FungibleToken.cdc"
import MetadataViews from "../MetadataViews.cdc"

transaction(artistId: UInt64, cut: UFix64 ) {

    let royalties: [EQCollectibles.Royalty]
    let adminResource: &EQCollectibles.PrimaryAdmin

    prepare(auth: AuthAccount){
        self.royalties = []
        let royalties = EQCollectibles.Royalty(wallet: auth.getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()),  cut: cut, type: EQCollectibles.RoyaltyType.percentage)
        self.royalties.append(royalties)
        let resources = auth.borrow<&EQCollectibles.AdminResources>(from: EQCollectibles.AdminResourcesPath)!
        self.adminResource = resources.borrowPrimaryAdmin(artistId: artistId)!
    }

    execute {
        self.adminResource.setProfileRoyalties(newRoyalties: self.royalties)
    }
}