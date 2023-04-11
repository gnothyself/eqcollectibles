import EQArtists from "../../EQArtists.cdc"
import NonFungibleToken from "../../NonFungibleToken.cdc"
import FungibleToken from "../../FungibleToken.cdc"
import MetadataViews from "../../MetadataViews.cdc"

transaction() {
    let royalties1: [EQArtists.Royalty]
    let royalties2: [EQArtists.Royalty]
    let capability: &EQArtists.Admin

    prepare(dapp: AuthAccount){
        log("Creating Artist Profiles")

        self.royalties1 = [] 
        self.royalties2 = [] 

        let artist1 = getAccount(0x01cf0e2f2f715450)
        let artist2 = getAccount(0x179b6b1cb6755e31)

        let royalty1 = EQArtists.Royalty(
            wallet: artist1.getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.025,
            type: EQArtists.RoyaltyType.percentage
        )
        self.royalties1.append(royalty1)

        let royalty2 = EQArtists.Royalty(
            wallet: artist2.getCapability<&{FungibleToken.Receiver}>(MetadataViews.getRoyaltyReceiverPublicPath()), 
            cut: 0.025,
            type: EQArtists.RoyaltyType.percentage
        )
        self.royalties2.append(royalty2)

        self.capability = dapp.borrow<&EQArtists.Admin>(from: EQArtists.AdminStoragePath)!
    }
    pre {
    }

    execute {
        self.capability.createCustodialProfile( //artistProfile 1
            name: "rapta", 
            description: "rapta makes music",
            avatar: "https://eqmusic.io/media/raptaCollect.png",
            royalties: self.royalties1
        )
        self.capability.createCustodialProfile( //artistProfile 1
            name: "eq keys", 
            description: "all things eq", 
            avatar: "https://eqmusic.io/media/eq.png",
            royalties: self.royalties2
        )
        log("Artist Profiles Created")
    }
}