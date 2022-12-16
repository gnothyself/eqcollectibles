import EQCollectibles from "./EQCollectibles.cdc"
transaction(){
    let acct: AuthAccount
    let profile: &EQCollectibles.ArtistProfile

    prepare(acct: AuthAccount) {
        self.profile = EQCollectibles.borrowProfile(artistId: 1)!
        self.acct = acct 
    }

    execute {
        self.profile.addApplicableArtistToTemplate(templateId: 6, artistId: 2)
    }
}