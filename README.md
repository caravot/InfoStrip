# About

InfoStrip is a light weight data broker addon. I didn't want the bulkiness of some of the other data brokers so I built my own. The entire addon runs around 100kb total during playtime.

# Features

In addition to the features of the bar below it also auto sells grey items in your bags (and tells you what was sold and for how much in your chat window). It also auto repairs your items, first by using Guild funds if possible then by using your own funds.

All features are listed below (from left to right on the bar):
* **Garrison:** Displays basic information about your garrison to include the number of available work order, number of shipments ready to pickup, and tlme to next shipment. Also shows completed mission, missions in progress (to include time left), and available missions to include diplaying its rewards, mission leve, and if the mission is rare.
* **Tracking:** Change/show what you are currently tracking. Useful for those who want a minimalistic UI since you can now hide your Minimap button but always know what your tracking.
* **Badges:** Hover will show you the badge name and total for all badge names specified in the file.
* **Friends/Guildies:** Shows the number of friends and guild members online. On hover displays information about members. Clicking the button text will bring up the appropriate display.
* **Location:** Shows zone/sub-zone if not in an instances. If in an instance/raid, will display the name of the instance, the difficulty level, and the party size.
* **Reputation:** Shows the current tracked reputation, your reaction to them, and what percentage into that reaction you are. Hovering over this shows a list (sorted by reaction) of reps you are at least friendly with but less than exhalted with.
* **Durability:** The percentage your gear is currently at.
* **XP:** Displays only for those below level 90 and show the current percentage you are into the current level. On hover displays more information about your experience.
* **Latency/FPS:** Simple memory display. On hover displays all your addons along with the memory used for each.
* **New Mail:** Displays if there is mail, otherwise displays "No Mail". On hover displays the first three senders.
* **Coordinates:** Where your character's current position is.
* **Time:** The current local time. Hover over for the local and realm times.

# Slash Commands

The two slash commands are just to show/hide the frame itself:

````
/InfoStrip show 
/InfoStrip hide
````

# Configuration Options

At the top of the InfoStrip.lua file there is a section of options you can configure. Here's a list of what they are and do.

````
local space = 5 										-- Space between each frame in the bar
local fontheight = 11									-- Fontsize
local font = "Interface\\AddOns\\InfoStrip\\font.ttf"	-- Font
local trackBadges = { 
	  "Honor Points",
	  "Darkmoon Prize Ticket",
	  "Epicurean's Award",
	  "Justice Points",
	  "Valor Points"
} 														-- Badge names to track. It MUST be the full name of the badge, no short names.

local MAX_ADDONS = 15									-- Maximum addons to display in dropdown list		
local MAX_GUILDIES = 25									-- Maximum guild members to display in dropdown list
local MAX_FACTIONS = 25									-- Maximum factions to display in dropdown list
````

To change the opacity of the background go to line 66~ in InfoStrip.lua

````
local background_frame = f:CreateTexture(nil, "ARTWORK")
background_frame:SetTexture(0, 0, 0, .5)
And change the .5 to be a number between 0 and 1 with 0 being completely see through. 
````

# Misc/Contact

There is no configuration screen but let me know if you have any suggestions or want to change something. I can help you out. And if you have any questions, comments, or find any problems please let me know either in a private message or in the comments section.

Thanks!
