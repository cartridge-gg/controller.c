#ifndef DiplomatCallList_D_HPP
#define DiplomatCallList_D_HPP

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <memory>
#include <functional>
#include <optional>
#include <cstdlib>
#include "diplomat_runtime.hpp"

namespace diplomat::capi { struct DiplomatCall; }
class DiplomatCall;


namespace diplomat {
namespace capi {
    struct DiplomatCallList;
} // namespace capi
} // namespace

class DiplomatCallList {
public:

  /**
   * Create a new empty call list
   */
  inline static std::unique_ptr<DiplomatCallList> new_();

  /**
   * Add a call to the list
   */
  inline void add_call(const DiplomatCall& call);

  inline const diplomat::capi::DiplomatCallList* AsFFI() const;
  inline diplomat::capi::DiplomatCallList* AsFFI();
  inline static const DiplomatCallList* FromFFI(const diplomat::capi::DiplomatCallList* ptr);
  inline static DiplomatCallList* FromFFI(diplomat::capi::DiplomatCallList* ptr);
  inline static void operator delete(void* ptr);
private:
  DiplomatCallList() = delete;
  DiplomatCallList(const DiplomatCallList&) = delete;
  DiplomatCallList(DiplomatCallList&&) noexcept = delete;
  DiplomatCallList operator=(const DiplomatCallList&) = delete;
  DiplomatCallList operator=(DiplomatCallList&&) noexcept = delete;
  static void operator delete[](void*, size_t) = delete;
};


#endif // DiplomatCallList_D_HPP
