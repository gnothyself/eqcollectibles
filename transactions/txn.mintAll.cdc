import EQCollectibles from "../EQCollectibles.cdc"
import NonFungibleToken from "../NonFungibleToken.cdc"
import MetadataViews from "../MetadataViews.cdc"

transaction {
  let collection: &EQCollectibles.Collection
  let dapp: &EQCollectibles.Admin

  prepare(acct: AuthAccount, dapp: AuthAccount) {

    if acct.borrow<&EQCollectibles.Collection>(from: EQCollectibles.CollectionStoragePath) == nil {
      let collection <- EQCollectibles.createEmptyCollection()
      acct.save(<-collection, to: EQCollectibles.CollectionStoragePath)
      acct.link<&EQCollectibles.Collection{NonFungibleToken.CollectionPublic, EQCollectibles.CollectionPublic, MetadataViews.ResolverCollection}>(EQCollectibles.CollectionPublicPath, target: EQCollectibles.CollectionStoragePath)
    }

    self.collection = acct.borrow<&EQCollectibles.Collection>(from: EQCollectibles.CollectionStoragePath)
      ?? panic("This collection does not exist at this address")       

    let admin = dapp.borrow<&EQCollectibles.Admin>(from: EQCollectibles.AdminStoragePath)!
    self.dapp = admin        
  }

  execute {
    //Mint Rapta Collection
    let token1 <- self.dapp.mintNFT(artistId: 1, templateId: 1)
    self.collection.deposit(token: <- token1)
    let token2 <- self.dapp.mintNFT(artistId: 1, templateId: 2)
    self.collection.deposit(token: <- token2)
    let token3 <- self.dapp.mintNFT(artistId: 1, templateId: 3)
    self.collection.deposit(token: <- token3)
    let token4 <- self.dapp.mintNFT(artistId: 1, templateId: 4)
    self.collection.deposit(token: <- token4)
    let token5 <- self.dapp.mintNFT(artistId: 1, templateId: 5)
    self.collection.deposit(token: <- token5)

    //Mint Keys
    let token6 <- self.dapp.mintNFT(artistId: 2, templateId: 6)
    self.collection.deposit(token: <- token6)
    let token7 <- self.dapp.mintNFT(artistId: 2, templateId: 6)
    self.collection.deposit(token: <- token7)
    let token8 <- self.dapp.mintNFT(artistId: 2, templateId: 6)
    self.collection.deposit(token: <- token8)
    let token9 <- self.dapp.mintNFT(artistId: 2, templateId: 7)
    self.collection.deposit(token: <- token9)

    log("NFT minted")
  }
}
 