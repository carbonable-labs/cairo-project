// Source: https://starkscan.co/class/0x0687acd1aa9dca381b305dcc7dfe1b8550fca9d2d7f81c9947c14a14149e9ef4#code
use starknet::ContractAddress;

#[starknet::interface]
trait IERC165<TContractState> {
    fn supportsInterface(self: @TContractState, interfaceId: felt252) -> bool;
}

#[starknet::interface]
trait IERC721Receiver<TContractState> {
    fn onERC721Received(ref self: TContractState, operator: ContractAddress, from: ContractAddress, tokenId: u256, data: Span<felt252>) -> felt252;
}

#[starknet::contract]
mod Project {
    // Core deps

    use array::ArrayTrait;

    // Starknet deps

    use starknet::ContractAddress;
    use starknet::get_caller_address;

    // Local deps
    use super::{IERC165Dispatcher, IERC165DispatcherTrait}; 
    use super::{IERC721ReceiverDispatcher, IERC721ReceiverDispatcherTrait}; 

    // Constants

    const INVALID_ID: felt252 = 0xffffffff;
    const IACCOUNT_ID: felt252 = 0xa66bd575;
    const IERC165_ID: felt252 = 0x01ffc9a7;
    const IERC721_ID: felt252 = 0x80ac58cd;
    const IERC721_RECEIVER_ID: felt252 = 0x150b7a02;
    const IERC721_METADATA_ID: felt252 = 0x5b5e139f;
    const IERC721_ENUMERABLE_ID: felt252 = 0x780e9d63;
    const IMPL_HASH: felt252 = 0x3864314828c08e9fd591506b9eebac815ff1584124c3db9059530a4617b7277;

    #[storage]
    struct Storage {
        // Cairopen
        strings_data: LegacyMap<(felt252, felt252), felt252>,
        strings_len: LegacyMap<felt252, felt252>,
        // Project
        CarbonableProject_times_len_: felt252,
        CarbonableProject_times_: LegacyMap<felt252, felt252>,
        CarbonableProject_absorptions_ton_equivalent_: felt252,
        CarbonableProject_absorptions_len_: felt252,
        CarbonableProject_absorptions_: LegacyMap<felt252, felt252>,
        // ERC165
        ERC165_supported_interfaces: LegacyMap<felt252, bool>,
        // Upgradeable
        Proxy_implementation_address: felt252,
        Proxy_admin: ContractAddress,
        Proxy_initialized: bool,
        // Ownable
        Ownable_owner: ContractAddress,
        // Access control
        AccessControl_role_admin: LegacyMap<felt252, ContractAddress>,
        AccessControl_role_member: LegacyMap<(felt252, ContractAddress), bool>,
        // ERC721
        ERC721_name: felt252,
        ERC721_symbol: felt252,
        ERC721_owners: LegacyMap<u256, ContractAddress>,
        ERC721_balances: LegacyMap<ContractAddress, u256>,
        ERC721_token_approvals: LegacyMap<u256, ContractAddress>,
        ERC721_operator_approvals: LegacyMap<(ContractAddress, ContractAddress), bool>,
        ERC721_token_uri: LegacyMap<u256, felt252>,
        // ERC721Enumerable
        ERC721Enumerable_all_tokens_len: u256,
        ERC721Enumerable_all_tokens: LegacyMap<u256, u256>,
        ERC721Enumerable_all_tokens_index: LegacyMap<u256, u256>,
        ERC721Enumerable_owned_tokens: LegacyMap<(ContractAddress, u256), u256>,
        ERC721Enumerable_owned_tokens_index: LegacyMap<u256, u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from_: ContractAddress,
        to: ContractAddress,
        tokenId: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        to: ContractAddress,
        tokenId: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        owner: ContractAddress,
        operator: ContractAddress,
        approved: bool,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        owner: ContractAddress,
    ) {
        self.initializer(name, symbol, owner);
    }

    #[generate_trait]
    #[external(v0)]
    impl UpgradeableImpl of UpgradeableTrait {
        fn getImplementationHash(self: @ContractState) -> felt252 {
            self.get_implementation_hash()
        }
        fn getAdmin(self: @ContractState) -> ContractAddress {
            self.get_admin()
        }
        fn upgrade(ref self: ContractState, new_implementation: felt252) {
            self.assert_only_admin();
            self._set_implementation_hash(new_implementation);
        }
        fn setAdmin(ref self: ContractState, new_admin: ContractAddress) {
            self.assert_only_admin();
            self._set_admin(new_admin);
        }
        fn restore(ref self: ContractState) {
            self.assert_only_admin();
            self._set_implementation_hash(IMPL_HASH);
        }
    }

