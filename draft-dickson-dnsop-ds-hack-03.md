%%%
title = "DS Algorithms for Securing NS and Glue"
abbrev = "DS Algorithms for Securing NS and Glue"
docName = "draft-dickson-dnsop-ds-hack"
category = "info"

[seriesInfo]
name = "Internet-Draft"
value = "draft-dickson-dnsop-ds-hack-02"
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

This document specifies a mechanism to encode relevant data for NS records on the parental side of a zone cut by encoding them in DS records based on a new DNSKEY algorithm.

Since DS records are signed by the parent, this creates a method for validation of the otherwise unsigned delegation records.

Notably, support for updating DS records in a parent zone is already present (by necessity) in the Registry-Registrar-Registrant (RRR) provisioning system, EPP. Thus, no changes to the EPP protocol are needed, and no changes to registry database or publication systems upstream of the DNS zones published by top level domains (TLDs).

This NS validation mechanism is beneficial if the name server _names_ need to be validated prior to use.

{mainmatter}
{{README.md}}
{backmatter}

# Acknowledgments

Thanks to everyone who helped create the tools that let everyone use Markdown to create 
Internet Drafts, and the RFC Editor for xml2rfc.

Thanks to Dan York for his Tutorial on using Markdown (specifically mmark) for writing IETF drafts.

Thanks to YOUR NAME HERE for contributions, reviews, etc.
