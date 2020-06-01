---
title: A month of VS Code
---


During the month of May 2020  or so, I put in a concentrated effort in using VS Code, despite all my instincts to go back to Emacs. This is a record of what I got from it.

## The good

A lot of things work by default. The introduction documentation is much friendlier for beginners. The _Interactive Playground_ gives a very nice sampling of all the stuff people expect from a modern editor:
- autocompletion
- multiple cursors
- renaming
- formatting
- folding
- live errors/warnings

On the other side, when clicking on the _Emacs Guided Tour_, it takes me to this:

![](/assets/vscode_emacs_images/why_emacs_why.png)

There is a kind of fixed form that is nice. Emacs is too fluid. Everything is a buffer. Anything can end up anywhere at any time. I can see why people might like it. Everything is kind of where you expect it to be: errors are at the bottom, lsp logs are at the bottom, terminal is at the bottom, a dropdown exists for the various interesting logs and outputs. At the same time, they are not as first class as Emacs buffers.

It manages external tools for you, I don't have to bother too much about gopls (although for other reasons I did), or rust-analyzer - although, more than once I did. My fault for running NixOS. lsp-mode does seem to be offering similar things. However VS Code pulls down non language server tools too.

Configuration can be nicer and easier to get into. The UI is nicer than Emacs' customize interface and the JSON configuration has autocompletion for known config fields.

There's a lot of good extensions, even for niche stuff. There's about 10 plugins for Jenkins, whereas for Emacs there's maybe 2? And _I_ wrote the one.

Installing plugins just works, there is no Elpa/Melpa distinction.

Writing extensions is a first class experience. There's lint config files, files that declare dependencies. All the stuff cask does for Emacs, but it feels significantly more robust.

You can get something very usable very easily, without having to touch lisp.
Yes, yes, customize, sure. I have this in my init.el:

```
  (lsp-register-custom-settings
   '(("gopls.completeUnimported" t t)
     ("gopls.staticcheck" nil t)))
```

There is nothing in customize that I could find that sets there. For VS Code it's just:
```
    "gopls": {
        // Add parameter placeholders when completing a function.
        "usePlaceholders": true,
        // If true, enable additional analyses with staticcheck.
        // Warning: This will significantly increase memory usage.
        "staticcheck": false,
        "analyses": {
            "simplifycompositelit": false
        },
    },
```

much clearer, and much easier for a beginner to get into. Although lsp-mode does offer variables for well known config values, JSON is friendlier than lisp.

As a language, TypeScript does have many things elisp will probably never get. There's types, there's actual imports, there's modern language features. My impression is that the simple things are singificantly easier to implement.

The much faster release cycles. I have to compile Emacs from source to get native C JSON support, which really makes a difference when using lsp.

The language support story is nicely streamlined. The supporting features for writing code feel consistent across languages. In Emacs that wasn't the case historically. lsp seems to be the big equalizer. I did in fact find out that `lsp-ui` supports code lenses but I coudln't get them to work within 5 minutes and I promised myself to keep off Emacs for a bit. I'm not sure how many Go extensions I have in Emacs. For VS Code it's just one and it does all the stuff I spent weekends trying to write elisp for.

