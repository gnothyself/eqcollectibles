import EQCollectibles from "./EQCollectibles.cdc"

pub fun main(): {UInt64: Address} {
    return EQCollectibles.getArtistAddresses()
}