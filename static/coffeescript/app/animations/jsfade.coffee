meanie.animation '.ng-fade-meanie', () ->
  return {
  enter: (element, done) ->
    jQuery(element).css {display: 'none'}
    jQuery(element).fadeIn 200, done
  leave: (element, done) ->
    jQuery(element).fadeOut 200, done
  }