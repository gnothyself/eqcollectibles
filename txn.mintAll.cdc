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
    //Mint Rapta Collection
    let token1 <- EQCollectibles.mintIcon(artistId: 1, templateId: 1, user: self.user.address)
    self.collection.deposit(token: <- token1)
    let token2 <- EQCollectibles.mintIcon(artistId: 1, templateId: 3, user: self.user.address)
    self.collection.deposit(token: <- token2)
    let token3 <- EQCollectibles.mintIcon(artistId: 1, templateId: 5, user: self.user.address)
    self.collection.deposit(token: <- token3)
    let token4 <- EQCollectibles.mintIcon(artistId: 1, templateId: 6, user: self.user.address)
    self.collection.deposit(token: <- token4)
    let token5 <- EQCollectibles.mintIcon(artistId: 1, templateId: 7, user: self.user.address)
    self.collection.deposit(token: <- token5)

    //Mint Keys
    let token6 <- EQCollectibles.mintIcon(artistId: 2, templateId: 2, user: self.user.address)
    self.collection.deposit(token: <- token6)
    let token7 <- EQCollectibles.mintIcon(artistId: 2, templateId: 2, user: self.user.address)
    self.collection.deposit(token: <- token7)
    let token8 <- EQCollectibles.mintIcon(artistId: 2, templateId: 2, user: self.user.address)
    self.collection.deposit(token: <- token8)
    let token9 <- EQCollectibles.mintIcon(artistId: 2, templateId: 4, user: self.user.address)
    self.collection.deposit(token: <- token9)

    log("NFT minted")
  }
}
 