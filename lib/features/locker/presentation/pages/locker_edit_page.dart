import 'package:face_locker/core/services/locker_service.dart';
import 'package:face_locker/features/locker/presentation/models/locker_item_view.dart';
import 'package:flutter/material.dart';

class LockerEditPage extends StatefulWidget {
  final LockerItemView? locker; // If null, it's 'Create Mode'

  const LockerEditPage({super.key, this.locker});

  @override
  State<LockerEditPage> createState() => _LockerEditPageState();
}

class _LockerEditPageState extends State<LockerEditPage> {
  final LockerService _lockerService = LockerService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _locationController;
  late TextEditingController _sizeController;

  bool _isLoading = false;

  bool get _isEditing => widget.locker != null;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.locker?.code ?? '');
    _locationController = TextEditingController(
      text: widget.locker?.location ?? '',
    );
    _sizeController = TextEditingController(text: widget.locker?.size ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'code': _codeController.text.trim(),
        'location': _locationController.text.trim(),
        'size': _sizeController.text.trim(),
        'openUrl':
            'https://api.example.com/lockers/${_codeController.text.trim()}/open',
        'closeUrl':
            'https://api.example.com/lockers/${_codeController.text.trim()}/close',
        'status': widget.locker?.status ?? 'AVAILABLE',
        'doorState': widget.locker?.doorState ?? 'CLOSED',
      };

      if (_isEditing) {
        await _lockerService.updateLocker(widget.locker!.id, data);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Locker updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
      } else {
        await _lockerService.createLocker(data);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Locker created successfully'),
              backgroundColor: Colors.green,
            ),
          );
      }

      if (mounted)
        Navigator.pop(context, true); // Pop and return true to trigger refresh
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    if (!_isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Locker'),
        content: const Text('Are you sure you want to delete this locker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _lockerService.deleteLocker(widget.locker!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Locker deleted'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.blue),
        ),
        title: Text(
          _isEditing ? 'Edit Locker' : 'Create Locker',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField('Locker Code', _codeController, 'e.g., A02'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Location',
                    _locationController,
                    'e.g., Floor 1 - Zone A',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Size', _sizeController, 'e.g., Medium'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text(
                        'Delete Locker',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required field' : null,
        ),
      ],
    );
  }
}
