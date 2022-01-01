address 0x69F1E543A3BeF043B63BEd825fcd2cf6 {
module KikoCatElement01 {
    use 0x1::Signer;
    use 0x1::Event;
    use 0x1::NFT::{Self, NFT};
    use 0x1::NFTGallery;

    const NFT_ADDRESS: address = @0x69F1E543A3BeF043B63BEd825fcd2cf6;

    const PERMISSION_DENIED: u64 = 100001;

    // ******************** NFT ********************
    // NFT extra meta
    struct KikoCatMeta has copy, store, drop {
        type: vector<u8>,
        type_id: u64,
        property: vector<u8>,
        score: u128,
    }

    // NFT body
    struct KikoCatBody has copy, store, drop {}

    // NFT extra type info
    struct KikoCatTypeInfo has copy, store, drop {}

    struct KikoCatNFTCapability has key {
        mint: NFT::MintCapability<KikoCatMeta>,
    }

    // init nft with image data
    fun init_nft(
        sender: &signer,
        metadata: NFT::Metadata,
    ) {
        NFT::register<KikoCatMeta, KikoCatTypeInfo>(sender, KikoCatTypeInfo {}, metadata);
        let mint = NFT::remove_mint_capability<KikoCatMeta>(sender);
        move_to(sender, KikoCatNFTCapability { mint });
    }

    // mint nft
    fun mint_nft(
        sender: &signer,
        metadata: NFT::Metadata,
        type: vector<u8>,
        type_id: u64,
        property: vector<u8>,
        score: u128,
    ) acquires KikoCatNFTCapability, Events {
        let sender_address = Signer::address_of(sender);
        let cap = borrow_global_mut<KikoCatNFTCapability>(sender_address);
        let nft = NFT::mint_with_cap<KikoCatMeta, KikoCatBody, KikoCatTypeInfo>(
            sender_address,
            &mut cap.mint,
            metadata,
            KikoCatMeta {
                type,
                type_id,
                property,
                score,
            },
            KikoCatBody {}
        );
        let events = borrow_global_mut<Events>(sender_address);
        let id = NFT::get_id<KikoCatMeta, KikoCatBody>(&nft);
        NFTGallery::deposit(sender, nft);

        Event::emit_event<NFTMintEvent<KikoCatMeta>>(&mut events.nft_mint_events,
            NFTMintEvent {
                creator: sender_address,
                id: id,
            },
        );
    }

    public fun get_type_id(nft: &NFT<KikoCatMeta, KikoCatBody>) : u64 {
        let meta = NFT::get_type_meta<KikoCatMeta, KikoCatBody>(nft);
        return meta.type_id
    }

    public fun get_score(nft: &NFT<KikoCatMeta, KikoCatBody>) : u128 {
        let meta = NFT::get_type_meta<KikoCatMeta, KikoCatBody>(nft);
        return meta.score
    }

    // ******************** NFT Events ********************
    // kiko gallery
    struct Events has key, store {
        nft_mint_events: Event::EventHandle<NFTMintEvent<KikoCatMeta>>,
    }

    // nft mint event
    struct NFTMintEvent<NFTMeta: store + drop> has drop, store {
        creator: address,
        id: u64,
    }

    // init kiko gallery
    fun init_events(sender: &signer) {
        if (!exists<Events>(Signer::address_of(sender))) {
            let events = Events {
                nft_mint_events: Event::new_event_handle<NFTMintEvent<KikoCatMeta>>(sender),
            };
            move_to(sender, events);
        }
    }

    // ******************** NFT public function ********************

    // init nft and box with image
    public(script) fun init_with_image(
        sender: signer,
        name: vector<u8>,
        image: vector<u8>,
        description: vector<u8>,
    ) {
        assert(Signer::address_of(&sender) == NFT_ADDRESS, PERMISSION_DENIED);
        let metadata = NFT::new_meta_with_image(name, image, description);
        init_nft(&sender, metadata);
        init_events(&sender);
        NFTGallery::accept<KikoCatMeta, KikoCatBody>(&sender);
    }

    // mint NFT and box
    public(script) fun mint_with_image(
        sender: &signer,
        name: vector<u8>,
        image: vector<u8>,
        description: vector<u8>,
        type: vector<u8>,
        type_id: u64,
        property: vector<u8>,
        score: u128,
    ) acquires KikoCatNFTCapability, Events {
        let sender_address = Signer::address_of(sender);
        assert(sender_address == NFT_ADDRESS, PERMISSION_DENIED);
        let metadata = NFT::new_meta_with_image(name, image, description);
        mint_nft(sender,
            metadata,
            type,
            type_id,
            property,
            score,
        );
    }

}
}
