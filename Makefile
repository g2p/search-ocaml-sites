
CSE_ID := qlsdpvmhhdi

OHLOH_API_KEY := ''

all: gh-repos.cse.tsv ohloh-projects.cse.tsv

gh-repos.xml:
	curl http://github.com/api/v2/xml/repos/search/*?language=OCaml -o $@

gh-repos.urls: gh-repos.xml
	xmlstarlet sel -t -m //url -v . -n $^ > $@

%.cse.tsv: %.urls
	{ printf 'Url\tLabel\n'; \
		sort -u -- $^ |sed -ne '/./s/$$/\t_cse_$(CSE_ID)/p'; } > $@

ohloh-projects.urls: ohloh-projects-list
	./$^ --max=500 > $@


.PHONY: all

