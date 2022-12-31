import EQCollectibles from "./EQCollectibles.cdc"
transaction(artistId: UInt64, templateId: UInt64, newArtistId: UInt64){
    let profile: &EQCollectibles.Profile{EQCollectibles.AdminProfile}

    prepare(acct: AuthAccount) {
        let resources = acct.borrow<&EQCollectibles.AdminResources>(from: EQCollectibles.AdminResourcesPath)!
        self.profile = resources.borrowProfile(artistId: artistId)!
    }

    execute {
        self.profile.addApplicableArtistToTemplate(templateId: templateId, artistId: newArtistId)
    }
}