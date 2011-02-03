default:
	cp ../senttok/licensesentence.dict /tmp/test.sentences
	./filter.pl /tmp/test.sentences
	diff -w -B /dev/null /tmp/test.badsent
