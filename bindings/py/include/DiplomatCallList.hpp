#ifndef DiplomatCallList_HPP
#define DiplomatCallList_HPP

#include "DiplomatCallList.d.hpp"

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "DiplomatCall.hpp"
#include "diplomat_runtime.hpp"


namespace diplomat {
namespace capi {
    extern "C" {

    diplomat::capi::DiplomatCallList* DiplomatCallList_new(void);

    void DiplomatCallList_add_call(diplomat::capi::DiplomatCallList* self, const diplomat::capi::DiplomatCall* call);

    void DiplomatCallList_destroy(DiplomatCallList* self);

    } // extern "C"
} // namespace capi
} // namespace

inline std::unique_ptr<DiplomatCallList> DiplomatCallList::new_() {
  auto result = diplomat::capi::DiplomatCallList_new();
  return std::unique_ptr<DiplomatCallList>(DiplomatCallList::FromFFI(result));
}

inline void DiplomatCallList::add_call(const DiplomatCall& call) {
  diplomat::capi::DiplomatCallList_add_call(this->AsFFI(),
    call.AsFFI());
}

inline const diplomat::capi::DiplomatCallList* DiplomatCallList::AsFFI() const {
  return reinterpret_cast<const diplomat::capi::DiplomatCallList*>(this);
}

inline diplomat::capi::DiplomatCallList* DiplomatCallList::AsFFI() {
  return reinterpret_cast<diplomat::capi::DiplomatCallList*>(this);
}

inline const DiplomatCallList* DiplomatCallList::FromFFI(const diplomat::capi::DiplomatCallList* ptr) {
  return reinterpret_cast<const DiplomatCallList*>(ptr);
}

inline DiplomatCallList* DiplomatCallList::FromFFI(diplomat::capi::DiplomatCallList* ptr) {
  return reinterpret_cast<DiplomatCallList*>(ptr);
}

inline void DiplomatCallList::operator delete(void* ptr) {
  diplomat::capi::DiplomatCallList_destroy(reinterpret_cast<diplomat::capi::DiplomatCallList*>(ptr));
}


#endif // DiplomatCallList_HPP
