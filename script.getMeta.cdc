import EQCollectibles from "./EQCollectibles.cdc"

pub fun main(): &EQCollectibles.NFT{EQCollectibles.Accessory} {
    let account = getAccount(0xf8d6e0586b0a20c7)
    let collection = account
        .getCapability(EQCollectibles.CollectionPublicPath)
        .borrow<&EQCollectibles.Collection{EQCollectibles.CollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    // let nft = collection.borrowIcon(id: 3)!
    let nft = collection.borrowAccessory(id: 2)!

        log(nft)

    return nft
}