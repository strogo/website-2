<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">

%url = "/entry/%s" % entry["name"]

<html>
<head>
  <meta name="generator" content=
  "HTML Tidy for Linux (vers 7 December 2008), see www.w3.org">
  <link rel="stylesheet" type="text/css" href="/static/styles.css">

  <title>{{"%s ~ %s" % (title, entry["headline"])}}</title>
</head>

<body>
<div id="body">
%include header

%include entrydiv **entry

%include footer
</div>
</body>
</html>
