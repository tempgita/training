#general help
help.start()

#help on a function
help('lm') #OR
?lm

#help on a package
help(package = 'stats')

#Searches the help system for instances of the given string
help.search('correlation') #OR
??correlation

#Examples of given function
example('lm')

#Lists all available example datasets contained in currently loaded packages
data()

#listing and exploring a particular vignette (detailed help file with tutorial and examples)
vignette()
vignette('ggplot2')
