OBJS := main.tf providers.tf tables.tf

all: $(OBJS)

.describe-regions:
	aws --output json ec2 describe-regions > .describe-regions

.regions: .describe-regions
	grep '"RegionName":' .describe-regions | sed 's/^[^:]*: "//;s/",//' | \
    sort | tr '\n' ',' | sed 's/,$$//;s/,/, /g' > $@

%.tf: %.m4 .regions
	m4 -DREGIONS="$(shell cat .regions)" $< > $@

clean:
	rm -f $(OBJS) .regions .describe-regions
