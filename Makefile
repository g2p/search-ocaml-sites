
CSE_ID := qlsdpvmhhdi

all: \
	data/gh-repos.direct.cse.tsv data/gh-repos.indirect.cse.tsv \
	data/ohloh-projects.direct.cse.tsv data/ohloh-projects.indirect.cse.tsv

data/gh-repos.xml:
	curl http://github.com/api/v2/xml/repos/search/*?language=OCaml -o $@

# Direct vs indirect:
# direct pages are OCaml project pages obtained from an API
# indirect pages are homepages linked from there.
# For example, an OCaml project linking to a company homepage.
# The company homepage has higher pagerank, but it's not OCaml-related.
# Score these lower so they don't swamp results.
data/gh-repos.direct.urls: data/gh-repos.xml
	xmlstarlet sel -t -m //repository -v url -n $^ > $@

data/gh-repos.indirect.urls: data/gh-repos.xml
	xmlstarlet sel -t -m //repository -v homepage -n $^ > $@

data/%.direct.cse.tsv: data/%.direct.urls
	{ printf 'Url\tLabel\tScore\n'; \
		sort -u -- $^ |sed -ne '/./s/$$/\t_cse_$(CSE_ID)\t.7/p'; } > $@

data/%.indirect.cse.tsv: data/%.indirect.urls
	{ printf 'Url\tLabel\tScore\n'; \
		sort -u -- $^ |sed -ne '/./s/$$/\t_cse_$(CSE_ID)\t.3/p'; } > $@

data/ohloh-projects.direct.urls data/ohloh-projects.indirect.urls: \
		ohloh-projects-list
	./$^ --max=500 \
		--projpages=ohloh-projects.direct.urls \
		--otherpages=ohloh-projects.indirect.urls


.PHONY: all

