%%%
title = "DS Algorithms for Securing NS and Glue"
abbrev = "DS Algorithms for Securing NS and Glue"
docName = "draft-dickson-dnsop-ds-hack"
category = "info"

[seriesInfo]
name = "Internet-Draft"
value = "draft-dickson-dnsop-ds-hack-01"
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

This Internet Draft proposes a mechanism to encode relevant data for NS records on the parental side of a zone cut by encoding them in DS records based on a new DNSKEY algorithm.

Since DS records are signed by the parent, this creates a method for validation of the otherwise unsigned delegation records.

Notably, support for updating DS records in a parent zone is already present (by necessity) in the Registry-Registrar-Registrant (RRR) provisioning system, EPP. Thus, no changes to the EPP protocol are needed, and no changes to registry database or publication systems upstream of the DNS zones published by top level domains (TLDs).

This NS validation mechanism is beneficial if the name server _names_ need to be validated prior to use.

{mainmatter}

# Introduction

There are new privacy goals and DNS server capability discovery goals, which cannot be met without the ability to validate the name of the name servers for a given domain at the delegation point.

Specifically, a query for NS records over an unprotected transport path returns results which do not have protection from tampering by an active on-path attacker, or against successful cache poisoning attackes.

If an attacker alters the NS records returned, the recursive resolver could be directed to a server operated by an attacker. The recursive resolver would then leak query information, even if the resolver was using DNSSEC to validate responses from whichever server it got answers from.

This is true regardless of the DNSSEC status of the domain containing the authoritative information for the name servers for the queried domain.

The specific use case is for use of TLS between the recursive resolver and the authoritative server. The resolver has no prior knowledge of the expected identity of the authoritative server except via the delegation response itself. 

Validating the RDATA in an delegation response with the name server name is strictly necessary to validate TLS certificate. TLS certificate identities are entirely reliant on the DNS name embedded in the certificate.


# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@RFC2119] [@!RFC8174]
when, and only when, they appear in all capitals, as shown here.

# Background

The methods developed for adding security to the Domain Name System, collectively refered to as DNSSEC, had as a primary requirement that they be backward compatible. The original specifications for DNS used the same Resourc Record Type (RRTYPE) on both the parent and child side of a zone cut (the NS record). The main goal of DNSSEC was to ensure data integrity by using cryptographic signatures. However, owing to this overlap in the NS record type  where the records above and below the zone cut have the same owner name  created an inherent conflict, as only the child zone is authoritative for these records.

The result is that the parental side of the zone cut has records needed for DNS resolution  which are not signed  and not validatable.

This has no impact on DNS zones which are fully DNSSEC signed (anchored at the IANA DNS Trust Anchor), but does impact unsigned zones  regardless of where the transition from secure to insecure occurs.

## Attack Example
Suppose a resolver queries for the NS records for "example.com", at the name servers for the "com" TLD.
Suppose this domain has been published in the com zone as "example.com NS ns1.example.net".

The response is not protected against MITM attacks. An on-path attacker can substitute its own name, "ns1.attacker.example". The resolver would then send its queries to the attacker.

Note that this vulnerability to MITM is present even if the domain "example.net" (the domain serving records for "ns1.example.net") is DNSSEC signed, and the resolver intends to use TLS to make queries for names within the child zone, "example.com".

Substituting the name server name is sufficient to prevent the resolver from validating the TLS connection. It can validate the received TLS certificate, but would do expect the certificate to be for "ns1.attacker.example". 

# New DNSKEY Algorithm {#algorithm}

This new DNSKEY algorithm conforms to the structure requirements from [@!RFC4034], but is not itself used as actual DNSKEY algorithm. It is assigned a value from the DNSKEY algorithm table. No DNSKEY records are published in the child zone using this algorithm.

This DNSKEY is used only as the input to the corresponding DS hashs published in the parent zone.

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


# Validation Using These DS Records

These new DS records are used to validate corresponding delegation records and glue.
Each record must have a matching DS record. The expected DS record RDATA is constructed, and a matching DS record with identical RDATA MUST be present. Any NS record without matching valid DS record MUST be ignored.

* NS records are validated using {TBD1}. The RDATA consists of only the RDATA from the NS record.

# Security Considerations

As outlined earlier in FIXME, there could be security issues in various use
cases.

The target domain containing each name server name is presumed (and required) to be DNSSEC signed. 

# IANA Considerations

This document has no IANA actions.
(FIXME - update this doc to specify the required IANA actions - add TBD1 to the DNSKEY algorithm table)

{backmatter}

# Acknowledgments

Thanks to everyone who helped create the tools that let everyone use Markdown to create 
Internet Drafts, and the RFC Editor for xml2rfc.

Thanks to Dan York for his Tutorial on using Markdown (specifically mmark) for writing IETF drafts.

Thanks to YOUR NAME HERE for contributions, reviews, etc.