It has kind of become what the plan was for Emacs and GNU: The universal interface. A big chunk of it is centered around Azure, Docker and other [the-cloud-is-just-someone-else's-computer stuff](https://code.visualstudio.com/docs/azure/extensions). This is the same way Emacs was built to integrate well with other tools of its time, like man and info pages, arbitrary compilation targets, make and various GNU tools. Due to ideological issues, Emacs will never get there. That's good and bad. You get something, you lose something.

On the same topic, there is even actual 3rd party interfaces for VS Code built by companies like [MongoDB](https://www.mongodb.com/blog/post/introducing-mongodb-for-vs-code). Realistically, I don't think I will ever see such a thing in Emacs. Are there good interfaces in Emacs? Absolutely. Are those restricted by Emacs, be the language or the general form of the Editor's UI? Also yes. The opossing side has a big advantage. Being powered by a browser is a hell of a drug. Being able to use the language you already know and use outside of your text editor is extremely powerful too.

There might be something to say about debugging, but I don't really use debuggers apart from poking at cores so I won't comment on that.

It's easy and tempting to dismiss the success of VS Code as a byproduct of money. Does Microsoft have more money than the FSF, never mind the people who work on Emacs, would ever see in their lives? Of course. Is this the reason VS Code is getting so much adoption? To a large extent. Attracting smart people by paying them well is one thing. Being beginner friendly, powered by the same stuff people are alway familiar with and being powerful out of the box cannot be dismissed. But in the end, being able to produce something beginner friendly and with so many features does stem from hiring multiple engineers at a six figure salaries.

To a large extent, I believe the difference is ideological, and this has manifested in various ways over the years. Some were results of the ivory tower position, which did largely hinder Emacs. Some are the result of how the Emacs community is structured. For example:
- emacs-devel has a history of putting people off *cough* flycheck. It even puts _me_ off.
- The copyright assignments. I almost write about this once in a while and then don't because it always riles me up. Re-implement magit? Make it impossible to ship flycheck out of the box? There are very very good plugins out there, and Emacs core always ends up with the half baked ones[^1]. I can't use Emacs without magit, flycheck, projectile, and use-package and none of them will ever see Emacs core the way things are. `use-package` is five years in trying to collect signatures of everyone who contributed to it.
- gcc development to make it usable as a tool and a compiler, like clang, was intentionally stopped on the off chance that it could be used in non-free software. Is that inherently bad? Not really, no. That's the thing you bite into with Emacs. Eventually that decision was unmade, but by then that ship had sailed.
- RMS. There's enough ink spilled on this already. Phenomenal engineers I've worked with have been put off by him in person. What's the chance of Emacs attracting developers, when he who has ultimate authority over what goes in or not has alienated the people who have been using it for decades and are more capable of contributing to the C corpus than anyone?
- People who have been using Emacs for years are looking for a way out, even though there is a cost in doing so. Consider this post. Consider https://github.com/bodil/ohai-emacs being archived. If it can't even keep the people who know enough to work with it, what is the point?

## The bad

I'll start with the first deal-breaker. VS Code is extremely non-keyboard centric. ```Control+Shift+` ``` for a terminal? `F12` for go to definition? A lot of the key combos are three key chords, and those are for the supposedly easy things. This is exacerbated by the fact that my keyboard is not a full keyboard and doesn't have easy access to backtick or the arrow keys.

A lot of the things I can do in Emacs with two keypresses without thinking require a mouse in VS Code. Following links to code from a compilation that failed requires `Ctrl+click`. The same thing in Emacs is `M-g M-n`.

The second deal breaker is that I feel marketed to _every step of the way_. When reading the docs, everything is there to make you more efficient. Everything was carefully selected specifically for you, never mind that simple operations are hidden behind a chord of 4(!) keys.

![](/assets/vscode_emacs_images/keybindings.png)

Oh, you want to learn how to use Git in VS Code? Here is a Microsoft tool for it:

![](/assets/vscode_emacs_images/use_azure.png)

This is where VS Code completely lost me. I mean, yes, ok, I knew going in that VS Code is a Microsoft product, it is their money, prerogative and motivation to get people to use it and their products. Which is fine, it's useful for those who use these things, but not for me. I get the marketing and no real use for these things. I will stick with the [ivory tower of ridiculous pendantery](https://github.com/emacs-mirror/emacs/commit/5daa7a5fd4aced33a2ae016bde5bb37d1d95edf6)[^2].

Maybe there's more good bits to VS Code, but at this point I don't feel inclined to continue using it.

One more thing I found out about after returning to Emacs, is how VS Code and Microsoft deal with licensing. The remote development extension is actually completely closed source. You have to use Microsoft builds to be allowed to use certain extensions, even [VSCodium is not](https://github.com/VSCodium/vscodium/blob/master/DOCS.md#proprietary-debugging-tools).

## Afterthoughts - In defence of Emacs

At the end of this month, I don't feel like I had a particular epiphany. I went in with the baggge of being really attached to Emacs and despite best intentions, I did spent a lot of the time trying to get the things I already had. There were some interesting things, Code Lenses, things that I didn't realise lsp-ui could do, they've done a lot of good work around the defaults and that was it. I was not concinved that sticking around for longer would give me something to be worth the annoyance of giving up significant parts of my workflow.

There are things I did get out of it. I now realise some places here and there where Emacs could be better. The random freezes due to almost everything being synchronous and blocking are annoying and an unfortunate thing that shouldn't be part of an interactive editor in 2020. I realised my Emacs looks really not nice, but I also realise that I don't particularly care about that. Definig tasks instead of just using `projectile-compile-project` is great, and I have wanted something similar in Emacs for a long time.

At this point, VS Code does make it glaringly obvious that vanilla Emacs does very much suck for 2020. I would never be able to use it as a daily driver. I wouldn't be able to use it with just Elpa either.

Thankfully, I don't have to live in the pure ideological world where everything I use needs to be copyrighted away to the FSF. And Emacs newbies don't have to either. There are _very_ good Emacs distributions out there.

Both [spacemacs](https://www.spacemacs.org/) and [doom](https://github.com/hlissner/doom-emacs) are great and come with a good out of the box experience and set of modern editor features. I started with spacemacs and eventually built my own config. I'm sure in those two years Spacemacs has gotten significantly better too. In my mind, this is the future of Emacs now. I will stop recommending Emacs abstractely to people, It will be "Try Spacemacs" or try "Doom Emacs". If someone finds out about the underlying Emacs in the process, so be it.

lsp-mode has broken a lot of barriers in what Emacs can do. Just by putting lsp-mode, lsp-ui and flycheck together, you get a lot of the things VS Code offers. Yes, the VS Code plugin for Go is better than what gopls currently offers. At the same time, there is very real work being put in gopls right now, it's barely at the 0.4 mark. With lsp, I don't have to leave Emacs to get a lot of the things VS Code offers. It's not either or anymore. It's not 2012, when I was typing code in vanilla vim while everyone else was breezing though code with Visual Studio.

I don't have to interact with RMS. No one is making me subscribe to emacs-devel. Maybe one day things will be better, until then Melpa and the community around it are nice and breezy.

There's more to Emacs too. It tickles the part of my brain that remembers fighting with SICP and learning something new that Python and C and the classical imperative languages had not shown me before.

And at the end of the day, it's all good fun. Yes, lisp is weird and hairy. I sure plan to be like that when I'm 62. But it's fun to sit down and explore Emacs itself. It fun to discover weird tidbits of history. It's fun to discover a powerful API that can do just the weird thing you were looking for. It's fun to explore the incredibly innovative plugins people have written over the years. It's a big Emacs world out there and I like being part of it.

### Afterword

In my initial drafts I had these negative points as well. They are kind of here and there, and the points above took over so I removed all the little things from that section. They are collected here for posterity.

The company autocompletion UI is actually better in Emacs. I can use M-1 through 9 to select a completion candidate. Nothing similar in VS Code, it seems like I have to use the arrow keys.

Noise. So much noise. Every plugin just adds so so much noise to everything. In Emacs I have to figure out how to make an extension work, in VS Code I end up having to figure out how to disable part of it or disable it completely.
I had similar issues with lsp-ui in Emacs, and ended up not using it. A few of the things I initially thought VS Code and Emacs didn't have were actualy in lsp-ui, which I refused to use due to the noise it created. Whoops.

No compilation-mode equivalent. Calling `mvn install` just ran the command on the terminal.

There is no inbetween `Ctrl+P` and using the Explorer. I guess it's `Ctrl+O` to call Open File, that takes me away from the keyboard since it just opens a graphical widget. `find-file` and `counsel` sit much better with me. [Update: When I wrote this there wasn't one. [Bodil](https://marketplace.visualstudio.com/items?itemName=bodil.file-browser) wrote one within the last week or so.]

The Emacs plugin kinda sucks. It kind of works yes, but `Alt` also focuses the menu so oh no I'm not typing I'm executing commands and closing VS Code for the billionth time today. The vim plugin also kinda sucks. I tried asvetliakov/vscode-neovim for a bit, and I ended up with constant mystery freezes. This seems like [this issue](https://github.com/asvetliakov/vscode-neovim/issues/156). Admitedly, I didn't expect much more than that. Emulating editors (or even using an actual neovim instance) never worked out well for me in the past.
I was suprised to see that the Emacs plugin did provide some rudimentary buffer management.

Emacs as a deamon is great. I frequently kill Emacs windows if I don't need them, the state is still there. A scratch buffer to jolt down thoughts is always one super-e press away.

[^1]: I don't want to drag anyone through the mud. Emacs core does have alternatives and very unique things that work extremely well. Very smart people have put very good work in them. There's a limit to what a single person can do though. Flymake, even after the rewrite is much more complex to implement a checker in than Flycheck. The Flymake improvements are great and welcome, but in my very biased opinion, it still holds no candle to Flycheck. As a matter of fact, Flycheck was the reason I stuck with Emacs - if Flymake had been my only option, I would have probably kept on using vim, eventually moving on to the at the time budding neovim.

[^2]: This decision was undone, see https://github.com/emacs-mirror/emacs/commit/efd4e973a4f0c7fe9442b677c6fdeebb347e2b9d
