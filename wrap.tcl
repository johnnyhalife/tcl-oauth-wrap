# wrap.tcl
#
#	Procedures to manage OAuth WRAP v0.9 Tokens.
#
#	This module depends on ncgi, base64 and sha256 modules for the procedures
#	that validate token elements based on the signature.
#
# Copyright (c) 2010 Johnny Halife <johnny.halife at me dot com> and Juan Pablo Garcia Dalolla <juanpablogarcia at gmail dot com>
#
# LICENSE: Do the fuck you want with code.

package require ncgi
package require base64
package require sha256

package provide oauth_wrap 0.9

namespace eval ::oauth::wrap {
	namespace export  parseToken validSignature?  validAudience?  validIssuer?  expired?  authenticate
}

# ::oauth::wrap::parseToken
#
# parses the content of the wrap_access_token excerpt of the WRAP0.9 header
#
# ARGS:
#       rawToken	the url decoded (using ncgi) wrap_access_token excerpt of the WRAP0.9 header
#
# RETURNS:
#       a dictionary containing key-value pairs for each of the token values
#
proc ::oauth::wrap::parseToken {rawToken} {
	set entries [split $rawToken &]
	foreach entry $entries {
		regexp {([^=]+)=(.*)$} $entry match key value
		dict set wrapToken [::ncgi::decode $key] [::ncgi::decode $value]
	}
	return $wrapToken
}

# ::oauth::wrap::validSignature?
#
#  computes and comprares the provided HMACSHA256 with a symmetric algorithm
#
# ARGS:
#       rawToken	the url decoded (using ncgi) wrap_access_token excerpt of the WRAP0.9 header
#       signingKey	the base64 encoded value of the application key used to sign the message
#
# RETURNS:
#       returns a value indicating whether the token signature is valid
#
proc ::oauth::wrap::validSignature? {rawToken signingKey} {
	regexp {&?HMACSHA256=([^&]+)} $rawToken match originalSignature
	set unsignedToken [regsub {&?HMACSHA256=[^&]+} $rawToken ""]
	set originalSignature [::ncgi::decode $originalSignature]
	set computedHash [::base64::encode [::sha2::hmac -bin -key [::base64::decode $signingKey] $unsignedToken]]
	return [string eq $originalSignature $computedHash]
}

# ::oauth::wrap::validAudience?
#
#  validates that the provided audience matches the expected application audience (applies to)
#
# ARGS:
#       token		a dictionary containing the key-value pair of the received token
#       audience	a string containing the expected audience (appliesTo) for the token
#
# RETURNS:
#       returns a value indicating whether the token audience is valid
#
proc ::oauth::wrap::validAudience? {token audience} {
	return [string eq [dict get $token Audience] $audience]
}

# ::oauth::wrap::validIssuer?
#
#  validates that the token issuer matches with an expected issuer
#
# ARGS:
#       token			a dictionary containing the key-value pair of the received token
#       trustedIssuer	a string containing a valid issuer for the token
#
# RETURNS:
#       returns a value indicating whether the token issuer is valid
#
proc ::oauth::wrap::validIssuer? {token trustedIssuer} {
	return [string eq [dict get $token Issuer] $trustedIssuer]
}

# ::oauth::wrap::expired?
#
#  validates that the token is not expired
#
# ARGS:
#       token		a dictionary containing the key-value pair of the received token
#       ttl			the wrap_access_token_expires_in provided excerpt of the WRAP0.9 header
#
# RETURNS:
#       returns a value indicating whether the token is expired
#
proc ::oauth::wrap::expired? {token} {
	return [expr [dict get $token ExpiresOn] < [clock seconds]]
}

# ::oauth::wrap::authenticate
#
#  parses, validates and returns (when valid) the provided token as part of the WRAP0.9 header
#
# ARGS:
#       configuration	a dictionary containing the key-value pair with the following values [signingKey, trustedIssuer, audience]
#       rawToken		full query content of the WRAP0.9 header
#
# RETURNS:
#       returns a token when it is valid or false when some of the preconditions fail
#
proc ::oauth::wrap::authenticate {configuration rawToken} {
	regexp {wrap_access_token=([^&]+)} $rawToken match wrapAccessToken
	set wrapAccessToken [::ncgi::decode $wrapAccessToken] 	

	if ([validSignature? $wrapAccessToken [dict get $configuration signingKey]]) {
		set token [parseToken $wrapAccessToken]
		if (![expired? $token]) {
			if ([validIssuer? $token [dict get $configuration issuer]]) {
				if ([validAudience? $token [dict get $configuration audience]]) {
					return $token
				}
			}
		}
	}
	return false
}