meanie.animation '.ng-show-toggle-slidedown', () ->
  return {
    beforeAddClass: (element, className, done) ->
      if className == 'ng-hide'
        jQuery(element).slideUp {duretion: 100}, done
      else done()
    beforeRemoveClass: (element, className, done) ->
      if className == 'ng-hide'
        jQuery(element).css {display: 'none'}
        jQuery(element).slideDown {duration: 100}, done
      else done()
  }

meanie.animation '.ng-slide-meanie', () ->
  return {
    enter: (element, done) ->
      jQuery(element).css {display: 'none'}
      jQuery(element).slideDown {duretion: 100}, done
    leave: (element, done) ->
      jQuery(element).slideUp {duretion: 100}, done
  }