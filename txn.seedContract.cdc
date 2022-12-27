import EQCollectibles from "./EQCollectibles.cdc"
import FungibleToken from "./FungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

transaction() {
  prepare(auth: AuthAccount){
    log("Seeding Contract")

    //create collectibles
    EQCollectibles.createCollectibleTemplate( //templateId 1
      artistId: 1, 
      name: "Rapta-bot", 
      description: "a digital assistant for the metaverse", 
      image: "https://images.eqmusic.io/temp/plugin.png", 
      imageModifier: nil,
      mintLimit: 108,
      royalties: [EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.005,
            type: EQCollectibles.RoyaltyType.percentage)]
      )

    EQCollectibles.createCollectibleTemplate( //templateId 2
      artistId: 2, 
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
    EQCollectibles.createIconTemplate( //templateId 3
      name: "Rapta Icon", 
      description: "the collection consists of 444 free-to-own icons. think of it like any traditional collectors item or a digital 'rookie card' that also gives you access. access to this interactive studio filled with exclusives and other unlock-able shi*. you'll see what i'm talking about as i roll out more collectibles in the weeks to come but for now, enjoy what has been under construction for a little over a year at eq. i'm excited to have you here and to embark on this journey together. yours truly - rapta", 
      category: "category", 
      mintLimit: 108, 
      image: "https://images.eqmusic.io/icons/rapta/", 
      imageModifier: ".png",
      layer: "layer", 
      artistId: 1,
      royalties: [EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.005,
            type: EQCollectibles.RoyaltyType.percentage)]
    )

    EQCollectibles.createIconTemplate( //templateId 4
      name: "Keys Icon", 
      description: "the collection consists of 444 free-to-own icons. think of it like any traditional collectors item or a digital 'rookie card' that also gives you access. access to this interactive studio filled with exclusives and other unlock-able shi*. you'll see what i'm talking about as i roll out more collectibles in the weeks to come but for now, enjoy what has been under construction for a little over a year at eq. i'm excited to have you here and to embark on this journey together. yours truly - rapta", 
      category: "category", 
      mintLimit: 108, 
      image: "image", 
      imageModifier: nil,
      layer: "layer", 
      artistId: 2,
      royalties: [EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.005,
            type: EQCollectibles.RoyaltyType.percentage)]
    )

    //create accessories
    EQCollectibles.createAccessoryTemplate( //templateId 5
      artistId: 1, 
      name: "DZN_x rapta blasé rubberman hoodie", 
      description: "20 oz. 90% thick cotton 10% polyester hoodie in heathered grey pigment dye. the front features 'blasé' in floral fabric, with a life-size rubberman on the back. DZN_® woven label with straight overstitch at wearer's lower-back. Fits true-to-size. collect this for a chance to redeem the physical merchandise irl.", 
      category: "jacket", 
      image: "https://ipfs.io/ipfs/QmNqMwhePsWvzqWeGawC6SgjK1x8QbTKxE8nZbASymWywH", 
      imageModifier: nil,
      layer: "layer", 
      mintLimit: 108,
      royalties: [EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.005,
            type: EQCollectibles.RoyaltyType.percentage)]
    )

    EQCollectibles.createAccessoryTemplate( //templateId 6
      artistId: 1, 
      name: "DZN_x rapta rosé rubberman short", 
      description: "100% cotton shorts dyed in orange and yellow colors with blue floral letters spelling “ROSÉ” while rubberman is dangling from the back pocket. “SS21” embroidered slightly above the right knee-cap. DZN_® woven label with straight overstitch at wearer's lower-leg.rue-to-size. collect this for a chance to redeem the physical merchandise irl.",
      category: "pants", 
      image: "https://ipfs.io/ipfs/QmR1DLaZT7dBgQ7cimzLt33mapABzfrNfmMJbfpvUFCY1z", 
      imageModifier: nil,
      layer: "layer", 
      mintLimit: 108,
      royalties: [EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.005,
            type: EQCollectibles.RoyaltyType.percentage)]
    )

    EQCollectibles.createAccessoryTemplate( //templateId 7
      artistId: 1, 
      name: "DZN_ 'Tabloids' balaclava", 
      description: "black & white DZN_ balaclava mask as seen in 'TABLOIDS' music video by rapta directed by jaketheshooter. this collectible earns you early access to the TABLOIDS music video and one random winner will receive the memorabilia in real life.",
      category: "hat", 
      image: "https://ipfs.io/ipfs/QmQDXa3tJQctu68X1UfXq4qQwrRNpjaLwKWBuwSCXuKoBq", 
      imageModifier: nil,
      layer: "layer", 
      mintLimit: 108,
      royalties: [EQCollectibles.Royalty(wallet: getAccount(0xf3fcd2c1a78f5eee).getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.005,
            type: EQCollectibles.RoyaltyType.percentage)]
    )


    let profile = EQCollectibles.borrowProfile(artistId: 1)!
    log(profile.name.concat(" now contains ").concat(profile.totalCollectibles.toString()).concat(" templates"))
    let profile2 = EQCollectibles.borrowProfile(artistId: 2)!
    log(profile2.name.concat(" now contains ").concat(profile2.totalCollectibles.toString()).concat(" templates"))
  }

  execute {
    log("Contract Seeded")
  }
}