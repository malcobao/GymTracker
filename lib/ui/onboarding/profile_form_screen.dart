import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/validation.dart';
import '../../utils/units.dart';
import 'profile_form_view_model.dart';

/// Onboarding form (first run) and profile editor.
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({required this.viewModel, super.key});

  final ProfileFormViewModel viewModel;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  DateTime? _birthDate;
  Sex? _sex;
  ExperienceLevel? _level;
  Goal? _goal;
  late WeightUnit _unit;
  String? _birthDateError;

  bool get _isOnboarding => widget.viewModel.existing == null;

  @override
  void initState() {
    super.initState();
    final p = widget.viewModel.existing;
    _unit = p?.weightUnit ?? WeightUnit.kg;
    _name = TextEditingController(text: p?.displayName ?? '');
    _height = TextEditingController(text: p == null ? '' : _num(p.heightCm));
    _weight = TextEditingController(
      text: p == null ? '' : _num(Units.fromKg(p.bodyWeightKg, _unit)),
    );
    _birthDate = p?.birthDate;
    _sex = p?.sex;
    _level = p?.experienceLevel;
    _goal = p?.goal;
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _changeUnit(WeightUnit unit) {
    final current = Validation.parseDecimal(_weight.text);
    setState(() {
      if (current != null) {
        _weight.text = _num(Units.fromKg(Units.toKg(current, _unit), unit));
      }
      _unit = unit;
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Birth date',
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateError = null;
      });
    }
  }

  String? _birthDateProblem() {
    if (_birthDate == null) return 'Choose your birth date';
    final probe = UserProfile(
      id: '',
      displayName: '',
      birthDate: _birthDate!,
      sex: Sex.unspecified,
      heightCm: 0,
      bodyWeightKg: 0,
      experienceLevel: ExperienceLevel.beginner,
      goal: Goal.generalFitness,
    );
    final age = probe.ageOn(DateTime.now());
    if (age < 13) return 'You must be at least 13';
    return null;
  }

  Future<void> _save() async {
    final birthProblem = _birthDateProblem();
    setState(() => _birthDateError = birthProblem);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || birthProblem != null) return;

    final saved = await widget.viewModel.save(
      UserProfile(
        id: widget.viewModel.userId,
        displayName: _name.text.trim(),
        birthDate: _birthDate!,
        sex: _sex!,
        heightCm: Validation.parseDecimal(_height.text)!,
        bodyWeightKg: double.parse(
          Units.toKg(
            Validation.parseDecimal(_weight.text)!,
            _unit,
          ).toStringAsFixed(2),
        ),
        experienceLevel: _level!,
        goal: _goal!,
        weightUnit: _unit,
      ),
    );
    if (saved && mounted && !_isOnboarding) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved')));
      Navigator.of(context).maybePop();
    }
  }

  String? _weightValidator(String? value) {
    final min = Units.fromKg(Validation.minBodyWeightKg, _unit);
    final max = Units.fromKg(Validation.maxBodyWeightKg, _unit);
    return Validation.range(
      value,
      min: double.parse(min.toStringAsFixed(0)),
      max: double.parse(max.toStringAsFixed(0)),
      unit: _unit.dbValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final birth = _birthDate;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isOnboarding ? 'Tell us about you' : 'Edit profile'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isOnboarding)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'This is used to personalise your training. '
                    'You can change it any time.',
                  ),
                ),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validation.requiredName(
                  v,
                  max: Validation.maxDisplayNameLength,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Birth date',
                    border: const OutlineInputBorder(),
                    errorText: _birthDateError,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    birth == null ? 'Choose a date' : dateOnly(birth),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Sex>(
                initialValue: _sex,
                decoration: const InputDecoration(
                  labelText: 'Sex',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final s in Sex.values)
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: (v) => setState(() => _sex = v),
                validator: (v) => v == null ? 'Choose an option' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _height,
                decoration: const InputDecoration(
                  labelText: 'Height',
                  suffixText: 'cm',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => Validation.range(
                  v,
                  min: Validation.minHeightCm,
                  max: Validation.maxHeightCm,
                  unit: 'cm',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weight,
                      decoration: InputDecoration(
                        labelText: 'Body weight',
                        suffixText: _unit.dbValue,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _weightValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<WeightUnit>(
                    segments: const [
                      ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                      ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                    ],
                    selected: {_unit},
                    onSelectionChanged: (s) => _changeUnit(s.first),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExperienceLevel>(
                initialValue: _level,
                decoration: const InputDecoration(
                  labelText: 'Experience',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final l in ExperienceLevel.values)
                    DropdownMenuItem(value: l, child: Text(l.label)),
                ],
                onChanged: (v) => setState(() => _level = v),
                validator: (v) => v == null ? 'Choose an option' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Goal>(
                initialValue: _goal,
                decoration: const InputDecoration(
                  labelText: 'Main goal',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final g in Goal.values)
                    DropdownMenuItem(value: g, child: Text(g.label)),
                ],
                onChanged: (v) => setState(() => _goal = v),
                validator: (v) => v == null ? 'Choose an option' : null,
              ),
              ListenableBuilder(
                listenable: vm,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vm.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          vm.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: vm.saving ? null : _save,
                      child: Text(_isOnboarding ? 'Start training' : 'Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
