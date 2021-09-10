all: draft-dickson-dnsop-ds-hack.txt draft-dickson-dnsop-ds-hack.html

draft-dickson-dnsop-ds-hack.txt: draft-dickson-dnsop-ds-hack.xml
	xml2rfc --v2 --text draft-dickson-dnsop-ds-hack.xml

draft-dickson-dnsop-ds-hack.html: draft-dickson-dnsop-ds-hack.xml
	xml2rfc --v2 --html draft-dickson-dnsop-ds-hack.xml

draft-dickson-dnsop-ds-hack.xml: draft-dickson-dnsop-ds-hack.md
	./mmark -xml2 -page draft-dickson-dnsop-ds-hack.md > draft-dickson-dnsop-ds-hack.xml

