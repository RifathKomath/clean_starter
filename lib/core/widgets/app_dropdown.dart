import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

class AppDropdown<T> extends StatefulWidget {
  final T? selectedValue;
  final List<T> items;
  final Function(T?) onChanged;
  final String hint;
  final double? w;
  final bool showHeading;
  final String? headingText;
  final double? h;
  final TextStyle? hintStyle;
  final String Function(T)? itemToString;
  final String? Function(T?)? validator;
  final double radius;
  final bool isloading;
  final bool isSelectedValid;
  final Color? borderClr;
  final Color? backgroundColor;
  final bool showBorder;
  final VoidCallback? onLoadMore;
  final bool isLoadMoreLoading;
  final Function(String)? onSearch;
  final bool isSearchLoading;
  final Color? iconColor;
  final bool isRequired;
  final TextStyle? headingStyle;

  const AppDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.hint,
    this.showHeading = false,
    this.headingText,
    this.w = 120,
    this.h = 56,
    this.hintStyle,
    this.itemToString,
    this.validator,
    this.radius = 36,
    this.isloading = false,
    required this.isSelectedValid,
    this.borderClr,
    this.backgroundColor = AppColors.white,
    this.showBorder = true,
    this.onLoadMore,
    this.isLoadMoreLoading = false,
    this.onSearch,
    this.isSearchLoading = false,
    this.iconColor = AppColors.primary,
    this.isRequired = false,
    this.headingStyle,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  final ScrollController _scrollController = ScrollController();

  static _AppDropdownState? _currentlyOpen;

  bool _isOpen = false;

  final TextEditingController _searchController = TextEditingController();
  // final FocusNode _searchFocusNode = FocusNode();

