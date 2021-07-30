---
title: DS Algorithms for Securing NS and Glue
abbrev: DANG
docname: draft-dickson-dnsop-ds-hack
category: info

ipr: trust200902
area: Operations
workgroup: DNSOP Working Group
keyword: Internet-Draft

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:
 -
    ins: B Dickson
    name: Brian Dickson	
    organization: GoDaddy
    email: brian.peter.dickson@gmail.com

normative:
  RFC2119:

informative:



--- abstract

This Internet Draft proposes a mechanism to encode relevant data for NS records (and optionally A and AAAA records) on the parental side of a zone cut, by encoding them in new DS algorithms.

Since DS records are signed by the parent, this creates a method for validation of the otherwise unsigned delegation and glue records.

The result is the protection of unsigned delegations, which is beneficial if the name servers themselves are named out of a DNSSEC signed zone.

--- middle

# Introduction

There are new privacy goals and DNS server capability discovery goals, which cannot be met without the ability to validate the name of the name servers for a given domain at the delegation point.

Specifically, a query for NS records over an unprotected transport path returns results which do not have protection from tampering by an active on-path attacker, or against successful cache poisoning attackes.

This is true regardless of the DNSSEC status of the domain containing the authoritative information for the name servers for the queried domain.

For example, querying for the NS records for "example.com", at the name servers for the "com" TLD, where the published com zone has "example.com NS ns1.example.net", is not protected against MITM attacks, even if the domain "example.net" (the domain serving records for "ns1.example.net") is DNSSEC signed.

More infomation can be found in {{?I-D.nottingham-for-the-users}}. (An exmple
of an informative reference to a draft in the middle of text. Note that 
referencing an Internet draft involves replacing "draft-" in the name with 
"I-D.")

# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 {{RFC2119}} {{!RFC8174}}
when, and only when, they appear in all capitals, as shown here.

# Background

The methods developed for adding security to the Domain Name System, collectively refered to as DNSSEC, had as a primary requirement that they be backward compatible. The original specifications for DNS used the same RRTYPE on both the parent and child side of a zone cut (the NS record). The main goal of DNSSEC was to ensure data integrity by using cryptographic signatures. However, owing to this overlap in the NS record type, where the records above and below the zone cut have the same owner name, created an inherent conflict, as only one of the two publishers/servers of this data is truly authoritative.

The result is that the parental side of the zone cut has records needed for DNS resolution, which are not signed, and not validatable.

This has no impact on DNS zones which are fully DNSSEC signed (anchored at the IANA DNS Trust Anchor), but does impact unsigned zones, regardless of where the transition from secure to insecure occurs.

# Use Cases {#usecases}

This section will include some use cases for our new protocol.  The use cases conform
to the guidelines found in {{!RFC7258}}. (Demonstrating a normative 
reference inline.)

Note that the section heading also includes an anchor name that can be referenced in a 
cross reference later in the document, as is done in {{security-considerations}} 
of this document.  (Demonstrating using a reference to a heading without writing an
actual anchor, but rather using the heading name in lowercase and with dashes.)

## First use case

Some text about the first use case. (and an example of using a second level heading.)

HTTP version 2 is defined in {{?HTTP2=RFC7540}}. (Demonstrating renaming a reference so
that it is "HTTP2" instead of "RFC7540". You need to do this the first time you use a
reference. From here on in the document you can just use "HTTP2" in a reference.)

## Second use case

This example includes a list:

- first item
- second item
- third item, with a reference to {{?HTTP2}}.

And text below the list.

# Security Considerations

As outlined earlier in {{usecases}}, there could be security issues in various use
cases.

# IANA Considerations

This document has no IANA actions.



--- back

# Acknowledgments
{:numbered="false"}

Thanks to everyone who helped create the tools that let us use Markdown to create 
Internet Drafts.
