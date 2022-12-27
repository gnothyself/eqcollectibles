import EQCollectibles from "./EQCollectibles.cdc"
import MetadataViews from "./MetadataViews.cdc"

pub fun main(address: Address, id: UInt64): &EQCollectibles.NFT{EQCollectibles.Public} {
    let account = getAccount(address)
    let collection = account
        .getCapability(EQCollectibles.CollectionPublicPath)
        .borrow<&EQCollectibles.Collection{EQCollectibles.CollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowCollectible(id: id)
    // let nft = collection.borrowAccessory(id: 2)!
    log(nft)
    return nft
}