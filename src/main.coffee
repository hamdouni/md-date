angular.module('mdDate', [])
.directive 'datePicker', ['$filter', '$sce', '$rootScope', '$parse', ($filter, $sce, $rootScope, $parse) ->
	_dateFilter = $filter 'date'
	restrict: 'E'
	replace: true
	scope:
		_modelValue: '=ngModel'
	require: 'ngModel'
	templateUrl: 'md-date.tpl.html'
	link: (scope, element, attrs, ngModel) ->

		attrs.$observe 'placeholder', (val) ->
			if val? then scope._placeholder = val

		isDate = (v) ->
			return Object.prototype.toString.call(v) == '[object Date]'

		toHumanDate = (v) ->
			if isDate(v)
				moment(v).format("DD/MM/YYYY")

		# init previous date viewed with today
		previousDate = new Date()

		# init calendar with today
		scope.setDate()

		# set default to model value
		scope._viewValue = if scope._modelValue? then toHumanDate scope._modelValue
		
		saveFn = $parse attrs.onSave
		cancelFn = $parse attrs.onCancel
		
		# if the view is changed and to avoid looping betwen model and view modification
		# test if the new value is exactly the same or not
		# don't forget the viewValue is human format ie DD/MM/YYYY
		scope.$watch '_viewValue', (v) ->
			oldDate = moment(previousDate,"DD/MM/YYYY")
			newDate = moment(v,"DD/MM/YYYY")
			if !(newDate.isSame(oldDate))
				previousDate = v
				scope.setFromView v

		# if the model is changed and to avoid looping between model and view modification
		# test if the new value is exactly the same or not
		# don't forget the modelValue is JS Date
		scope.$watch '_modelValue', (v) ->
			if v? and isDate(v) and !(moment(v).isSame(scope._modelValue))
				scope._viewValue = toHumanDate(v)
 
		scope.save = ->
			#console.log('save ' + scope.date)
			scope._viewValue = toHumanDate(scope.date)
			scope._modelValue = scope.date
			ngModel.$setDirty()
			scope._showPicker = false
			saveFn scope.$parent, $value: scope.date
		scope.cancel = ->
			cancelFn scope.$parent, {}
			ngModel.$render()
			scope._showPicker = false

	controller: ['$scope', (scope) ->

		fromHumanDate = (v) ->
			moment(v,"DD/MM/YYYY").toDate()

		scope.setFromView = (newVal) ->
			if newVal?
				scope.setDate newVal
				scope._modelValue = scope.date

		scope.setDate = (newVal) ->
			#console.log('setDate ' + if newVal? then newVal else '')
			# update from input in the form dd/mm/yyyy or set to today
			t = if newVal? then fromHumanDate(newVal)
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
