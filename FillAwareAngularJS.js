var app = angular.module("myApp", []);

app.controller("ACController", function($scope, $q, $http) // Your controller
{
  $scope.suggestionList = [];
  $scope.hideSuggestions = true;

  var promiseCanceller = $q.defer(); // creating a promise, so there would not be 10 calls in a queue.

  $scope.updateAC = function($event,construct) // Function name to call
  {
    if(construct.length < 3) // Less calls and more accurate search. Change this number to whatever you want
    {
      return;
    }
    var type = $event.target.getAttribute("resourceType"); // This is your attribute. resourceType can be: names, companies, first_names, last_names, emails, addresses, colors 
    var APIKey = "iSkwEtRMxzOFzWwoy8GEvsL7DMlpn94Uffrg8ETYMOlrsspEZI7Ck_ElqvevdIxz";
	$scope.hideSuggestions = false;
    promiseCanceller.resolve('New request!'); // Cancel previous calls.
    promiseCanceller = $q.defer();
    $http.get("https://api.fillaware.com/v1/suggest/" + type + "?q=" + construct + "&key=" + APIKey, {timeout: promiseCanceller.promise}).
    then(function(response)
    {
        $scope.suggestionList = angular.fromJson(response.data);
    },
    function (error)
    {
        $scope.hideSuggestions = true;
        $scope.suggestionList = [];
    })
  };
  $scope.selectSuggestion = function(selection)
  {
    $scope.compName = selection;
    $scope.hideSuggestions = true;
  }
});