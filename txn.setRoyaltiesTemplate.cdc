import EQCollectibles from "./EQCollectibles.cdc"
import FungibleToken from "./FungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

transaction(artistId: UInt64, templateId: UInt64, cut: UFix64 ) {
    let account: AuthAccount
    let royalties: [EQCollectibles.Royalty]
    let storagePath: StoragePath?

    prepare(auth: AuthAccount){
        self.storagePath = StoragePath(identifier: "EQProfile".concat(artistId.toString()).concat("Admin"))
        self.account = auth
        self.royalties = []
        let royalties = EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()),  cut: cut, type: EQCollectibles.RoyaltyType.percentage)
        self.royalties.append(royalties)

    }

    execute {
        let admin = self.account.borrow<&EQCollectibles.ProfileAdmin>(from: self.storagePath!) ?? panic("could not borrow reference")
        admin.setTemplateRoyalties(templateId: templateId, newRoyalties: self.royalties)
    }
}