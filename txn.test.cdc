import EQCollectibles from "./EQCollectibles.cdc"
transaction() {
    // let account: AuthAccount


    prepare(account: AuthAccount){
        let capability = getAccount(0xf8d6e0586b0a20c7).getCapability<&EQCollectibles.ProfileCollection{EQCollectibles.ProfileCollectionPublic}>(EQCollectibles.ProfilePublicPath)
        log(capability.getType())
        let collection = capability.borrow()!
        log(collection.getType())
        let profile = collection.borrowProfile(artistId: 1)!
        let name = profile.name
        log(name)
        log(profile.getType())
        // profile.changeName(newName: "Matt")
        let templates = profile.borrowCollection()
        let template = profile.getTemplate(templateId: 7)!
        log(template.name)
        account.address
    }
    execute {

    }
}