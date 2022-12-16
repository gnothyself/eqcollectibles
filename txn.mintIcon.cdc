import EQCollectibles from "./EQCollectibles.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

transaction {
  let user: AuthAccount
  let collection: &EQCollectibles.Collection

  prepare(acct: AuthAccount) {
    self.user = acct

    if acct.borrow<&EQCollectibles.Collection>(from: EQCollectibles.CollectionStoragePath) == nil {
      let collection <- EQCollectibles.createEmptyCollection()
      acct.save(<-collection, to: EQCollectibles.CollectionStoragePath)
      acct.link<&EQCollectibles.Collection{NonFungibleToken.CollectionPublic, EQCollectibles.CollectionPublic, MetadataViews.ResolverCollection}>(EQCollectibles.CollectionPublicPath, target: EQCollectibles.CollectionStoragePath)
    }

    self.collection = acct.borrow<&EQCollectibles.Collection>(from: EQCollectibles.CollectionStoragePath)
      ?? panic("This collection does not exist at this address")            
  }

  execute {
    //Mint Rapta Icon
    let token2 <- EQCollectibles.mintIcon(artistId: 1, templateId: 3, user: self.user.address)
    self.collection.deposit(token: <- token2)
    log("NFT minted")
  }
}
 