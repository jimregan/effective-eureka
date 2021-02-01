roman_to_arabic.far: roman_to_arabic.grm alphabet.far roman-to-arabic-1-9.tsv roman-to-arabic-11-19.tsv roman-to-arabic-10-90.tsv roman-to-arabic-20-90-nozero.tsv roman-to-arabic-100-900.tsv roman-to-arabic-100-900-nozero.tsv roman-to-arabic-1000-3000.tsv roman-to-arabic-1000-3000-nozero.tsv
	thraxcompiler --input_grammar=$< --output_far=$@

alphabet.far: alphabet.grm 
	thraxcompiler --input_grammar=$< --output_far=$@

clean:
	rm -f alphabet.far
