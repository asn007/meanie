window.jQuery = require 'jquery'
window._ = require 'lodash'
require 'angular'
require 'angular-animate'
require 'angular-ui-router'
require 'angular-bootstrap'

window.PARTIALS_URL = '/partials/'
window.AJAX_API_URL = '/ajax/'


window.meanie = angular.module('meanie', ['ui.router', 'ngAnimate', 'ui.bootstrap'])

require './animations/slide.coffee'
require './animations/jsfade.coffee'

require './controllers/general.coffee'

meanie.controller 'ApplicationController', ($scope, $rootScope, $timeout, $http) ->
  $rootScope.messages = {}
  $rootScope.addNotification = (message) ->
    id = Math.random()
    $rootScope.messages[id] = message
    $timeout () ->
      delete $rootScope.messages[id]
    , 3000

  $rootScope.curtain = true
  $scope.init = () ->
    $rootScope.curtain = false

  $scope.init()

meanie.factory 'MessageInterceptor', MessageInterceptor = ($rootScope, $window) ->
  processData = (response) ->
    if response != null and response != undefined and response.data
      if response.data.message
        $rootScope.addNotification response.data.message
      if response.data.url
        $window.location.href = response.data.url
    return response
  return {
  response: (response) ->
    return processData response
  responseError: (response) ->
    return processData response
  }

meanie.config ($httpProvider, $stateProvider, $urlRouterProvider) ->
  $httpProvider.interceptors.push MessageInterceptor
  $urlRouterProvider.when '/', '/main'
  $urlRouterProvider.when '', '/main'
  $urlRouterProvider.otherwise '/main'
  $stateProvider.state('main', {
    url: '/main'
    templateUrl: "#{PARTIALS_URL}/main"
    controller: 'GeneralController'
  })

