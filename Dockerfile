FROM perl:5.20
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
RUN perl Makefile.PL; make; make install
ENTRYPOINT [ "/usr/local/bin/ninka" ]
