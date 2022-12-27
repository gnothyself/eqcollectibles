import EQCollectibles from "./EQCollectibles.cdc"
import FungibleToken from "./FungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

transaction() {
    let account: AuthAccount
    let royalties: [EQCollectibles.Royalty]
    let admin: &EQCollectibles.Admin


    prepare(auth: AuthAccount){
        self.account = auth
        self.royalties = []
        let royalties = EQCollectibles.Royalty(wallet: self.account.getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()),  cut: 0.025, type: EQCollectibles.RoyaltyType.percentage)
        self.royalties.append(royalties)

        self.admin = auth.borrow<&EQCollectibles.Admin>(from: EQCollectibles.AdminStoragePath)!

    }

    execute {
        self.admin.setRoyalites(newRoyalties: self.royalties)
    }
}