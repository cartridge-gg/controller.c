#[diplomat::bridge]
pub mod ffi {
    use account_sdk::account::session::policy::Policy;

    use crate::felt::ffi::DiplomatFelt;

    /// Session Wrapper
    #[diplomat::opaque]
    pub struct DiplomatPolicies(Vec<Policy>);

    impl DiplomatPolicies {
        pub fn new() -> Box<Self> {
            Box::new(DiplomatPolicies(Vec::new()))
        }

        pub fn add_call(&mut self, contract_address: &DiplomatFelt, selector: &DiplomatFelt) {
            self.0
                .push(Policy::new_call(contract_address.0, selector.0));
        }

        pub fn add_typed_data(&mut self, scope_hash: &DiplomatFelt) {
            self.0.push(Policy::new_typed_data(scope_hash.0));
        }
    }

    impl From<DiplomatPolicies> for Vec<Policy> {
        fn from(value: DiplomatPolicies) -> Vec<Policy> {
            value.0
        }
    }

    impl From<&DiplomatPolicies> for Vec<Policy> {
        fn from(value: &DiplomatPolicies) -> Vec<Policy> {
            value.0.clone()
        }
    }

    impl IntoIterator for DiplomatPolicies {
        type Item = Policy;
        type IntoIter = std::vec::IntoIter<Self::Item>;

        fn into_iter(self) -> Self::IntoIter {
            self.0.into_iter()
        }
    }
}
