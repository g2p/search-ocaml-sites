
CSE_ID := qlsdpvmhhdi

all: \
	gh-repos.direct.cse.tsv gh-repos.indirect.cse.tsv \
	ohloh-projects.direct.cse.tsv ohloh-projects.indirect.cse.tsv

gh-repos.xml:
	curl http://github.com/api/v2/xml/repos/search/*?language=OCaml -o $@

# Direct vs indirect:
# direct pages are OCaml project pages obtained from an API
# indirect pages are homepages linked from there.
# For example, an OCaml project linking to a company homepage.
# The company homepage has higher pagerank, but it's not OCaml-related.
# Score these lower so they don't swamp results.
gh-repos.direct.urls: gh-repos.xml
	xmlstarlet sel -t -m //repository -v url -n $^ > $@

gh-repos.indirect.urls: gh-repos.xml
	xmlstarlet sel -t -m //repository -v homepage -n $^ > $@

%.direct.cse.tsv: %.direct.urls
	{ printf 'Url\tLabel\tScore\n'; \
		sort -u -- $^ |sed -ne '/./s/$$/\t_cse_$(CSE_ID)\t.7/p'; } > $@

%.indirect.cse.tsv: %.indirect.urls
	{ printf 'Url\tLabel\tScore\n'; \
		sort -u -- $^ |sed -ne '/./s/$$/\t_cse_$(CSE_ID)\t.3/p'; } > $@

ohloh-projects.direct.urls ohloh-projects.indirect.urls: ohloh-projects-list
	./$^ --max=500 \
		--projpages=ohloh-projects.direct.urls \
		--otherpages=ohloh-projects.indirect.urls


.PHONY: all