  List<T> _filteredItems = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _filteredItems = widget.items;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _rotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      setState(() {
        if (widget.onSearch != null) {
          _filteredItems = widget.items;
        } else if (_searchController.text.isEmpty) {
          _filteredItems = widget.items;
        } else {
          _filteredItems = widget.items
              .where(
                (item) =>
                    (widget.itemToString != null
                            ? widget.itemToString!(item)
                            : item.toString())
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()),
              )
              .toList();
        }
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (widget.onLoadMore != null && !widget.isLoadMoreLoading) {
        widget.onLoadMore!();
      }
    }
  }

  static const double _itemHeight = 56;
  static const int _maxVisibleItems = 4;

  void _toggle(bool open) {
    if (open) {
      if (_currentlyOpen != null && _currentlyOpen != this) {
        _currentlyOpen!._closeInternal();
      }
      _currentlyOpen = this;
    } else {
      if (_currentlyOpen == this) {
        _currentlyOpen = null;
      }
    }

    setState(() {
      _isOpen = open;
    });

    if (open) {
      _controller.forward();
    } else {
      _controller.reverse();
      _debounceTimer?.cancel();
      if (widget.onSearch != null && _searchController.text.isNotEmpty) {
        widget.onSearch!("");
      }
      _searchController.clear();
      _filteredItems = widget.items;
    }
  }

  void _closeInternal() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
      });
      _controller.reverse();
      _debounceTimer?.cancel();
      if (widget.onSearch != null && _searchController.text.isNotEmpty) {
        widget.onSearch!("");
      }
      _searchController.clear();
      _filteredItems = widget.items;
    }
  }

  @override
  void dispose() {
    if (_currentlyOpen == this) {
      _currentlyOpen = null;
    }
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    _searchController.dispose();
    // _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,

      initialValue: widget.selectedValue,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeading && widget.headingText != null) ...[
              RichText(
                text: TextSpan(
                  text: widget.headingText,
                  style:
                      widget.headingStyle ??
                      AppTextStyles.textStyle_500_12.copyWith(
                        color: AppColors.textCharcoal,
                      ),
                  children: widget.isRequired
                      ? const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                      : [],
                ),
              ),
              8.hBox,
            ],

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: widget.w,
              height: widget.h,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                border: widget.showBorder
                    ? Border.all(
                        color: widget.borderClr ?? Colors.grey.shade300,
                      )
                    : null,
                borderRadius: BorderRadius.circular(widget.radius),
              ),

              child: InkWell(
                onTap: () => _toggle(!_isOpen),
                child: Row(
                  children: [
                    Expanded(
                      child: _isOpen
                          ? TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: "Search...",
                                hintStyle: AppTextStyles.textStyle_400_14
                                    .copyWith(color: AppColors.fieldTextColor),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                if (widget.onSearch != null) {
                                  _debounceTimer?.cancel();
                                  _debounceTimer = Timer(
                                    const Duration(milliseconds: 300),
                                    () {
                                      widget.onSearch!(value);
                                    },
                                  );
                                } else {
                                  setState(() {
                                    _filteredItems = widget.items
                                        .where(
                                          (item) =>
                                              (widget.itemToString != null
                                                      ? widget.itemToString!(
                                                          item,
                                                        )
                                                      : item.toString())
                                                  .toLowerCase()
                                                  .contains(
                                                    value.toLowerCase(),
                                                  ),
                                        )
                                        .toList();
                                  });
                                }
                              },
                            )
                          : Text(
                              field.value != null
                                  ? (widget.itemToString != null
                                        ? widget.itemToString!(field.value as T)
                                        : field.value.toString())
                                  : widget.hint,
                              style: field.value == null
                                  ? (widget.hintStyle ??
                                        AppTextStyles.textStyle_400_14.copyWith(
                                          color: AppColors.fieldTextColor,
                                        ))
                                  : AppTextStyles.textStyle_400_14.copyWith(
                                      color: AppColors.textCharcoal,
                                    ),
                            ),
                    ),

                    /// 🔄 Arrow Animation or Search Indicator
                    if (widget.isSearchLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      RotationTransition(
                        turns: _rotation,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: widget.iconColor ?? AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            /// 🔽 Dropdown List
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _isOpen
                  ? Container(
                      width: widget.w,
                      margin: const EdgeInsets.only(top: 4),
                      child: Material(
                        color: Colors.white,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: widget.borderClr ?? const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: widget.isSearchLoading
                            ? const SizedBox(
                                height: _itemHeight,
                                child: Center(child: ThreeDotIndicator()),
                              )
                            : _filteredItems.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text("No results found"),
                              )
                            : ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      (_filteredItems.length +
                                              (widget.isLoadMoreLoading
                                                  ? 1
                                                  : 0)) <=
                                          _maxVisibleItems
                                      ? (_filteredItems.length +
                                                (widget.isLoadMoreLoading
                                                    ? 1
                                                    : 0)) *
                                            _itemHeight
                                      : _maxVisibleItems * _itemHeight,
                                ),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.zero,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount:
                                      _filteredItems.length +
                                      (widget.isLoadMoreLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == _filteredItems.length) {
                                      return const SizedBox(
                                        height: _itemHeight,
                                        child: Center(
                                          child: ThreeDotIndicator(),
                                        ),
                                      );
                                    }
                                    final item = _filteredItems[index];
                                    return SizedBox(
                                      height: _itemHeight,
                                      child: ListTile(
                                        title: Text(
                                          widget.itemToString != null
                                              ? widget.itemToString!(item)
                                              : item.toString(),
                                        ),
                                        onTap: () {
                                          field.didChange(item);
                                          widget.onChanged(item);
                                          field.validate();
                                          _toggle(false);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  field.errorText ?? '',
                  style: AppTextStyles.textStyle_400_14.copyWith(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ThreeDotIndicator extends StatefulWidget {
  const ThreeDotIndicator({super.key});

  @override
  State<ThreeDotIndicator> createState() => _ThreeDotIndicatorState();
}

class _ThreeDotIndicatorState extends State<ThreeDotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final double progress = (_animationController.value - delay) % 1.0;
            final double value =
                (progress < 0.5 ? progress * 2 : (1 - progress) * 2).clamp(
                  0.0,
                  1.0,
                );
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3 + (0.7 * value)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
