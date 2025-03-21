import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'typedef.dart';

class TypeAheadFormField<T> extends FormField<String> {
  final TextFieldConfiguration textFieldConfiguration;

  /// Creates a [TypeAheadFormField]
  TypeAheadFormField(
      {super.key,
      String? initialValue,
      bool getImmediateSuggestions = false,
      @Deprecated('Use autovalidateMode parameter which provides more specific '
          'behavior related to auto validation. '
          'This feature was deprecated after Flutter v1.19.0.')
      bool autovalidate = false,
      super.enabled,
      AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
      super.onSaved,
      super.validator,
      ErrorBuilder? errorBuilder,
      WidgetBuilder? noItemsFoundBuilder,
      WidgetBuilder? loadingBuilder,
      Duration debounceDuration = const Duration(milliseconds: 300),
      SuggestionsBoxDecoration suggestionsBoxDecoration =
          const SuggestionsBoxDecoration(),
      SuggestionsBoxController? suggestionsBoxController,
      required SuggestionSelectionCallback<T> onSuggestionSelected,
      required ItemBuilder<T> itemBuilder,
      required SuggestionsCallback<T> suggestionsCallback,
      double suggestionsBoxVerticalOffset = 5.0,
      this.textFieldConfiguration = const TextFieldConfiguration(),
      AnimationTransitionBuilder? transitionBuilder,
      Duration animationDuration = const Duration(milliseconds: 500),
      double animationStart = 0.25,
      AxisDirection direction = AxisDirection.down,
      bool hideOnLoading = false,
      bool hideOnEmpty = false,
      bool hideOnError = false,
      bool hideSuggestionsOnKeyboardHide = true,
      bool keepSuggestionsOnLoading = true,
      bool keepSuggestionsOnSuggestionSelected = false,
      bool autoFlipDirection = false,
      bool hideKeyboard = false,
      int minCharsForSuggestions = 0})
      : assert(
            initialValue == null || textFieldConfiguration.controller == null),
        assert(minCharsForSuggestions >= 0),
        super(
            initialValue: textFieldConfiguration.controller != null
                ? textFieldConfiguration.controller!.text
                : (initialValue ?? ''),
            builder: (FormFieldState<String> field) {
              final _TypeAheadFormFieldState state =
                  field as _TypeAheadFormFieldState<dynamic>;

              return TypeAheadField(
                getImmediateSuggestions: getImmediateSuggestions,
                transitionBuilder: transitionBuilder,
                errorBuilder: errorBuilder,
                noItemsFoundBuilder: noItemsFoundBuilder,
                loadingBuilder: loadingBuilder,
                debounceDuration: debounceDuration,
                suggestionsBoxDecoration: suggestionsBoxDecoration,
                suggestionsBoxController: suggestionsBoxController,
                textFieldConfiguration: textFieldConfiguration.copyWith(
                  decoration: textFieldConfiguration.decoration
                      .copyWith(errorText: state.errorText),
                  onChanged: (text) {
                    state.didChange(text);
                    textFieldConfiguration.onChanged?.call(text);
                  },
                  controller: state._effectiveController,
                ),
                suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
                onSuggestionSelected: onSuggestionSelected,
                itemBuilder: itemBuilder,
                suggestionsCallback: suggestionsCallback,
                animationStart: animationStart,
                animationDuration: animationDuration,
                direction: direction,
                hideOnLoading: hideOnLoading,
                hideOnEmpty: hideOnEmpty,
                hideOnError: hideOnError,
                hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
                keepSuggestionsOnLoading: keepSuggestionsOnLoading,
                keepSuggestionsOnSuggestionSelected:
                    keepSuggestionsOnSuggestionSelected,
                autoFlipDirection: autoFlipDirection,
                hideKeyboard: hideKeyboard,
                minCharsForSuggestions: minCharsForSuggestions,
              );
            });

  @override
  _TypeAheadFormFieldState<T> createState() => _TypeAheadFormFieldState<T>();
}

class _TypeAheadFormFieldState<T> extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _controller;

  @override
  TypeAheadFormField get widget => super.widget as TypeAheadFormField<dynamic>;

  @override
  void initState() {
    super.initState();
    if (widget.textFieldConfiguration.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.textFieldConfiguration.controller!
          .addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(TypeAheadFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textFieldConfiguration.controller !=
        oldWidget.textFieldConfiguration.controller) {
      oldWidget.textFieldConfiguration.controller
          ?.removeListener(_handleControllerChanged);
      widget.textFieldConfiguration.controller
          ?.addListener(_handleControllerChanged);

      if (oldWidget.textFieldConfiguration.controller != null &&
          widget.textFieldConfiguration.controller == null) {
        _controller = TextEditingController.fromValue(
            oldWidget.textFieldConfiguration.controller!.value);
      }
      if (widget.textFieldConfiguration.controller != null) {
        setValue(widget.textFieldConfiguration.controller!.text);
        if (oldWidget.textFieldConfiguration.controller == null) {
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    widget.textFieldConfiguration.controller
        ?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController!.text = widget.initialValue!;
    });
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController!.text != value) {
      didChange(_effectiveController!.text);
    }
  }
}

class TypeAheadField<T> extends StatefulWidget {
  final SuggestionsCallback<T> suggestionsCallback;

  final SuggestionSelectionCallback<T> onSuggestionSelected;

  final ItemBuilder<T> itemBuilder;

