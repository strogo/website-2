title: The Bird is the Word
type: entry
category: entries
datetime: 2010-08-09 14:02:52
---

Twitter's apparently the rage these days. I've decided to get into it by
posting updates to this site, pushes to `my Github`_, and other code-related
things, automatically on Twitter.

This is harder than it sounds, mostly because Twitter's API is tricky to work
with, and also partially due to confusing and faulty tools. I'm going to
outline the basic steps I took to make my Twitter integration work, and also
point out that this took me **days**. For comparison, my RSS feed took me
around two minutes to implement, test, and deploy. (Oh, did I mention?  I have
an RSS feed now!)

First things first. In Python, there are a few different libraries available
to do Twitter API calls. Confusingly, they all have the same module name,
twitter, meaning that this statement is frustratingly ambiguous:

.. sourcecode:: pycon

    >>> import twitter

Which library did I just import?

The most common one is called python-twitter_ and it is usually available as a
package of the same name in your distro of choice. At least Debian (and
Ubuntu), Fedora, and Gentoo (via an overlay) have it.  *is **not** the right
library.* In about a week, Twitter will turn off the basic authentication,
totally disabling most deployed versions of this library.

Instead, use the `Python Twitter Tools`_. This package, available on PyPI as
`"twitter"`_, works with the newer OAuth system being deployed on Twitter, and
will work into the future.

So, OAuth. This is kind of tricky, and I'm not going to go into the gory
details. Suffice it to say that you need two pairs of keys: A consumer pair,
from Twitter's API service, and a token pair, from the user you're going to
post tweets as. To get consumer keys, you will need to go to
http://dev.twitter.com/apps and register a new application. Make sure you
specify Client access instead of Browser access. Now, go back to your Python
shell, and do the following:

.. sourcecode:: pycon

    >>> import twitter.oauth_dance
    >>> app_name = "my application" # use the info from the twitter app
    >>> key = "mumbo-jumbo" # the consumer key
    >>> secret = "secret-agent-man" # and the consumer secret
    >>> twitter.oauth_dance.oauth_dance(app_name, key, secret)

Follow the instructions, and you'll get a tuple containing your token key and
secret. Now just add the following to your client and you'll be set!

.. sourcecode:: python

    # Obviously, these are not real keys! Follow the instructions above to get
    # real keys.
    consumer_key = "mumbo-jumbo"
    consumer_secret = "secret-agent-man"
    token_key = "number-with-random-letters"
    token_secret = "mission-impossible"
    oauth = twitter.OAuth(token_key, token_secret, consumer_key,
        consumer_secret)
    twitter.Twitter(auth=oauth).statuses.update(status=message)

The library follows the same pattern as the official Twitter API, so this is
equivalent to requesting ``statuses/update.json`` with a ``status`` parameter.

.. _my Github: http://github.com/MostAwesomeDude
.. _python-twitter: http://code.google.com/p/python-twitter/
.. _Python Twitter Tools: http://mike.verdone.ca/twitter/
.. _"twitter": http://pypi.python.org/pypi/twitter
