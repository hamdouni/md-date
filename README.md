mdDate
===========

A Angular Material Directive that let your users select a date and only a date.

<img src="http://barim.us/md-date.png">

```html
<date-picker ng-model="myDate" placeholder="Select a date"></date-picker>
```

Demo here : http://barim.us/md-date/

## Original work

Thanks to Simeon Cheeseman (https://github.com/simeonc) for the original work, including far more features, see at https://github.com/SimeonC/md-date-time

## Requirements

1. `AngularJS` ≥ `1.2.x`
1. [Angular-Material](https://github.com/angular/material)

### Usage

1. Include `md-date.js` and `md-date.css`.
2. Add a dependency to `mdDate` in your app module, for example: ```angular.module('myModule', ['mdDate'])```.
3. Some implementation settings are required to get this useful, but for basic inline use:
```html
<date-picker ng-model="dateValue"></date-picker>
```

### Options

* **on-cancel:** Function passed in is called if the cancel button is pressed. `on-cancel="cancelFn()"`
* **on-save:** Function passed in is called when the date is saved via the OK button, date value is available as $value. `on-save="saveFn($value)"`

## Developer Notes

When checking out, you need a node.js installation, running `npm install` will get you setup with everything to run the compile.
Run `gulp compile` to compile the app or use `gulp watch` to compile the files as you save them.

## License

This project is licensed under the [MIT license](http://opensource.org/licenses/MIT).
