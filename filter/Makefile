default:
	cp ../senttok/licensesentence.dict /tmp/test.sentences
	./filter.pl /tmp/test.sentences
	egrep -v '^#' /tmp/test.badsent
