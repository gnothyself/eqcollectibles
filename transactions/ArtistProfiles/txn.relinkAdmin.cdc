import EQArtists from "../../EQArtists.cdc"

transaction(artistId: UInt64, relinkId: UInt64) {

    let adminResource: &EQArtists.PrimaryAdmin
    let admin: AuthAccount

    prepare(admin: AuthAccount){
        let adminResources = admin.borrow<&EQArtists.AdminResources>(from: EQArtists.AdminResourcesPath) ?? panic("could not borrow reference")

        self.adminResource = adminResources.borrowPrimaryAdmin(artistId: artistId)!
        self.admin = admin
    }

    execute {
        self.adminResource.relinkAdmin(admin: self.admin, relinkId: relinkId)
    }
}
  