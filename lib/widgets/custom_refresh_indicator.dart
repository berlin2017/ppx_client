import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

enum _RefreshState {
  idle, // Not being pulled, or settled.
  drag, // User is actively dragging.
  armed, // Dragged far enough, will refresh on release.
  refreshing, // Currently executing onRefresh.
  settle, // Animating back to idle.
  cancelling, // Animating back to idle from drag or armed.
}

class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String lottieAssetPath;
  final double refreshTriggerOffset;
  final double maxDragOffset;
  final Duration settleDuration;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.lottieAssetPath,
    this.refreshTriggerOffset = 80.0,
    this.maxDragOffset = 120.0,
    this.settleDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin { // CORRECTED: TickerProviderStateMixin
  late final AnimationController _lottieController;
  late final AnimationController _settleController;

  _RefreshState _state = _RefreshState.idle;
  double _dragOffset = 0.0;
  LottieComposition? _composition;

  final double _dragDamping = 0.5; // How much to resist the drag
  static const double _kAtTopScrollThreshold = 1.0; // Max pixels away from top to consider "at top"
  static const double _kDragMinDelta = 0.5; // Min dy delta to consider a drag update significant

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _settleController = AnimationController(vsync: this, duration: widget.settleDuration);
    _settleController.addListener(_settleAnimationTick);
    _loadLottieComposition();

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _state == _RefreshState.refreshing) {
        _lottieController.repeat(); // Loop the animation while refreshing
      }
    });
  }

  Future<void> _loadLottieComposition() async {
    try {
      final assetData = await AssetLottie(widget.lottieAssetPath).load();
      if (!mounted) return;
      setState(() {
        _composition = assetData;
        _lottieController.duration = _composition!.duration;
      });
    } catch (e) {
      debugPrint('Error loading Lottie composition: $e');
      // Potentially handle error by using a fallback or informing the user
    }
  }

  void _settleAnimationTick() {
    if (!mounted) return;
    setState(() {
      // During settle/cancel, _dragOffset is directly driven by _settleController's value
      // which animates from the current drag offset down to 0.
      _dragOffset = _settleController.value;
    });

    // Sync Lottie progress during settle/cancel if not already refreshing
    if (_composition != null && _lottieController.duration != null && _state != _RefreshState.refreshing) {
      // Lottie progress should reflect the diminishing drag offset
      final lottieProgress = (_dragOffset / widget.refreshTriggerOffset).clamp(0.0, 0.8);
      if (_lottieController.value != lottieProgress) {
        _lottieController.value = lottieProgress;
      }
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_state == _RefreshState.refreshing || _state == _RefreshState.settle || _state == _RefreshState.cancelling) {
      return false; // Don't interfere with ongoing refresh or settling/cancelling
    }

    final bool isAtTop = notification.metrics.pixels <= _kAtTopScrollThreshold;

    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails != null) { // User is actively dragging
        final double dy = notification.dragDetails!.delta.dy;

        if (_dragOffset == 0 && isAtTop && dy > _kDragMinDelta) {
          // Starting a new drag from the top
          if (_state != _RefreshState.drag && _state != _RefreshState.armed) {
            _ensureAnimating(false); // Stop any settle/cancel animations
            _changeState(_RefreshState.drag);
          }
        }

        if (_state == _RefreshState.drag || _state == _RefreshState.armed) {
          // Apply damping and update drag offset
          double newOffset = _dragOffset + (dy * _dragDamping);
          // Clamp the drag offset to be between 0 and maxDragOffset
          _dragOffset = math.max(0, math.min(newOffset, widget.maxDragOffset));

          if (_dragOffset >= widget.refreshTriggerOffset && _state == _RefreshState.drag) {
            _changeState(_RefreshState.armed);
            // Consider HapticFeedback.mediumImpact();
          } else if (_dragOffset < widget.refreshTriggerOffset && _state == _RefreshState.armed) {
            _changeState(_RefreshState.drag);
          }
          
          if (_dragOffset == 0 && _state != _RefreshState.idle) {
             _resetToIdle(); // If dragged back to 0, reset.
          } else {
            // Update Lottie progress based on drag, up to 80% to leave room for loading animation
            if (_composition != null && _lottieController.duration != null) {
              _lottieController.value = (_dragOffset / widget.refreshTriggerOffset).clamp(0.0, 0.8);
            }
            setState(() {}); // Update UI to reflect drag
          }
          return false; // We are handling this scroll if dragging
        }
      } else if (_dragOffset > 0 && !isAtTop && _state != _RefreshState.refreshing) {
        // User scrolled away (not by dragging up) while an indicator was visible, reset it.
        // This can happen if the list scrolls due to content change or other reasons.
        _cancel();
      }
    } else if (notification is ScrollEndNotification || (notification is UserScrollNotification && notification.direction == ScrollDirection.idle)) {
      // Scroll has ended or user lifted finger
      if (_state == _RefreshState.armed) {
        _triggerRefresh();
      } else if (_state == _RefreshState.drag && _dragOffset > 0) {
        _cancel(); // Not armed enough, animate back
      } else if (_dragOffset > 0 && _state != _RefreshState.refreshing) {
        // If for some other reason dragOffset is > 0 but not in an active state, cancel.
        // This is a safeguard.
        _cancel();
      }
    }
    return false;
  }
  
  void _ensureAnimating(bool ensureTickerIsActive) {
    // This function's logic might need to be re-evaluated based on how _settleController is used.
    // For now, it just stops the settle controller if we don't want it to be active.
    if (!ensureTickerIsActive) {
      if (_settleController.isAnimating) {
        _settleController.stop(canceled: true); // `canceled: true` prevents onComplete from firing
      }
    }
    // If ensureTickerIsActive is true, we assume the caller will start an animation.
  }

  Future<void> _triggerRefresh() async {
    if (!mounted || _state == _RefreshState.refreshing) return;
    
    _ensureAnimating(false);
    _changeState(_RefreshState.refreshing);
    
    // Animate the indicator to the refreshTriggerOffset (if not already there)
    // and then play the Lottie animation.
    _settleController.value = _dragOffset; // Start settle from current drag
    _settleController.animateTo(widget.refreshTriggerOffset, duration: const Duration(milliseconds: 150))
      .whenComplete(() {
          if (mounted && _state == _RefreshState.refreshing && _composition != null) {
            // Ensure Lottie is at the start of its looping segment or a defined point
             _lottieController.value = (_dragOffset / widget.refreshTriggerOffset).clamp(0.0, 1.0); // Make Lottie visible
            if(!_lottieController.isAnimating){
                 _lottieController.forward(from: _lottieController.value); // Play from current, then repeat (listener handles repeat)
            }
          }
      });

    await widget.onRefresh(); // Call the user's refresh function
    if (!mounted) return;
    
    // Potentially add a minimum display time for the refresh indicator
    // await Future.delayed(const Duration(milliseconds: 500)); 

    _settle(); // Settle the indicator back down
  }

  void _settle() {
    if (!mounted || (_state == _RefreshState.settle && _settleController.isAnimating && _settleController.value == 0.0)) {
      // Already settling to 0 or unmounted
      return;
    }
     if (_state == _RefreshState.idle && _dragOffset == 0.0) return;


    _ensureAnimating(false); // Stop any previous animations on _settleController
    _changeState(_RefreshState.settle);
    
    if (_lottieController.isAnimating) {
       _lottieController.stop(); // Stop looping Lottie
    }
    // Lottie should visually settle along with the drag offset
    _lottieController.value = (_dragOffset / widget.refreshTriggerOffset).clamp(0.0, 0.8);


    _settleController.value = _dragOffset; // Start animation from current offset
    _settleController.animateTo(0.0).whenComplete(() {
      if (mounted) {
        _resetToIdle();
      }
    });
  }

  void _cancel() {
    if (!mounted || (_state == _RefreshState.cancelling && _settleController.isAnimating && _settleController.value == 0.0)) {
      // Already cancelling to 0 or unmounted
      return;
    }
    if (_state == _RefreshState.idle && _dragOffset == 0.0) return;
    
    _ensureAnimating(false);
    _changeState(_RefreshState.cancelling);

    // Lottie should visually recede along with the drag offset
    _lottieController.value = (_dragOffset / widget.refreshTriggerOffset).clamp(0.0, 0.8);

    _settleController.value = _dragOffset; // Start animation from current offset
    _settleController.animateTo(0.0).whenComplete(() {
       if (mounted) {
         _resetToIdle();
       }
    });
  }
  
  void _resetToIdle(){
    if (!mounted) return;
    _ensureAnimating(false); // Ensure settle controller is stopped.
    _changeState(_RefreshState.idle);
    _dragOffset = 0.0;
    if (_composition != null) {
      _lottieController.reset(); // Reset Lottie to its initial frame
    }
    if(mounted){ // Check mounted again before calling setState
        setState(() {});
    }
  }

  void _changeState(_RefreshState newState) {
    if (_state == newState) return;
    // For debugging:
    // debugPrint("CustomRefreshIndicator State: $_state -> $newState, Offset: $_dragOffset");
    if(mounted){
      setState(() {
        _state = newState;
      });
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _settleController.removeListener(_settleAnimationTick);
    _settleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Indicator should be visible if not idle, or if dragOffset > 0 (even if transitioning to idle)
    final bool showIndicator = _state != _RefreshState.idle || _dragOffset > 0;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Transform.translate(
            offset: Offset(0.0, _dragOffset),
            child: widget.child,
          ),
          if (showIndicator)
            Positioned(
              top: 0, 
              // The Lottie animation's vertical position can be adjusted.
              // Here, it stays at the top of the Stack.
              // You might want it to follow the dragOffset slightly, e.g.,
              // top: _dragOffset - (widget.refreshTriggerOffset * 0.5) ,
              child: Opacity(
                opacity: (_dragOffset / widget.refreshTriggerOffset).clamp(0.0, 1.0),
                child: _composition != null
                    ? Lottie(
                        composition: _composition,
                        controller: _lottieController,
                        height: widget.refreshTriggerOffset, // Lottie height constrained by trigger offset
                        width: widget.refreshTriggerOffset, // Lottie width
                      )
                    : SizedBox(height: widget.refreshTriggerOffset), // Fallback if Lottie hasn't loaded
              ),
            ),
        ],
      ),
    );
  }
}
