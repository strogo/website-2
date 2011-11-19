title: Summertime
type: entry
category: entries
datetime: 2011-07-31 23:47:12
---

Some people use summer vacation to do useful things. I have been using my
summertime to demonstrate how awesome <a
href="http://twistedmatrix.com/">Twisted</a> is.

Here's a fun example: Take <a
href="http://toastdriven.com/blog/2011/jul/31/gevent-long-polling-you/">this
basic long-polling example</a>, in gevent, and turn it into a Twisted-based
server instead.

First, let's look at the chunk of code that will communicate with the web
browser:

<code class="python">
class Pusher(Resource):
    isLeaf = True
    def render_GET(self, request):
        d = cc.connectTCP("localhost", 6379)
        @d.addCallback
        def cb(protocol):
            protocol.request = request
            protocol.subscribe("messages")
        request.write(" " * 4096)
	request.write("&lt;!DOCTYPE html&gt;&lt;h1&gt;Messages!&lt;/h1&gt;\n")
        return NOT_DONE_YET
</code>

Pretty nifty, right? This is a straightforward Twisted Web resource. It will
respond to GET requests by writing a small banner, "Messages!" and will leave
the connection open via <tt>NOT_DONE_YET</tt>. It also opens a connection to
some local server via the <tt>cc</tt> object, which I will explain
momentarily.

Now, let's look at the Redis client. This is my first time ever using Redis,
and also using txRedis, but I think I did alright.

<code class="python">
class Puller(RedisSubscriber):
    request = None
    def messageReceived(self, channel, message):
        if self.request and not self.request.finished:
            self.request.write("&lt;div&gt;Message on %s: '%s'&lt;/div&gt;\n"
                % (channel, message))
            if message == "quit":
                self.request.finish()
        if message == "quit":
            self.transport.loseConnection()
</code>

What does this do? I'm not super-sure, but it's pretty self-explanatory,
thankfully. <tt>RedisSubscriber</tt> is a protocol which can subscribe to, and
publish, messages on Redis. Only the <tt>messageReceived</tt> method needs to
be overriden, and we just use it to send messages to that request object.

Here's the part where people might get lost. How are these two objects hooked
up? Well, the answer (as some of you Twisted veterans may have guessed) is the
venerable <a
href="http://twistedmatrix.com/documents/current/api/twisted.internet.protocol.ClientCreator.html">ClientCreator</a>,
which creates instances of <tt>Puller</tt> for every GET request made in the
<tt>Pusher</tt>. Now, hopefully, the first half of <tt>render_GET()</tt> makes
more sense: The <tt>ClientCreator</tt> is asked to connect to the local Redis
server on port 6379, and will return a <tt>Puller</tt> in the callback. The
<tt>Pusher</tt> then hands the request over, and the <tt>Puller</tt> will
relay any Redis messages it picks up into that request. Everything else is
plumbing or sanity stuff; of note are the 4KiB of empty space at the beginning
of the request, which convinces browsers to start rendering the page, and also
the logic in <tt>messageReceived</tt> for closing the request and transport
properly.

Here's the entire thing, imports and all. Note that it's only one line longer
than the gevent version, and comes with a bunch of nifty free features like <a
href="http://pypy.org/">PyPy</a> compatibility.

<code class="python">
from twisted.internet import reactor
from twisted.internet.protocol import ClientCreator
from twisted.web.resource import Resource
from twisted.web.server import Site, NOT_DONE_YET
from txredis.protocol import RedisSubscriber
class Puller(RedisSubscriber):
    request = None
    def messageReceived(self, channel, message):
        if self.request and not self.request.finished:
            self.request.write("&lt;div&gt;Message on %s: '%s'&lt;/div&gt;\n"
                % (channel, message))
            if message == "quit":
                self.request.finish()
        # Ugh, Venn logic.
        if message == "quit":
            self.transport.loseConnection()
cc = ClientCreator(reactor, Puller)
class Pusher(Resource):
    isLeaf = True
    def render_GET(self, request):
        d = cc.connectTCP("localhost", 6379)
        @d.addCallback
        def cb(protocol):
            protocol.request = request
            protocol.subscribe("messages")
        request.write(" " * 4096)
	request.write("&lt;!DOCTYPE html&gt;&lt;h1&gt;Messages!&lt;/h1&gt;\n")
        return NOT_DONE_YET
reactor.listenTCP(1234, Site(Pusher()))
reactor.run()
</code>