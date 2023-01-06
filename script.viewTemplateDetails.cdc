import EQCollectibles from "./EQCollectibles.cdc"

pub fun main(artistId: UInt64): {UInt64: [String]} {
    let account = getAccount(0xf8d6e0586b0a20c7)
    let collection = account
        .getCapability(EQCollectibles.ProfilesPublicPath)
        .borrow<&EQCollectibles.ArtistProfiles{EQCollectibles.PublicAccess}>()
        ?? panic("Could not borrow a reference to the collection")

    let profile = collection.borrowProfile(artistId: artistId)!
    let savedTemplates: {UInt64: [String]} = {}

    for key in profile.getCollectibleIds() {
        let templateName = profile.getTemplate(templateId: key)!.name
        let type = profile.getCollectibleType(templateId: key)!
        let detail: [String] = []
        switch type {
            case Type<@EQCollectibles.AccessoryTemplate?>():
                detail.append("ACCESSORY")
            
            case Type<@EQCollectibles.IconTemplate?>():
                detail.append("ICON")

            case Type<@EQCollectibles.CollectibleTemplate?>():
                detail.append("COLLECTIBLE")
            default: 
                detail.append("DEFAULT")
        }
        detail.append(templateName)
        savedTemplates[key] = detail
    }
    
    return savedTemplates
}