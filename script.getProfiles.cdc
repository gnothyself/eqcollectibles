import EQCollectibles from "./EQCollectibles.cdc"

pub fun main(): [&EQCollectibles.ArtistProfile{EQCollectibles.ArtistProfilePublic}] {
    let account = getAccount(0xf8d6e0586b0a20c7)
    let collection = account
        .getCapability(EQCollectibles.ProfilePublicPath)
        .borrow<&EQCollectibles.ProfileCollection{EQCollectibles.ProfileCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let profiles: [&EQCollectibles.ArtistProfile{EQCollectibles.ArtistProfilePublic}]= []

    let profile1 = collection.borrowProfile(artistId: 1)
    profiles.append(profile1!)

    let profile2 = collection.borrowProfile(artistId: 2)
    profiles.append(profile2!)

    return profiles
}