import EQCollectibles from "./EQCollectibles.cdc"

pub fun main(): [&EQCollectibles.Profile{EQCollectibles.PublicProfile}] {
    let account = getAccount(0xf8d6e0586b0a20c7)
    let collection = account
        .getCapability(EQCollectibles.ProfilesPublicPath)
        .borrow<&EQCollectibles.ArtistProfiles{EQCollectibles.PublicAccess}>()
        ?? panic("Could not borrow a reference to the collection")

    let profiles: [&EQCollectibles.Profile{EQCollectibles.PublicProfile}]= []

    let profile1 = collection.borrowProfile(artistId: 1)
    profiles.append(profile1!)
    log(profile1!.name)
    let profile2 = collection.borrowProfile(artistId: 2)
    profiles.append(profile2!)
    log(profile2!.name)
    return profiles
}