import EQCollectibles from "./EQCollectibles.cdc"
transaction(artistId: UInt64, newName: String) {
    // let account: AuthAccount


    prepare(account: AuthAccount){
        let storagePath = StoragePath(identifier: "EQProfile".concat(artistId.toString()).concat("Admin"))
        let type = account.type(at: storagePath!) ?? panic("No resource stored here")
        log(type)
        switch type {
            case Type<@EQCollectibles.ProfileAdmin>():
                log("case is profile admin")
                let admin = account.borrow<&EQCollectibles.ProfileAdmin>(from: storagePath!) ?? panic("could not borrow reference")
                admin.accessProfile().changeName(newName: newName)
            case Type<@EQCollectibles.LimitedAdmin>():
                log("case is limited admin")
                let admin = account.borrow<&EQCollectibles.LimitedAdmin>(from: storagePath!)!
                admin.accessProfile().changeName(newName: newName)
            default: 
                log("no matching case")
        }
        
    }
    execute {

    }
}