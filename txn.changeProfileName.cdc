import EQCollectibles from "./EQCollectibles.cdc"
transaction(artistId: UInt64, newName: String) {

    let profile: &EQCollectibles.Profile{EQCollectibles.AdminProfile}

    prepare(account: AuthAccount){
        let adminResources = account.borrow<&EQCollectibles.AdminResources>(from: EQCollectibles.AdminResourcesPath)!
        self.profile = adminResources.borrowProfile(artistId: artistId) ?? panic("this account does not have administrative access to this profile")
    }

    execute {
        self.profile.changeName(newName: newName)
    }
}