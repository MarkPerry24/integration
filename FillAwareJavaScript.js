window.addEventListener('load', function()
{
  var inputName = document.getElementById('nameInput'); // nameInput is the name of input field.
  inputName.addEventListener('keyup', function(event)
  {
    hinter(event);
  });
  window.suggestionReqest = new XMLHttpRequest();

});

function hinter(event)
{
  if(typeof(event.key) === "undefined"
      || event.key === "Escape"
      || event.key === "ArrowRight"
      || event.key === "ArrowLeft"
      || event.key === "ArrowUp"
      || event.key === "ArrowDown")
  {
    return;
  }

  var input = event.target;

  var suggestionList = document.getElementById('suggestionList'); // name of the list for suggestions

  var type = event.target.getAttribute("resourceType"); // This is your attribute. resourceType can be: names, companies, first_names, last_names, emails, addresses, colors

  var min_characters = 3;
  
  var APIKey = "iSkwEtRMxzOFzWwoy8GEvsL7DMlpn94Uffrg8ETYMOlrsspEZI7Ck_ElqvevdIxz";

  if (input.value.length >= min_characters)
  {
    window.suggestionReqest.abort();

    window.suggestionReqest.onreadystatechange = function()
    {
      if (this.readyState === 4 && this.status === 200)
      {
        var response = JSON.parse(this.responseText);

        suggestionList.innerHTML = '';

        response.forEach(function(item)
        {
          var option = document.createElement('option');
          option.value = item;

          suggestionList.appendChild(option);
        });
      }
    };

    window.suggestionReqest.open('GET', 'https://api.fillaware.com/v1/suggest/' + type + '?q=' + input.value + "&key=" + APIKey, true);
    window.suggestionReqest.send();
  }
}
