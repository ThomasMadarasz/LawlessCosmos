class_name BaseResource

extends Resource


func _duplicate(flag: Variant) -> Variant:
	var newRes: Variant = self.duplicate(flag)
	if flag:
		newRes._CheckDuplicateRes()
	return newRes

func _ArrayCheck(_type: Variant,pvalue: Array) -> void:
	var needcpobj: Dictionary = {}
	for i: int in range(pvalue.size()):
		var value: Variant = pvalue[i]
		var vtype: int = typeof(value)
		#handle type obj copy
		if vtype == TYPE_OBJECT:
			if not value.has_method("_duplicate"): continue
			var dpvalue: Variant = value._duplicate(true)
			needcpobj[i] = dpvalue
		else:
			self._CheckType(vtype,value)

	for i: int in needcpobj.keys():
		pvalue[i] = needcpobj[i]
	return

func _DictionaryCheck(_type: Variant,pvalue: Dictionary) -> void:
	var needcpobj: Dictionary = {}
	for key: Variant in pvalue:
		var value: Variant = pvalue[key]
		var vtype: int = typeof(value)
		#handle type obj copy
		if vtype == TYPE_OBJECT:
			if not value.has_method("_duplicate"): continue
			var dpvalue: Variant = value._duplicate(true)
			needcpobj[key] = dpvalue
		else:
			self._CheckType(vtype,value)

	for i: Variant in needcpobj.keys():
		pvalue[i] = needcpobj[i]
	return

func _CheckType(type: Variant,value: Variant) -> void:
	match type:
		TYPE_ARRAY:
			_ArrayCheck(type,value)
			return
		TYPE_DICTIONARY:
			_DictionaryCheck(type,value)
			return
		TYPE_OBJECT:
			if value.has_method("_CheckDuplicateRes"):
				value._CheckDuplicateRes()
			return

func _CheckDuplicateRes() -> void:
	for property: Dictionary in self.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value: Variant = self.get(property.name)
			if value == null: continue
			var type: int = property.type
			self._CheckType(type,value)
	return
