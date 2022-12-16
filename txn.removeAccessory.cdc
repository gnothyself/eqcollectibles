import EQCollectibles from "./EQCollectibles.cdc"
transaction(){

    prepare(acct: AuthAccount) {
        EQCollectibles.removeAccessory(account: acct, iconId: 2, category: "pants")
    
    }

    execute {

    }
}