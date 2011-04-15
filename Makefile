
CSE_ID := qlsdpvmhhdi

all: gh-repos.cse.tsv

gh-repos-list.xml:
	curl http://github.com/api/v2/xml/repos/search/*?language=OCaml -o $@

gh-repos.urls: repos-list.xml
	xmlstarlet sel -t -m //url -v . -n $^ > $@

gh-repos.cse.tsv: gh-repos.urls
	{ printf 'Url\tLabel\n'; < $^ sed -ne '/./s/$$/\t_cse_$(CSE_ID)/p'; } > $@


.PHONY: all

