import EQCollectibles from "./EQCollectibles.cdc"
transaction() {
    // let account: AuthAccount


    prepare(account: AuthAccount){
        let admin = account.borrow<&EQCollectibles.ProfileAdmin>(from: /storage/EQProfileAdmin) ?? panic("could not borrow reference")
        // <&EQCollectibles.ProfileCollection{EQCollectibles.ProfileCollectionAdmin}>(/private/ArtistProfileAdmin).borrow()
        log(admin)
        let profile = admin.accessProfile().changeName(newName: "Matt")

    }
    pre {
        // self.account.getLinkTarget(EQCollectibles.ProfilePublicPath) != nil : "This account does not have a profile collection."
    }

    execute {

    }
}