import EQCollectibles from "../EQCollectibles.cdc"

pub fun main(){
    let limit = EQCollectibles.royaltyLimit * 100.0
    log(limit)
    let integer = Int(limit)
    log(integer)
}