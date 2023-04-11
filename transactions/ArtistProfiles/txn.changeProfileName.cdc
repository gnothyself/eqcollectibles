import EQArtists from "../../EQArtists.cdc"
transaction(artistId: UInt64, newName: String) {

    let profile: &EQArtists.Profile{EQArtists.AdminProfile}

    prepare(account: AuthAccount){
        let adminResources = account.borrow<&EQArtists.AdminResources>(from: EQArtists.AdminResourcesPath)!
        self.profile = adminResources.borrowProfile(artistId: artistId) ?? panic("this account does not have administrative access to this profile")
    }

    execute {
        self.profile.changeName(newName: newName)
    }
}
 