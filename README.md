# WorkshopFetcher

**WorkshopFetcher** is a small server-side Lua utility for **Garry’s Mod** that automatically fetches all addons from a **Steam Workshop collection** using the Steam Web API and registers them via `resource.AddWorkshop`.

This removes the need to manually list every Workshop ID when using large addon collections.

---

## Features

- Fetches Steam Workshop collections via `ISteamRemoteStorage/GetCollectionDetails`
- Automatically parses and extracts addon IDs
- Adds all addons using `resource.AddWorkshop`
- Simple API — one function call
- Ideal for servers with large or frequently updated addon collections

---

## Installation

1. Create the required directory if it does not exist.
2. Copy the source folder into this directory.
3. Create the `autorun/server` folder.
4. Create file in there.
5. Call `require` for workshop_fetcher.

You can now add a Workshop collection using `AddCollection(collectionID)`.


That's all!