  /// used to control the scroll behavior of item-builder list
  final ScrollController? scrollController;

  final SuggestionsBoxDecoration suggestionsBoxDecoration;

  final SuggestionsBoxController? suggestionsBoxController;
  final Duration debounceDuration;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final AnimationTransitionBuilder? transitionBuilder;
  final Duration animationDuration;
  final AxisDirection direction;
  final double animationStart;
  final TextFieldConfiguration textFieldConfiguration;
  final double suggestionsBoxVerticalOffset;
  final bool getImmediateSuggestions;
  final bool hideOnLoading;

  final bool hideOnEmpty;
  final bool hideOnError;
  final bool hideSuggestionsOnKeyboardHide;
  final bool keepSuggestionsOnLoading;
  final bool keepSuggestionsOnSuggestionSelected;
  final bool autoFlipDirection;
  final bool hideKeyboard;
  final int minCharsForSuggestions;

  /// Creates a [TypeAheadField]
  const TypeAheadField(
      {super.key,
      required this.suggestionsCallback,
      required this.itemBuilder,
      required this.onSuggestionSelected,
      this.textFieldConfiguration = const TextFieldConfiguration(),
      this.suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
      this.debounceDuration = const Duration(milliseconds: 300),
      this.suggestionsBoxController,
      this.scrollController,
      this.loadingBuilder,
      this.noItemsFoundBuilder,
      this.errorBuilder,
      this.transitionBuilder,
      this.animationStart = 0.25,
      this.animationDuration = const Duration(milliseconds: 500),
      this.getImmediateSuggestions = false,
      this.suggestionsBoxVerticalOffset = 5.0,
      this.direction = AxisDirection.down,
      this.hideOnLoading = false,
      this.hideOnEmpty = false,
      this.hideOnError = false,
      this.hideSuggestionsOnKeyboardHide = true,
      this.keepSuggestionsOnLoading = true,
      this.keepSuggestionsOnSuggestionSelected = false,
      this.autoFlipDirection = false,
      this.hideKeyboard = false,
      this.minCharsForSuggestions = 0})
      : assert(animationStart >= 0.0 && animationStart <= 1.0),
        assert(
            direction == AxisDirection.down || direction == AxisDirection.up),
        assert(minCharsForSuggestions >= 0);

  @override
  _TypeAheadFieldState<T> createState() => _TypeAheadFieldState<T>();
}

