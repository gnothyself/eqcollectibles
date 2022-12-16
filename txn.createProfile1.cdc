import EQCollectibles from "./EQCollectibles.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"

transaction() {
    let account: AuthAccount


    prepare(account: AuthAccount){
        log("Creating Artist Profiles")
        self.account = account

        if account.borrow<&EQCollectibles.ProfileCollection>(from: EQCollectibles.ProfileStoragePath) == nil {
            let collection <- EQCollectibles.createEmptyProfileCollection()
            account.save(<-collection, to: EQCollectibles.ProfileStoragePath)
            account.link<&EQCollectibles.ProfileCollection>(EQCollectibles.ProfilePublicPath, target: EQCollectibles.ProfileStoragePath)
        }  

    }
    pre {
        self.account.getLinkTarget(EQCollectibles.ProfilePublicPath) != nil : "This account does not have a profile collection."
    }

    execute {
        EQCollectibles.createArtistProfile( //artistProfile 1
            account: self.account,
            name: "rapta", 
            description: "rapta makes music",
            avatar: "https://eqmusic.io/media/raptaCollect.png"
        )
        log("Artist Profiles Created")
    }
}