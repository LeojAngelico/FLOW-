import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/components/back_button.dart';
import '../../../../core/design/components/flow_text_button.dart';
import '../../../../core/design/components/flow_text_field.dart';
import '../../../../core/design/components/info_card.dart';
import '../../../../core/design/components/primary_button.dart';
import '../../../../core/design/components/quick_add_chip.dart';
import '../../../../core/design/components/stepper_button.dart';
import '../../../../core/design/tokens/flow_colors.dart';
import '../../../../core/design/tokens/flow_spacing.dart';
import '../../../../core/design/tokens/flow_typography.dart';
import '../../../../core/utils/volume_format.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/usecases/log_water.dart';
import 'add_water_notifier.dart';

/// `/home/add` — APP-02's custom-amount entry: stepper, direct numeric
/// entry, value-setting quick-amount chips, a large-amount confirm
/// above 1,000ml (`FR-024`), and a discard-on-back confirm (`CPY-108`)
/// once the amount has changed. All business logic lives in
/// `add_water_notifier.dart`; this widget renders state and owns only
/// the text-editing controller's lifecycle — the reason this is a
/// `StatefulWidget` rather than a `StatelessWidget`.
///
/// `StepperButton`, `QuickAddChip`, `FlowTextField`, `PrimaryButton` and
/// `InfoCard` are all reused from the shared UI kit rather than
/// reinvented — see `flutter-ui-kit` SKILL.
class AddWaterPage extends ConsumerStatefulWidget {
  const AddWaterPage({super.key});

  @override
  ConsumerState<AddWaterPage> createState() => _AddWaterPageState();
}

class _AddWaterPageState extends ConsumerState<AddWaterPage> {
  late final TextEditingController _controller;

  /// The value-setting quick amounts (`APP-02`'s "quick-amount chips
  /// that set the value rather than logging it") — reuses `FR-021`'s
  /// default set rather than inventing a second list.
  static const _quickSetAmountsMl = [150, 250, 350, 500];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.addWaterDiscardTitle),
        actions: [
          FlowTextButton(
            label: loc.cancel,
            showIcon: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          FlowTextButton(
            label: loc.discard,
            showIcon: false,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _confirmLargeAmount(int amountMl) async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.largeAmountConfirmMessage(formatVolumeMl(amountMl))),
        actions: [
          FlowTextButton(
            label: loc.cancel,
            showIcon: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          FlowTextButton(
            label: loc.logWaterButton,
            showIcon: false,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleSubmit() async {
    final notifier = ref.read(addWaterProvider.notifier);
    final succeeded = await notifier.submit();
    if (succeeded) {
      if (mounted) context.pop();
      return;
    }

    if (!mounted) return;
    if (!ref.read(addWaterProvider).needsLargeAmountConfirm) {
      // Blocked for a reason other than the large-amount gate (out of
      // bounds, already submitting, or a write failure already in
      // state) — nothing further to do here.
      return;
    }

    final amountMl = ref.read(addWaterProvider).amountMl;
    final confirmed = await _confirmLargeAmount(amountMl);
    if (!mounted) return;

    if (confirmed) {
      final succeededOnConfirm = await notifier.submit();
      if (succeededOnConfirm && mounted) {
        context.pop();
      }
    } else {
      notifier.dismissLargeAmountConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final state = ref.watch(addWaterProvider);

    final text = state.amountMl == 0 ? '' : state.amountMl.toString();
    if (_controller.text != text) {
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
    }

    final canSubmit =
        state.amountMl >= LogWater.minAmountMl &&
        state.amountMl <= LogWater.maxAmountMl &&
        !state.isSubmitting;

    return PopScope(
      canPop: !state.isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (discard && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: FlowBackButton(onPressed: () => Navigator.maybePop(context)),
          title: Text(loc.addWaterTitle),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(FlowSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.failure != null) ...[
                  InfoCard(
                    message: loc.errorHydrationStorage,
                    kind: InfoCardKind.caution,
                  ),
                  const SizedBox(height: FlowSpacing.md),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StepperButton(
                      direction: StepDirection.decrement,
                      enabled: state.amountMl > LogWater.minAmountMl,
                      onStep: () =>
                          ref.read(addWaterProvider.notifier).decrement(),
                    ),
                    const SizedBox(width: FlowSpacing.lg),
                    SizedBox(
                      width: 140,
                      child: FlowTextField(
                        controller: _controller,
                        numericHero: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          final parsed = int.tryParse(value) ?? 0;
                          ref.read(addWaterProvider.notifier).setAmount(parsed);
                        },
                      ),
                    ),
                    const SizedBox(width: FlowSpacing.lg),
                    StepperButton(
                      direction: StepDirection.increment,
                      enabled: state.amountMl < LogWater.maxAmountMl,
                      onStep: () =>
                          ref.read(addWaterProvider.notifier).increment(),
                    ),
                  ],
                ),
                const SizedBox(height: FlowSpacing.sm),
                Text(
                  loc.hydrationAmountUnitLabel,
                  textAlign: TextAlign.center,
                  style: typography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: FlowSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: FlowSpacing.sm,
                  runSpacing: FlowSpacing.sm,
                  children: [
                    for (final amount in _quickSetAmountsMl)
                      QuickAddChip(
                        amountMl: amount,
                        selected: state.amountMl == amount,
                        onTap: () => ref
                            .read(addWaterProvider.notifier)
                            .setAmount(amount),
                      ),
                  ],
                ),
                const SizedBox(height: FlowSpacing.xl3),
                PrimaryButton(
                  label: loc.logWaterButton,
                  isLoading: state.isSubmitting,
                  onPressed: canSubmit ? _handleSubmit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
