import EQArtists from "../../EQArtists.cdc"
import NonFungibleToken from "../../NonFungibleToken.cdc"
import FungibleToken from "../../FungibleToken.cdc"
import MetadataViews from "../../MetadataViews.cdc"

transaction() {
    let account: AuthAccount
    let royalties: [EQArtists.Royalty]
    let capability: &EQArtists.Admin{EQArtists.ProfileCreation}

    prepare(account: AuthAccount, dapp: AuthAccount){
        log("Creating Artist Profiles")
        self.account = account
        self.royalties = [] 

        let royalty = EQArtists.Royalty(
            wallet: account.getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.025,
            type: EQArtists.RoyaltyType.percentage
        )
        self.royalties.append(royalty)

        self.capability = dapp.getCapability<&EQArtists.Admin{EQArtists.ProfileCreation}>(/private/EQProfileCreation).borrow()!

    }
    pre {
    }

    execute {
        self.capability.createArtistProfile( //artistProfile 1
            account: self.account,
            name: "rapta", 
            description: "rapta makes music",
            avatar: "https://eqmusic.io/media/raptaCollect.png",
            royalties: self.royalties
        )
        
        
        log("Artist Profiles Created")
    }
}