import EQCollectibles from "./EQCollectibles.cdc"
transaction(){
    let acct: AuthAccount
    let template: EQCollectibles.TemplateData
    let icon: &EQCollectibles.NFT{EQCollectibles.Icon}

    prepare(acct: AuthAccount) {
        let collection = acct.borrow<&EQCollectibles.Collection>(from: EQCollectibles.CollectionStoragePath)!
        self.icon = collection.borrowIcon(id: 9)!
        let accessory = collection.borrowAccessory(id: 4)!
        let profile = EQCollectibles.borrowProfile(artistId: accessory.artistId)!
        self.template = profile.getTemplate(templateId: accessory.templateId)!
        self.acct = acct 
        
    }

    pre {
        self.template.applicableArtists!.contains(self.icon.artistId) : "This accessory is not appicable to this icon"
    }

    execute {
        EQCollectibles.addAccessory(account: self.acct, iconId: 9, accessoryId: 4)
    }
}