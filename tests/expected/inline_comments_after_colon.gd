var prop = 10: # var comment
	set(value): # set comment
		prop = value
	get: # get comment
		return prop


class InnerClass: # class comment
	pass


func _init(): # constructor comment
	pass


func foo(): # func comment
	if true: # if comment
		pass
	elif false: # elif comment
		pass
	else: # else comment
		pass

	match 0: # match comment
		1: # case comment
			pass
		_: # default comment
			pass

	for i in 10: # for comment
		pass

	while false: # while comment
		pass

	var lam = func(): # lambda comment
		pass
