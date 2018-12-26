REPO_ASSERT := $(shell git config --get remote.origin.url)
REPO ?= $(REPO_ASSERT)

GHPAGES = gh-pages

LESSC    = node_modules/less/bin/lessc
LESSFILE = less/main.less

CSSDIR  = $(GHPAGES)/css
CSSFILE = $(CSSDIR)/main.css

INDEXFILE = $(GHPAGES)/index.html

all: init clean $(addprefix $(GHPAGES)/, $(addsuffix .html, $(basename $(wildcard *.md)))) commit serve

$(GHPAGES)/%.html: %.md $(GHPAGES) $(CSSFILE)
	@echo Converting files to html5
	pandoc -s --template "_layout" -c "css/main.css" -f markdown -t html5 -o "$@" "$<"

$(CSSFILE): $(CSSDIR) $(LESSFILE)
	$(LESSC) "$(LESSFILE)" "$(CSSFILE)"

$(CSSDIR):
	mkdir "$(CSSDIR)"

$(GHPAGES):
	git clone "$(REPO)" "$(GHPAGES)"
	@(cd $(GHPAGES) && git checkout $(GHPAGES)) || (cd $(GHPAGES) && git checkout --orphan $(GHPAGES) && git rm -rf .)
	@touch `git status --porcelain | cut -c4- | grep .md` || touch .

init:
	@echo Initializing Pandoc and Less
	@command -v pandoc > /dev/null 2>&1 || (echo 'pandoc not found http://johnmacfarlane.net/pandoc/installing.html' && exit 1)
	@[ -x $(LESSC) ] || npm install

serve:
	cd gh-pages && python -m SimpleHTTPServer

clean:
	rm -rf gh-pages

commit:
	@echo Committing updated files
	cd $(GHPAGES) && \
		git add . && \
		git commit --message="Publish @$$(date)"
	cd $(GHPAGES) && \
		git push origin $(GHPAGES)


.PHONY: clean init $(GHPAGES) commit serve