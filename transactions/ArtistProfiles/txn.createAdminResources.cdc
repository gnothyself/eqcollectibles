import EQArtists from "../../EQArtists.cdc"
transaction() {

    prepare(account: AuthAccount){
      if account.borrow<&EQArtists.AdminResources{EQArtists.AdminResourcesPublic}>(from: EQArtists.AdminResourcesPath) == nil {
        let collection <- EQArtists.createAdminResources()
        account.save(<-collection, to: EQArtists.AdminResourcesPath)
        account.link<&EQArtists.AdminResources{EQArtists.AdminResourcesPublic}>(/public/EQAdminResources, target: EQArtists.AdminResourcesPath)
      }
    }

    execute {
    }
}