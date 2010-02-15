# OAuth WRAP 0.9 for Tcl #

Simple implementation of OAuth WRAP 0.9 token validation library for Tcl.

	# => the token as it comes on the header
	set rawToken {wrap_access_token=name%3dmy_user%2540foo.com%26Issuer%3dhttps%253a%252f%252ffoo.accesscontrol.windows.net%252f%26Audience%3dhttps%253a%252f%252flocalhost%252fa-expense%26ExpiresOn%3d1266260230%26HMACSHA256%3dSW%252biW0CTcnuDTBEAHdtGi%252b2Lu%252f3La1snAjcwoGdJWDE%253d&wrap_access_token_expires_in=60}
	
	# => creates a configuration dictionary for the values
	dict set configuration signingKey {valid_key} # => signing key used by the Identity Provider
	dict set configuration issuer {valid_issuer} # => the identity provider URI
	dict set configuration audience {valid_audience}  # => my application audience URI
	
	# this will return the token when it's valid else it will return false
	set token [oauth::wrap::authenticate $configuration $rawToken]
	
	# at this point if the token valid you can mess around with its claims
	set name [dict get $token name]

## Installation ##
The package consists of a directory with the files (it is exactly what you have in the checkout folder) making up that package, 
plus the pkgIndex.tcl file. There are a couple of options which will enable autoloading to work:

- Make it a subdirectory of one of the directories given in the tcl_pkgPath variable, or
- If you install it elsewhere on your system, then make sure you add the directory name to the auto_path global variable. (This can be either explicitly e.g. lappend auto_path $dir within the application itself, or via the TCLLIBPATH environment variable.)

## Contributing ##
Once you've made your great commits:

1. [Fork](http://github.com/johnnyhalife/tcl-oauth-wrap "Fork") me
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create an Issue with a link to your branch
5. That's it!

## Meta ##
Written by Johnny G. Halife (johnny.halife at me dot com) and Juan Pablo Garcia Dalolla (juanpablogarcia at gmail dot com)

Released under the **'do the fuck you want'** license.


