import EQCollectibles from "../EQCollectibles.cdc"
import NonFungibleToken from "../NonFungibleToken.cdc"
import MetadataViews from "../MetadataViews.cdc"

transaction(artistId: UInt64, templateId: UInt64) {
  let dapp: &EQCollectibles.Admin
  let collection: &EQCollectibles.Collection

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
    //Mint Rapta Icon
    let token2 <- self.dapp.mintNFT(artistId: artistId, templateId: templateId)
    self.collection.deposit(token: <- token2)
    log("NFT minted")
  }
}
 