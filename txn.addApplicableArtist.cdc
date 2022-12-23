import EQCollectibles from "./EQCollectibles.cdc"
transaction(artistId: UInt64, templateId: UInt64, newArtistId: UInt64){
    let acct: AuthAccount
    let admin: &EQCollectibles.ProfileAdmin

    prepare(acct: AuthAccount) {
        let storagePath = StoragePath(identifier: "EQProfile".concat(artistId.toString()).concat("Admin"))!
        self.admin = acct.borrow<&EQCollectibles.ProfileAdmin>(from: storagePath)!
        self.acct = acct 
    }

    execute {
        self.admin.accessProfile().addApplicableArtistToTemplate(templateId: templateId, artistId: newArtistId)
    }
}