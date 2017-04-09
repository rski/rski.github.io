---
layout: post
title: "Emacs: A case for Hydra"
date: 2017-04-09 00:23:00 +0200
categories: emacs hydra
---

For a long time I knew that [Hydra](https://github.com/abo-abo/hydra)
was a great package. It has users, it is written
by [abo-abo](https://github.com/abo-abo), it has a not so big number
of stars on Github, it seems to be the whole package.

But I couldn't understand /why/. I read the README, but I couldn't get
it. Until I found a usecase that hits close to home: Flycheck.

One thing I used to do a lot was:

- Open the list of errors buffer (`C-c ! l`)
- Go to it (`C-x o`)
- Go up and down the errors (`C-n C-n C-p`)
- Find an error that seems big and open the original buffer at that point (`RET`)
- Look at the error a bit and GOTO step 1

How many times did I type C-? A lot.

Enter Hydra.

After setting up a hydra, what I do now is:

- Type the hydra keybinding (`C-c e`)
- Go up and down the errors (`n n p`)
- Look at the error at point
- Resume going up and down (`n n n`)

How many times do I type C-? 1. That is a big improvement right there.

Ok, ok, what does "hydra keybinding" mean?

Here is the deal: Hydra is modal editing. That's all there is to
it. Modal editing a la evil, but without evil and much more flexible
that evil. Evil (Vim?) has a few predefined modes (insert, normal,
visual etc). With Hydra, every hydra body is a mode. Let's see this in
action.

Here's a hydra (mode):

{% highlight emacs-lisp %}
      (defhydra flycheck-hydra ()
        "Move around flycheck errors"
        ("n" flycheck-next-error "next")
        ("p" flycheck-previous-error "previous")
        ("f" flycheck-first-error "first")
        ("l" flycheck-list-errors "list")))
{% endhighlight %}

This is a mode where typing n,p,f,l does the action bound to it. To
enter the mode, you have to call `flycheck-hydra/body`. Then
typing `n` takes you to the next error. You no longer have to type
`C-c ! n` again and again and again.

Just how great is that? You bind a key to enter the hydra's mode and
then just press any of the mode's bindings. I'm pretty sure evil's
modes could be implemented as hydras as well.

Hydra is capable of doing way more than just defining a simple
mode. Take a look at
the [documentation](https://github.com/abo-abo/hydra/wiki), it's way
more than worth it.
