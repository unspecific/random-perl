Compare letters within Unicode to determine whch ones most resemble each other.

Use images and image comparison to determine which ones are closest based on the visual characters.

This test does depend on font.
Specific fonts can be specified.

initisl goal, compare letters for matches.

Current version compairs each 2 letters, right now using the Latin alphabet. 
Proof of concept on matching and then use that process to generate a config file
that says what substitusions to make.  THe process is time consuming, so it would only
have to be run when updating or changing a font.


Current version is also workng with image caching.  Current results example
52 generated, 5356 images used cache

DUMP is a samle of the DEBUG=1 output.  Generating the data to see the best way to use it.


The homographs.db is a list of all comparisons that match over 90%.
It incudes 100% when comparing a letter with itself.


