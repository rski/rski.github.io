---
title: "Two linters I'll always add to new Go projects: errcheck and ineffassign"
---

The reason for that is that they are the best bang for your buck by far. They are easy to appease, I have yet to see them produce false positives, they very frequently catch outright buggy code and retrofitting them is a pain.

# ineffassign

This is the sort of thing that ineffassign prevents:

    func getDataFromRpc() (string, error) {
        rand.Seed(time.Now().UnixNano())
	    data := []struct {
		    v   string
		    err error
	    }{ {v: "a"}, {v: "b"}, {err: fmt.Errorf("call failed")}}
        res := data[rand.Intn(len(data))]
        return res.v, res.err
    }

    func doGetAndWriteData() error {
        data, err := getDataFromRpc()
        err = writeData(data)
        return err
    }

This is perfectly valid code, and will write garbage sometimes, without any indication whatsoever. Yes, Go does refuse to compile code like this


    func doGetAndWriteData() error {
        data, err := getDataFromRpc()
        return err
    }

because `data` is not used, but declaring a variable and then immediately overwriting its value is perfectly legal and almost never what you want. At best the variable was never needed, in which case a `_` is a good way to signal it, or it was meant to be used and ineffassign found a bug.

I've seen this pattern frequently enough in tests, where part of the test code accidentally doesn't check intermediate errors or return values, leading to parts of the test silently breaking over time.

To its credit, [gopls does check for this now](https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md#assign).

# errcheck

In a similar vein, errcheck enforces checking error return values. In Go, errors are values, and unlike other[^1] languages[^2], nothing enforces they are checked.

This is valid:


    func foo() error { return fmt.Errorf("always errors out" ) }
    func bar() { foo() }
    func baz() string { foo(); return "" }


And so are all these:

    func foo() error { return fmt.Errorf("always errors out") }
    func bar() { _ = foo() }

    func foo() (string, error) { return "", fmt.Errorf("always errors out") }
    func bar() string { s, _ := foo(); return s  }

The only difference is that the first example carries no indication where this was intentional or not. errcheck enforces that error values are at least assigned to `_`, therefore being explicit that a decision was made to ignore the error[^3].

One case where this matters is when writing new code. It's easy enough to forget about checking all error returns of _all_ functions called. Again, tests passing by accident is a very frequent occasion, and so is production code.

Another also interesting case is functions changing signatures. When adding an error return to a function that previously returned nothing or updating a dependency that does so, you probably want to verify all the call sites, at the very least making the executive choice to explicitly ignore the errors.

# Retrofitting using golangci-lint

[golangci-lint](https://github.com/golangci/golangci-lint) has positioned itself as _the_ tool everyone uses on CI, and I'd say with good reason. It supports many linters, has improved massively over the past couple of years and has facilities for wiring up into existing codebases by only checking code that changes[^4], allowing for incremental cleanup.

For example:

    func foo() error { return nil }
    func bar() {
        foo()
    }


No one has to fix the unchecked error, until they touch the call in `bar()`. This works well, until you realise there are transformations where this heuristic falls flat. This is still true according to the latest golangci-lint, 1.28.3.

Here is an example of this in action:

    // from
    func foo() { }
    func bar() {
        foo()
    }
    // to
    func foo() error { return nil }
    func bar() {
        foo()
    }

Since the call to `foo()` is not touched, golangci-lint considers the unchecked error pre-existing and does not report it! The check is completely elided on changes that simply go from zero returns to a single error return. This simply makes the check not as useful as it could be, allowing regressions to merge over time.

The other problem with retrofitting is that the cleanup can be boring and take a long time. Clearing hundreds for errors in bulk is mind-numbing. Merely shifting around existing code might require fixing existing issues, unrelated to the change at hand.

Why go through that, when simply adding these linters from the start does the trick and saves you from bugs?

[^1]: good

[^2]: Rust

[^3]: Not necessarily a good decision, you can always find yourself staring at git blame wondering why.

[^4]: according to git and revgrep, using the `new-` settings in the config. Nowadays it works, a long time ago I found out the hard way it [didn't](https://github.com/rski/revgrep/commit/47e4fa165a7e434ef295b6837621de2d4f9db6b1)
