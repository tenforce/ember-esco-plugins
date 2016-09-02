# About
This is a collection of components and utilities that are shared across different platforms. They are meant to be specific for the ESCO project and to use parts of the generic ESCO model, not specific parts for a certain platform like e.g. the mapping platform.

## Taxonomy browser
The taxonomy browser allows visualization, search and browsing of a hierarchy over a certain taxonomy.

### How to use
Include the following snippet into your template
```
    {{#taxonomy-browser taxonomy=model.taxonomy filterTypes=filters activateItem="activateItem" searchPlaceholder="Filter..." baseConfig=config}}
      <div class="options" {{action 'toggleDisplayInChosenLanguage'}}>
        <i class="fa {{if (eq user.showIscoInChosenLanguage 'yes') 'fa-toggle-off' 'fa-toggle-on'}}"></i>
        Show tree in English
      </div>
    {{/taxonomy-browser}}
```
In this snippet, the following things are to be passed in:
- taxonomy: the ESCO.ConceptScheme to show
- filters: a list of filters in the format below
- optionally a yielded component that will be part of the hierarchy settings area

### Filters
Filters have to be passed into the taxonomy browser:
```
[
  {
    name: "All",
    id: null
  },
  {
    name: "To be translated",
    id: "70d7bd9f-107a-40dd-91f7-9bd210b7e7fc",
    params: {
      language: "en",
      status: "toDo"
    }
  },
  {
    name: "In progress",
    id: "70d7bd9f-107a-40dd-91f7-9bd210b7e7fc",
    params: {
      language: "en", 
      status: "inProgress"
    }
  }
]
```
ID is the uuid of the filter specification to use. Filter specifications are described in the hierarchy micro service. Params is a hash of parameters to be passed in to the hierarchy filter call where the key is the name of the parameter and the value the value.

## Usage
ember install git+ssh://git@git.tenforce.com:esco/ember-esco-plugins.git
