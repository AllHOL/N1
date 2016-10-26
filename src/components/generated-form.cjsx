_ = require 'underscore'
classNames = require 'classnames'
React = require 'react'
ReactDOM = require 'react-dom'
{Utils} = require 'nylas-exports'
DatePicker = require('./date-picker').default
TabGroupRegion = require('./tab-group-region')

idPropType = React.PropTypes.oneOfType([
  React.PropTypes.string
  React.PropTypes.number
])

# The FormItem acts like a React controlled input.
# The `value` will set the "value" of whatever type of form item it is.
# The `onChange` handler will get passed this item's unique index (so
# parents can lookup and change the data appropriately) and the new value.
# Either direct parents, grandparents, etc are responsible for updating
# the `value` prop to update the value again.
class FormItem extends React.Component
  @displayName: "FormItem"

  @inputElementTypes:
    "checkbox": true
    "color": true
    "date": false # We use Nylas DatePicker instead
    "datetime": true
    "datetime-local": true
    "email": true
    "file": true
    "hidden": true
    "month": true
    "number": true
    "password": true
    "radio": true
    "range": true
    "search": true
    "tel": true
    "text": true
    "time": true
    "url": true
    "week": true

  @propTypes:
    # Some sort of unique identifier
    id: idPropType.isRequired

    formItemError: React.PropTypes.shape(
      id: idPropType # The formItemId
      message: React.PropTypes.string
    )

    # Either a type of input or any type that can be passed into
    # `React.createElement(type, ...)`
    type: React.PropTypes.oneOfType([
      React.PropTypes.string
      React.PropTypes.func
    ]).isRequired

    name: React.PropTypes.string
    label: React.PropTypes.node

    # For making all items controlled inputs
    value: React.PropTypes.oneOfType([
      React.PropTypes.string
      React.PropTypes.number
      React.PropTypes.object
      React.PropTypes.bool
    ])

    # For initialization
    defaultValue: React.PropTypes.string

    # selectOptions
    # An array of options.
    selectOptions: React.PropTypes.arrayOf(React.PropTypes.shape(
      label: React.PropTypes.node
      value: React.PropTypes.string
    ))

    # A function that takes two arguments:
    #   - The id of this FormItem
    #   - The new value of the FormItem
    onChange: React.PropTypes.func

    # Common <input> props.
    # Anything that can be passed into a standard React <input> item will
    # be passed along. Here are some common ones. There can be many more
    required: React.PropTypes.bool
    prefilled: React.PropTypes.bool
    multiple: React.PropTypes.bool
    maxlength: React.PropTypes.number
    placeholder: React.PropTypes.string
    tabIndex: React.PropTypes.number

    referenceTo: React.PropTypes.array
    referenceType: React.PropTypes.oneOf(["belongsTo", "hasMany", "hasManyThrough"])
    referenceThrough: React.PropTypes.string
    relationshipName: React.PropTypes.string

    formType: React.PropTypes.oneOf(['new', 'update'])
    editableForNew: React.PropTypes.bool
    editableForUpdate: React.PropTypes.bool

  render: =>
    classes = classNames
      "prefilled": @props.prefilled
      "form-item": true
      "invalid": !@_isValid()
      "valid": @_isValid()

    label = @props.label
    if @props.required
      label = <strong><span className="required">*</span>{@props.label}</strong>

    if @props.type is "hidden"
      @_renderInput()
    else
      <div className={classes} ref="inputWrap">
        <div className="label-area">
          <label htmlFor={@props.id}>{label}</label>
        </div>
        <div className="input-area">
          {@_renderInput()}
          {@_renderError()}
        </div>
      </div>

  shouldComponentUpdate: (nextProps) =>
    not Utils.isEqualReact(nextProps, @props)

  componentDidUpdate: (prevProps) ->
    if !prevProps.formItemError and !@_isValid()
      ReactDOM.findDOMNode(@refs.inputWrap).scrollIntoView(true)

  _isValid: ->
    !@props.formItemError

  _renderError: =>
    return false if @_isValid()
    msg = @props.formItemError.message
    <div className="form-error">{msg}</div>

  _isDisabled: =>
    (@props.formType is "new" and @props.editableForNew is false) or
    (@props.formType is "update" and @props.editableForUpdate is false)

  _renderInput: =>
    inputProps = _.extend {}, @props,
      ref: "input"
      onChange: (eventOrValue) =>
        @props.onChange(@props.id, ((eventOrValue?.target?.value) ? eventOrValue))

    if @_isDisabled() then inputProps.disabled = true

    if FormItem.inputElementTypes[@props.type]
      React.createElement("input", inputProps)
    else if @props.type is "select"
      options = (@props.selectOptions ? []).map (optionData) ->
        <option {...optionData} key={"#{Utils.generateTempId()}-optionData.value"} >{optionData.label}</option>
      options.unshift(<option key={"#{Utils.generateTempId()}-blank-option"}></option>)
      <select {...inputProps}>{options}</select>
    else if @props.type is "textarea"
      React.createElement("textarea", inputProps)
    else if @props.type is "date"
      inputProps.dateFormat = "YYYY-MM-DD"
      React.createElement(DatePicker, inputProps)
    else if @props.type is "EmptySpace"
      React.createElement("div", {className: "empty-space"})
    else if _.isFunction(@props.type)
      React.createElement(@props.type, inputProps)
    else
      console.warn "We do not support type #{@props.type} with attributes:", inputProps

