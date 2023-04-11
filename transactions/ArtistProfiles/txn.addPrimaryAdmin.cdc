import EQArtists from "../../EQArtists.cdc"

transaction(artistId: UInt64, newAdmin: Address) {
    let collection: &EQArtists.ArtistProfiles
    prepare(admin: AuthAccount){
        self.collection = admin.borrow<&EQArtists.ArtistProfiles>(from: EQArtists.ProfilesStoragePath)!
    }     
    execute {
      self.collection.addPrimaryAdmin(artistId: artistId, newAdmin: newAdmin)
    }
}
 