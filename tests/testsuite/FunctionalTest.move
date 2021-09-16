//! new-transaction
//! account: kiko, 0x111
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x111::KikoCat01;

    fun init(sender: signer) {
        KikoCat01::init(sender);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x111::KikoCat01;

    fun init(sender: signer) {
        KikoCat01::mint(
            sender,
            b"kiko cat",
            b"abcdefg",
            b"this is a cat",
            b"red",
            b"kaffe",
            b"hat",
        );
    }
}
// check: EXECUTED

//! new-transaction
//! sender: kiko
address kiko = {{kiko}};
script {
    use 0x111::KikoCat01;

    fun init(sender: signer) {
        KikoCat01::open_box(sender);
    }
}
// check: EXECUTED


//! new-transaction
//! account: alice
//! account: admin, 0x222
//! sender: admin
script {
    use 0x1::STC;
    use 0x222::NFTMarket;
    use 0x111::KikoCat01;

    fun init_buy_back_list(sender: signer) {
        NFTMarket::init_buy_back_list<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody, STC::STC>(&sender);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: admin
script {
    use 0x1::STC;
    use 0x222::NFTMarket;
    use 0x111::KikoCat01;

    fun nft_buy_back(sender: signer) {
        NFTMarket::nft_buy_back<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody, STC::STC>(&sender, 1u64, 12u128);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: kiko
script {
    use 0x1::STC;
    use 0x222::NFTMarket;
    use 0x111::KikoCat01;
    use 0x1::Errors;
    use 0x1::NFTGallery;
    use 0x1::NFT::NFTInfo;
    use 0x1::Signer;
    use 0x1::Debug;

    fun nft_buy_back_sell(sender: signer) {
        let sender_address = Signer::address_of(&sender);
        assert(NFTGallery::is_accept<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody>(sender_address), Errors::invalid_argument(111111));
        let info = NFTGallery::get_nft_info_by_idx<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody>(sender_address, 0u64);
        Debug::print<NFTInfo<KikoCat01::KikoCatMeta>>(&info);
        NFTMarket::nft_buy_back_sell<KikoCat01::KikoCatMeta, KikoCat01::KikoCatBody, STC::STC>(&sender, 1u64);
    }
}
// check: EXECUTED