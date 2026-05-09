#define BOOST_TEST_MODULE item_lifetime

#include "../otpch.h"

#include "../item.h"

#include <boost/test/unit_test.hpp>
#include <memory>

extern bool isValidItemPointer(Item* item);

BOOST_AUTO_TEST_CASE(item_lifetime_registry_tracks_destroyed_item)
{
	Item* rawItem = nullptr;
	{
		auto item = std::make_shared<Item>(0);
		rawItem = item.get();
		BOOST_TEST(isValidItemPointer(rawItem));
	}

	BOOST_TEST(!isValidItemPointer(rawItem));
}
