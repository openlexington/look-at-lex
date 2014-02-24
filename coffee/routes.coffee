lex_app.config(['$routeProvider', '$locationProvider', '$httpProvider', ($routeProvider, $locationProvider, $httpProvider) ->

  $routeProvider.when '/',
    templateUrl: '/home.html'
    controller: lex_app.HomeController

  $routeProvider.when '/page/:page',
    templateUrl: '/home.html'
    controller: lex_app.HomeController

  $routeProvider.when '/page/:page/fund/:fund',
    templateUrl: '/home.html'
    controller: lex_app.HomeController

  $routeProvider.when '/page/:page/division/:dept_id',
    templateUrl: '/home.html'
    controller: lex_app.HomeController

  $routeProvider.when '/page/:page/fund/:fund/division/:dept_id',
    templateUrl: '/home.html'
    controller: lex_app.HomeController

  $routeProvider.otherwise
    redirectTo: '/'
])
