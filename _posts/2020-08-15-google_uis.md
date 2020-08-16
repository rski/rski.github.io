---
title: "The Google can't make UIs rant"
---

This is a rant, don't expect much in the way of redemption for Google as those are not the aspects of it that I wanted to write down here.

# The Gmail

After a long time of Thunderbird habitually freezing on me, I decided to try the Gmail web client. Here is what is an almost complete list of all the things that annoyed me to a fault:

- five seconds in, trying to change some settings I was already pointed to Chrome. `Note: This browser does not support desktop notifications. To enable notifications, upgrade your browser to Google Chrome.`. I hate Chrome, I hate notifications. I'm not going to do either.
- It takes forever to switch between labels. About 3s to go from one folder to Indox.
- Default colours are terrible. Labels with unread emails don't really stick out compared to labels that have none. Labels with unread emails that I have opened are the same as labels I have not opened. Thunderbird has three levels: fully read folder, folder with unread I have not opened (bold/blue), folder with unread I have opened (bold). That makes it easy for me to tell which folders I've kept up with, Gmail does not.
- Right clicks are web page right clicks. On Thunderbird if I want to fiddle with a folder, I right click on it, that's it. On Gmail, I have to select the label first at the very least.
- Deletion is absolute horrendous garbage. I wanted to delete a large volume of emails, for which I had a query. I could not delete them in one go. I had to click on the checkbox, which only selected up to a certain number of emails. Then I had to click on "All 100 conversations on this page are selected..." to select more, but still not all of then. Then click on the trashcan icon, but that didn't delete all of the results of the query, so I had to keep repeating. Each iteration took forever to send to trash. After that, I still had to clean the trash folder, which took forever. `Empty trash can` did not in fact empty it in one go. It would say there were 2k conversations to delete, it would delete ~500 and then the textbox would go away. Creating a filter that had deletion as the action seemed to do nothing as well.

After the horror of this, I went back to Thunderbird. Here is what I did to make it better:

- Moved `$HOME/.Thunderbird` out of the way and set up my account from scratch.
- Went to Edit -> Account Settings -> Syncronisations and Settings and disabled everything that had to do with the [Gmail] folder and especially `All Mail` to prevent Thunderbird from ever downloading it. Apparently that is yet another copy of all the emails that already end up in my Inbox and Folders. The [Thunderbird documentation](http://kb.mozillazine.org/Gmail) suggests doing so and it explains how to do it without starting from scratch.
- Added very strict, max 5-10 day retention policies to folders I am not interested in keeping around for a long time.

After doing this, and with the email cleanup, I ended up with a 70MB email folder. Compared with the 44GB one I started with, that is pretty good. Most of that was the `[Gmail Folder]`. Now Thunderbird is very, very fast again.

Some miscellany thoughts:

I like being able to @Someone and have Gmail complete that and add them to the recipients. I have not figured out if it is possible to do that in Thunderbird. I do have my address book synced from gmail into Thunderbird so don't mind too much not having it, since autocompletion works in the address boxes.

Thunderbird is a desktop application, I can read my email whenever, wherever.

I really, really dislike Google's magic, out of spec emails. I think I received one of those that came from a Google form and it said I should open it on Gmail to use it as an email or go to forms to complete it there. Yet another way for Google to drag me into its garden.

# The Google Chat

By far my biggest issue with GChat is that every user facing update on Android makes it consistently and considerably worse. The most recent change is twofold:

- The colour for unread channels went from making the channel's name a non-intrusive bold, to a red dot next to the channel name.
- There is no distinction between channels that have notifications and channels that are simply unread!

I know I have two notifications because of the 2 at the bottom. There are 10 unread channels, and all of them look the same. Even if I have no notifications, the channels look like they do, because the Web UI uses red to denote a channel has a notification.

The Web UI has remained the same piece of mediocre annoyance for at least a year now, the only change I have noticed is they added a search for emojis.

- If I expand the list of all people and scroll down enough, it is easier to refresh the tab than find the `Less` to fold it back up. If I search for someone I have not talked to in some time, it will expand and scroll down for me, and in this cases I almost always end up reloading the tab.
- Threads don't fully expand. If a thread with 99+ messages has folded and you want to read it, good luck. Click, expand ten messages, scroll up to get back to the fold, click, expand, scroll. Clearly inspired by Cookieclicker.
- If you are pinged in a channel, there is no way to easy go to the source of the notification. If it was before you left for PTO and the channel has traffic? You'll never find it, sorry.
- Pinging and then deleting the thread/message still leaves a notification to the pinged person. Combine that with the above for heaps and heaps of fun.
- The threads have no links! You can't link them! Except they do, but they are not in the UI. Only recently a hover-only email button was added, which emails you the link. Why? Just put the link there. There's half a finger's worth of whitespace between threads. I have a greasemonkey extension that grabs the link from the HTML and puts it right there above each thread, so clearly it's doable, available and supported since Google does give it to you, but only via email.
- Thread links don't always work. Clicking on a link for a thread on the same channel or a different channel you have not joined does not take you to the thread. We always end up having the conversation of "This does not take me anywhere/Go to room X/It's the link for this channel you are in, 5 threads above". If the link is for a channel that is not visible to, you don't get a 404, you simply get thrown back to the current conversation.
- When looking at a room, the affordance is to reply to the last thread instead of starting a new one, since that is where the bottommost textbox is attached. This results in the latest thread being bombarded by unrelated new threads. What problem does the `New thread in <Room>` button even solve? Remove it and leave the `New thread` textbox always there at the bottom, gah.
- Webhook links are a random string, you have to leave a comment to point readers to the room some piece of code notifies. Slack simply uses the channel name. Is that more prone to breaking on renames than the GChat hooks? Yes. Is it a worthy tradeoff? Not in my book.
- Posting links generates thumbnails. When posting a Google docs link that points to a heading, the thumbnail's link does _not_ point to the heading, only the top of the document.

Rant over.
