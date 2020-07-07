---
title: "Adventures  in Go modules #1: Gently removing dependency adhesions"
---

One of the things that I have to deal with in Go from time to time is how easy it is to pick up new dependencies. Add an import and suddenly a binary's import graph doubles. Sometimes a trick or two are needed to avoid pulling in more code than is needed, and this writeup is about one of those tricks. This will be a build up from starting a new module, adding a few dependencies and then using the hack to remove a few dependencies, corresponding to more than 40k lines of code.

To wit,
```sh
    git show e48ec4bda83fc2b5ddfaac2ccfd55df78d63b0df --shortstat --format=oneline
    e48ec4bda83fc2b5ddfaac2ccfd55df78d63b0df vendor: Remove gunk
    130 files changed, 45 insertions(+), 40725 deletions(-)
```

For those who want to follow along, this assumes go1.14[^1] (although 1.13 should also work).

## The contrived module

```sh
    mkdir -p ~/go/src/github.com/$USER/left-pad-thai
    cd ~/go/src/github.com/$USER/left-pad-thai
    go mod init
    git init
    git add go.mod
    git commit -m "so be it"
```

Ok, so this is a module. Let's add some code to make it useful. In `pad/pad.go`:

```go
package pad

type Padder struct {}

func New() *Padder {
	return &Padder{}
}
```

and in `pad/pad_test.go` to make sure New() doesn't panic:
```go
package pad

import "testing"

func TestNew(t *testing.T) {
	_ = New()
}

```

and now this should work:
```sh
    left-pad-thai $ go test ./...
    ok  	github.com/rski/left-pad-thai/pad	0.002s
```

Cool cool cool. `git add . && git commit -m "add go files"` and let's move on.

## Deconstructing the first dependency

Let's add a bit more to the test to make sure `New()` returns what we want. To get a pretty diff if it doesn't, let's throw goarista in the mix:

```go
package pad

import (
	"testing"

	"github.com/aristanetworks/goarista/test"
)

func TestNew(t *testing.T) {
	expected := &Padder{}
	got := New()
	if d := test.Diff(expected, got); d != "" {
		t.Fatalf("wanted %v, got %v: %s", expected, got, d)
	}
}
```

If you've been using modules, you probably know what will happen on `go test`.

```
go test -count=1 -run TestNew\$ .
go: finding module for package github.com/aristanetworks/goarista/test
go: found github.com/aristanetworks/goarista/test in github.com/aristanetworks/goarista v0.0.0-20200521140103-6c3304613b30
ok  	github.com/rski/left-pad-thai/pad	0.001s
```

`go test` is module aware. It downloads the modules needed and if they are not already there, they get recorded in `go.mod`. At the time of writing, this was the line added to `go.mod`:
```
require github.com/aristanetworks/goarista v0.0.0-20200521140103-6c3304613b30
```

But wait, what is this?
```
~/go/src/github.com/rski/left-pad-thai $ wc -l go.sum
186 go.sum
```

