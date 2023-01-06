import EQCollectibles from "./EQCollectibles.cdc"

transaction(artistId: UInt64) {
  let dapp: &EQCollectibles.Admin

  prepare(dapp: AuthAccount) {
    let admin = dapp.borrow<&EQCollectibles.Admin>(from: EQCollectibles.AdminStoragePath)!
    self.dapp = admin      
  }

  execute {
    //Mint Rapta Icon
    self.dapp.lockProfile(artistId: artistId)
    log("Profile ".concat(artistId.toString()).concat(" has been locked."))
  }
}
 