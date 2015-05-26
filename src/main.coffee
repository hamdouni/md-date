angular.module('mdDate', [])
.directive 'datePicker', ['$filter', '$sce', '$rootScope', '$parse', ($filter, $sce, $rootScope, $parse) ->
	_dateFilter = $filter 'date'
	restrict: 'AE'
	replace: true
	scope:
		_modelValue: '=ngModel'
	require: 'ngModel'
	templateUrl: 'md-date.tpl.html'
	link: (scope, element, attrs, ngModel) ->
		attrs.$observe 'placeholder', (val) ->
			if val? then scope._placeholder = val
		ngModel.$render = -> scope.setDate ngModel.$modelValue
		
		saveFn = $parse attrs.onSave
		cancelFn = $parse attrs.onCancel
		
		scope.$watch '_viewValue', (value) ->
			if value?
				scope.setDate value
				scope._modelValue = scope.date
 
		scope.save = ->
			#console.log('save ' + scope.date)
			scope._viewValue = moment(scope.date).format("DD/MM/YYYY")
			scope._modelValue = scope.date
			ngModel.$setDirty()
			scope._showPicker = false
			saveFn scope.$parent, $value: scope.date
		scope.cancel = ->
			cancelFn scope.$parent, {}
			ngModel.$render()
			scope._showPicker = false
	controller: ['$scope', (scope) ->
		moment().utc()
		scope.setDate = (newVal) ->
			#console.log('setDate ' + if newVal? then newVal else '')
			# update from input in the form dd/mm/yyyy or set to today
			t = if newVal? then moment(newVal,"DD/MM/YYYY").toDate()
			else new Date()
			# convert date to utc format (we don't care about hours)
			scope.date = new Date(Date.UTC(t.getFullYear(), t.getMonth(), t.getDate()))
			# set the calendar year and month
			scope.calendar._year = scope.date.getFullYear()
			scope.calendar._month = scope.date.getMonth()
		scope._showPicker = false
		scope.calendar =
			_month: 0
			_year: 0
			_months: (_dateFilter new Date(0, i), 'MMMM' for i in [0..11])
			offsetMargin: -> "#{ (new Date(@_year, @_month).getDay() - 1) * 2.7}rem"
			isVisible: (d) -> new Date(@_year, @_month, d).getMonth() is @_month
			class: (d) ->
				# coffeelint: disable=max_line_length
				if scope.date? and new Date(@_year, @_month, d).getTime() is new Date(scope.date.getTime()).setHours(0,0,0,0) then "selected"
				else if new Date(@_year, @_month, d).getTime() is new Date().setHours(0,0,0,0) then "today"
				else ""
				# coffeelint: enable=max_line_length
			#select: (d) -> scope.date.setFullYear @_year, @_month, d
			select: (d) -> scope.setDate d + "/" + (@_month+1) + "/" + @_year
			monthChange: ->
				if not @_year? or isNaN @_year then @_year = new Date().getFullYear()
				scope.date.setFullYear @_year, @_month
				if scope.date.getMonth() isnt @_month then scope.date.setDate 0
			_incMonth: (months) ->
				@_month += months
				while @_month < 0 or @_month > 11
					if @_month < 0
						@_month += 12
						@_year--
					else
						@_month -= 12
						@_year++
				@monthChange()
		scope.setNow = -> scope.setDate()
]]
