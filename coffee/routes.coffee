lex_app.config(['$routeProvider', '$locationProvider', '$httpProvider', ($routeProvider, $locationProvider, $httpProvider) ->

  $routeProvider.when '/',
    templateUrl: '/home.html'
    controller: lex_app.HomeController

  $routeProvider.otherwise
    redirectTo: '/'
])