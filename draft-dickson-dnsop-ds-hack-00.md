%%%
title = "DS Algorithms for Securing NS and Glue"
abbrev = "DS Algorithms for Securing NS and Glue"
docName = "draft-dickson-dnsop-ds-hack"
category = "info"

[seriesInfo]
name = "Internet-Draft"
value = "draft-dickson-dnsop-ds-hack-00"
stream = "IETF"
status = "informational"


ipr = "trust200902"
area = "Operations"
workgroup = "DNSOP Working Group"
keyword = ["Internet-Draft"]

[pi]
toc = "yes"
sortrefs = "yes"
symrefs = "yes"
stand_alone = "yes"

[[author]]
initials = "B."
surname = "Dickson"
fullname = "Brian Dickson"
organization = "GoDaddy"
  [author.address]
  email = "brian.peter.dickson@gmail.com"

%%%

.# Abstract

This Internet Draft proposes a mechanism to encode relevant data for NS records (and optionally A and AAAA records) on the parental side of a zone cut, by encoding them in new DS algorithms.

Since DS records are signed by the parent, this creates a method for validation of the otherwise unsigned delegation and glue records.

This is beneficial if the name server _names_ are in a DNSSEC signed zone.

{mainmatter}

# Introduction

There are new privacy goals and DNS server capability discovery goals, which cannot be met without the ability to validate the name of the name servers for a given domain at the delegation point.

Specifically, a query for NS records over an unprotected transport path returns results which do not have protection from tampering by an active on-path attacker, or against successful cache poisoning attackes.

This is true regardless of the DNSSEC status of the domain containing the authoritative information for the name servers for the queried domain.

For example, querying for the NS records for "example.com", at the name servers for the "com" TLD, where the published com zone has "example.com NS ns1.example.net", is not protected against MITM attacks, even if the domain "example.net" (the domain serving records for "ns1.example.net") is DNSSEC signed.

# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@RFC2119] [@!RFC8174]
when, and only when, they appear in all capitals, as shown here.

# Background

The methods developed for adding security to the Domain Name System, collectively refered to as DNSSEC, had as a primary requirement that they be backward compatible. The original specifications for DNS used the same Resourc Record Type (RRTYPE) on both the parent and child side of a zone cut (the NS record). The main goal of DNSSEC was to ensure data integrity by using cryptographic signatures. However, owing to this overlap in the NS record type  where the records above and below the zone cut have the same owner name  created an inherent conflict, as only the child zone is authoritative for these records.

The result is that the parental side of the zone cut has records needed for DNS resolution  which are not signed  and not validatable.

This has no impact on DNS zones which are fully DNSSEC signed (anchored at the IANA DNS Trust Anchor), but does impact unsigned zones  regardless of where the transition from secure to insecure occurs.

# New DNSKEY Algorithms {#algorithms}

These new DNSKEY algorithms conform to the structure requirements from [@!RFC4034], but are not themselves used as actual DNSKEY algorithms. They are assigned values from the DNSKEY algorithm table. No DNSKEY records are published with these algorithms.

They are used only as the input to the corresponding DS hashes published in the parent zone.

## Algorithm {TBD1}

This algorithm is used to validate the NS records of the delegation for the owner name.

The NS records are canonicalized and sorted according to the DNSSEC signing process [@!RFC4034] section 6, including removing any label compression, and normalizing the character cases to lower case. The RDATA fields of the records are concatenated, and the result is hashed using the selected digest algorithm(s), e.g. SHA2-256 for DS digest algorithm 1.

### Example

Consider the delegation in the COM zone:

    example.com NS ns1.example.net
    example.com NS ns2.example.net

These two records have RDATA, which after canonicalization and sorting, would be:

    ns1.example.net
    ns2.example.net

The input to the digest is the concatenation of those values, i.e. "ns1.example.netns2.example.net".

The Key Tag is calculated per [@!RFC4034] using this value as the RDATA.

The resulting DS record is:

    ; example.com DS KeyTag=FOO Algorithm={TBD1}
    ;   DigestType=2 Digest=sha2-256("ns1.example.netns2.example.net")
    example.com DS KeyTag=FOO Algorithm={TBD1} DigestType=2 Digest=...


## Algorithm {TBD2}

This algorithm is used to validate the glue A records required as glue for the delegation NS set associated with the owner name.

The glue A records are canonicalized and sorted according to the DNSSEC signing process [@!RFC4034], including removing any label compression, and normalizing the character cases. The entirety of the records are concatenated, and the result is hashed using the selected hash type(s), e.g. SHA2-256 for DS type 2.

### Example

## Algorithm {TBD3}

This algorithm is used to validate the glue AAAA records required as glue for the delegation NS set associated with the owner name.

The glue AAAA records are canonicalized and sorted according to the DNSSEC signing process [@!RFC4034], including removing any label compression, and normalizing the character cases. The entirety of the records are concatenated, and the result is hashed using the selected hash type(s), e.g. SHA2-256 for DS type 2.

### Example

# Validation Using These DS Records

These new DS records are used to validate corresponding delegation records and glue, as follows:

* NS records are validated using {TBD1}
* Glue A records (if present) are validated using {TBD2}
* Glue AAAA records (if present) are validated using {TBD3}

The same method used for constructing the DS records, is used to validate their contents. The algorithm is replicated with the corresponding inputs, and the hash compared to the published DS record(s).

# Security Considerations

As outlined earlier in FIXME, there could be security issues in various use
cases.

# IANA Considerations

This document has no IANA actions.



{backmatter}

# Acknowledgments

Thanks to everyone who helped create the tools that let everyone use Markdown to create 
Internet Drafts, and the RFC Editor for xml2rfc.

Thanks to Dan York for his Tutorial on using Markdown for writing IETF drafts.

Thanks to YOUR NAME HERE for contributions, reviews, etc.
