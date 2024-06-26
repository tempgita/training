// cd "G:\.shortcut-targets-by-id\1ASYiYxEAcgJNzEL19Ex5oWLpC3ekSV7j\ROOT\TSM\to be delivered\training\Owner-occupied dwelling and imputed rent"

import excel using data/example1.xlsx, clear sheet("rent1") firstrow
reg price solar city garden

*Changing price to 120,000 from 100,000 in the fourth row
replace price = 120000 in 4

*now coefficient of garden represents the average change in the price represented by [(120,000-50,000) + (100,000 - 50,000)]/2 = 60,000
reg price solar city garden