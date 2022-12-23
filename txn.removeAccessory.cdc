import EQCollectibles from "./EQCollectibles.cdc"
transaction(category: String, iconId: UInt64){

    prepare(acct: AuthAccount) {
        EQCollectibles.removeAccessory(account: acct, iconId: iconId, category: category)
    
    }

    execute {

    }
}