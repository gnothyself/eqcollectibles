import EQArtists from "../../EQArtists.cdc"

pub fun main(): [&EQArtists.Profile{EQArtists.PublicProfile}] {
    let account = getAccount(0xf8d6e0586b0a20c7)
    let collection = account
        .getCapability(EQArtists.ProfilesPublicPath)
        .borrow<&EQArtists.ArtistProfiles{EQArtists.PublicAccess}>()
        ?? panic("Could not borrow a reference to the collection")

    let profiles: [&EQArtists.Profile{EQArtists.PublicProfile}]= []

    let profile1 = collection.borrowProfile(artistId: 1)
    profiles.append(profile1!)
    log(profile1!.name)
    let profile2 = collection.borrowProfile(artistId: 2)
    profiles.append(profile2!)
    log(profile2!.name)
    return profiles
}