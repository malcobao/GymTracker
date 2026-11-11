import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/profile_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/validation.dart';
import '../../utils/units.dart';
import '../core/app_theme.dart';
import '../core/labels.dart';
import '../core/view_models/session_controller.dart';
import '../core/widgets/dialogs.dart';
import '../core/widgets/state_views.dart';
import '../settings/language_picker.dart';
import 'profile_form_view_model.dart';

/// Onboarding (first launch) and "Edit profile". Every field is validated
/// while the user types; a live card shows the age and BMI.
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({this.isOnboarding = false, super.key});

  final bool isOnboarding;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  /// Each field validates itself as soon as the user changes it (real-time
  /// validation), without flagging fields the user has not touched yet.
  static const _live = AutovalidateMode.onUserInteraction;

  late final vm = ProfileFormViewModel(
    profiles: context.read<ProfileRepository>(),
    session: context.read<SessionController>(),
  );

  final _formKey = GlobalKey<FormState>();
  late final UserProfile? _p = vm.existing;
  late final _name = TextEditingController(text: _p?.displayName ?? '');
  late WeightUnit _unit = _p?.weightUnit ?? WeightUnit.kg;
  late final _height = TextEditingController(text: _num(_p?.heightCm));
  late final _weight = TextEditingController(
    text: _p == null ? '' : _num(Units.fromKg(_p.bodyWeightKg, _unit)),
  );
  late DateTime? _birthDate = _p?.birthDate;
  late Sex? _sex = _p?.sex;
  late ExperienceLevel? _level = _p?.experienceLevel;
  late Goal? _goal = _p?.goal;

  static String _num(double? v) =>
      v == null ? '' : v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _height, _weight]) {
      c.addListener(() => setState(() {})); // live age / BMI card
    }
  }

  @override
  void dispose() {
    vm.dispose();
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _switchUnit(WeightUnit unit) {
    final value = Validation.parseDecimal(_weight.text);
    setState(() {
      if (value != null) {
        _weight.text = _num(Units.fromKg(Units.toKg(value, _unit), unit));
      }
      _unit = unit;
    });
  }

  Future<void> _pickBirthDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - Validation.maxAge - 1),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
      field.didChange(picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final error = await vm.save(
      UserProfile(
        displayName: _name.text.trim(),
        birthDate: _birthDate!,
        sex: _sex!,
        heightCm: Validation.parseDecimal(_height.text)!,
        bodyWeightKg: Units.toKg(Validation.parseDecimal(_weight.text)!, _unit),
        experienceLevel: _level!,
        goal: _goal!,
        weightUnit: _unit,
      ),
    );
    if (!mounted) return;
    showMessage(context, error == null ? l10n.profileSaved : l10n.error(error));
    if (error == null && !widget.isOnboarding && context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final minKg = Units.fromKg(
      Validation.minBodyWeightKg,
      _unit,
    ).ceilToDouble();
    final maxKg = Units.fromKg(
      Validation.maxBodyWeightKg,
      _unit,
    ).floorToDouble();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isOnboarding ? l10n.onboardingTitle : l10n.editProfile,
        ),
        actions: [if (widget.isOnboarding) const LanguageMenuButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.space4),
                children: [
                  if (widget.isOnboarding) ...[
                    FadeSlideIn(
                      child: Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppTheme.space3),
                          Expanded(child: Text(l10n.onboardingIntro)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.space4),
                  ],
                  TextFormField(
                    autovalidateMode: _live,
                    controller: _name,
                    maxLength: Validation.maxDisplayNameLength,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) => l10n.field(
                      Validation.name(v, max: Validation.maxDisplayNameLength),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space2),
                  FormField<DateTime>(
                    autovalidateMode: _live,
                    initialValue: _birthDate,
                    validator: (v) {
                      final error = Validation.birthDate(v, DateTime.now());
                      return error?.code == FieldErrorCode.outOfRange
                          ? l10n.errAgeRange(
                              Validation.minAge,
                              Validation.maxAge,
                            )
                          : l10n.field(error);
                    },
                    builder: (field) => InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      onTap: () => _pickBirthDate(field),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.birthDate,
                          prefixIcon: const Icon(Icons.cake_outlined),
                          suffixIcon: const Icon(Icons.calendar_today),
                          errorText: field.errorText,
                        ),
                        child: Text(
                          _birthDate == null
                              ? l10n.chooseDate
                              : context.fmt.date(_birthDate!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  DropdownButtonFormField<Sex>(
                    isExpanded: true,
                    autovalidateMode: _live,
                    initialValue: _sex,
                    decoration: InputDecoration(
                      labelText: l10n.sex,
                      prefixIcon: const Icon(Icons.wc),
                    ),
                    items: [
                      for (final s in Sex.values)
                        DropdownMenuItem(
                          value: s,
                          child: Text(l10n.sexLabel(s)),
                        ),
                    ],
                    validator: (v) => l10n.field(Validation.requiredChoice(v)),
                    onChanged: (v) => setState(() => _sex = v),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  TextFormField(
                    autovalidateMode: _live,
                    controller: _height,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.height,
                      suffixText: 'cm',
                      prefixIcon: const Icon(Icons.height),
                    ),
                    validator: (v) => l10n.field(
                      Validation.decimal(
                        v,
                        min: Validation.minHeightCm,
                        max: Validation.maxHeightCm,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          autovalidateMode: _live,
                          controller: _weight,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.bodyWeight,
                            suffixText: _unit.dbValue,
                            prefixIcon: const Icon(
                              Icons.monitor_weight_outlined,
                            ),
                          ),
                          validator: (v) => l10n.field(
                            Validation.decimal(v, min: minKg, max: maxKg),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space2),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: SegmentedButton<WeightUnit>(
                          segments: const [
                            ButtonSegment(
                              value: WeightUnit.kg,
                              label: Text('kg'),
                            ),
                            ButtonSegment(
                              value: WeightUnit.lb,
                              label: Text('lb'),
                            ),
                          ],
                          selected: {_unit},
                          onSelectionChanged: (s) => _switchUnit(s.first),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),
                  DropdownButtonFormField<ExperienceLevel>(
                    isExpanded: true,
                    autovalidateMode: _live,
                    initialValue: _level,
                    decoration: InputDecoration(
                      labelText: l10n.experience,
                      prefixIcon: const Icon(Icons.trending_up),
                    ),
                    items: [
                      for (final e in ExperienceLevel.values)
                        DropdownMenuItem(value: e, child: Text(l10n.level(e))),
                    ],
                    validator: (v) => l10n.field(Validation.requiredChoice(v)),
                    onChanged: (v) => setState(() => _level = v),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  DropdownButtonFormField<Goal>(
                    isExpanded: true,
                    autovalidateMode: _live,
                    initialValue: _goal,
                    decoration: InputDecoration(
                      labelText: l10n.mainGoal,
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                    items: [
                      for (final g in Goal.values)
                        DropdownMenuItem(value: g, child: Text(l10n.goal(g))),
                    ],
                    validator: (v) => l10n.field(Validation.requiredChoice(v)),
                    onChanged: (v) => setState(() => _goal = v),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  _LivePreview(
                    birthDate: _birthDate,
                    heightCm: Validation.parseDecimal(_height.text),
                    weightKg: switch (Validation.parseDecimal(_weight.text)) {
                      final v? => Units.toKg(v, _unit),
                      null => null,
                    },
                  ),
                  const SizedBox(height: AppTheme.space4),
                  ListenableBuilder(
                    listenable: vm,
                    builder: (context, _) => FilledButton.icon(
                      onPressed: vm.saving ? null : _save,
                      icon: Icon(
                        widget.isOnboarding ? Icons.arrow_forward : Icons.save,
                      ),
                      label: Text(
                        widget.isOnboarding ? l10n.startTraining : l10n.save,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Age and BMI, recalculated on every keystroke (shown once valid).
class _LivePreview extends StatelessWidget {
  const _LivePreview({
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
  });

  final DateTime? birthDate;
  final double? heightCm;
  final double? weightKg;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final valid =
        birthDate != null &&
        Validation.birthDate(birthDate, now) == null &&
        heightCm != null &&
        heightCm! >= Validation.minHeightCm &&
        heightCm! <= Validation.maxHeightCm &&
        weightKg != null &&
        weightKg! >= Validation.minBodyWeightKg &&
        weightKg! <= Validation.maxBodyWeightKg;
    final scheme = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: AppTheme.medium,
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: !valid
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('preview'),
              padding: const EdgeInsets.all(AppTheme.space3),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(Icons.insights, color: scheme.onPrimaryContainer),
                  const SizedBox(width: AppTheme.space2),
                  Text(
                    context.l10n.ageAndBmi(
                      UserProfile(
                        displayName: '-',
                        birthDate: birthDate!,
                        sex: Sex.unspecified,
                        heightCm: heightCm!,
                        bodyWeightKg: weightKg!,
                        experienceLevel: ExperienceLevel.beginner,
                        goal: Goal.generalFitness,
                      ).ageOn(now),
                      context.fmt.number(
                        weightKg! / ((heightCm! / 100) * (heightCm! / 100)),
                      ),
                    ),
                    style: TextStyle(color: scheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
    );
  }
}
