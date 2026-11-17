# GryphonForever

A tiny World of Warcraft addon that draws Blizzard's modern action bar art as a standalone, movable
backdrop: gryphon / wyvern end caps, frame border, slot backgrounds and dividers. It draws art only,
so you can lay any buttons on top (Dominos, Bartender4, ...). Built for the `wowf` ("Forever") client,
interface `16001`.

No art files are shipped. Everything is referenced by Blizzard's own atlas names
(`ui-hud-actionbar-gryphon-left`, `ui-hud-actionbar-frame`, `ui-hud-actionbar-iconframe-slot`, ...).

## Install

Clone into your AddOns folder:

```
git clone <repo-url> "World of Warcraft/_forever_/Interface/AddOns/GryphonForever"
```

## Usage

`/gb` (or `/gryphonforever`) prints the full list. The frame is named `GryphonForeverFrame` and
covers exactly the button area, so other addons can anchor to it.

| Command | Effect |
|---|---|
| `/gb slots <n>`, `rows <n>` | number of slots / rows (default 24 x 1) |
| `/gb size <px>`, `spacing <px>`, `scale <n>` | slot size (45 = Blizzard native), gap, scale |
| `/gb caps\|border\|slotart\|dividers [on\|off]` | toggle parts |
| `/gb tint <r> <g> <b>` / `off` / `reset` | colour multiplier for the grey border and dividers (default bronze) |
| `/gb faction auto\|alliance\|horde` | gryphon or wyvern caps |
| `/gb strata background\|low\|medium` | frame strata |
| `/gb capstrata background|low|medium|high|dialog` | strata of the gryphon/wyvern caps (own frame, default low) |
| `/gb unlock`, `/gb lock` | drag to move, then lock |
| `/gb pos <x> <y>`, `/gb flush` | numeric position / flush with the screen bottom |
| `/gb on`, `off`, `reset` | enable, disable, restore defaults |

Settings are saved in `GryphonForeverDB`.

## License

MIT, see [LICENSE](LICENSE). Blizzard art referenced by atlas name remains Blizzard's property.
