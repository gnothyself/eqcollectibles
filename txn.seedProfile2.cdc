import EQCollectibles from "./EQCollectibles.cdc"
import FungibleToken from "./FungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

transaction(artistId: UInt64) {
  prepare(auth: AuthAccount){
    log("Seeding Profile 2")
    let adminResources = auth.borrow<&EQCollectibles.AdminResources>(from: EQCollectibles.AdminResourcesPath)!
    let adminProfile = adminResources.borrowPrimaryAdmin(artistId: artistId) ?? panic("This admin does not possess a Primary Resrouce for this artist")
    
    //create collectibles
    adminProfile.createCollectibleTemplate( //templateId 2
      name: "plugin", 
      description: "a collection of plugins that serve as keys to the whole eq music ecosystem", 
      image: "https://ipfs.io/ipfs/QmcvBqdNSXnSzbPDRsbnarnk1LnWR3rxp1SHuXDCQXTPLK/", 
      imageModifier: ".webp",
      mintLimit: 108,
      royalties: [EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.005,
            type: EQCollectibles.RoyaltyType.percentage)]
    )

    //create icons
    adminProfile.createIconTemplate( //templateId 4
      name: "Keys Icon", 
      description: "the collection consists of 444 free-to-own icons. think of it like any traditional collectors item or a digital 'rookie card' that also gives you access. access to this interactive studio filled with exclusives and other unlock-able shi*. you'll see what i'm talking about as i roll out more collectibles in the weeks to come but for now, enjoy what has been under construction for a little over a year at eq. i'm excited to have you here and to embark on this journey together. yours truly - rapta", 
      category: "category", 
      mintLimit: 108, 
      image: "image", 
      imageModifier: nil,
      layer: "layer", 
      royalties: [EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.005,
            type: EQCollectibles.RoyaltyType.percentage)]
    )

    let profile2 = EQCollectibles.borrowProfile(artistId: 2)!
    log(profile2.name.concat(" now contains ").concat(profile2.totalCollectibles.toString()).concat(" templates"))
  }

  execute {
    log("Profile 2 Seeded")
  }
}