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

This Internet Draft proposes a mechanism to encode relevant data for NS records, and when necessary A and AAAA glue data, on the parental side of a zone cut by encoding them in DS records based on new DNSKEY algorithms, one algorithm per encoded RRTYPE.

Since DS records are signed by the parent, this creates a method for validation of the otherwise unsigned delegation and glue records.

Notably, support for updating DS records in a parent zone is already present (by necessity) in the Registry-Registrar-Registrant (RRR) provisioning system, EPP. Thus, no changes to the EPP protocol are needed, and no changes to registry database or publication systems upstream of the DNS zones published by top level domains (TLDs).

This NS validation mechanism is beneficial if the name server _names_ need to be validated prior to use.

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

These new DNSKEY algorithms conform to the structure requirements from [@!RFC4034], but are not themselves used as actual DNSKEY algorithms. They are assigned values from the DNSKEY algorithm table. No DNSKEY records are published in the child zone using these algorithms.

They are used only as the input to the corresponding DS hashes published in the parent zone.

## Algorithm {TBD1}

This algorithm is used to validate the NS records of the delegation for the owner name.

The NS records are canonicalized according to the DNSSEC signing process [@!RFC4034] section 6, including removing any label compression, and normalizing the character cases to lower case. The RDATA field of the record is hashed using the selected digest algorithm(s), e.g. SHA2-256 for DS digest algorithm 2.

Note that only the RDATA from the original NS record is used in constructing the DS record.

### Example

Consider the delegation in the COM zone:

    example.com NS ns1.Example.Net
    example.com NS ns2.Example.Net

These two records have RDATA, which after canonicalization and converting to lower case, would be:

    ns1.example.net
    ns2.example.net

The input to the digest for each NS recrod is the corresponding value.

The Key Tag is calculated per [@!RFC4034] using this value as the RDATA.

The resulting combination of NS and DS records are:

    example.com NS ns1.Example.Net
    example.com NS ns2.Example.Net
    ; example.com DS KeyTag=FOO Algorithm={TBD1}
    ;   DigestType=2 Digest=sha2-256(wireformat("ns1.example.net"))
    example.com DS KeyTag=FOO Algorithm={TBD1} DigestType=2 Digest=...
    ; example.com DS KeyTag=FOO Algorithm={TBD1}
    ;   DigestType=2 Digest=sha2-256(wireformat("ns2.example.net"))
    example.com DS KeyTag=FOO Algorithm={TBD1} DigestType=2 Digest=...


## Algorithm {TBD2}

This algorithm is used to validate the glue A records required as glue for the delegation NS set associated with the owner name. Only "strict" glue for name servers whose name is subordinate to the zone name would be thusly encoded.

The glue A records are canonicalized according to the DNSSEC signing process [@!RFC4034], including removing any label compression, and normalizing the character cases. The owner name and RDATA records are concatenated, and the result is hashed using the selected hash type(s), e.g. SHA2-256 for DS type 2.

### Example
Consider the following delegation, where the name server name (RDATA from the NS record) is beneath the zone cut, i.e. subordinate to the domain name (owner name of the NS record):

    example.com NS ns1.example.com
    example.com NS ns2.example.com
    ns1.example.com A FIXME_EXAMPLE_IPV4_A_1
    ns2.example.com A FIXME_EXAMPLE_IPV4_A_2

The corresponding additional DS records would be:

    ; example.com DS KeyTag=FOO Algorithm={TBD2}
    ;   DigestType=2 Digest=sha2-256(wireformat("ns1.example.com",
    ;     FIXME_EXAMPLE_IPV4_A_1))
    example.com DS KeyTag=FOO Algorithm={TBD1} DigestType=2 Digest=...
    ; example.com DS KeyTag=FOO Algorithm={TBD2}
    ;   DigestType=2 Digest=sha2-256(wireformat("ns2.example.com", 
    ;     FIXME_EXAMPLE_IPV4_A_2))
    example.com DS KeyTag=FOO Algorithm={TBD2} DigestType=2 Digest=...

