// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts for Cairo ^0.19.0

#[starknet::contract]
mod PumpBTC {
    use core::num::traits::Zero;
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::token::erc20::ERC20Component;
    use openzeppelin::token::erc20::ERC20HooksEmptyImpl;
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;

    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        is_minter: Map<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.erc20.initializer("pumpBTC", "pumpBTC");
        self.ownable.initializer(owner);
    }

    #[generate_trait]
    #[abi(per_item)]
    impl ExternalImpl of ExternalTrait {
        #[external(v0)]
        fn is_minter(self: @ContractState, minter: ContractAddress) -> bool {
            self.is_minter.read(minter)
        }

        fn assert_only_minter(self: @ContractState) {
            let caller = get_caller_address();
            assert(!caller.is_zero(), 'Zero Caller');
            assert(self.is_minter.read(caller), 'Not Minter');
        }

        fn assert_not_zero_amount(self: @ContractState, amount: u256) {
            assert(amount > 0, 'Zero Amount');
        }

        #[external(v0)]
        fn set_minter(ref self: ContractState, minter: ContractAddress, status: bool) {
            self.ownable.assert_only_owner();
            self.is_minter.write(minter, status);
        }

        #[external(v0)]
        fn mint(ref self: ContractState, to: ContractAddress, amount: u256) {
            self.assert_not_zero_amount(amount);
            self.assert_only_minter();
            self.erc20.mint(to, amount);
        }

        #[external(v0)]
        fn burn(ref self: ContractState, from: ContractAddress, amount: u256) {
            self.assert_not_zero_amount(amount);
            self.assert_only_minter();
            self.erc20.burn(from, amount);
        }
    }
}
