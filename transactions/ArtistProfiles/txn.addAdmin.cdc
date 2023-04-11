import EQArtists from "../../EQArtists.cdc"

transaction(artistId: UInt64, newAdmin: Address) {
    prepare(admin: AuthAccount){
        let resourceCollection = admin.borrow<&EQArtists.AdminResources>(from: EQArtists.AdminResourcesPath)!
        let adminResource = resourceCollection.borrowPrimaryAdmin(artistId: artistId)!
        log(admin)

        adminResource.addAdmin(admin: admin, newAdmin: newAdmin)
    }     
}