For example, if the original "glue" (unsigned) A records are:

    ns1.example.net IN 3600 A standard-example-ip-1
    ns2.example.net IN 3600 A standard-example-ip-2

There would be one DS record for each of the glue "A" records, with the canonicalized
wire format of the entire record provided as input to the hash function.

    FIXME replace 0xfffffffx with real example IP addresses
    (per IANA table of example IPs)
    First A record's DS record:
    wire_format(ns1.example.net) 0x01 0x01 3600 0xfffffff0
    Second A record's DS record:
    wire_format(ns2.example.net) 0x01 0x01 3600 0xfffffff1

Then the resulting DS record is

    FIXME - who is the right owner to use here?
    (The glue owner name, or the zone owner name (bailiwick only)?)
    example.net DS KeyTag=0 Algorithm={TBD2} DigestType=2 \
    Digest=sha2-256()
    example.net DS KeyTag=0 Algorithm={TBD2} DigestType=2 \
    Digest=sha2-256()

## Algorithm {TBD3}

This algorithm is used to validate the glue AAAA records required as glue for the delegation NS set associated with the owner name. Only "strict" glue for name servers whose name is subordinate to the zone name would be thusly encoded.

The glue AAAA records are canonicalized according to the DNSSEC signing process [@!RFC4034], including removing any label compression, and normalizing the character cases. The owner name and RDATA records are concatenated, and the result is hashed using the selected hash type(s), e.g. SHA2-256 for DS type 2.

### Example
Consider the following delegation, where the name server name (RDATA from the NS record) is beneath the zone cut, i.e. subordinate to the domain name (owner name of the NS record):

    example.com NS ns1.example.com
    example.com NS ns2.example.com
    ns1.example.com AAAA FIXME_EXAMPLE_IPV4_AAAA_1
    ns2.example.com AAAA FIXME_EXAMPLE_IPV4_AAAA_2

The corresponding additional DS records would be:

    ; example.com DS KeyTag=FOO Algorithm={TBD3}
    ;   DigestType=2 Digest=sha2-256(wireformat("ns1.example.com", 
    ;     FIXME_EXAMPLE_IPV4_AAAA_1))
    example.com DS KeyTag=FOO Algorithm={TBD3} DigestType=2 Digest=...
    ; example.com DS KeyTag=FOO Algorithm={TBD3}
    ;   DigestType=2 Digest=sha2-256(wireformat("ns2.example.com", 
    ;     FIXME_EXAMPLE_IPV4_AAAA_2))
    example.com DS KeyTag=FOO Algorithm={TBD3} DigestType=2 Digest=...

# Validation Using These DS Records

These new DS records are used to validate corresponding delegation records and glue.
Each record must have a matching DS record. The expected DS record RDATA is constructed, and a matching DS record with identical RDATA MUST be present or validation fails.

* NS records are validated using {TBD1}. The RDATA consists of only the RDATA from the NS record.
* Glue A records (if present) are validated using {TBD2}. The RDATA consists of the owner name of the A record plus the RDATA from the A record.
* Glue AAAA records (if present) are validated using {TBD3}. The RDATA consists of the owner name of the A record plus the RDATA from the AAAA record.

# Security Considerations

As outlined earlier in FIXME, there could be security issues in various use
cases.

# IANA Considerations

This document has no IANA actions.
(FIXME - update to list the required IANA actions - add TBD1, TBD2, TBD3 to the DNSKEY algorithm table)

{backmatter}

# Acknowledgments

Thanks to everyone who helped create the tools that let everyone use Markdown to create 
Internet Drafts, and the RFC Editor for xml2rfc.

Thanks to Dan York for his Tutorial on using Markdown (specifically mmark) for writing IETF drafts.

Thanks to YOUR NAME HERE for contributions, reviews, etc.
