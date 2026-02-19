import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/pages/blood_request_form_page.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/presentation/state/eligibility_state.dart';
import 'package:lifelink/feature/eligibility/presentation/view_model/eligibility_view_model.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/pages/create_organ_donation_request_screen.dart';
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

  bool _showResult = false;
  bool _isEligibleResult = false;
  EligibilityResultEntity? _result;

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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  bool get _isFemale => _gender == 'female';

  List<String> _splitCommaSeparated(String rawValue) {
    return rawValue
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  EligibilityQuestionnaireEntity _buildQuestionnaire() {
    return EligibilityQuestionnaireEntity(
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
          ? _splitCommaSeparated(_travelCountriesController.text)
          : const [],
      takingMedications: _takingMedications,
      medications: _takingMedications
          ? _splitCommaSeparated(_medicationsController.text)
          : const [],
      activeInfection: _activeInfection,
      infectionDetails: _activeInfection
          ? _optionalText(_infectionDetailsController)
          : null,
      isPregnant: _isFemale ? _isPregnant : null,
      isBreastfeeding: _isFemale ? _isBreastfeeding : null,
      hasRecentTattoo: _hasRecentTattoo,
      hasRecentPiercing: _hasRecentPiercing,
      hadBloodTransfusion: _hadBloodTransfusion,
      additionalNotes: _optionalText(_additionalNotesController),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select gender')));
      return;
    }

    final questionnaire = _buildQuestionnaire();

    final isEligible = await ref
        .read(eligibilityViewModelProvider.notifier)
        .submitAndCheck(questionnaire);

    if (!mounted) return;

    final result = ref.read(eligibilityViewModelProvider).result;

    setState(() {
      _showResult = true;
      _isEligibleResult = isEligible;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eligibilityState = ref.watch(eligibilityViewModelProvider);
    final isLoading = eligibilityState.status == EligibilityStatus.loading;

    ref.listen<EligibilityState>(eligibilityViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == EligibilityStatus.error && next.errorMessage != null) {
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
        title: Text(
          _showResult ? 'Eligibility Result' : 'Eligibility Questionnaire',
        ),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _showResult
            ? _buildResultBody()
            : SingleChildScrollView(
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
                          if (val == null || val.isEmpty)
                            return 'Age is required';
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          'Weight (kg)',
                          Icons.monitor_weight,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Weight is required';
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
                                child: Text(
                                  gender[0].toUpperCase() + gender.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _gender = value ?? ''),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Gender is required'
                            : null,
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
                        decoration: _inputDecoration(
                          'Additional notes',
                          Icons.note,
                        ),
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _handleResultAction() {
    if (_isEligibleResult) {
      if (widget.requestType == 'organ') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateOrganRequestScreen(
              hospitalId: widget.hospitalId,
              hospitalName: widget.hospitalName,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BloodRequestFormPage(
              hospitalId: widget.hospitalId,
              hospitalName: widget.hospitalName,
            ),
          ),
        );
      }
      return;
    }

    Navigator.pop(context);
  }

  Widget _buildResultBody() {
    final result = _result;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _isEligibleResult
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isEligibleResult ? Icons.check_circle : Icons.cancel,
              size: 60,
              color: _isEligibleResult ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isEligibleResult ? 'You are Eligible!' : 'Not Eligible',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isEligibleResult ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isEligibleResult
                ? 'You can proceed to submit a donation request.'
                : 'You cannot donate blood at this time.',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (result != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Eligibility Score',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.score}/100',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: result.score >= 70 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: result.score / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        result.score >= 70 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (result.reasons.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Reasons',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...result.reasons.map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (result.nextEligibleDate != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You may be eligible after ${_formatDate(result.nextEligibleDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleResultAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEligibleResult
                    ? AppTheme.primaryColor
                    : Colors.grey.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isEligibleResult ? 'Proceed to Request' : 'Go Back',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