    #[generate_trait]
    #[external(v0)]
    impl OwnableImpl of OwnableTrait {
        fn owner(self: @ContractState) -> ContractAddress {
            self.Ownable_owner.read()
        }
        fn transferOwnership(ref self: ContractState, newOwner: ContractAddress) {
            self.transfer_ownership(newOwner)
        }
        fn renounceOwnership(ref self: ContractState) {
            self.renounce_ownership();
        }
    }

    #[generate_trait]
    #[external(v0)]
    impl ERC165Impl of ERC165Trait {
        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            self.supports_interface(interfaceId)
        }
    }

    #[generate_trait]
    #[external(v0)]
    impl ERC721EnumerableImpl of ERC721EnumerableTrait {
        fn totalSupply(self: @ContractState) -> u256 {
            self.total_supply()
        }
        fn tokenByIndex(self: @ContractState, index: u256) -> u256 {
            self.token_by_index(index)
        }
        fn tokenOfOwnerByIndex(self: @ContractState, owner: ContractAddress, index: u256) -> u256 {
            self.token_of_owner_by_index(owner, index)
        }
    }

    #[generate_trait]
    #[external(v0)]
    impl ERC721MetadataImpl of ERC721MetadataTrait {
        fn name(self: @ContractState) -> felt252 {
            self.ERC721_name.read()
        }
        fn symbol(self: @ContractState) -> felt252 {
            self.ERC721_symbol.read()
        }
        fn tokenURI(self: @ContractState, tokenId: u256) -> Span<felt252> {
            let mut uri = self.base_uri();
            uri.append('token.json');
            uri.span()
        }
        fn contractURI(self: @ContractState) -> Span<felt252> {
            let mut uri = self.base_uri();
            uri.append('metadata.json');
            uri.span()
        }
        fn setURI(ref self: ContractState, uri: Span<felt252>) {
            assert(false, 'Project: Not implemented error');
        }
    }

    #[generate_trait]
    #[external(v0)]
    impl ERC721Impl of ERC721Trait {
        fn balanceOf(self: @ContractState, owner: ContractAddress) -> u256 {
            self.balance_of(owner)
        }
        fn ownerOf(self: @ContractState, tokenId: u256) -> ContractAddress {
            self.owner_of(tokenId)
        }
        fn getApproved(self: @ContractState, tokenId: u256) -> ContractAddress {
            self.get_approved(tokenId)
        }
        fn isApprovedForAll(self: @ContractState, owner: ContractAddress, operator: ContractAddress) -> bool {
            self.is_approved_for_all(owner, operator)
        }
        fn approve(ref self: ContractState, to: ContractAddress, tokenId: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'ERC721: caller is zero address');
            let owner = self.owner_of(tokenId);
            assert(to != owner, 'ERC721: approval to owner');
            assert(caller == owner || self.is_approved_for_all(owner, caller), 'ERC721: not owner nor approved');
            self._approve(to, tokenId);
        }
        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'ERC721: caller is zero');
            assert(!operator.is_zero(), 'ERC721: operator is zero');
            assert(operator != caller, 'ERC721: approve to caller');
            self.ERC721_operator_approvals.write((caller, operator), approved);
            self.emit(Event::ApprovalForAll(ApprovalForAll { owner: caller, operator: operator, approved: approved }));
        }
        fn transferFrom(ref self: ContractState, from: ContractAddress, to: ContractAddress, tokenId: u256) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'ERC721: caller is zero');
            assert(self._is_approved_or_owner(caller, tokenId), 'ERC721: not allowed');
            self._transfer(from, to, tokenId);
        }
        fn safeTransferFrom(ref self: ContractState, from: ContractAddress, to: ContractAddress, tokenId: u256, data: Span<felt252>) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'ERC721: caller is zero');
            assert(self._is_approved_or_owner(caller, tokenId), 'ERC721: not allowed');
            self._safe_transfer(from, to, tokenId, data);
        }
        fn mint(ref self: ContractState, to: ContractAddress, tokenId: u256) {
            assert(false, 'Project: Not implemented error');
        }
        fn burn(ref self: ContractState, tokenId: u256) {
            self.assert_only_token_owner(tokenId);
            self._burn(tokenId);
        }
    }

    #[generate_trait]
    #[external(v0)]
    impl CarbonableProject of CarbonableProjectTrait {
        fn getStartTime(self: @ContractState) {
            assert(false, 'Project: Not implemented error');
        }
        fn getFinalTime(self: @ContractState) {
            assert(false, 'Project: Not implemented error');
        }
        fn getTimes(self: @ContractState) {
            assert(false, 'Project: Not implemented error');
        }
        fn getAbsorptions(self: @ContractState) {
            assert(false, 'Project: Not implemented error');
        }
        fn getAbsorption(self: @ContractState, time: felt252) {
            assert(false, 'Project: Not implemented error');
        }
        fn getCurrentAbsorption(self: @ContractState) {
            assert(false, 'Project: Not implemented error');
        }
        fn getFinalAbsorption(self: @ContractState) {
            assert(false, 'Project: Not implemented error');
        }
        fn getTonEquivalent(self: @ContractState) {
            assert(false, 'Project: Not implemented error');
        }
        fn isSetup(self: @ContractState) {
            assert(false, 'Project: Not implemented error');
        }
        fn addMinter(ref self: ContractState, minter: ContractAddress) {
            assert(false, 'Project: Not implemented error');
        }
        fn setAbsorptions(ref self: ContractState, absorptions: Span<felt252>) {
            assert(false, 'Project: Not implemented error');
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn initializer(ref self: ContractState, name: felt252, symbol: felt252, owner: ContractAddress) {
            self.ERC721_name.write(name);
            self.ERC721_symbol.write(symbol);
            self.Ownable_owner.write(owner);
        }

        // Upgradeable

        fn assert_only_admin(self: @ContractState) {
            let caller = get_caller_address();
            let admin = self.Proxy_admin.read();
            assert(caller == admin, 'Proxy: caller is not admin');
        }
        fn get_implementation_hash(self: @ContractState) -> felt252 {
            self.Proxy_implementation_address.read()
        }
        fn get_admin(self: @ContractState) -> ContractAddress {
            self.Proxy_admin.read()
        }
        fn _set_admin(ref self: ContractState, new_admin: ContractAddress) {
            self.Proxy_admin.write(new_admin);
        }
        fn _set_implementation_hash(ref self: ContractState, new_implementation: felt252) {
            assert(new_implementation != 0, 'Proxy: impl hash cannot be zero');
            self.Proxy_implementation_address.write(new_implementation);
        }

        // Ownable

        fn assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            let owner = self.Ownable_owner.read();
            assert(!caller.is_zero(), 'Ownable: caller is the zero');
            assert(caller == owner, 'Ownable: caller is not owner');
        }
        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            assert(!new_owner.is_zero(), 'Ownable: new owner is the zero');
            self.assert_only_owner();
            self.Ownable_owner.write(new_owner);
        }
        fn renounce_ownership(ref self: ContractState) {
            self.assert_only_owner();
            let zero = starknet::contract_address_const::<0>();
            self.Ownable_owner.write(zero);
        }

        // ERC165

        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            interface_id == IERC165_ID || self.ERC165_supported_interfaces.read(interface_id)
        }
        fn register_interface(ref self: ContractState, interface_id: felt252) {
            assert(interface_id != INVALID_ID, 'ERC165: invalid interface id');
            self.ERC165_supported_interfaces.write(interface_id, true);
        }

        // ERC721

        fn assert_only_token_owner(self: @ContractState, token_id: u256) {
            let caller = get_caller_address();
            let owner = self.owner_of(token_id);
            assert(caller == owner, 'ERC721: caller is not owner');
        }
        fn balance_of(self: @ContractState, owner: ContractAddress) -> u256 {
            assert(!owner.is_zero(), 'ERC721: zero address');
            self.ERC721_balances.read(owner)
        }
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let owner = self.ERC721_owners.read(token_id);
            assert(!owner.is_zero(), 'ERC721: nonexistent token');
            owner
        }
        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            assert(self._exist(token_id), 'ERC721: nonexistent token');
            self.ERC721_token_approvals.read(token_id)
        }
        fn is_approved_for_all(self: @ContractState, owner: ContractAddress, operator: ContractAddress) -> bool {
            self.ERC721_operator_approvals.read((owner, operator))
        }

        // ERC721Metadata

        fn base_uri(self: @ContractState) -> Array<felt252> {
            let len = self.strings_len.read('uri');
            let mut uri: Array<felt252> = ArrayTrait::new();
            let mut index = 0;
            loop {
                if index == len {
                    break;
                }
                uri.append(self.strings_data.read(('uri', index)));
                index += 1;
            };
            uri
        }

        // ERC721Enumerable

        fn total_supply(self: @ContractState) -> u256 {
            self.ERC721Enumerable_all_tokens_len.read()
        }
        fn token_by_index(self: @ContractState, index: u256) -> u256 {
            let len = self.total_supply();
            assert(index < len, 'ERC721Enum: index out of bounds');
            self.ERC721Enumerable_all_tokens.read(index)
        }
        fn token_of_owner_by_index(self: @ContractState, owner: ContractAddress, index: u256) -> u256 {
            let len = self.balance_of(owner);
            assert(index < len, 'ERC721Enum: index out of bounds');
            self.ERC721Enumerable_owned_tokens.read((owner, index))
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn _is_approved_or_owner(self: @ContractState, spender: ContractAddress, token_id: u256) -> bool {
            assert(self._exist(token_id), 'ERC721: nonexistent token');
            let owner = self.owner_of(token_id);
            spender == owner || self.get_approved(token_id) == spender || self.is_approved_for_all(owner, spender)
        }
        fn _exist(self: @ContractState, token_id: u256) -> bool {
            let owner = self.ERC721_owners.read(token_id);
            !owner.is_zero()
        }
        fn _approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            self.ERC721_token_approvals.write(token_id, to);
            self.emit(Event::Approval(Approval { owner: self.owner_of(token_id), to: to, tokenId: token_id }));
        }
        fn _transfer(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256) {
            // ERC721Enumerable
            self._remove_token_from_owner_enumeration(from, token_id);
            self._add_token_to_owner_enumeration(to, token_id);

            // ERC721
            assert(self.owner_of(token_id) == from, 'ERC721: incorrect owner');
            assert(!to.is_zero(), 'ERC721: to is zero address');
            let zero = starknet::contract_address_const::<0>();
            self._approve(zero, token_id);
            self.ERC721_balances.write(from, self.balance_of(from) - 1);
            self.ERC721_balances.write(to, self.balance_of(to) + 1);
            self.ERC721_owners.write(token_id, to);
            self.emit(Event::Transfer(Transfer { from_: from, to: to, tokenId: token_id }));
        }
        fn _safe_transfer(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>) {
            // ERC721Enumerable
            self._remove_token_from_owner_enumeration(from, token_id);
            self._add_token_to_owner_enumeration(to, token_id);

            // ERC721
            self._transfer(from, to, token_id);
            assert(self._check_on_erc721_received(from, to, token_id, data), 'ERC721: non ERC721Receiver');
        }
        fn _burn(ref self: ContractState, token_id: u256) {
            // ERC721Enumerable
            let owner = self.owner_of(token_id);
            self._remove_token_from_owner_enumeration(owner, token_id);
            self._remove_token_from_all_tokens_enumeration(token_id);

            // ERC721
            let zero = starknet::contract_address_const::<0>();
            self._approve(zero, token_id);
            self.ERC721_balances.write(owner, self.balance_of(owner) - 1);
            self.ERC721_owners.write(token_id, zero);
            self.emit(Event::Transfer(Transfer { from_: owner, to: zero, tokenId: token_id }));
        }
        fn _check_on_erc721_received(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256, data: Span<felt252>) -> bool {
            let caller = get_caller_address();
            let receiver_erc165 = IERC165Dispatcher { contract_address: to };

            if receiver_erc165.supportsInterface(IERC721_RECEIVER_ID) {
                let receiver_erc721 = IERC721ReceiverDispatcher { contract_address: to };
                let selector = receiver_erc721.onERC721Received(caller, from, token_id, data);
                assert(selector == IERC721_RECEIVER_ID, 'ERC721: invalid return selector');
                return true;
            }
            
            receiver_erc165.supportsInterface(IACCOUNT_ID)
        }
        fn _add_token_to_owner_enumeration(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let len = self.balance_of(to);
            self.ERC721Enumerable_owned_tokens.write((to, len), token_id);
            self.ERC721Enumerable_owned_tokens_index.write(token_id, len);
        }
        fn _remove_token_from_owner_enumeration(ref self: ContractState, from: ContractAddress, token_id: u256) {
            let last_token_index = self.balance_of(from) - 1;
            let token_index = self.ERC721Enumerable_owned_tokens_index.read(token_id);

            if last_token_index == token_index {
                self.ERC721Enumerable_owned_tokens_index.write(token_id, 0);
                self.ERC721Enumerable_owned_tokens.write((from, last_token_index), 0);
                return;
            }

            let last_token_id = self.ERC721Enumerable_owned_tokens.read((from, last_token_index));
            self.ERC721Enumerable_owned_tokens.write((from, token_index), last_token_id);
            self.ERC721Enumerable_owned_tokens_index.write(last_token_id, token_index);
        }
        fn _remove_token_from_all_tokens_enumeration(ref self: ContractState, token_id: u256) {
            let supply = self.ERC721Enumerable_all_tokens_len.read();
            let last_token_index = supply - 1;
            let token_index = self.ERC721Enumerable_all_tokens_index.read(token_id);
            let last_token_id = self.ERC721Enumerable_all_tokens.read(last_token_index);

            self.ERC721Enumerable_all_tokens.write(last_token_index,0);
            self.ERC721Enumerable_all_tokens_index.write(token_id, 0);
            self.ERC721Enumerable_all_tokens_len.write(last_token_index);

            if last_token_index == token_index {
                self.ERC721Enumerable_all_tokens_index.write(last_token_id, token_index);
                self.ERC721Enumerable_all_tokens.write(token_index, last_token_id);
            };
        }
    }
}