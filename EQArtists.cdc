import MetadataViews from "./MetadataViews.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import FungibleToken from "./FungibleToken.cdc"

pub contract EQArtists {
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////STORAGE PATHS & EVENTS
	pub let AdminStoragePath: StoragePath
	pub let ProfilesStoragePath: StoragePath
	pub let ProfilesPublicPath: PublicPath
	pub let ProfilesPrivatePath: PrivatePath
	pub let AdminResourcesPath: StoragePath

	pub event ContractInitialized()
	pub event Withdraw(id: UInt64, from: Address?)
	pub event Deposit(id: UInt64, to: Address?)
	pub event ProfileCreated(artistId: UInt64)
	pub event TemplateCreated(artistId: UInt64, templateId: UInt64)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////CONTRACT VARIABLES & ROYALTIES
	pub var totalProfiles: UInt64
	pub var totalTemplates: UInt64
	pub var royalties: [Royalty]
	pub var royaltyLimit: UFix64
	access(contract) let totalMintedByTemplate: {UInt64: UInt64}

	pub enum RoyaltyType: UInt8{
		pub case fixed
		pub case percentage
	}

	pub struct Royalties {
		pub let royalty: [Royalty]
		init(
				royalty: [Royalty]
		) {
				self.royalty = royalty
		}
	}

	pub struct Royalty {
		pub let wallet: Capability<&{FungibleToken.Receiver}>
		pub let cut: UFix64
		pub let type: RoyaltyType
		init(
				wallet:Capability<&{FungibleToken.Receiver}>, cut: UFix64, type: RoyaltyType
		){
				self.wallet=wallet
				self.cut=cut
				self.type=type
		}
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////ARTIST PROFILES & PROFILE ADMIN RESOURCES
	// PROFILE COLLECTION & INTERFACES
	// ArtistProfiles is the collection where all profiles are stored. This collection is owned by EQ Music and a private capability to
	// grant access to this collection is distributed upon the creation of a profile and stored in an PrimaryAdmin Resource.
	pub resource ArtistProfiles: PublicAccess, AdminAccess {
		pub var Profiles: @{UInt64: EQArtists.Profile}

		init () {
			self.Profiles <- {}
		}

		destroy() {
			destroy self.Profiles
		}

		pub fun deposit(profile: @EQArtists.Profile) {
			log("depositing profile: ".concat(profile.name))
			let id: UInt64 = profile.id
			let oldProfile <- self.Profiles[id] <- profile
			destroy oldProfile
		}

		pub fun borrowProfile(artistId: UInt64): &EQArtists.Profile? {
			if self.Profiles[artistId] != nil {
				let ref: auth &EQArtists.Profile? = &self.Profiles[artistId] as auth &EQArtists.Profile?
				return ref
			} else {
				return nil
			}
		}

		pub fun addPrimaryAdmin(artistId: UInt64, newAdmin: Address) {
			let account = getAccount(newAdmin)
			let storagePath = "EQProfile".concat(artistId.toString()).concat("Admin")
			let collectionCapability = EQArtists.account.getCapability<&ArtistProfiles{AdminAccess}>(/private/EQProfileAdmin)
			let adminResources = account.getCapability<&EQArtists.AdminResources{EQArtists.AdminResourcesPublic}>(/public/EQAdminResources).borrow()
				?? panic("This wallet does not have an Admin Resources Collection")
			adminResources.deposit(adminResource: <- EQArtists.createProfileAdmin(collection: collectionCapability, artistId: artistId))
		}
	}

	// This interface restricts the ArtistProfiles collection for public access and returns profiles restricted by the PublicProfile interface .
	// The capability for this interface is linked in the public folder of EQ Music.
	pub resource interface PublicAccess {
		pub fun borrowProfile(artistId: UInt64): &EQArtists.Profile{PublicProfile}? {
			post {
				(result == nil) || (result?.id == artistId):
				"Cannot borrow profile reference: The ID of the returned reference is incorrect"
			}
		}
	}

	// This interface restricts the ArtistProfiles collection for private admin access and returns profiles restricted by the AdminProfile interface.
	// The capability for this interface is linked in the private folder of EQ Music, and access to the capability is store in the PrimaryAdmin resource.
	pub resource interface AdminAccess {
		pub fun borrowProfile(artistId: UInt64): &EQArtists.Profile{AdminProfile}? {
			post {
				(result == nil) || (result?.id == artistId):
				"Cannot borrow profile reference: The ID of the returned reference is incorrect"
			}
		}
	}

	// PROFILES & INTERFACES
	// Profile is the individual profile resource, stored in ArtistProfiles. The Profile holds all the artist's metadata and stores thier collectible templates.
	// The royalty cut for each artist is also stored in the Profile and can be set from the Admin Resource. Profiles can be locked and unlocked by the EQ Collectibles Admin.
	// Locking a profile prevents Profile Admins from being able to access or edit profile information, and from creating or editing templates.
	pub resource Profile: PublicProfile, AdminProfile {
		pub let id: UInt64
		pub var name: String
		pub var description: String
		pub var avatar: String
		pub var collectibleTemplates: @{UInt64: AnyResource}
		pub var totalCollectibles : UInt64
		pub var totalMintedByTemplate: {UInt64: UInt64}
		pub var royalties: [Royalty]
		pub var locked: Bool

		init(
			name: String,
			description: String,
			avatar: String,
			royalties: [Royalty]
		) {
			EQArtists.totalProfiles = EQArtists.totalProfiles + 1
			self.id = EQArtists.totalProfiles
			self.name = name
			self.description = description
			self.avatar = avatar
			self.collectibleTemplates <- {}
			self.totalCollectibles = 0
			self.totalMintedByTemplate = {}
			self.royalties = royalties
			self.locked = false
		}

		destroy() {
			destroy self.collectibleTemplates
		}

		pub fun getCollectibleIds(): [UInt64] {
			return self.collectibleTemplates.keys
		}

		pub fun getCollectibleType(templateId: UInt64): Type? {
			if self.collectibleTemplates[templateId] != nil {
				let type = self.collectibleTemplates[templateId].getType()

				return type
			} else {return nil}

		}

		pub fun depositTemplate(template: @AnyResource) {
			pre{
					self.locked == false : "This profile is locked"
			}
			let type = template.getType()
			switch type {
				case Type<@EQArtists.CollectibleTemplate>():
					let template <- template as! @CollectibleTemplate
					let oldTemplate <- self.collectibleTemplates[template.id] <- template
					destroy oldTemplate
				case Type<@EQArtists.TicketTemplate>():
					let template <- template as! @TicketTemplate
					let oldTemplate <- self.collectibleTemplates[template.id] <- template
					destroy oldTemplate

				case Type<@EQArtists.IconTemplate>():
					let template <- template as! @IconTemplate
					let oldTemplate <- self.collectibleTemplates[template.id] <- template
					destroy oldTemplate

				case Type<@EQArtists.AccessoryTemplate>():
					let template <- template as! @AccessoryTemplate
					let oldTemplate <- self.collectibleTemplates[template.id] <- template
					destroy oldTemplate

				default:
						destroy template
			}
		}

		pub fun getTemplate(templateId: UInt64): TemplateData? {
			if self.collectibleTemplates[templateId] != nil {
				let type = self.collectibleTemplates[templateId].getType()
				switch type {
					case Type<@EQArtists.CollectibleTemplate?>():
						let template = self.borrowCollectibleTemplate(templateId: templateId)
						return TemplateData(
								id: templateId,
								artistId: template.artistId,
								applicableArtists: nil,
								name: template.name,
								description: template.description,
								image: template.image,
								imageModifier: template.imageModifier,
								mintLimit: template.mintLimit,
								ownsAccessories: false,
								layer: nil,
								category: nil,
								royalties: template.royalties
						);
					case Type<@EQArtists.IconTemplate?>():
						let template = self.borrowIconTemplate(templateId: templateId)
						return TemplateData(
								id: templateId,
								artistId: template.artistId,
								applicableArtists: nil,
								name: template.name,
								description: template.description,
								image: template.image,
								imageModifier: template.imageModifier,
								mintLimit: template.mintLimit,
								ownsAccessories: true,
								layer: template.layer,
								category: nil,
								royalties: template.royalties
						);
					case Type<@EQArtists.AccessoryTemplate?>():
						let template = self.borrowAccessoryTemplate(templateId: templateId)
						return TemplateData(
								id: templateId,
								artistId: template.artistId,
								applicableArtists: template.applicableArtists,
								name: template.name,
								description: template.description,
								image: template.image,
								imageModifier: template.imageModifier,
								mintLimit: template.mintLimit,
								ownsAccessories: false,
								layer: template.layer,
								category: template.category ,
								royalties: template.royalties
						);
					case Type<@EQArtists.TicketTemplate?>():
						let template = self.borrowTicketTemplate(templateId: templateId)
						return TemplateData(
								id: templateId,
								artistId: template.artistId,
								applicableArtists: nil,
								name: template.name,
								description: template.description,
								image: template.image,
								imageModifier: template.imageModifier,
								mintLimit: template.mintLimit,
								ownsAccessories: false,
								layer: nil,
								category: nil ,
								royalties: template.royalties
					);
					default:
						log("could not borrow template")
						return nil
				}
			} else {
				return nil
			}
		}

		pub fun getTotalTemplates(): Int {
			return self.collectibleTemplates.length
		}

		access(contract) fun borrowCollectibleTemplate(templateId: UInt64): &CollectibleTemplate {
			log("borrowing collectible")
			let ref = &self.collectibleTemplates[templateId] as auth &AnyResource
			let template = ref as! &CollectibleTemplate
			return template
		}

		access(contract) fun borrowTicketTemplate(templateId: UInt64): &TicketTemplate {
			log("borrowing collectible")
			let ref = &self.collectibleTemplates[templateId] as auth &AnyResource
			let template = ref as! &TicketTemplate
			return template
		}

		access(contract) fun borrowIconTemplate(templateId: UInt64): &IconTemplate  {
			log("borrowing icon")
			let ref = &self.collectibleTemplates[templateId] as auth &AnyResource
			let template = ref as! &IconTemplate
			return template
		}

		access(contract) fun borrowAccessoryTemplate(templateId: UInt64): &AccessoryTemplate  {
			log("borrowing accessory")
			let ref = &self.collectibleTemplates[templateId] as auth &AnyResource
			let template = ref as! &AccessoryTemplate
			return template
		}

		pub fun borrowCollection(): {UInt64: AnyStruct} {
			// pre{
			//     self.locked == false : "This profile is locked"
			// }
			var collection: {UInt64: AnyStruct} = {}
			for templateId in self.collectibleTemplates.keys {
					let ref = (&self.collectibleTemplates[templateId] as auth &AnyResource?)!
					collection[templateId] = ref
			}
			return collection
		}

		pub fun getImageURL(templateId: UInt64, nftId: UInt64): String? {
			let template = self.getTemplate(templateId: templateId)!
			let isUnique = template.imageModifier != nil
			if isUnique {
					return template.image.concat(nftId.toString()).concat(template.imageModifier!)
			} else {
					return template.image
			}
		}

		access(contract) fun incrementTemplateNumber(): UInt64 {
			self.totalCollectibles = self.totalCollectibles + 1
			return self.totalCollectibles
		}

		pub fun addApplicableArtistToTemplate(templateId: UInt64, artistId: UInt64){
			pre {
					self.locked == false : "This profile is locked"
					self.collectibleTemplates[templateId].isInstance(Type<@EQArtists.AccessoryTemplate?>()) : "This template is not an Accessory Template"
			}

			let template = self.borrowAccessoryTemplate(templateId: templateId)
			template.addApplicableArtist(artistId: artistId)
		}

		pub fun changeName(newName: String){
			self.name = newName
			log("profile name changed to ".concat(newName))
		}

		pub fun changeDescription(newDescription: String){
			self.description = newDescription
		}

		pub fun changeAvatar(newAvatar: String){
			self.avatar = newAvatar
		}

		pub fun borrowTemplate(templateId: UInt64): auth &AnyResource {
			pre{
					self.locked == false : "This profile is locked"
			}
			return &self.collectibleTemplates[templateId] as auth &AnyResource
		}

		access(contract) fun setRoyalties(newRoyalties: [Royalty]){
			self.royalties = newRoyalties
		}

		access(contract) fun lockProfile() {
			self.locked = true
		}

		access(contract) fun unlockProfile() {
			self.locked = false
		}
	}

	// This interface restricts a Profile to publically viewable information. It can be accessed through the ArtistProfiles{PublicAccess} capability linked in EQ Music's public folder.
	pub resource interface PublicProfile {
		pub let id: UInt64
		pub var name: String
		pub var description: String
		pub var avatar: String
		pub var totalCollectibles: UInt64
		pub var totalMintedByTemplate: {UInt64: UInt64}
		pub var royalties: [Royalty]
		pub fun borrowCollection(): {UInt64: AnyStruct}?
		access(contract) fun incrementTemplateNumber(): UInt64
		pub fun getImageURL(templateId: UInt64, nftId: UInt64): String?
		pub fun getTemplate(templateId: UInt64): TemplateData?
		pub fun getCollectibleIds(): [UInt64]
		pub fun getCollectibleType(templateId: UInt64): Type?
	}

	// This interface retricts a Profile to the viewable information and functions used to manage a profile. An artist can use this interface to alter thier metadata or create new collectibles.
	// It can be accessed through the ArtistProfiles{AdminAccess} capability linked in EQ Musics private folder, and stored in the PrimaryAdmin resource created with the profile.
	pub resource interface AdminProfile {
		pub let id: UInt64
		pub var name: String
		pub var description: String
		pub var avatar: String
		pub var collectibleTemplates: @{UInt64: AnyResource}
		pub var totalCollectibles : UInt64
		pub var totalMintedByTemplate: {UInt64: UInt64}
		pub var royalties: [Royalty]
		pub var locked: Bool

		pub fun changeName(newName: String)
		pub fun changeDescription(newDescription: String)
		pub fun changeAvatar(newAvatar: String)
		pub fun addApplicableArtistToTemplate(templateId: UInt64, artistId: UInt64)
		pub fun getCollectibleType(templateId: UInt64): Type?
		pub fun borrowTemplate(templateId: UInt64): auth &AnyResource
		access(contract) fun setRoyalties(newRoyalties: [Royalty])
	}

	// AdminResources is a collection that stores resources for profile administrators. This collection stores both PrimaryAdmin and SecondaryAdmin resources.
	// Borrowing a PrimaryAdmin comes with special privileges and functions stored in the PrimaryAdmin resource. Borrowing a profile (borrowProfile()) is used to
	// gain accesses to a Profile{AdminProfile}.
	pub resource AdminResources: AdminResourcesPublic {
			pub var primaryAdmin: @{UInt64: PrimaryAdmin}
			pub var secondaryAdmin: @{UInt64: SecondaryAdmin}

			init(){
					self.primaryAdmin <- {}
					self.secondaryAdmin <- {}
			}

			destroy() {
					destroy self.primaryAdmin
					destroy self.secondaryAdmin
			}

			pub fun deposit(adminResource: @AnyResource) {
					let type = adminResource.getType()
					switch type{
							case Type<@PrimaryAdmin>():
									let profileAdmin <- adminResource as! @PrimaryAdmin
									let id = profileAdmin.artistId
									let oldAdminResource <- self.primaryAdmin[id] <- profileAdmin
									destroy oldAdminResource

							case Type<@SecondaryAdmin>():
									let SecondaryAdmin <- adminResource as! @SecondaryAdmin
									let id = SecondaryAdmin.artistId
									let oldAdminResource <- self.secondaryAdmin[id] <- SecondaryAdmin
									destroy oldAdminResource

							default:
									destroy adminResource
					}
			}

			pub fun borrowPrimaryAdmin(artistId: UInt64): &PrimaryAdmin? {
					if self.primaryAdmin[artistId] != nil {
							let ref = &self.primaryAdmin[artistId] as auth &PrimaryAdmin?
							return ref
					} else {
							return nil
					}
			}

			pub fun borrowProfile(artistId: UInt64): &Profile{AdminProfile}? {
					post {
							(result == nil) || (result?.id == artistId) : "This profile does not match this artistId"
					}

					if self.primaryAdmin.keys.contains(artistId) {
							let admin = &self.primaryAdmin[artistId] as &PrimaryAdmin?
							let profile = admin!.accessProfile()
							return profile
					} else if self.secondaryAdmin.keys.contains(artistId) {
							let admin = &self.secondaryAdmin[artistId] as &SecondaryAdmin?
							let profile = admin!.accessProfile()
							return profile
					} else {
							return nil
					}

			}
	}

	//This interface publicly exposes the deposit function of AdminResources, so a PrimaryAdmin can create and deposit a SecondaryAdmin resource to another wallet.
	pub resource interface AdminResourcesPublic {
		pub fun deposit(adminResource: @AnyResource)
	}

	// @PrimaryAdmin is a resource created together with a @Profile. The @Profile is stored in EQ Music's wallet, and the @PrimaryAdmin is stored in the @AdminResources of the admin's wallet.
	// This resource stores a capability that references EQ Music's @ArtistProfiles collection, restricted by the {AdminAccess} interface. To prevent the admin from being able to access all profiles within
	// @ArtistProfiles, the capability is only accessabile by the EQArtists contract. Access to the profile is granted via the accessProfile() function, which borrows the capability and uses another variable
	// stored in the resource, artistId, to access the appropriate profile. This resource also gives the admin the ability to manage royalties and collectible templates. The owner of @PrimaryAdmin can also
	// create a @SecondaryAdmin and store within it a Capability linked to the admins own @AdminResources by a unique private path. This private path can be unlinked and linked again in order to revoke or reinstate
	// secondary admin access.
	pub resource PrimaryAdmin {
		access(contract) let collection: Capability<&ArtistProfiles{AdminAccess}>
		access(contract) let artistId: UInt64
		access(contract) var totalAdmins: UInt64

		init(
			collection: Capability<&ArtistProfiles{AdminAccess}>,
			artistId: UInt64
		) {
			self.collection = collection
			self.artistId = artistId
			self.totalAdmins = 0
		}

		pub fun accessProfile(): &Profile{AdminProfile} {
			post {
				!result.locked : "This profile is locked"
			}
			let collection = self.collection.borrow()!
			let profile = collection.borrowProfile(artistId: self.artistId)
			return profile!

		}

		access(contract) fun incrementTotalAdmins(): UInt64 {
			self.totalAdmins = self.totalAdmins + 1
			return self.totalAdmins
		}

		pub fun addAdmin(admin: AuthAccount, newAdmin: Address) {
			pre {
				!self.accessProfile().locked : "This profile is locked"
			}
			let artistId = self.artistId.toString()
			let privatePathString = "EQProfile".concat(artistId).concat("SecondaryAdmin_").concat(self.incrementTotalAdmins().toString())
			let privatePath = PrivatePath(identifier: privatePathString)!
			let uniqueCapability = admin.link<&AdminResources>(privatePath, target: EQArtists.AdminResourcesPath)!
			let account = getAccount(newAdmin)
			let adminResources = account.getCapability<&AdminResources{AdminResourcesPublic}>(/public/EQAdminResources).borrow()
				?? panic("This account does not have an Admin Resources Collection")
			adminResources.deposit(adminResource: <- create SecondaryAdmin(capability: uniqueCapability, artistId: self.artistId))
		}

		pub fun unlinkAdmin(admin: AuthAccount, unlinkId: UInt64) {
			let privatePathString = "EQProfile".concat(self.artistId.toString()).concat("SecondaryAdmin_").concat(unlinkId.toString())
			let privatePath = PrivatePath(identifier: privatePathString)!
			admin.unlink(privatePath)
		}

		pub fun relinkAdmin(admin: AuthAccount, relinkId: UInt64) {
			pre {
				!self.accessProfile().locked : "This profile is locked"
				relinkId <= self.totalAdmins : "this link id has not been used yet"
			}
			let artistId = self.artistId.toString()
			let privatePathString = "EQProfile".concat(artistId).concat("SecondaryAdmin_").concat(relinkId.toString())
			let privatePath = PrivatePath(identifier: privatePathString)!
			admin.link<&AdminResources>(privatePath, target: EQArtists.AdminResourcesPath)!
		}

		pub fun setProfileRoyalties(newRoyalties: [Royalty]) {
			pre {
				EQArtists.getCutTotal(royalties: newRoyalties) +  EQArtists.getHighestTemplateCut(artistId: self.artistId) <= EQArtists.royaltyLimit
					: "Royaly limit is ".concat(Int(EQArtists.royaltyLimit * 100.0).toString().concat("%"))
			}
			let profile = self.accessProfile()
			profile.setRoyalties(newRoyalties: newRoyalties)
		}

		pub fun createCollectibleTemplate(
			name: String,
			description: String,
			image: String,
			imageModifier: String?,
			mintLimit: UInt64,
			royalties: [Royalty]
		) {
			pre {
				self.accessProfile().locked == false : "This profile is locked"
			}
			EQArtists.createCollectibleTemplate(
				artistId: self.artistId,
				name: name,
				description: description,
				image: image,
				imageModifier: imageModifier,
				mintLimit: mintLimit,
				royalties: royalties
			)
		}

		pub fun createIconTemplate(
			name: String,
			description: String,
			category: String,
			mintLimit: UInt64,
			image: String,
			imageModifier: String?,
			layer: String,
			royalties: [Royalty]
		) {
			pre {
				!self.accessProfile().locked : "This profile is locked"
			}
			EQArtists.createIconTemplate(
				artistId: self.artistId,
				name: name,
				description: description,
				category: category,
				mintLimit: mintLimit,
				image: image,
				imageModifier: imageModifier,
				layer: layer,
				royalties: royalties
			)
		}

		pub fun createAccessoryTemplate(
			name: String,
			description: String,
			category: String,
			image: String,
			imageModifier: String?,
			layer: String,
			mintLimit: UInt64,
			royalties: [Royalty]
		) {
			pre {
				!self.accessProfile().locked : "This profile is locked"
			}
			EQArtists.createAccessoryTemplate(
				artistId: self.artistId,
				name: name,
				description: description,
				category: category,
				image: image,
				imageModifier: imageModifier,
				layer: layer,
				mintLimit: mintLimit,
				royalties: royalties
			)
		}

		pub fun setTemplateRoyalties(templateId: UInt64, newRoyalties: [Royalty]) {
			pre {
				!self.accessProfile().locked! : "This profile is locked"
			}
			let profile = self.accessProfile()
			let artistCutTotal = EQArtists.getCutTotal(royalties: profile.royalties)
			let templateCutTotal = EQArtists.getCutTotal(royalties: newRoyalties)
			let totalCut = artistCutTotal + templateCutTotal
			if totalCut <= EQArtists.royaltyLimit {
				let ref = &profile.collectibleTemplates[templateId] as auth &AnyResource
				let type = profile.getCollectibleType(templateId: templateId)
				switch type {
					case Type<@CollectibleTemplate>():
						let template = ref as! &CollectibleTemplate
						template.setRoyalties(newRoyalties: newRoyalties)

					case Type<@IconTemplate>():
						let template = ref as! &IconTemplate
						template.setRoyalties(newRoyalties: newRoyalties)

					case Type<@AccessoryTemplate>():
						let template = ref as! &AccessoryTemplate
						template.setRoyalties(newRoyalties: newRoyalties)
				}
			} else { panic("total royalties must be below ".concat(Int(EQArtists.royaltyLimit * 100.0).toString().concat("%")))}
		}
	}

	//@SecondaryAdmin stores a Capability via a unique private path linked to a profile admins @AdminResources. Similar to a @PrimaryAdmin, the Capability is only accessable by the EQArtists contract and provides
	// access to a profile by the sole function of @SecondaryAdmin, accessProfile(). This function borrows the stored Capability, and uses the stored artistId to access the profile from the granting admin's @PrimaryAdmin
	// resource.
	pub resource SecondaryAdmin {
		access(contract) let capability: Capability<&AdminResources>
		access(contract) let artistId: UInt64

		init(
			capability: Capability<&AdminResources>,
			artistId: UInt64
		) {
			self.capability = capability
			self.artistId = artistId
		}

		pub fun accessProfile() :&Profile{AdminProfile} {
			let collection = self.capability.borrow() ?? panic("This capability has been unlinked")
			let admin = collection.borrowPrimaryAdmin(artistId: self.artistId)!
			let profile = admin.accessProfile()
			return profile
		}
	}

	pub fun createEmptyCollection(): @ArtistProfiles {
		return <- create ArtistProfiles()
	}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////COLLECTIBLE TEMPLATES
	// The @CollectibleTemplate is used to create general NFTs. This template holds the basic information to populate the NFT initializing function and can be
	// modified by the profile admins. Each template resource contains the relevant fields for how the NFTs will be used (as a collectible, and icon, or an accessory).
	// The imageModifier field is used by the MetadataResolver. If each individual collectible has the same image, then a imageModifier is not used. If each individual
	// collectible is unique, the image field will point to the ipfs folder containing each individual image, and the imageModifier will hold the file extension (ex: .png).
	// The MetadataResolver will append the tokenId and the imageModifier to the end of the image address to return the correct NFT image file.
	pub resource CollectibleTemplate {
		pub let id: UInt64
		pub let artistId: UInt64
		pub var name: String
		pub var description: String
		pub var image: String
		pub var imageModifier: String?
		pub var mintLimit: UInt64
		pub var royalties: [Royalty]

		init(
			artistId: UInt64,
			name: String,
			description: String,
			image: String,
			imageModifier: String?,
			mintLimit: UInt64,
			royalties: [Royalty]
		) {
			EQArtists.totalTemplates = EQArtists.totalTemplates + 1
			self.id = EQArtists.totalTemplates
			self.artistId = artistId
			self.name = name
			self.description = description
			self.mintLimit = mintLimit
			self.image = image
			self.imageModifier = imageModifier
			self.royalties = royalties
		}

		pub fun updateImage(newImage: String) {
			self.image = newImage
		}
		pub fun updateDescription(newDescription: String) {
			self.description = newDescription
		}
		pub fun updateName(newName: String){
			self.name = newName
		}
		pub fun updateMintLimit(newLimit: UInt64){
			self.mintLimit = newLimit
		}

		access(contract) fun setRoyalties(newRoyalties: [Royalty]){
			self.royalties = newRoyalties
		}
	}

	pub resource TicketTemplate {
		pub let id: UInt64
		pub let artistId: UInt64
		pub var name: String
		pub var description: String
		pub var image: String
		pub var imageModifier: String?
		pub var mintLimit: UInt64
		pub var royalties: [Royalty]

		init(
			artistId: UInt64,
			name: String,
			description: String,
			image: String,
			imageModifier: String?,
			mintLimit: UInt64,
			royalties: [Royalty]
		) {
			EQArtists.totalTemplates = EQArtists.totalTemplates + 1
			self.id = EQArtists.totalTemplates
			self.artistId = artistId
			self.name = name
			self.description = description
			self.mintLimit = mintLimit
			self.image = image
			self.imageModifier = imageModifier
			self.royalties = royalties
		}

		pub fun updateImage(newImage: String) {
			self.image = newImage
		}
		pub fun updateDescription(newDescription: String) {
			self.description = newDescription
		}
		pub fun updateName(newName: String){
			self.name = newName
		}
		pub fun updateMintLimit(newLimit: UInt64){
			self.mintLimit = newLimit
		}

		access(contract) fun setRoyalties(newRoyalties: [Royalty]){
			self.royalties = newRoyalties
		}
	}

	// The @IconTemplate is used for EQ Icons. Icons are composable NFTs meant to represent the artist. The image field for an Icon is not an IPFS address, but rather an eqmusic.io
	// address. The EQ backend composes the image based on the layer field (the base layer of the composable NFT) and the layers of each accessory (@AccessoryTemplate) held in the
	// icon @NFT's @AccessoryCollection. In the template, the boolean field ownedAccessories determines if the @NFT initializer should create an @AccessoryCollection for the @NFT.
	pub resource IconTemplate {
		pub let id: UInt64
		pub let artistId: UInt64
		pub var name: String
		pub var description: String
		pub var mintLimit: UInt64
		pub var ownedAccessories: Bool
		pub var image: String
		pub var imageModifier: String?
		pub var layer: String
		pub var royalties: [Royalty]

		init(
			name: String,
			description: String,
			mintLimit: UInt64,
			image: String,
			imageModifier: String?,
			layer: String,
			artistId: UInt64,
			royalties: [Royalty]
		) {
			EQArtists.totalTemplates = EQArtists.totalTemplates + 1
			self.id = EQArtists.totalTemplates
			self.artistId = artistId
			self.name = name
			self.description = description
			self.mintLimit = mintLimit
			self.ownedAccessories = true
			self.image = image
			self.imageModifier = imageModifier
			self.layer = layer
			self.royalties = royalties
		}

		pub fun updateImage(newImage: String) {
			self.image = newImage
		}
		pub fun updateLayer(newLayer: String) {
			self.layer = newLayer
		}
		pub fun updateDescription(newDescription: String) {
			self.description = newDescription
		}
		pub fun updateName(newName: String){
			self.name = newName
		}
		pub fun updateMintLimit(newLimit: UInt64){
			self.mintLimit = newLimit
		}

		access(contract) fun setRoyalties(newRoyalties: [Royalty]){
			self.royalties = newRoyalties
		}
	}

	// The @AccessoryTemplate is used for create accessory @NFTs for icon @NFTs. The image field for accessories are IPFS addresses and is used for marketplace views, while the layer
	// field hold the .png neccessary for compiling the icon @NFT image by the EQ backend. Additionally, the @AccessoryTemplate has an extra field, category. This field is used as a
	// label for what type of accessory the template is (hat, pants, jacket, etc).
	pub resource AccessoryTemplate {
		pub let id: UInt64
		pub let artistId: UInt64
		pub var applicableArtists: [UInt64]
		pub var name: String
		pub var description: String
		pub var category: String
		pub var mintLimit: UInt64
		pub var image: String
		pub var imageModifier: String?
		pub var layer: String?
		pub var royalties: [Royalty]

		init(
			artistId: UInt64,
			name: String,
			description: String,
			category: String,
			image: String,
			imageModifier: String?,
			layer: String,
			mintLimit: UInt64,
			royalties: [Royalty]
		) {
			EQArtists.totalTemplates = EQArtists.totalTemplates + 1
			self.id = EQArtists.totalTemplates
			self.artistId = artistId
			self.applicableArtists = [artistId]
			self.name = name
			self.description = description
			self.category = category
			self.mintLimit = mintLimit
			self.image = image
			self.imageModifier = imageModifier
			self.layer = layer
			self.royalties = royalties
		}

		pub fun updateImage(newImage: String) {
			self.image = newImage
		}
		pub fun updateLayer(newLayer: String) {
			self.layer = newLayer
		}
		pub fun updateDescription(newDescription: String) {
			self.description = newDescription
		}
		pub fun updateCategory(newCategory: String){
			self.category = newCategory
		}
		pub fun updateName(newName: String){
			self.name = newName
		}
		pub fun updateMintLimit(newLimit: UInt64){
			self.mintLimit = newLimit
		}
		pub fun addApplicableArtist(artistId: UInt64) {
			self.applicableArtists.append(artistId)
			log(self.applicableArtists)
		}
		access(contract) fun setRoyalties(newRoyalties: [Royalty]){
			self.royalties = newRoyalties
		}
	}

	// This struct is a universal template struct, utilizing optionals, to return the data of each Template to the @NFT initializer. This is used by the getTemplate() function of an
	// artist @Profile.
	pub struct TemplateData {
		pub let id: UInt64  //global id
		pub let artistId: UInt64
		pub let applicableArtists: [UInt64]?
		pub var name: String
		pub var description: String
		pub var image: String
		pub var imageModifier: String?
		pub var mintLimit: UInt64
		pub var ownsAccessories: Bool
		pub var layer: String?
		pub var category: String?
		pub var royalties: [Royalty]

		init(
			id: UInt64,
			artistId: UInt64,
			applicableArtists: [UInt64]?,
			name: String,
			description: String,
			image: String,
			imageModifier: String?,
			mintLimit: UInt64,
			ownsAccessories: Bool,
			layer: String?,
			category: String?,
			royalties: [Royalty]
		) {
			self.id = id
			self.artistId = artistId
			self.applicableArtists = applicableArtists
			self.name = name
			self.description = description
			self.image = image
			self.imageModifier = imageModifier
			self.mintLimit = mintLimit
			self.ownsAccessories = ownsAccessories
			self.layer = layer
			self.category = category
			self.royalties = royalties
		}
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////CONTRACT FUNCTIONS
	access(contract) fun createArtistProfile(
		account: AuthAccount,
		name: String,
		description: String,
		avatar: String,
		royalties: [Royalty]
	) {
		var newProfile <- create Profile(
			name: name,
			description: description,
			avatar: avatar,
			royalties: royalties
		)
		let artistId = newProfile.id
		let storagePath = "EQProfile".concat(artistId.toString()).concat("Admin")
		self.account.borrow<&EQArtists.ArtistProfiles>(from: EQArtists.ProfilesStoragePath)!.deposit(profile: <- newProfile)

		let collectionCapability = self.account.getCapability<&ArtistProfiles{AdminAccess}>(/private/EQProfileAdmin)
		account.save(<- EQArtists.createAdminResources(), to: EQArtists.AdminResourcesPath)
		account.link<&EQArtists.AdminResources{AdminResourcesPublic}>(/public/EQAdminResources, target: EQArtists.AdminResourcesPath)
		account.borrow<&AdminResources>(from: EQArtists.AdminResourcesPath)!.deposit(adminResource: <- EQArtists.createProfileAdmin(collection: collectionCapability, artistId: artistId))
		account.save(<- EQArtists.createProfileAdmin(collection: collectionCapability, artistId: artistId), to: StoragePath(identifier: storagePath)!)
	};

	access(contract) fun createCustodialProfile(
		name: String,
		description: String,
		avatar: String,
		royalties: [Royalty]
	) {
		var newProfile <- create Profile(
			name: name,
			description: description,
			avatar: avatar,
			royalties: royalties
		)
		self.account.borrow<&EQArtists.ArtistProfiles>(from: EQArtists.ProfilesStoragePath)!.deposit(profile: <- newProfile)
	}

	pub fun createAdminResources(): @AdminResources {
		return <- create AdminResources()
	}

	access(contract) fun createProfileAdmin(collection: Capability<&ArtistProfiles{AdminAccess}>, artistId: UInt64): @PrimaryAdmin {
		return <- create PrimaryAdmin(collection: collection, artistId: artistId)
	}

	access(contract) fun createCollectibleTemplate(
		artistId: UInt64,
		name: String,
		description: String,
		image: String,
		imageModifier: String?,
		mintLimit: UInt64,
		royalties: [Royalty]
	) {

		var newTemplate <- create CollectibleTemplate(
			artistId: artistId,
			name: name,
			description: description,
			image: image,
			imageModifier: imageModifier,
			mintLimit: mintLimit,
			royalties: royalties
		)
		self.totalMintedByTemplate[newTemplate.id] = 0
		self.account.borrow<&EQArtists.ArtistProfiles>(from: EQArtists.ProfilesStoragePath)!.borrowProfile(artistId: artistId)!.depositTemplate(template: <- newTemplate)
		EQArtists.incrementTemplateNumber(artistId: artistId)
	}

	access(contract) fun createIconTemplate(
		artistId: UInt64,
		name: String,
		description: String,
		category: String,
		mintLimit: UInt64,
		image: String,
		imageModifier: String?,
		layer: String,
		royalties: [Royalty]
	) {

		var newTemplate <- create IconTemplate(
			name: name,
			description: description,
			mintLimit: mintLimit,
			image: image,
			imageModifier: imageModifier,
			layer: layer,
			artistId: artistId,
			royalties: royalties
		)
			self.totalMintedByTemplate[newTemplate.id] = 0
			self.account.borrow<&EQArtists.ArtistProfiles>(from: EQArtists.ProfilesStoragePath)!.borrowProfile(artistId: artistId)!.depositTemplate(template: <- newTemplate)
			EQArtists.incrementTemplateNumber(artistId: artistId)
	}

	access(contract) fun createAccessoryTemplate(
		artistId: UInt64,
		name: String,
		description: String,
		category: String,
		image: String,
		imageModifier: String?,
		layer: String,
		mintLimit: UInt64,
		royalties: [Royalty]
	) {
		var newTemplate <- create AccessoryTemplate(
			artistId: artistId,
			name: name,
			description: description,
			category: category,
			image: image,
			imageModifier: imageModifier,
			layer: layer,
			mintLimit: mintLimit,
			royalties: royalties
		)
		self.totalMintedByTemplate[newTemplate.id] = 0
		self.account.borrow<&EQArtists.ArtistProfiles>(from: EQArtists.ProfilesStoragePath)!.borrowProfile(artistId: artistId)!.depositTemplate(template: <- newTemplate)
		EQArtists.incrementTemplateNumber(artistId: artistId)
	}

	pub fun borrowProfile(artistId: UInt64): &Profile{PublicProfile}? {
		var Profiles = self.account.getCapability(self.ProfilesPublicPath).borrow<&ArtistProfiles{PublicAccess}>()
		let profile = Profiles?.borrowProfile(artistId: artistId)!
		return profile!
	}

	access(contract) fun incrementTemplateNumber(artistId: UInt64): UInt64 {
		var Profiles = self.account.getCapability(self.ProfilesPublicPath).borrow<&ArtistProfiles{PublicAccess}>()
		let profile = Profiles?.borrowProfile(artistId: artistId)
		let total = profile!?.incrementTemplateNumber()!
		return total
	}

	pub fun getTotalMintedByTemplate(templateId: UInt64): UInt64 {
		return EQArtists.totalMintedByTemplate[templateId]!
	}

	access(contract) fun setTotalMintedByTemplate(templateId: UInt64, value: UInt64) {
		EQArtists.totalMintedByTemplate[templateId] = value
	}

	access(account) fun setRoyalites(newRoyalties: [Royalty]): [EQArtists.Royalty] {
		self.royalties = newRoyalties
		return self.royalties
	}

	access(contract) fun getCutTotal(royalties: [Royalty]): UFix64{
		var cutTotal:UFix64 = 0.0
		for royalty in royalties {
			log(royalty.cut)
			cutTotal = cutTotal + royalty.cut
		}
		log("cutTotal: ".concat(cutTotal.toString()))
		return cutTotal
	}

	access(contract) fun getHighestTemplateCut(artistId: UInt64): UFix64{
		var highestTemplateCut = 0.0
		let profile = self.borrowProfile(artistId: artistId)!
		let collection = profile.borrowCollection()!
		for key in collection.keys {
			var templateCut = 0.0
			let template = profile.getTemplate(templateId: key)!
			for royalty in template.royalties {
				log(royalty.cut)
				templateCut = templateCut + royalty.cut
			}
			if templateCut > highestTemplateCut {
				highestTemplateCut = templateCut
				log(highestTemplateCut)
			}
		}
			return highestTemplateCut
	}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////CONTRACT ADMIN & INTERFACE
	pub resource Admin: ProfileCreation {
		pub fun createNewAdmin(): @Admin {
			return <-create Admin()
		}

		pub fun setRoyalites(newRoyalties: [Royalty]): [EQArtists.Royalty] {
			EQArtists.setRoyalites(newRoyalties: newRoyalties)
			return EQArtists.royalties
		}

		pub fun setRoyaltyLimit(newLimit: UFix64) {
			EQArtists.royaltyLimit = newLimit
			log("New royalty limit set to: ".concat((EQArtists.royaltyLimit*100.0).toString()).concat("%"))
		}

		pub fun createArtistProfile(
			account: AuthAccount,
			name: String, 
			description: String,
			avatar: String,
			royalties: [Royalty]
		){
			EQArtists.createArtistProfile(
				account: account,
				name: name,
				description: description,
				avatar: avatar,
				royalties: royalties
			)
		}

		pub fun createCustodialProfile(
			name: String, 
			description: String,
			avatar: String,
			royalties: [Royalty]
		) {
			EQArtists.createCustodialProfile(
				name: name, 
				description: description, 
				avatar: avatar, 
				royalties: royalties
			)
		}

		pub fun lockProfile(artistId: UInt64){
			let profiles = EQArtists.account.borrow<&ArtistProfiles>(from: EQArtists.ProfilesStoragePath)!
			let profile = profiles.borrowProfile(artistId: artistId) ?? panic("There is not profile with this id")
			profile.lockProfile()
		}

		pub fun unlockProfile(artistId: UInt64){
			let profiles = EQArtists.account.borrow<&ArtistProfiles>(from: EQArtists.ProfilesStoragePath)!
			let profile = profiles.borrowProfile(artistId: artistId) ?? panic("There is not profile with this id")
			profile.unlockProfile()
		}

		pub fun createCollectibleTemplate(
			artistId: UInt64,
			name: String,
			description: String,
			image: String,
			imageModifier: String?,
			mintLimit: UInt64,
			royalties: [Royalty]
		) {
			EQArtists.createCollectibleTemplate(
				artistId: artistId,
				name: name,
				description: description,
				image: image,
				imageModifier: imageModifier,
				mintLimit: mintLimit,
				royalties: royalties
			)
		}

		pub fun createIconTemplate(
			artistId: UInt64,
			name: String,
			description: String,
			category: String,
			mintLimit: UInt64,
			image: String,
			imageModifier: String?,
			layer: String,
			royalties: [Royalty]
		) {
			EQArtists.createIconTemplate(
				artistId: artistId,
				name: name,
				description: description,
				category: category,
				mintLimit: mintLimit,
				image: image,
				imageModifier: imageModifier,
				layer: layer,
				royalties: royalties
			)
		}

		pub fun createAccessoryTemplate(
			artistId: UInt64,
			name: String,
			description: String,
			category: String,
			image: String,
			imageModifier: String?,
			layer: String,
			mintLimit: UInt64,
			royalties: [Royalty]
		) {
			EQArtists.createAccessoryTemplate(
				artistId: artistId,
				name: name,
				description: description,
				category: category,
				image: image,
				imageModifier: imageModifier,
				layer: layer,
				mintLimit: mintLimit,
				royalties: royalties    
			)
		}
	}

	pub resource interface ProfileCreation {
		pub fun createArtistProfile(            
			account: AuthAccount,
			name: String, 
			description: String,
			avatar: String,
			royalties: [Royalty]
		)
	}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////CONTRACT INITIALIZER
	init(){
		self.AdminStoragePath = /storage/EQContractAdmin
		self.ProfilesStoragePath = /storage/EQArtistProfiles
		self.ProfilesPublicPath = /public/EQArtistProfiles
		self.ProfilesPrivatePath = /private/EQArtistProfiles
		self.AdminResourcesPath = /storage/EQArtistAdminResources
		self.totalProfiles = 0
		self.totalTemplates = 0
		self.totalMintedByTemplate = {}
		self.royalties = []
		self.royaltyLimit = 0.07

		self.account.save(<- create Admin(), to: EQArtists.AdminStoragePath)
		self.account.link<&EQArtists.Admin{EQArtists.ProfileCreation}>(/private/EQProfileCreation, target: EQArtists.AdminStoragePath)
		self.account.save<@EQArtists.ArtistProfiles>(<- create ArtistProfiles(), to: EQArtists.ProfilesStoragePath)
		self.account.link<&EQArtists.ArtistProfiles{EQArtists.PublicAccess}>(EQArtists.ProfilesPublicPath, target: EQArtists.ProfilesStoragePath)
		self.account.link<&EQArtists.ArtistProfiles{EQArtists.AdminAccess}>(/private/EQProfileAdmin, target: EQArtists.ProfilesStoragePath)
	}
}
 