class _TypeAheadFieldState<T> extends State<TypeAheadField<T>>
    with WidgetsBindingObserver {
  FocusNode? _focusNode;
  TextEditingController? _textEditingController;
  _SuggestionsBox? _suggestionsBox;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _textEditingController;

  FocusNode? get _effectiveFocusNode =>
      widget.textFieldConfiguration.focusNode ?? _focusNode;
  late VoidCallback _focusNodeListener;

  final LayerLink _layerLink = LayerLink();

  // Timer that resizes the suggestion box on each tick. Only active when the user is scrolling.
  Timer? _resizeOnScrollTimer;

  // The rate at which the suggestion box will resize when the user is scrolling
  final Duration _resizeOnScrollRefreshRate = const Duration(milliseconds: 500);

  // Will have a value if the typeahead is inside a scrollable widget
  ScrollPosition? _scrollPosition;

  // Keyboard detection
  final Stream<bool>? _keyboardVisibility = null;

  // (supportedPlatform) ? KeyboardVisibilityController().onChange : null;
  late StreamSubscription<bool>? _keyboardVisibilitySubscription;

  @override
  void didChangeMetrics() {
    // Catch keyboard event and orientation change; resize suggestions list
    this._suggestionsBox!.onChangeMetrics();
  }

  @override
  void dispose() {
    this._suggestionsBox!.close();
    this._suggestionsBox!.widgetMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    _keyboardVisibilitySubscription?.cancel();
    _effectiveFocusNode!.removeListener(_focusNodeListener);
    _focusNode?.dispose();
    _resizeOnScrollTimer?.cancel();
    _scrollPosition?.removeListener(_scrollResizeListener);
    _textEditingController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.textFieldConfiguration.controller == null) {
      this._textEditingController = TextEditingController();
    }

    if (widget.textFieldConfiguration.focusNode == null) {
      this._focusNode = FocusNode();
    }

    this._suggestionsBox =
        _SuggestionsBox(context, widget.direction, widget.autoFlipDirection);
    widget.suggestionsBoxController?._suggestionsBox = this._suggestionsBox;
    widget.suggestionsBoxController?._effectiveFocusNode =
        this._effectiveFocusNode;

    this._focusNodeListener = () {
      if (_effectiveFocusNode!.hasFocus) {
        this._suggestionsBox!.open();
      } else {
        if (widget.hideSuggestionsOnKeyboardHide) {
          this._suggestionsBox!.close();
        }
      }
    };

    this._effectiveFocusNode!.addListener(_focusNodeListener);

    // hide suggestions box on keyboard closed
    this._keyboardVisibilitySubscription =
        _keyboardVisibility?.listen((bool isVisible) {
      if (widget.hideSuggestionsOnKeyboardHide && !isVisible) {
        _effectiveFocusNode!.unfocus();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      if (mounted) {
        this._initOverlayEntry();
        // calculate initial suggestions list size
        this._suggestionsBox!.resize();

        // in case we already missed the focus event
        if (this._effectiveFocusNode!.hasFocus) {
          this._suggestionsBox!.open();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScrollableState? scrollableState = Scrollable.of(context);
    _scrollPosition = scrollableState.position;

    _scrollPosition!.removeListener(_scrollResizeListener);
    _scrollPosition!.isScrollingNotifier.addListener(_scrollResizeListener);
  }

  void _scrollResizeListener() {
    bool isScrolling = _scrollPosition!.isScrollingNotifier.value;
    _resizeOnScrollTimer?.cancel();
    if (isScrolling) {
      // Scroll started
      _resizeOnScrollTimer =
          Timer.periodic(_resizeOnScrollRefreshRate, (timer) {
        _suggestionsBox!.resize();
      });
    } else {
      // Scroll finished
      _suggestionsBox!.resize();
    }
  }

  void _initOverlayEntry() {
    _suggestionsBox!._overlayEntry = OverlayEntry(builder: (context) {
      final suggestionsList = _SuggestionsList<T>(
        suggestionsBox: _suggestionsBox,
        decoration: widget.suggestionsBoxDecoration,
        debounceDuration: widget.debounceDuration,
        controller: _effectiveController,
        loadingBuilder: widget.loadingBuilder,
        scrollController: widget.scrollController,
        noItemsFoundBuilder: widget.noItemsFoundBuilder,
        errorBuilder: widget.errorBuilder,
        transitionBuilder: widget.transitionBuilder,
        suggestionsCallback: widget.suggestionsCallback,
        animationDuration: widget.animationDuration,
        animationStart: widget.animationStart,
        getImmediateSuggestions: widget.getImmediateSuggestions,
        onSuggestionSelected: (T selection) {
          if (!widget.keepSuggestionsOnSuggestionSelected) {
            _effectiveFocusNode!.unfocus();
            _suggestionsBox!.close();
          }
          widget.onSuggestionSelected(selection);
        },
        itemBuilder: widget.itemBuilder,
        direction: _suggestionsBox!.direction,
        hideOnLoading: widget.hideOnLoading,
        hideOnEmpty: widget.hideOnEmpty,
        hideOnError: widget.hideOnError,
        keepSuggestionsOnLoading: widget.keepSuggestionsOnLoading,
        minCharsForSuggestions: widget.minCharsForSuggestions,
      );

      double w = _suggestionsBox!.textBoxWidth;
      if (widget.suggestionsBoxDecoration.constraints != null) {
        if (widget.suggestionsBoxDecoration.constraints!.minWidth != 0.0 &&
            widget.suggestionsBoxDecoration.constraints!.maxWidth !=
                double.infinity) {
          w = (widget.suggestionsBoxDecoration.constraints!.minWidth +
                  widget.suggestionsBoxDecoration.constraints!.maxWidth) /
              2;
        } else if (widget.suggestionsBoxDecoration.constraints!.minWidth !=
                0.0 &&
            widget.suggestionsBoxDecoration.constraints!.minWidth > w) {
          w = widget.suggestionsBoxDecoration.constraints!.minWidth;
        } else if (widget.suggestionsBoxDecoration.constraints!.maxWidth !=
                double.infinity &&
            widget.suggestionsBoxDecoration.constraints!.maxWidth < w) {
          w = widget.suggestionsBoxDecoration.constraints!.maxWidth;
        }
      }

      return Positioned(
        width: w,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
              widget.suggestionsBoxDecoration.offsetX,
              _suggestionsBox!.direction == AxisDirection.down
                  ? _suggestionsBox!.textBoxHeight +
                      widget.suggestionsBoxVerticalOffset
                  : _suggestionsBox!.directionUpOffset),
          child: _suggestionsBox!.direction == AxisDirection.down
              ? suggestionsList
              : FractionalTranslation(
                  translation:
                      const Offset(0.0, -1.0), // visually flips list to go up
                  child: suggestionsList,
                ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        focusNode: _effectiveFocusNode,
        controller: _effectiveController,
        decoration: widget.textFieldConfiguration.decoration,
        style: widget.textFieldConfiguration.style,
        textAlign: widget.textFieldConfiguration.textAlign,
        enabled: widget.textFieldConfiguration.enabled,
        keyboardType: widget.textFieldConfiguration.keyboardType,
        autofocus: widget.textFieldConfiguration.autofocus,
        inputFormatters: widget.textFieldConfiguration.inputFormatters,
        autocorrect: widget.textFieldConfiguration.autocorrect,
        maxLines: widget.textFieldConfiguration.maxLines,
        textAlignVertical: widget.textFieldConfiguration.textAlignVertical,
        minLines: widget.textFieldConfiguration.minLines,
        maxLength: widget.textFieldConfiguration.maxLength,
        maxLengthEnforcement:
            widget.textFieldConfiguration.maxLengthEnforcement,
        obscureText: widget.textFieldConfiguration.obscureText,
        onChanged: widget.textFieldConfiguration.onChanged,
        onSubmitted: widget.textFieldConfiguration.onSubmitted,
        onEditingComplete: widget.textFieldConfiguration.onEditingComplete,
        onTap: widget.textFieldConfiguration.onTap,
        scrollPadding: widget.textFieldConfiguration.scrollPadding,
        textInputAction: widget.textFieldConfiguration.textInputAction,
        textCapitalization: widget.textFieldConfiguration.textCapitalization,
        keyboardAppearance: widget.textFieldConfiguration.keyboardAppearance,
        cursorWidth: widget.textFieldConfiguration.cursorWidth,
        cursorRadius: widget.textFieldConfiguration.cursorRadius,
        cursorColor: widget.textFieldConfiguration.cursorColor,
        textDirection: widget.textFieldConfiguration.textDirection,
        enableInteractiveSelection:
            widget.textFieldConfiguration.enableInteractiveSelection,
        readOnly: widget.hideKeyboard,
      ),
    );
  }
}

class _SuggestionsList<T> extends StatefulWidget {
  final _SuggestionsBox? suggestionsBox;
  final TextEditingController? controller;
  final bool getImmediateSuggestions;
  final SuggestionSelectionCallback<T>? onSuggestionSelected;
  final SuggestionsCallback<T>? suggestionsCallback;
  final ItemBuilder<T>? itemBuilder;
  final ScrollController? scrollController;
  final SuggestionsBoxDecoration? decoration;
  final Duration? debounceDuration;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final AnimationTransitionBuilder? transitionBuilder;
  final Duration? animationDuration;
  final double? animationStart;
  final AxisDirection? direction;
  final bool? hideOnLoading;
  final bool? hideOnEmpty;
  final bool? hideOnError;
  final bool? keepSuggestionsOnLoading;
  final int? minCharsForSuggestions;

  const _SuggestionsList({
    required this.suggestionsBox,
    this.controller,
    this.getImmediateSuggestions = false,
    this.onSuggestionSelected,
    this.suggestionsCallback,
    this.itemBuilder,
    this.scrollController,
    this.decoration,
    this.debounceDuration,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.transitionBuilder,
    this.animationDuration,
    this.animationStart,
    this.direction,
    this.hideOnLoading,
    this.hideOnEmpty,
    this.hideOnError,
    this.keepSuggestionsOnLoading,
    this.minCharsForSuggestions,
  });

  @override
  _SuggestionsListState<T> createState() => _SuggestionsListState<T>();
}

class _SuggestionsListState<T> extends State<_SuggestionsList<T>>
    with SingleTickerProviderStateMixin {
  Iterable<T>? _suggestions;
  late bool _suggestionsValid;
  late VoidCallback _controllerListener;
  Timer? _debounceTimer;
  bool? _isLoading, _isQueued;
  Object? _error;
  AnimationController? _animationController;
  String? _lastTextValue;
  late final ScrollController _scrollController =
      widget.scrollController ?? ScrollController();

  _SuggestionsListState() {
    _controllerListener = () {
      // If we came here because of a change in selected text, not because of
      // actual change in text
      if (widget.controller!.text == _lastTextValue) return;

      _lastTextValue = widget.controller!.text;

      _debounceTimer?.cancel();
      if (widget.controller!.text.length < widget.minCharsForSuggestions!) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _suggestions = null;
            _suggestionsValid = true;
          });
        }
        return;
      } else {
        _debounceTimer = Timer(widget.debounceDuration!, () async {
          if (_debounceTimer!.isActive) return;
          if (_isLoading!) {
            _isQueued = true;
            return;
          }

          await invalidateSuggestions();
          while (_isQueued!) {
            _isQueued = false;
            await invalidateSuggestions();
          }
        });
      }
    };
  }

  @override
  void didUpdateWidget(_SuggestionsList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller!.addListener(_controllerListener);
    _getSuggestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getSuggestions();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _suggestionsValid = widget.minCharsForSuggestions! > 0 ? true : false;
    _isLoading = false;
    _isQueued = false;
    _lastTextValue = widget.controller!.text;

    if (widget.getImmediateSuggestions) {
      _getSuggestions();
    }

    widget.controller!.addListener(this._controllerListener);
  }

  Future<void> invalidateSuggestions() async {
    _suggestionsValid = false;
    await _getSuggestions();
  }

  Future<void> _getSuggestions() async {
    if (_suggestionsValid) return;
    _suggestionsValid = true;

    if (mounted) {
      setState(() {
        _animationController!.forward(from: 1.0);
        _isLoading = true;
        _error = null;
      });

      Iterable<T>? suggestions;
      Object? error;

      try {
        suggestions =
            await widget.suggestionsCallback!(widget.controller!.text);
      } catch (e) {
        error = e;
      }

      if (mounted) {
        // if it wasn't removed in the meantime
        setState(() {
          double? animationStart = widget.animationStart;
          // allow suggestionsCallback to return null and not throw error here
          if (error != null || suggestions?.isEmpty == true) {
            animationStart = 1.0;
          }
          _animationController!.forward(from: animationStart);

          _error = error;
          this._isLoading = false;
          this._suggestions = suggestions;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEmpty = (_suggestions?.isEmpty ?? false) &&
        (widget.controller?.text ?? '') == "";
    if ((this._suggestions == null || isEmpty) &&
        this._isLoading == false &&
        this._error == null) return Container();

    Widget child;
    if (this._isLoading!) {
      if (widget.hideOnLoading!) {
        child = Container(height: 0);
      } else {
        child = createLoadingWidget();
      }
    } else if (this._error != null) {
      if (widget.hideOnError!) {
        child = Container(height: 0);
      } else {
        child = createErrorWidget();
      }
    } else if (this._suggestions!.isEmpty) {
      if (widget.hideOnEmpty!) {
        child = Container(height: 0);
      } else {
        child = createNoItemsFoundWidget();
      }
    } else {
      child = createSuggestionsWidget();
    }

    final animationChild = widget.transitionBuilder != null
        ? widget.transitionBuilder!(context, child, this._animationController)
        : SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: CurvedAnimation(
                parent: this._animationController!,
                curve: Curves.fastOutSlowIn),
            child: child,
          );

    BoxConstraints constraints;
    if (widget.decoration!.constraints == null) {
      constraints = const BoxConstraints(
        maxHeight: 220, //widget.suggestionsBox!.maxHeight,
      );
    } else {
      double maxHeight = min(widget.decoration!.constraints!.maxHeight,
          widget.suggestionsBox!.maxHeight);
      constraints = widget.decoration!.constraints!.copyWith(
        minHeight: min(widget.decoration!.constraints!.minHeight, maxHeight),
        maxHeight: 220, //maxHeight,
      );
    }

    var container = Material(
      elevation: widget.decoration!.elevation,
      color: widget.decoration!.color,
      shape: widget.decoration!.shape,
      borderRadius: widget.decoration!.borderRadius,
      shadowColor: widget.decoration!.shadowColor,
      clipBehavior: widget.decoration!.clipBehavior,
      child:
          // widget.noItemsFoundBuilder != null
          //     ? const SizedBox()
          //     : SizedBox(
          //         height: 220,
          //         child: animationChild,
          //       ),

          ConstrainedBox(
        constraints: constraints,
        child: animationChild,
      ),
    );

    return container;
  }

  Widget createLoadingWidget() {
    Widget child;

    if (widget.keepSuggestionsOnLoading! && this._suggestions != null) {
      if (this._suggestions!.isEmpty) {
        child = createNoItemsFoundWidget();
      } else {
        child = createSuggestionsWidget();
      }
    } else {
      child = widget.loadingBuilder != null
          ? widget.loadingBuilder!(context)
          : const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),
            );
    }

    return child;
  }

  Widget createErrorWidget() {
    return widget.errorBuilder != null
        ? widget.errorBuilder!(context, this._error)
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${this._error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
  }

  Widget createNoItemsFoundWidget() {
    return widget.noItemsFoundBuilder != null
        ? widget.noItemsFoundBuilder!(context)
        : const SizedBox();
    // Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 8.0),
    //         child: Text(
    //           'No Items Found!',
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //               color: Theme.of(context).disabledColor, fontSize: 18.0),
    //         ),
    //       );
  }

  Widget createSuggestionsWidget() {
    Widget child = ListView(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      controller: _scrollController,
      reverse:
          widget.suggestionsBox!.direction == AxisDirection.down ? false : true,
      // reverses the list to start at the bottom
      children: this._suggestions!.map((T suggestion) {
        return InkWell(
          child: widget.itemBuilder!(context, suggestion),
          onTap: () {
            widget.onSuggestionSelected!(suggestion);
          },
        );
      }).toList(),
    );

    if (widget.decoration!.hasScrollbar) {
      child = Scrollbar(
        controller: _scrollController,
        child: child,
      );
    }

    return child;
  }
}

/// Supply an instance of this class to the [TypeAhead.suggestionsBoxDecoration]
/// property to configure the suggestions box decoration
class SuggestionsBoxDecoration {
  /// The z-coordinate at which to place the suggestions box. This controls the size
  /// of the shadow below the box.
  ///
  /// Same as [Material.elevation](https://docs.flutter.io/flutter/material/Material/elevation.html)
  final double elevation;

  /// The color to paint the suggestions box.
  ///
  /// Same as [Material.color](https://docs.flutter.io/flutter/material/Material/color.html)
  final Color? color;

  /// Defines the material's shape as well its shadow.
  ///
  /// Same as [Material.shape](https://docs.flutter.io/flutter/material/Material/shape.html)
  final ShapeBorder? shape;

  /// Defines if a scrollbar will be displayed or not.
  final bool hasScrollbar;

  /// If non-null, the corners of this box are rounded by this [BorderRadius](https://docs.flutter.io/flutter/painting/BorderRadius-class.html).
  ///
  /// Same as [Material.borderRadius](https://docs.flutter.io/flutter/material/Material/borderRadius.html)
  final BorderRadius? borderRadius;

  /// The color to paint the shadow below the material.
  ///
  /// Same as [Material.shadowColor](https://docs.flutter.io/flutter/material/Material/shadowColor.html)
  final Color shadowColor;

  /// The constraints to be applied to the suggestions box
  final BoxConstraints? constraints;

  /// Adds an offset to the suggestions box
  final double offsetX;

  /// The content will be clipped (or not) according to this option.
  ///
  /// Same as [Material.clipBehavior](https://api.flutter.dev/flutter/material/Material/clipBehavior.html)
  final Clip clipBehavior;

  /// Creates a SuggestionsBoxDecoration
  const SuggestionsBoxDecoration(
      {this.elevation = 4.0,
      this.color,
      this.shape,
      this.hasScrollbar = true,
      this.borderRadius,
      this.shadowColor = const Color(0xFF000000),
      this.constraints,
      this.clipBehavior = Clip.none,
      this.offsetX = 0.0});
}

/// Supply an instance of this class to the [TypeAhead.textFieldConfiguration]
/// property to configure the displayed text field
class TextFieldConfiguration {
  /// The decoration to show around the text field.
  ///
  /// Same as [TextField.decoration](https://docs.flutter.io/flutter/material/TextField/decoration.html)
  final InputDecoration decoration;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController](https://docs.flutter.io/flutter/widgets/TextEditingController-class.html).
  /// A typical use case for this field in the TypeAhead widget is to set the
  /// text of the widget when a suggestion is selected. For example:
  ///
  /// ```dart
  /// final _controller = TextEditingController();
  /// ...
  /// ...
  /// TypeAheadField(
  ///   controller: _controller,
  ///   ...
  ///   ...
  ///   onSuggestionSelected: (suggestion) {
  ///     _controller.text = suggestion['city_name'];
  ///   }
  /// )
  /// ```
  final TextEditingController? controller;

  /// Controls whether this widget has keyboard focus.
  ///
  /// Same as [TextField.focusNode](https://docs.flutter.io/flutter/material/TextField/focusNode.html)
  final FocusNode? focusNode;

  /// The style to use for the text being edited.
  ///
  /// Same as [TextField.style](https://docs.flutter.io/flutter/material/TextField/style.html)
  final TextStyle? style;

  /// How the text being edited should be aligned horizontally.
  ///
  /// Same as [TextField.textAlign](https://docs.flutter.io/flutter/material/TextField/textAlign.html)
  final TextAlign textAlign;

  /// Same as [TextField.textDirection](https://docs.flutter.io/flutter/material/TextField/textDirection.html)
  ///
  /// Defaults to null
  final TextDirection? textDirection;

  /// Same as [TextField.textAlignVertical](https://api.flutter.dev/flutter/material/TextField/textAlignVertical.html)
  final TextAlignVertical? textAlignVertical;

  /// If false the textfield is "disabled": it ignores taps and its
  /// [decoration] is rendered in grey.
  ///
  /// Same as [TextField.enabled](https://docs.flutter.io/flutter/material/TextField/enabled.html)
  final bool enabled;

  /// Whether to show input suggestions as the user types.
  ///
  /// Same as [TextField.enableSuggestions](https://api.flutter.dev/flutter/material/TextField/enableSuggestions.html)
  final bool enableSuggestions;

  /// The type of keyboard to use for editing the text.
  ///
  /// Same as [TextField.keyboardType](https://docs.flutter.io/flutter/material/TextField/keyboardType.html)
  final TextInputType keyboardType;

  /// Whether this text field should focus itself if nothing else is already
  /// focused.
  ///
  /// Same as [TextField.autofocus](https://docs.flutter.io/flutter/material/TextField/autofocus.html)
  final bool autofocus;

  /// Optional input validation and formatting overrides.
  ///
  /// Same as [TextField.inputFormatters](https://docs.flutter.io/flutter/material/TextField/inputFormatters.html)
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to enable autocorrection.
  ///
  /// Same as [TextField.autocorrect](https://docs.flutter.io/flutter/material/TextField/autocorrect.html)
  final bool autocorrect;

  /// The maximum number of lines for the text to span, wrapping if necessary.
  ///
  /// Same as [TextField.maxLines](https://docs.flutter.io/flutter/material/TextField/maxLines.html)
  final int? maxLines;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  ///
  /// Same as [TextField.minLines](https://docs.flutter.io/flutter/material/TextField/minLines.html)
  final int? minLines;

  /// The maximum number of characters (Unicode scalar values) to allow in the
  /// text field.
  ///
  /// Same as [TextField.maxLength](https://docs.flutter.io/flutter/material/TextField/maxLength.html)
  final int? maxLength;

  /// If true, prevents the field from allowing more than [maxLength]
  /// characters.
  ///
  /// Same as [TextField.maxLengthEnforcement](https://api.flutter.dev/flutter/material/TextField/maxLengthEnforcement.html)
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Whether to hide the text being edited (e.g., for passwords).
  ///
  /// Same as [TextField.obscureText](https://docs.flutter.io/flutter/material/TextField/obscureText.html)
  final bool obscureText;

  /// Called when the text being edited changes.
  ///
  /// Same as [TextField.onChanged](https://docs.flutter.io/flutter/material/TextField/onChanged.html)
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates that they are done editing the text in the
  /// field.
  ///
  /// Same as [TextField.onSubmitted](https://docs.flutter.io/flutter/material/TextField/onSubmitted.html)
  final ValueChanged<String>? onSubmitted;

  /// The color to use when painting the cursor.
  ///
  /// Same as [TextField.cursorColor](https://docs.flutter.io/flutter/material/TextField/cursorColor.html)
  final Color? cursorColor;

  /// How rounded the corners of the cursor should be. By default, the cursor has a null Radius
  ///
  /// Same as [TextField.cursorRadius](https://docs.flutter.io/flutter/material/TextField/cursorRadius.html)
  final Radius? cursorRadius;

  /// How thick the cursor will be.
  ///
  /// Same as [TextField.cursorWidth](https://docs.flutter.io/flutter/material/TextField/cursorWidth.html)
  final double cursorWidth;

  /// The appearance of the keyboard.
  ///
  /// Same as [TextField.keyboardAppearance](https://docs.flutter.io/flutter/material/TextField/keyboardAppearance.html)
  final Brightness? keyboardAppearance;

  /// Called when the user submits editable content (e.g., user presses the "done" button on the keyboard).
  ///
  /// Same as [TextField.onEditingComplete](https://docs.flutter.io/flutter/material/TextField/onEditingComplete.html)
  final VoidCallback? onEditingComplete;

  /// Called for each distinct tap except for every second tap of a double tap.
  ///
  /// Same as [TextField.onTap](https://docs.flutter.io/flutter/material/TextField/onTap.html)
  final GestureTapCallback? onTap;

  /// Configures padding to edges surrounding a Scrollable when the Textfield scrolls into view.
  ///
  /// Same as [TextField.scrollPadding](https://docs.flutter.io/flutter/material/TextField/scrollPadding.html)
  final EdgeInsets scrollPadding;

  /// Configures how the platform keyboard will select an uppercase or lowercase keyboard.
  ///
  /// Same as [TextField.TextCapitalization](https://docs.flutter.io/flutter/material/TextField/textCapitalization.html)
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Same as [TextField.textInputAction](https://docs.flutter.io/flutter/material/TextField/textInputAction.html)
  final TextInputAction? textInputAction;

  final bool enableInteractiveSelection;

  /// Creates a TextFieldConfiguration
  const TextFieldConfiguration({
    this.decoration = const InputDecoration(),
    this.style,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.maxLengthEnforcement,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textAlignVertical,
    this.autocorrect = true,
    this.inputFormatters,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.enableSuggestions = true,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.cursorColor,
    this.cursorRadius,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.cursorWidth = 2.0,
    this.keyboardAppearance,
    this.onEditingComplete,
    this.onTap,
    this.textDirection,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
  });

  /// Copies the [TextFieldConfiguration] and only changes the specified
  /// properties
  TextFieldConfiguration copyWith(
      {InputDecoration? decoration,
      TextStyle? style,
      TextEditingController? controller,
      ValueChanged<String>? onChanged,
      ValueChanged<String>? onSubmitted,
      bool? obscureText,
      MaxLengthEnforcement? maxLengthEnforcement,
      int? maxLength,
      int? maxLines,
      int? minLines,
      bool? autocorrect,
      List<TextInputFormatter>? inputFormatters,
      bool? autofocus,
      TextInputType? keyboardType,
      bool? enabled,
      bool? enableSuggestions,
      TextAlign? textAlign,
      FocusNode? focusNode,
      Color? cursorColor,
      TextAlignVertical? textAlignVertical,
      Radius? cursorRadius,
      double? cursorWidth,
      Brightness? keyboardAppearance,
      VoidCallback? onEditingComplete,
      GestureTapCallback? onTap,
      EdgeInsets? scrollPadding,
      TextCapitalization? textCapitalization,
      TextDirection? textDirection,
      TextInputAction? textInputAction,
      bool? enableInteractiveSelection}) {
    return TextFieldConfiguration(
      decoration: decoration ?? this.decoration,
      style: style ?? this.style,
      controller: controller ?? this.controller,
      onChanged: onChanged ?? this.onChanged,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      obscureText: obscureText ?? this.obscureText,
      maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      autocorrect: autocorrect ?? this.autocorrect,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      autofocus: autofocus ?? this.autofocus,
      keyboardType: keyboardType ?? this.keyboardType,
      enabled: enabled ?? this.enabled,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      focusNode: focusNode ?? this.focusNode,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      onEditingComplete: onEditingComplete ?? this.onEditingComplete,
      onTap: onTap ?? this.onTap,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textInputAction: textInputAction ?? this.textInputAction,
      textDirection: textDirection ?? this.textDirection,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
    );
  }
}

class _SuggestionsBox {
  static const int waitMetricsTimeoutMillis = 1000;
  static const double minOverlaySpace = 64.0;

  final BuildContext context;
  final AxisDirection desiredDirection;
  final bool autoFlipDirection;

  OverlayEntry? _overlayEntry;
  AxisDirection direction;

  bool isOpened = false;
  bool widgetMounted = true;
  double maxHeight = 300.0;
  double textBoxWidth = 100.0;
  double textBoxHeight = 100.0;
  late double directionUpOffset;

  _SuggestionsBox(this.context, this.direction, this.autoFlipDirection)
      : desiredDirection = direction;

  void open() {
    if (isOpened) return;
    assert(_overlayEntry != null);
    resize();
    Overlay.of(context).insert(_overlayEntry!);
    isOpened = true;
  }

  void close() {
    if (!isOpened) return;
    assert(_overlayEntry != null);
    _overlayEntry!.remove();
    isOpened = false;
  }

  void toggle() {
    if (isOpened) {
      close();
    } else {
      open();
    }
  }

  MediaQuery? _findRootMediaQuery() {
    MediaQuery? rootMediaQuery;
    context.visitAncestorElements((element) {
      if (element.widget is MediaQuery) {
        rootMediaQuery = element.widget as MediaQuery;
      }
      return true;
    });

    return rootMediaQuery;
  }

  /// Delays until the keyboard has toggled or the orientation has fully changed
  Future<bool> _waitChangeMetrics() async {
    if (widgetMounted) {
      // initial viewInsets which are before the keyboard is toggled
      EdgeInsets initial = MediaQuery.of(context).viewInsets;
      // initial MediaQuery for orientation change
      MediaQuery? initialRootMediaQuery = _findRootMediaQuery();

      int timer = 0;
      // viewInsets or MediaQuery have changed once keyboard has toggled or orientation has changed
      while (widgetMounted && timer < waitMetricsTimeoutMillis) {
        // TODO: reduce delay if showDialog ever exposes detection of animation end
        await Future<void>.delayed(const Duration(milliseconds: 170));
        timer += 170;

        if (widgetMounted &&
            (MediaQuery.of(context).viewInsets != initial ||
                _findRootMediaQuery() != initialRootMediaQuery)) {
          return true;
        }
      }
    }

    return false;
  }

  void resize() {
    // check to see if widget is still mounted
    // user may have closed the widget with the keyboard still open
    if (widgetMounted) {
      _adjustMaxHeightAndOrientation();
      _overlayEntry!.markNeedsBuild();
    }
  }

  // See if there's enough room in the desired direction for the overlay to display
  // correctly. If not, try the opposite direction if things look more roomy there
  void _adjustMaxHeightAndOrientation() {
    TypeAheadField widget = context.widget as TypeAheadField;

    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || box.hasSize == false) {
      return;
    }

    textBoxWidth = box.size.width;
    textBoxHeight = box.size.height;

    // top of text box
    double textBoxAbsY = box.localToGlobal(Offset.zero).dy;

    // height of window
    double windowHeight = MediaQuery.of(context).size.height;

    // we need to find the root MediaQuery for the unsafe area height
    // we cannot use BuildContext.ancestorWidgetOfExactType because
    // widgets like SafeArea creates a new MediaQuery with the padding removed
    MediaQuery rootMediaQuery = _findRootMediaQuery()!;

    // height of keyboard
    double keyboardHeight = rootMediaQuery.data.viewInsets.bottom;

    double maxHDesired = _calculateMaxHeight(desiredDirection, box, widget,
        windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);

    // if there's enough room in the desired direction, update the direction and the max height
    if (maxHDesired >= minOverlaySpace || !autoFlipDirection) {
      direction = desiredDirection;
      maxHeight = maxHDesired;
    } else {
      // There's not enough room in the desired direction so see how much room is in the opposite direction
      AxisDirection flipped = flipAxisDirection(desiredDirection);
      double maxHFlipped = _calculateMaxHeight(flipped, box, widget,
          windowHeight, rootMediaQuery, keyboardHeight, textBoxAbsY);

      // if there's more room in this opposite direction, update the direction and maxHeight
      if (maxHFlipped > maxHDesired) {
        direction = flipped;
        maxHeight = maxHFlipped;
      }
    }

    if (maxHeight < 0) maxHeight = 0;
  }

  double _calculateMaxHeight(
      AxisDirection direction,
      RenderBox box,
      TypeAheadField widget,
      double windowHeight,
      MediaQuery rootMediaQuery,
      double keyboardHeight,
      double textBoxAbsY) {
    return direction == AxisDirection.down
        ? _calculateMaxHeightDown(box, widget, windowHeight, rootMediaQuery,
            keyboardHeight, textBoxAbsY)
        : _calculateMaxHeightUp(box, widget, windowHeight, rootMediaQuery,
            keyboardHeight, textBoxAbsY);
  }

  double _calculateMaxHeightDown(
      RenderBox box,
      TypeAheadField widget,
      double windowHeight,
      MediaQuery rootMediaQuery,
      double keyboardHeight,
      double textBoxAbsY) {
    // unsafe area, ie: iPhone X 'home button'
    // keyboardHeight includes unsafeAreaHeight, if keyboard is showing, set to 0
    double unsafeAreaHeight =
        keyboardHeight == 0 ? rootMediaQuery.data.padding.bottom : 0;

    return windowHeight -
        keyboardHeight -
        unsafeAreaHeight -
        textBoxHeight -
        textBoxAbsY -
        2 * widget.suggestionsBoxVerticalOffset;
  }

  double _calculateMaxHeightUp(
      RenderBox box,
      TypeAheadField widget,
      double windowHeight,
      MediaQuery rootMediaQuery,
      double keyboardHeight,
      double textBoxAbsY) {
    // recalculate keyboard absolute y value
    double keyboardAbsY = windowHeight - keyboardHeight;

    directionUpOffset = textBoxAbsY > keyboardAbsY
        ? keyboardAbsY - textBoxAbsY - widget.suggestionsBoxVerticalOffset
        : -widget.suggestionsBoxVerticalOffset;

    // unsafe area, ie: iPhone X notch
    double unsafeAreaHeight = rootMediaQuery.data.padding.top;

    return textBoxAbsY > keyboardAbsY
        ? keyboardAbsY -
            unsafeAreaHeight -
            2 * widget.suggestionsBoxVerticalOffset
        : textBoxAbsY -
            unsafeAreaHeight -
            2 * widget.suggestionsBoxVerticalOffset;
  }

  Future<void> onChangeMetrics() async {
    if (await _waitChangeMetrics()) {
      resize();
    }
  }
}

/// Supply an instance of this class to the [TypeAhead.suggestionsBoxController]
/// property to manually control the suggestions box
class SuggestionsBoxController {
  _SuggestionsBox? _suggestionsBox;
  FocusNode? _effectiveFocusNode;

  /// Opens the suggestions box
  void open() {
    _effectiveFocusNode!.requestFocus();
  }

  bool isOpened() {
    return _suggestionsBox!.isOpened;
  }

  /// Closes the suggestions box
  void close() {
    _effectiveFocusNode!.unfocus();
  }

  /// Opens the suggestions box if closed and vice-versa
  void toggle() {
    if (_suggestionsBox!.isOpened) {
      close();
    } else {
      open();
    }
  }

  /// Recalculates the height of the suggestions box
  void resize() {
    _suggestionsBox!.resize();
  }
}
