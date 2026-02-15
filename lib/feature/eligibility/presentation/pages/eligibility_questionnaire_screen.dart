import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/presentation/pages/eligibility_result_screen.dart';
import 'package:lifelink/feature/eligibility/presentation/state/eligibility_state.dart';
import 'package:lifelink/feature/eligibility/presentation/view_model/eligibility_view_model.dart';
import 'package:lifelink/theme/app_theme.dart';

class EligibilityQuestionnaireScreen extends ConsumerStatefulWidget {
  final String? hospitalId;
  final String? hospitalName;
  final String requestType;

  const EligibilityQuestionnaireScreen({
    super.key,
    this.hospitalId,
    this.hospitalName,
    this.requestType = 'blood',
  });

  @override
  ConsumerState<EligibilityQuestionnaireScreen> createState() =>
      _EligibilityQuestionnaireScreenState();
}

class _EligibilityQuestionnaireScreenState
    extends ConsumerState<EligibilityQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _travelCountriesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _infectionDetailsController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  String _gender = '';

  bool _noDiseases = false;
  bool _hasBloodPressure = false;
  bool _hasDiabetes = false;
  bool _hasHeartDisease = false;
  bool _hasCancer = false;
  bool _hasHepatitis = false;
  bool _hasHIV = false;
  bool _hasTuberculosis = false;
  bool _recentTravel = false;
  bool _takingMedications = false;
  bool _activeInfection = false;
  bool _isPregnant = false;
  bool _isBreastfeeding = false;
  bool _hasRecentTattoo = false;
  bool _hasRecentPiercing = false;
  bool _hadBloodTransfusion = false;

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _travelCountriesController.dispose();
    _medicationsController.dispose();
    _infectionDetailsController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _toggleNoDiseases(bool value) {
    setState(() {
      _noDiseases = value;
      if (value) {
        _hasBloodPressure = false;
        _hasDiabetes = false;
        _hasHeartDisease = false;
        _hasCancer = false;
        _hasHepatitis = false;
        _hasHIV = false;
        _hasTuberculosis = false;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    final questionnaire = EligibilityQuestionnaireEntity(
      age: int.parse(_ageController.text.trim()),
      weight: double.parse(_weightController.text.trim()),
      gender: _gender,
      hasBloodPressure: _hasBloodPressure,
      hasDiabetes: _hasDiabetes,
      hasHeartDisease: _hasHeartDisease,
      hasCancer: _hasCancer,
      hasHepatitis: _hasHepatitis,
      hasHIV: _hasHIV,
      hasTuberculosis: _hasTuberculosis,
      recentTravel: _recentTravel,
      travelCountries: _recentTravel
          ? _travelCountriesController.text
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList()
          : const [],
      takingMedications: _takingMedications,
      medications: _takingMedications
          ? _medicationsController.text
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList()
          : const [],
      activeInfection: _activeInfection,
      infectionDetails:
          _activeInfection ? _infectionDetailsController.text.trim() : null,
      isPregnant: _gender == 'female' ? _isPregnant : null,
      isBreastfeeding: _gender == 'female' ? _isBreastfeeding : null,
      hasRecentTattoo: _hasRecentTattoo,
      hasRecentPiercing: _hasRecentPiercing,
      hadBloodTransfusion: _hadBloodTransfusion,
      additionalNotes: _additionalNotesController.text.trim().isNotEmpty
          ? _additionalNotesController.text.trim()
          : null,
    );

    final isEligible = await ref
        .read(eligibilityViewModelProvider.notifier)
        .submitAndCheck(questionnaire);

    if (!mounted) return;

    final result = ref.read(eligibilityViewModelProvider).result;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EligibilityResultScreen(
          result: result,
          isEligible: isEligible,
          hospitalId: widget.hospitalId,
          hospitalName: widget.hospitalName,
          requestType: widget.requestType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eligibilityState = ref.watch(eligibilityViewModelProvider);
    final isLoading = eligibilityState.status == EligibilityStatus.loading;

    ref.listen<EligibilityState>(eligibilityViewModelProvider,
        (previous, next) {
      if (next.status == EligibilityStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eligibility Questionnaire'),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Basic Information'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Age', Icons.cake),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Age is required';
                  final age = int.tryParse(val);
                  if (age == null || age < 18 || age > 100) {
                    return 'Age must be between 18-100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration('Weight (kg)', Icons.monitor_weight),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Weight is required';
                  final weight = double.tryParse(val);
                  if (weight == null || weight < 40) {
                    return 'Enter valid weight (minimum 40 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender.isEmpty ? null : _gender,
                decoration: _inputDecoration('Gender', Icons.person),
                items: const ['male', 'female', 'other']
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender[0].toUpperCase() + gender.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _gender = value ?? ''),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Gender is required' : null,
              ),
              const SizedBox(height: 20),

              _sectionTitle('Health Conditions'),
              const SizedBox(height: 10),
              _checkTile('No diseases', _noDiseases, _toggleNoDiseases),
              _checkTile(
                'High blood pressure',
                _hasBloodPressure,
                (value) => setState(() => _hasBloodPressure = value),
                disabled: _noDiseases,
              ),
              _checkTile(
                'Diabetes',
                _hasDiabetes,
                (value) => setState(() => _hasDiabetes = value),
                disabled: _noDiseases,
              ),
              _checkTile(
                'Heart disease',
                _hasHeartDisease,
                (value) => setState(() => _hasHeartDisease = value),
                disabled: _noDiseases,
              ),
              _checkTile(
                'Cancer',
                _hasCancer,
                (value) => setState(() => _hasCancer = value),
                disabled: _noDiseases,
              ),
              _checkTile(
                'Hepatitis',
                _hasHepatitis,
                (value) => setState(() => _hasHepatitis = value),
                disabled: _noDiseases,
              ),
              _checkTile(
                'HIV',
                _hasHIV,
                (value) => setState(() => _hasHIV = value),
                disabled: _noDiseases,
              ),
              _checkTile(
                'Tuberculosis',
                _hasTuberculosis,
                (value) => setState(() => _hasTuberculosis = value),
                disabled: _noDiseases,
              ),
              const SizedBox(height: 8),

              _sectionTitle('Additional Questions'),
              const SizedBox(height: 10),
              _checkTile(
                'Recent travel',
                _recentTravel,
                (value) => setState(() => _recentTravel = value),
              ),
              if (_recentTravel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _travelCountriesController,
                    decoration: _inputDecoration(
                      'Travel countries (comma separated)',
                      Icons.flight_takeoff,
                    ),
                  ),
                ),
              _checkTile(
                'Taking medications',
                _takingMedications,
                (value) => setState(() => _takingMedications = value),
              ),
              if (_takingMedications)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _medicationsController,
                    decoration: _inputDecoration(
                      'Medications (comma separated)',
                      Icons.medication,
                    ),
                  ),
                ),
              _checkTile(
                'Active infection',
                _activeInfection,
                (value) => setState(() => _activeInfection = value),
              ),
              if (_activeInfection)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _infectionDetailsController,
                    decoration: _inputDecoration(
                      'Infection details',
                      Icons.coronavirus,
                    ),
                  ),
                ),
              if (_gender == 'female') ...[
                _checkTile(
                  'Pregnant',
                  _isPregnant,
                  (value) => setState(() => _isPregnant = value),
                ),
                _checkTile(
                  'Breastfeeding',
                  _isBreastfeeding,
                  (value) => setState(() => _isBreastfeeding = value),
                ),
              ],
              _checkTile(
                'Recent tattoo',
                _hasRecentTattoo,
                (value) => setState(() => _hasRecentTattoo = value),
              ),
              _checkTile(
                'Recent piercing',
                _hasRecentPiercing,
                (value) => setState(() => _hasRecentPiercing = value),
              ),
              _checkTile(
                'Had blood transfusion',
                _hadBloodTransfusion,
                (value) => setState(() => _hadBloodTransfusion = value),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _additionalNotesController,
                maxLines: 4,
                decoration: _inputDecoration('Additional notes', Icons.note),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkTile(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    bool disabled = false,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      value: value,
      onChanged: disabled ? null : (newValue) => onChanged(newValue ?? false),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      activeColor: AppTheme.primaryColor,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
      ),
    );
  }
}
