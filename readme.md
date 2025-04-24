# Monument Valley 3 for iOS 15

Fix [this](https://apps.apple.com/us/app/monument-valley-3-netflix/id6450062082) for my iPhone SE.

## build

This repo doesn't contain any game files; you will need to install and decrypt with e.g. [FoulDecrypt](https://github.com/NyaMisty/fouldecrypt).

```
bash
zsh patch.zsh 'Monument 3 1.2.17528.ipa' Monument3_decrypted UnityFramework_decrypted
```

Install `build/fixed.ipa` with TrollStore, it might work.

## find save

Netflix integration is broken, so it's probably a good idea to backup.

```
bash
find /var/mobile/Containers -name SaveSlot1_1.sav
```
