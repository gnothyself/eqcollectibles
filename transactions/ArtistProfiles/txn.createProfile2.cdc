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

        let royalty1 = EQArtists.Royalty(
            wallet: account.getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.025,
            type: EQArtists.RoyaltyType.percentage
        )
        self.royalties.append(royalty1)

        let royalty2 = EQArtists.Royalty(
            wallet: account.getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.025,
            type: EQArtists.RoyaltyType.percentage
        )
        self.royalties.append(royalty2)

        self.capability = dapp.getCapability<&EQArtists.Admin{EQArtists.ProfileCreation}>(/private/EQProfileCreation).borrow()!

    }

    execute {
        self.capability.createArtistProfile( //artistProfile 2
            account: self.account,
            name: "eq keys", 
            description: "all things eq", 
            avatar: "https://eqmusic.io/media/eq.png",
            royalties: self.royalties
        )


        log("Artist Profiles Created")
    }
}