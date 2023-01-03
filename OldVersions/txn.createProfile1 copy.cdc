import EQCollectibles from "../EQCollectibles.cdc"
import NonFungibleToken from "../NonFungibleToken.cdc"
import FungibleToken from "../FungibleToken.cdc"
import MetadataViews from "../MetadataViews.cdc"

transaction() {
    // let account: AuthAccount
    // let royalties: [EQCollectibles.Royalty]

    prepare(account: AuthAccount, dapp: AuthAccount){
        // log("Creating Artist Profiles")
        // self.account = account
        // self.royalties = [] 

        // let royalty = EQCollectibles.Royalty(
        //     wallet: account.getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
        //     cut: 0.025,
        //     type: EQCollectibles.RoyaltyType.percentage
        // )
        // self.royalties.append(royalty)

    }
    pre {
    }

    execute {
        // EQCollectibles.createArtistProfile( //artistProfile 1
        //     account: self.account,
        //     name: "rapta", 
        //     description: "rapta makes music",
        //     avatar: "https://eqmusic.io/media/raptaCollect.png",
        //     royalties: self.royalties
        // )
        
        
        log("Artist Profiles Created")
    }
}