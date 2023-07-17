def browse(path, filterString, recursive=False):
	''' 
       EDIT: This may have been fixed in later version of Ignition.
       
	   system.tag.browse() does not allow filtering by fullPath. 
	   This script allows a fullPath key in the filter dictionary.
	   fullPath filters may use * and ? wildcards.
	   fullPath filters must be an iterable, i.g. a list or tuple.
	   USAGE : browseTags(basePath, {filters}, recursive)
	      Parameters:
	          String path - The path that will be browsed, typically to a folder or UDT instance. 
	          PyDictionary filter - A dictionary of browse filter keys.
	          Boolean recursive - Flag to allow recursive browsing
	       Returns: 
	          A list of tagPaths.
	   Example: browseTags('[default]', {'fullPath':[*/Production/*, */Bypass/*], 'tagType':'AtomicTag', 'dataType':'Boolean'}, recursive=True)
	'''
	import fnmatch
	# Pops the fullPath filter, if it exists.
	fullPathFilter = filterString.pop('fullPath', None)
	if fullPathFilter is not None:
		if not hasattr(fullPathFilter, '__iter__'):
			raise 'fullPath filter must be an iterable object, i.g. list or tuple'
	
	def tagBrowse(path, filterString, fullPathFilter):
		# First, browse for anything that can have children (Folders and UDTs, generally)
		results = system.tag.browse(path)
		for branch in results.getResults():    
			if branch['hasChildren'] and recursive:
				# If something has a child node, then call this function again so we can search deeper.
				# Include the filter, so newer instances of this call will have the same filter.
				tagBrowse(branch['fullPath'], filterString, fullPathFilter)
 

		# Call this function again at the current path, but apply the filter.
		results = system.tag.browse(path, filterString)

		for result in results.getResults():
			# Here's where you'd want to do something useful.
			resultString = str(result['fullPath'])
			
			if fullPathFilter is None:
				#print resultString
				tagListOut.append(resultString)
			else:
				# Check if fullPath filter is in the result string
				for item in fullPathFilter:
					if fnmatch.fnmatch(resultString, item):
						#print resultString
						tagListOut.append(resultString)

	tagListOut = []
	tagBrowse(path, filterString, fullPathFilter)
	return tagListOut