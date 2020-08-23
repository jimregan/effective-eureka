dzienniki-loc.tsv: dzienniki-nom.tsv
	@awk 'BEGIN{OFS=FS="\t"}{a=$$1; gsub("Dziennik ", "Dzienniku ");print a "\t" $$2}' < $< > $@
