import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';

enum _StepState { done, current, upcoming }

/// CMP-44. Onboarding progression (ONB-03 to ONB-07). Every node state
/// carries a shape cue as well as a color, never color alone: done =
/// 14dp square with a light notch, current = 22dp square with a white
/// core (deliberately larger so "you are here" survives greyscale),
/// upcoming = 14dp square on trackSubtle. Pair with a plain "Step N of
/// N" text label elsewhere — that label is not part of this widget.
class StepTrack extends StatelessWidget {
  const StepTrack({required this.currentStep, this.totalSteps = 5, super.key});

  final int currentStep;
  final int totalSteps;

  _StepState _stateFor(int step) {
    if (step < currentStep) return _StepState.done;
    if (step == currentStep) return _StepState.current;
    return _StepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final children = <Widget>[];

    for (var step = 1; step <= totalSteps; step++) {
      final state = _stateFor(step);
      children.add(_StepNode(state: state, colors: colors));
      if (step != totalSteps) {
        final connectorDone = state != _StepState.upcoming;
        children.add(
          Expanded(
            child: Container(
              height: 4,
              color: connectorDone ? colors.brandPrimary : colors.trackSubtle,
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.state, required this.colors});

  final _StepState state;
  final FlowColors colors;

  @override
  Widget build(BuildContext context) {
    final size = state == _StepState.current ? 22.0 : 14.0;
    final fill = state == _StepState.upcoming
        ? colors.trackSubtle
        : colors.brandPrimary;

    return Container(
      key: const ValueKey('step-track-node'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: colors.frameInk, width: 2),
        borderRadius: BorderRadius.circular(
          state == _StepState.current ? 3 : 2,
        ),
      ),
      child: Center(
        child: Container(
          width: state == _StepState.current ? 8 : 4,
          height: state == _StepState.current ? 8 : 4,
          decoration: BoxDecoration(
            color: colors.onPrimary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
