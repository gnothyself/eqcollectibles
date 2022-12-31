import EQCollectibles from "./EQCollectibles.cdc"

transaction(artistId: UInt64, newAdmin: Address) {
    prepare(admin: AuthAccount){
        let resourceCollection = admin.borrow<&EQCollectibles.AdminResources>(from: EQCollectibles.AdminResourcesPath)!
        let adminResource = resourceCollection.borrowPrimaryAdmin(artistId: artistId)!
        log(admin)

        adminResource.addAdmin(admin: admin, newAdmin: newAdmin)
    }
        
}
