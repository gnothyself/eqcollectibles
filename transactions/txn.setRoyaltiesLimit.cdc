import EQCollectibles from "../EQCollectibles.cdc"
import FungibleToken from "../FungibleToken.cdc"
import MetadataViews from "../MetadataViews.cdc"

transaction(newLimit: UFix64) {
    let admin: &EQCollectibles.Admin

    prepare(auth: AuthAccount){
        self.admin = auth.borrow<&EQCollectibles.Admin>(from: EQCollectibles.AdminStoragePath)!
    }

    execute {
        self.admin.setRoyaltyLimit(newLimit: newLimit)
    }
}