class GeneratedFieldset extends React.Component
  @displayName: "GeneratedFieldset"

  @propTypes:
    # Some sort of unique identifier
    id: idPropType.isRequired

    formItems: React.PropTypes.arrayOf(React.PropTypes.shape(
      _.extend(FormItem.propTypes,
        row: React.PropTypes.number
        column: React.PropTypes.number
      )
    ))

    # The key is the formItem id, the value is the error object
    formItemErrors: React.PropTypes.object

    # A function that takes two arguments:
    #   - The id of this GeneratedFieldset
    #   - A new array of updated formItems with the correct value.
    onChange: React.PropTypes.func

    heading: React.PropTypes.node
    useHeading: React.PropTypes.bool
    formType: React.PropTypes.string
    zIndex: React.PropTypes.number

    lastFieldset: React.PropTypes.bool
    firstFieldset: React.PropTypes.bool

  render: =>
    classStr = classNames
      "first-fieldset": @props.firstFieldset
      "last-fieldset": @props.lastFieldset

    <fieldset style={{zIndex: @props.zIndex ? 0}} className={classStr} >
      {@_renderHeader()}
      <div className="fieldset-form-items">
        {@_renderFormItems()}
      </div>
      {@_renderFooter()}
    </fieldset>

  shouldComponentUpdate: (nextProps) =>
    not Utils.isEqualReact(nextProps, @props)

  _renderHeader: =>
    if @props.useHeading
      <header><legend>{@props.heading}</legend></header>
    else <div></div>

  _renderFormItems: =>
    byRow = _.groupBy(@props.formItems, "row")
    _.map byRow, (itemsInRow=[], rowNum) =>
      byCol = _.groupBy(itemsInRow, "column")
      numCols = Math.max.apply(null, Object.keys(byCol))

      style = { zIndex: 1000-rowNum }
      allHidden = _.every(itemsInRow, (item) -> item.type is "hidden")
      if allHidden then style.display = "none"

      <div className="row"
           data-row-num={rowNum}
           style={style}
           key={rowNum}>
        {_.map byCol, (itemsInCol=[], colNum) =>
          colEls = [<div className="column" data-col-num={colNum} key={colNum}>
            {itemsInCol.map (formItemData) =>
              props = @_propsFromFormItemData(formItemData)
              <FormItem {...props} ref={"form-item-#{formItemData.id}"}/>
            }
          </div>]
          if colNum isnt numCols - 1
            colEls.push(
              <div className="column-spacer" data-col-num={"#{colNum}-spacer"} key={"#{colNum}-spacer"}>
              </div>
            )
          return colEls
        }
      </div>

  # Given the raw data of an individual FormItem, prepare a set of props
  # to pass down into the FormItem.
  _propsFromFormItemData: (formItemData) =>
    props = _.clone(formItemData)
    props.key = props.id
    error = @props.formItemErrors?[props.id]
    if error then props.formItemError = error
    props.onChange = _.bind(@_onChangeItem, @)
    props.formType = @props.formType
    return props

  _onChangeItem: (itemId, newValue) =>
    newFormItems = _.map @props.formItems, (formItem) ->
      if formItem.id is itemId
        newFormItem = _.clone(formItem)
        newFormItem.value = newValue
        return newFormItem
      else return formItem
    @props.onChange(@props.id, newFormItems)

  _renderFooter: =>
    <footer></footer>

