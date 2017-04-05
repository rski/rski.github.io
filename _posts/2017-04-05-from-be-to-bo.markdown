---
layout: post
title: "OPNFV SDNVPN: Danube, from Beryllium to Boron"
date: 2017-04-05 00:16:54 02000
categories: SDN Cloud OpenDaylight OpenStack OPNFV SDNVPN
---

I started this post a long long time ago, January of 2017, but for
various left it half-finished. Now that the Danube release of OPNFV is
upon us (and almost year later, I finished cleaning up the draft and
Euphrates is released too), I found it a good time to revise it,
cleanup a few things and make it a kind of retrospective of the
release.

After eight months in SDNVPN, 50 patches in the OPNFV gerrit, patches on the
OpenStack gerrit, and even some on Github, here is what it all boiled down to.

# The good

## New Features

We got a lot of things in this release, all of them quite exciting.

First and foremost, Automatic VTEP creation. OpenDaylight's new NetVirt project
automatically creates (and tears down if needed) tunnels between the Compute
nodes. In the Colorado release, SDNVPN used VPNService, where the tunnels had to
be created manually. This was my favourite change, mostly because it allowed us
to remove a lot of code from the plugin that deployed OpenDaylight in Mirantis Fuel.

Floating IP. Finally. I'm not sure how we lived before that. It opens
up a great number of possibilities, so many new things to do and test
on your cloud. As a surprising alternate point of view, the fine
people from CERN said in their Barcelona OpenStack Summit presentation
that they didn't have floating IPs *at all*.

First steps towards peering OpenDaylight with an external router (Quagga) came together
too. Sure, that is something that you can do yourself, but the documentation is
rather lacking and to my knowledge SDNVPN is the only project that actually
verifies this functionality with integration tests.

Finally, things really moved forward on the installer side. We uplifted the Fuel
plugin to install OpenDaylight Boron along with under the hood code quality
improvements, moved to OpenStack Newton and SDNVPN came to the APEX
installer. Now you can use the VPN features out of the box both on top of
Mirantis Fuel and RDO, which is pretty cool.

## The Community

If I had a penny for every time someone in the community helped me, I would only
be moderately wealthy, but if I had a penny for every minute of my time they saved me, I
would be on the track for permanent retirement.

The OPNFV community is not large, at least compared to others (OpenStack,
[shameless plug] VoxPupuli, etc). It more than makes up for that with hard work
and enjoyment for what they do.

Jose Lausuch was incredible. I'm not sure how he managed keep such a pace of
work, he was there even jet lagged and I'm pretty sure I saw his irc handle next
to messages timestamped at 00:00. He helped me time after time with Functest,
deploying Fuel and Apex and probably a lot of other things that I forget. Of
course the rest of the Functest community wasn't that far behind either.

The Fuel people were there to answer all my silly questions and solved issues
that I still wouldn't be able to solve. Without them moving to the new
OpenStack/Fuel version would have been nothing sort of impossible.

The APEX community (read: Tim Rozet) was delightful to work with. Packaging
Quagga/Zrpcd for CentOS and integrating it with APEX was 99% his effort and the
parts I worked on to make that happen were really fun.

Of course, this section would not be complete without mentioning Nikolas
Hermanns, who was brave enough to entrust me with a large part of SDNVPN and
steamrolled in zero time every task in his path. Among other things, the initial
work for moving to Boron was his and he integrated the baseline SDNVPN features
with APEX.

## Upsteam Testing

Nikolas Hermanns' work on adding OPNFV to OpenDaylight's upsteam testing
pipeline is just brilliant and deserves a section of its own, even though I
don't have much to say about it.

# The Bad

Ho boy. Let's see what we can dig up here.

## The Documentation

A lot of things in the OpenDaylight community are still tribal knowledge. Known
bugs might not be on the Bugzilla, the right way to do things is only known to
those who implemented it or those willing to read the devstack bash scripts and
so on.

Don't get me wrong, I'm very sure this is improving at an incredible speed. My
issue is that I spent a lot of time tracking down a regression, figuring out the
really weird way to reproduce it, reporting it, and only getting a "Yeah, we
know" back. A hint in the upgrade notes would have been nice.

The OpenDaylight docs have improved greatly, although they still need work. The
developer getting started tutorial is great now. If you have only seen the
Toaster tutorial, you're in for a treat. Still, the NetVirt/BGP documentation
leaves a lot of things out. Getting the proper network configuration for
floating IP required me reading the relevant OpenDaylight code and the devstack
README/scripts. Not the most integrator-friendly alternatives. The BGP features
are largely undocumented, for example there is an RPC for adding a
BGP router, but only a not-so-equivalent karaf command actually works. This took
me quite a bit to figure out.

In summary: Docs, we need more of them. This is great to see
https://twitter.com/Jamo0081/status/848672699178143744, but I would like to see
docs taking a higher priority and becoming more of an everyday thing rather than
a Sunday citizen.

## Heisenbugs and instability

Let's build a massively parallel distributed controller, nothing can go wrong.

Except for all the things that do.

Remember the automatic tunnel creation? That was broken in Boron SR-1 and it was
a pain for me to figure out what was wrong. In fact, it was the reason why Boron
was not included in Colorado SR3 for SDNVPN. The very nice folks in OpenDaylight
reproduced it consistently for me, patched it and got the fix in on time for
SR2. And they lived happily ever after.

Until the time for Danube came around. Due to a combination of factors, an
instability in Boron with respect to DHCP flows was only discovered a couple of
days before the release. As such, SDNVPN had to withdraw participation from
Danube and now targets Danube SR2.

# Disappointment (or the Future is looking bright)

After all this effort and time and and and... we get no release because of
upsteam bugs? That's just frustrating. Sucks to be me who spent so much effort
on this, right?

Yes. And no.

We got so many cool things in and so many goals were achieved, the release was
just a nice to have. This non-release put so many pieces together and not
releasing does not cancel out all the work done.

SDNVPN was the first OPNFV project to (un)successfully try out OpenDaylight's
NetVirt. We discovered and weeded out big bugs in OpenDaylight. Red Hat felt
confident enough to release a Technology Preview of Red Hat Openstack + Boron
with NetVirt:
http://redhatstackblog.redhat.com/2017/02/28/sdn-with-red-hat-openstack-platform-opendaylight-integration/

That is a success for me.
