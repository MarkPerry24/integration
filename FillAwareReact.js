import React from 'react';
import Autosuggest from 'react-autosuggest'
import AwesomeDebouncePromise from 'awesome-debounce-promise';

const getSuggestionValue = suggestion => suggestion;

const APIKey = "iSkwEtRMxzOFzWwoy8GEvsL7DMlpn94Uffrg8ETYMOlrsspEZI7Ck_ElqvevdIxz";

class AutoComplete extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: '',
      suggestions: ['']
    };
  }

  getSuggestions = value => {
    let url = `https://api.fillaware.com/v1/suggest/${this.props.resourceType}?q=${value}&key=${APIKey}` // Available resourceTypes are: names, companies, first_names, last_names, emails, addresses, colors
    return fetch(url).then(response => response.json());
  };

  getSuggestionsDebounced = AwesomeDebouncePromise(this.getSuggestions, 250);

  onChange = (event, { newValue }) => {
    this.setState({
      value: newValue
    });
  };

  onSuggestionsFetchRequested = async ({value}) =>
  {
    const result = await this.getSuggestionsDebounced(value);
    this.setState({
      suggestions: result
    });
  };

    onSuggestionsClearRequested = () => {
    this.setState({
      suggestions: []
    });
  };

  render() {
    const { value, suggestions } = this.state;

        const inputProps = {
      placeholder: '',
      value,
      onChange: this.onChange
    };

        return (
        <Autosuggest
            suggestions={suggestions}
            onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
            onSuggestionsClearRequested={this.onSuggestionsClearRequested}
            getSuggestionValue={getSuggestionValue}
            renderSuggestion={this.props.renderSuggestElement}
            inputProps={inputProps}
        />
    );
  }
}

export default AutoComplete;