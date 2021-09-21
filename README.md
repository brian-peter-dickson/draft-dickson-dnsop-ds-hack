
# Introduction


Currently, any query for delegation NS records over an unprotected transport path returns results which do not have protection from tampering by an active on-path attacker, or against successful cache poisoning attacks. As a result, the recursive resolver could be directed to a server operated by an attacker.

This is because the parent NS records are not authoritative, and thus do not have RRSIGs. The child NS records with the same owner name are authoritative, but the parent NS records are what gets used for delegations.

There is new privacy work that relies on the name server names in the delegation RDATA. Unsigned records are vulnerable to modification by on-path attackers and to cache poisoning by off-path attackers.
That privacy work uses the name server name for TLS validation, and the only source of that name is the NS record in the delegation.

This document is about protecting the RDATA of NS record, not the privacy issues per se.

Note that the use of an encrypted transport (such as DoT [@RFC7858]) to the parent would be an alternative approach, but in the absence of encrypted transport, the approach proposed here is recommended.


# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@RFC2119] [@!RFC8174]
when, and only when, they appear in all capitals, as shown here.

# Background

The methods developed for adding security to the Domain Name System, collectively referred to as DNSSEC, had as a primary requirement that they be backward compatible. The original specifications for DNS used the same Resource Record Type (RRTYPE) on both the parent and child side of a zone cut (the NS record). The main goal of DNSSEC was to ensure data integrity by using cryptographic signatures. However, owing to this overlap in the NS record type (where the records above and below the zone cut have the same owner name) created an inherent conflict, as only the child zone is authoritative for these records.

The result is that the parent side of the zone cut has records needed for DNS resolution which are not signed and not validatable.

This has no security (data validation) impact on DNS zones which are fully DNSSEC signed (anchored at the IANA DNS Trust Anchor), but does impact unsigned zones regardless of where the transition from secure to insecure occurs.

## Attack Example
Suppose a resolver queries for the NS records for "example.com", at the name servers for the "com" TLD.
Suppose this domain has been published in the com zone as "example.com NS ns1.example.net".

The response is not protected against MITM attacks. An on-path attacker can substitute its own name, "ns1.attacker.example". The resolver would then send its queries to the attacker.

Note that this vulnerability to MITM is present even if the domain "example.net" (the domain serving records for "ns1.example.net") is DNSSEC signed, and the resolver intends to use TLS to make queries for names within the target zone "example.com".

Substituting the name server name is sufficient to prevent the resolver from validating the TLS connection. It can validate the received TLS certificate, but would do expect the certificate to be for "ns1.attacker.example".

# New DNSKEY Algorithm {#algorithm}

This new DNSKEY algorithm conforms to the structure requirements from [@!RFC4034], but is not itself used as an actual DNSKEY algorithm. It is assigned a value from the DNSKEY algorithm table.

This DNSKEY algorithm value is used only as the input to the corresponding DS hashes published in the parent zone. No DNSKEY records are published in the child zone using this algorithm.

Note that this method is orthogonal to the specific choice of DS hashes. Examples here refer to the what is published currently in the IANA tables for recommended DNSSEC parameters, including recommended choices. Any valid supported hash for DS records MAY be used.

## Algorithm {TBD1}

This algorithm is used to validate the NS records of the delegation for the owner name.

The original NS records are canonicalized according to the DNSSEC signing process [@!RFC4034] section 6, including removing any label compression, and normalizing the character cases to lower case. The RDATA field of the record is hashed using the selected digest algorithm(s), e.g. SHA2-256 for DS digest algorithm 2.

Note that only the RDATA from the wire format of the original NS record is used in constructing the DS record.

### Example

Consider the delegation in the COM zone:

    example.com NS ns1.Example.Net
    example.com NS ns2.Example.Net

The input to the digest for each NS record is the uncompressed wire format of their respective canonicalized RVALUEs.

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
Each NS record must have a matching DS record. The expected DS record RDATA is constructed, and a matching DS record with identical RDATA MUST be present. Any NS record without matching valid DS record MUST be ignored.

* NS records are validated using {TBD1}. The RDATA consists of only the RDATA from the NS record.

# Protection of glue records

For the issue of glue records (parent side A/AAAA records which are not signed), please see the proposal [@I-D.dickson-dnsop-glueless].

# Security Considerations

As outlined earlier in FIXME, there could be security issues in various use
cases.

The domain containing each name server name is presumed (and required) to be DNSSEC signed. 

# IANA Considerations

This document has no IANA actions.
(FIXME - update this doc to specify the required IANA actions - add TBD1 to the DNSKEY algorithm table)

