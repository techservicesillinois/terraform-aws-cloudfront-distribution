REGIONS := regions.tf.json
PHONY   := .regions

all: $(REGIONS)

.regions:
	aws --output json ec2 describe-regions | ./make-regions > $(REGIONS)

$(REGIONS): .regions

clean:
	rm -f $(REGIONS) .regions
