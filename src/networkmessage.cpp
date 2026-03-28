// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "networkmessage.h"

#include "container.h"
#include "creature.h"

static std::string utf8_to_latin1(std::string_view utf8)
{
	std::string out;
	out.reserve(utf8.size());

	size_t i = 0;

	if (utf8.size() >= 3 &&
			static_cast<unsigned char>(utf8[0]) == 0xEF &&
			static_cast<unsigned char>(utf8[1]) == 0xBB &&
			static_cast<unsigned char>(utf8[2]) == 0xBF) {
		i = 3;
	}

	while (i < utf8.size()) {
		const auto c = static_cast<unsigned char>(utf8[i]);

		if (c < 0x80) {
			out += static_cast<char>(c);
			++i;
			continue;
		}

		size_t seq_len = 0;
		if      ((c& 0xE0) == 0xC0) seq_len = 2;
		else if ((c& 0xF0) == 0xE0) seq_len = 3;
		else if ((c& 0xF8) == 0xF0) seq_len = 4;
		else {
			out += static_cast<char>(c);
			++i;
			continue;
		}

		if (i + seq_len > utf8.size()) {
			out += static_cast<char>(c);
			++i;
			continue;
		}

		bool valid = true;
		for (size_t j = 1; j < seq_len; ++j) {
			if ((static_cast<unsigned char>(utf8[i + j])& 0xC0) != 0x80) {
				valid = false;
				break;
			}
		}

		if (!valid) {
			out += static_cast<char>(c);
			++i;
			continue;
		}

		uint32_t cp = 0;
		switch (seq_len) {
			case 2: cp = (c& 0x1F); break;
			case 3: cp = (c& 0x0F); break;
			case 4: cp = (c& 0x07); break;
		}
		for (size_t j = 1; j < seq_len; ++j)
			cp = (cp << 6) | (static_cast<unsigned char>(utf8[i + j])& 0x3F);

		out += (cp <= 0xFF) ? static_cast<char>(cp) : '?';
		i += seq_len;
	}

	return out;
}

std::string_view NetworkMessage::getString(uint16_t stringLen /* = 0*/)
{
	if (stringLen == 0) {
		stringLen = get<uint16_t>();
	}

	if (!canRead(stringLen)) {
		return "";
	}

	auto it = buffer.data() + info.position;
	info.position += stringLen;
	return {reinterpret_cast<char*>(it), stringLen};
}

Position NetworkMessage::getPosition()
{
	Position pos;
	pos.x = get<uint16_t>();
	pos.y = get<uint16_t>();
	pos.z = getByte();
	return pos;
}

void NetworkMessage::addString(std::string_view value)
{
	const std::string latin1 = utf8_to_latin1(value);
	size_t stringLen = latin1.size();
	if (!canAdd(stringLen + 2) || stringLen > 8192) {
		return;
	}

	add<uint16_t>(stringLen);
	std::memcpy(buffer.data() + info.position, latin1.data(), stringLen);
	info.position += stringLen;
	info.length += stringLen;
}

void NetworkMessage::addDouble(double value, uint8_t precision /* = 2*/)
{
	addByte(precision);
	add<uint32_t>(static_cast<uint32_t>((value * std::pow(static_cast<float>(10), precision)) +
	                                    std::numeric_limits<int32_t>::max()));
}

void NetworkMessage::addBytes(const char* bytes, size_t size)
{
	if (!canAdd(size) || size > 8192) {
		return;
	}

	std::memcpy(buffer.data() + info.position, bytes, size);
	info.position += size;
	info.length += size;
}

void NetworkMessage::addPaddingBytes(size_t n)
{
	if (!canAdd(n)) {
		return;
	}

	std::fill_n(buffer.data() + info.position, n, 0x33);
	info.length += n;
}

void NetworkMessage::addPosition(const Position& pos)
{
	add<uint16_t>(pos.x);
	add<uint16_t>(pos.y);
	addByte(pos.z);
}

void NetworkMessage::addItemId(uint16_t itemId)
{
	const ItemType& it = Item::items[itemId];
	uint16_t clientId = it.clientId;

	add<uint16_t>(clientId);
}

void NetworkMessage::addItem(uint16_t id, uint8_t count)
{
	addItemId(id);

	const ItemType& it = Item::items[id];
	if (it.stackable) {
		addByte(count);
	} else if (it.isSplash() || it.isFluidContainer()) {
		addByte(fluidMap[count & 7]);
	}
}

void NetworkMessage::addItem(const Item* item)
{
	addItemId(item->getID());

	const ItemType& it = Item::items[item->getID()];
	if (it.stackable) {
		addByte(static_cast<uint8_t>(std::min<uint16_t>(0xFF, item->getItemCount())));
	} else if (it.isSplash() || it.isFluidContainer()) {
		addByte(fluidMap[item->getFluidType() & 7]);
	}
}