class GeneratedForm extends React.Component
  @displayName: "GeneratedForm"

  @propTypes:
    # Some sort of unique identifier
    id: idPropType

    errors: React.PropTypes.shape(
      formError: React.PropTypes.shape(
        message: React.PropTypes.string
        location: React.PropTypes.string # Can be "header" (default) or "footer"
      )
      formItemErrors: GeneratedFieldset.propTypes.formItemErrors
    )

    fieldsets: React.PropTypes.arrayOf(
      React.PropTypes.shape(GeneratedFieldset.propTypes)
    )

    # A function whose argument is a new set of Props
    onChange: React.PropTypes.func.isRequired

    onSubmit: React.PropTypes.func.isRequired

    style: React.PropTypes.object

    formType: React.PropTypes.string
    prefilled: React.PropTypes.bool

  @defaultProps:
    style: {}

  render: =>
    <form className="generated-form" ref="form" style={this.props.style} onSubmit={this.props.onSubmit}>
      <TabGroupRegion>
        {@_renderHeaderFormError()}
        {@_renderPrefilledMessage()}
        <div className="fieldsets">
          {@_renderFieldsets()}
        </div>
        <div className="form-footer">
          <input type="submit" value="Submit" className="btn btn-emphasis" />
        </div>
      </TabGroupRegion>
    </form>

  shouldComponentUpdate: (nextProps) =>
    not Utils.isEqualReact(nextProps, @props)

  componentDidUpdate: (prevProps) ->
    if !prevProps.errors?.formError and @props.errors?.formError
      ReactDOM.findDOMNode(@refs.formHeaderError).scrollIntoView(true)

  _renderPrefilledMessage: =>
    if @props.prefilled
      <div className="prefilled-message">
        The <span className="highlighted">highlighted</span> fields have been prefilled for you!
      </div>

  _renderHeaderFormError: =>
    if @props.errors?.formError
      <div ref="formHeaderError" className="form-error form-header-error">
        {@props.errors.formError.message}
      </div>
    else return false

  _renderFieldsets: =>
    (@props.fieldsets ? []).map (fieldset, i) =>
      props = @_propsFromFieldsetData(fieldset)
      props.zIndex = 100-i
      props.firstFieldset = i is 0
      props.lastFieldset = i isnt 0 and i is @props.fieldsets.length - 1
      <GeneratedFieldset {...props} ref={"fieldset-#{fieldset.id}"} />

  _propsFromFieldsetData: (fieldsetData) =>
    props = _.clone(fieldsetData)
    errors = @props.errors?.formItemErrors
    if errors then props.formItemErrors = errors
    props.key = fieldsetData.id
    props.onChange = _.bind(@_onChangeFieldset, @)
    props.formType = @props.formType
    return props

  _onChangeFieldset: (fieldsetId, newFormItems) =>
    newFieldsets = _.map @props.fieldsets, (fieldset) ->
      if fieldset.id is fieldsetId
        newFieldset = _.clone(fieldset)
        newFieldset.formItems = newFormItems
        return newFieldset
      else return fieldset

    @props.onChange _.extend {}, @props,
      fieldsets: newFieldsets

module.exports =
  FormItem: FormItem
  GeneratedForm: GeneratedForm
  GeneratedFieldset: GeneratedFieldset