For one dependency, go recorded almost 200 lines worth of dependency signatures. It's time to inspect `goarista` a bit closer.
Its [go.mod](https://raw.githubusercontent.com/aristanetworks/goarista/master/go.mod) file has a lot of entries. Its [go.sum](https://raw.githubusercontent.com/aristanetworks/goarista/master/go.sum) even more.

In fact, here is something interesting.

```
    wget -q https://raw.githubusercontent.com/aristanetworks/goarista/master/go.sum -O goarista.sum
    diff -u goarista.sum go.sum
```

This produces two sorts of diffs:
- Two added lines for goarista which look like
```
+github.com/aristanetworks/goarista v0.0.0-20200521140103-6c3304613b30 h1:cgk6xsRVshE29qzHDCQ+tqmu7ny8GnjPQhAw/RTk/Co=
+github.com/aristanetworks/goarista v0.0.0-20200521140103-6c3304613b30/go.mod h1:QZe5Yh80Hp1b6JxQdpfSEEe8X7hTyTEZSosSrFf/oJE=
```
- removed lines for various other packages like
```
 github.com/beorn7/perks v1.0.0/go.mod h1:KWe93zE9D1o94FZ5RNwFwVgaQK1VOXiVxmqh+CedLV8=
-github.com/beorn7/perks v1.0.1 h1:VlbKKnNfV8bJzeqoa4cOKqO6bYr3WgKZxO8Z16+hsOM=
```

The explanation for these lines is on the [golang website](https://golang.org/cmd/go/#hdr-Module_authentication_using_go_sum):
    ```
    Each known module version results in two lines in the go.sum file. The first line gives the hash of the module version's file tree. The second line appends "/go.mod" to the version and gives the hash of only the module version's (possibly synthesized) go.mod file. The go.mod-only hash allows downloading and authenticating a module version's go.mod file, which is needed to compute the dependency graph, without also downloading all the module's source code.
    ```

For goarista, we got two lines, the filesystem one and the mod one. For _many_ packages, we didn't get the filesystem ones. That is, well, because those packages were never downloaded. Remember the output of `go test` from before. It only said `finding module for package github.com/aristanetworks/goarista/test`. goarista was downloaded, its two hashes were recorded and that was it. While goarista did have many dependencies in its go.sum, left-pad-thai did not actually depend on any of those. As a result, none of them were downloaded and only their go.mod sums were recorded.

Put another way: You can have a monorepo which is a single module and your users will download the dependencies of only the specific packages they use, not the entire module.

In this case, `goarista/test` has no dependencies outside of `goarista` itself, so go only grabbed that. This is a neat optimisation. It takes a second to download goarista. It takes significantly longer to download everything it depends on.

```
rski@belauensis ~/g/s/g/a/goarista> time -v go get ./...
go: downloading github.com/aristanetworks/glog v0.0.0-20191112221043-67e8567f59f3
go: downloading github.com/Shopify/sarama v1.26.1
...
	Command being timed: "go get ./..."
	User time (seconds): 41.53
	System time (seconds): 10.29
	Percent of CPU this job got: 98%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 0:52.66
```

Yup.

Ok, enough introductions, it is time to move to the more interesting stuff. `rm goarista.sum && git add . && git commit -m "end of first section"` and onwards.

## Aside: vendor

One trick to see what you are signing up for is to run `go mod vendor`. This puts everything the module needs to build under vendor/.

```
~/go/src/github.com/rski/left-pad-thai $ tree -L 2 vendor/
vendor/
├── github.com
│   └── aristanetworks
└── modules.txt
```

Checking vendor in has various benefits. Among other things it can make reviewing dependencies easier and removes the need to have Internet connectivity in order to build. It can also potentially make git bisect faster, since each step won't have to download the dependencies at that point in time. Of course that comes at the cost of checking in extra code.

Even without vendor, the less work `go` has to do before executing any tests or builds the better.

## Hacking away pointless dependencies

Turns out, what we _really_ want for this padding implementation is to talk to Google's spanner. Task one on the board says "Add dependency on spanner (10) points". A strategically placed import does just that.

```
package pad

+import _ "cloud.google.com/go/spanner"
+
```

Task complete. Time for "verify import (100 points)". You run a command and go off for a cup of tea. 18 computers seconds and a cup's worth of time later, you come back to find this:

```
rski@belauensis ~/g/s/g/r/left-pad-thai> time -v go mod tidy
go: downloading cloud.google.com/go v0.57.0
go: downloading github.com/aristanetworks/goarista v0.0.0-20200521140103-6c3304613b30
go: downloading cloud.google.com/go/spanner v1.6.0
go: downloading github.com/golang/protobuf v1.4.2
go: downloading google.golang.org/api v0.25.0
go: downloading github.com/googleapis/gax-go/v2 v2.0.5
go: downloading golang.org/x/xerrors v0.0.0-20191204190536-9bdfabe68543
go: downloading go.opencensus.io v0.22.3
go: downloading google.golang.org/genproto v0.0.0-20200526151428-9bb895338b15
go: downloading github.com/jstemmer/go-junit-report v0.9.1
go: downloading google.golang.org/grpc v1.29.1
go: downloading golang.org/x/lint v0.0.0-20200302205851-738671d3881b
go: downloading google.golang.org/protobuf v1.23.0
go: downloading honnef.co/go/tools v0.0.1-2020.1.4
go: downloading github.com/google/go-cmp v0.4.1
go: downloading cloud.google.com/go/pubsub v1.3.1
go: downloading golang.org/x/tools v0.0.0-20200522201501-cb1345f3a375
go: downloading golang.org/x/sync v0.0.0-20200317015054-43a5402ce75a
go: downloading cloud.google.com/go/datastore v1.1.0
go: downloading github.com/BurntSushi/toml v0.3.1
go: downloading golang.org/x/oauth2 v0.0.0-20200107190931-bf48bf16ab8d
go: downloading golang.org/x/net v0.0.0-20200520182314-0ba52f642ac2
go: downloading cloud.google.com/go/bigquery v1.8.0
go: downloading google.golang.org/appengine v1.6.6
go: downloading github.com/golang/groupcache v0.0.0-20200121045136-8c9f03a8e57e
go: downloading golang.org/x/sys v0.0.0-20200523222454-059865788121
go: downloading golang.org/x/mod v0.3.0
go: downloading cloud.google.com/go/storage v1.8.0
go: downloading github.com/google/martian v2.1.0+incompatible
go: downloading golang.org/x/text v0.3.2
	Command being timed: "go mod tidy"
	User time (seconds): 8.54
	System time (seconds): 3.50
	Percent of CPU this job got: 63%
	Elapsed (wall clock) time (h:mm:ss or m:ss): 0:18.93
```

Being as meticulous as can be, you inspect this line by line. There are a few fishy lines in there:

```
go: downloading github.com/jstemmer/go-junit-report v0.9.1
go: downloading honnef.co/go/tools v0.0.1-2020.1.4
```

Junit? Tools?

```
rski@belauensis ~/g/s/g/r/left-pad-thai> go mod why honnef.co/go/tools
go: finding module for package honnef.co/go/tools
# honnef.co/go/tools
(main module does not need package honnef.co/go/tools
```

No dice.

```
rski@belauensis ~/g/s/g/r/left-pad-thai> go mod why github.com/jstemmer/go-junit-report
# github.com/jstemmer/go-junit-report
github.com/rski/left-pad-thai/pad
cloud.google.com/go/spanner
cloud.google.com/go
github.com/jstemmer/go-junit-report
```

Now that's something. Still, what about honnef.co? Thankfully the next command is more helpful.

```
go mod graph | grep " honnef.co/go/tools" # note the leading space, we don't care about what honnef.co depends on'
cloud.google.com/go@v0.45.1 honnef.co/go/tools@v0.0.0-20190418001031-e561f6794a2a
cloud.google.com/go@v0.50.0 honnef.co/go/tools@v0.0.1-2019.2.3
cloud.google.com/go@v0.44.1 honnef.co/go/tools@v0.0.0-20190418001031-e561f6794a2a
cloud.google.com/go@v0.46.3 honnef.co/go/tools@v0.0.1-2019.2.3
...
```

`cloud.google.com/go` again, this is no coincidence. Something there causes them to get pulled in, as if they were actual build dependencies. But what?

```
rski@belauensis ~/g/s/g/r/left-pad-thai> go mod vendor
rski@belauensis ~/g/s/g/r/left-pad-thai> loc vendor | tail -n 2
 Total                 1102       429630        37202        71896       320532
 --------------------------------------------------------------------------------
rski@belauensis ~/g/s/g/r/left-pad-thai> ls vendor/cloud.google.com/go/*.go
vendor/cloud.google.com/go/doc.go  vendor/cloud.google.com/go/tools.go
rski@belauensis ~/g/s/g/r/left-pad-thai> head -n 1 vendor/cloud.google.com/go/tools.go
// +build tools
```

400k lines? Where do these come from? Turns out, [the go module documentation recommends this!](https://github.com/golang/go/wiki/Modules#how-can-i-track-tool-dependencies-for-a-module)

The developers of `cloud.google.com/go` use the non-building `tools.go` file to import `honnef.co/go/tools/cmd/staticcheck` and keep in sync the various tools they use. Unfortunately, as a downstream consumer this impacts you as well.

Thankfully there is a way out of this pickle. Time to make up your own modules and convince go they are the real thing. How hard can that be?

Turns out, surprisingly easy. The blank imports mean the fake modules don't even have to satisfy an API. All they need to do is _be there_.

`honnef.co/go/tools/cmd/staticcheck` has a few dependencies, so it's going to be the biggest bang for your buck.

```
rski@belauensis ~/g/s/g/r/left-pad-thai> mkdir .fake-honnef
rski@belauensis ~/g/s/g/r/left-pad-thai> cd .fake-honnef/
rski@belauensis ~/g/s/g/r/l/.fake-honnef> go mod init
go: creating new go.mod: module github.com/rski/left-pad-thai/.fake-honnef
rski@belauensis ~/g/s/g/r/l/.fake-honnef> mkdir -p cmd/staticcheck
rski@belauensis ~/g/s/g/r/l/.fake-honnef> echo "package staticcheck" > cmd/staticcheck/empty.go
```

And now for the magic line at the end of `go.mod` that puts it all together:

`replace honnef.co/go/tools => ./.fake-honnef`

Did it work?

```
rski@belauensis ~/g/s/g/r/left-pad-thai> go mod tidy
rski@belauensis ~/g/s/g/r/left-pad-thai> go mod vendor
rski@belauensis ~/g/s/g/r/left-pad-thai> loc vendor | tail -n 2
 Total                  959       385860        32843        63779       289238
```

About 150 files and 10% of the lines of code gone. Not too bad for 4 extra lines of code.

## Stubbing away pointless dependencies

In some cases, it is possible that a dependency is there and used during compilation, but not much. For example, `cloud.google.com/go/spanner` could have been calling a single function from the dependency you want to remove. But, you _know_ that in your code you will never hit that codepath, making this one-function dependency very much redundant. In that case, just creating an `empty.go` file would not cut it. Still, it's possible to work around that too, simply by stubbing out the uncalled function:

```
rski@belauensis ~/g/s/arista> cat empty.go
package staticcheck

func GoogleNeedsThis() error { panic("should never be called!) }
```

The fake module now fulfills the API contract and all is good. However, a lot of functions in modules operate on data structures also defined in the module, so this would end up being

```
rski@belauensis ~/g/s/arista> cat empty.go
package staticcheck

type AStruct struct{}

func GoogleNeedsThis() (*Astruct, error) { panic("should never be called!) }
```

Of course, the more contracts a fake module has to fulfill, the less useful it becomes, and harder to maintain. If it's a big surface of functions and types, it will probably be better and less of a maintenance burden to just use the real module.

[^1]: and the module versions at the time of writing. Unfortunately for this post, I think spanner removed the dependency on honnef.co/go/tools anyway, presumably since gopls provides the same thing.
