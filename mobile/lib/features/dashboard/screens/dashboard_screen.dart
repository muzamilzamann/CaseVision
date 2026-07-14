import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/fir_service.dart';
import '../../../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _firs = [];
  Map<String, dynamic>? _selectedFir;
  bool _isUploading = false;
  bool _isLoadingFirs = true;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadFirs();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.instance.readUser();
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  Future<void> _loadFirs() async {
    setState(() {
      _isLoadingFirs = true;
    });
    try {
      final firs = await FirService.instance.listFirs();
      if (!mounted) return;
      setState(() {
        _firs = firs;
        _selectedFir = firs.isNotEmpty ? firs.first : null;
      });
    } catch (_) {
      // Silently ignore for now; user can retry via upload.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFirs = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadFir() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final file = File(result.files.single.path!);

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      await FirService.instance.uploadFir(file);
      await _loadFirs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FIR uploaded and analyzed successfully.')),
      );
    } catch (e) {
      setState(() {
        _uploadError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _selectFir(Map<String, dynamic> fir) {
    setState(() {
      _selectedFir = fir;
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _user?['full_name'] as String? ?? 'CaseVision User';
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppPalette.parchment,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppPalette.gold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.balance, color: AppPalette.goldDark, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('CaseVision', style: TextStyle(fontWeight: FontWeight.w800, color: AppPalette.ink)),
          ],
        ),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: AppPalette.ink)),
          const SizedBox(width: 8),
        ],
      ),
      body: isWide
          ? _DesktopDashboard(
              userName: fullName,
              firs: _firs,
              selectedFir: _selectedFir,
              isUploading: _isUploading,
              isLoadingFirs: _isLoadingFirs,
              uploadError: _uploadError,
              onUploadPressed: _pickAndUploadFir,
              onFirSelected: _selectFir,
            )
          : _MobileDashboard(
              userName: fullName,
              firs: _firs,
              selectedFir: _selectedFir,
              isUploading: _isUploading,
              isLoadingFirs: _isLoadingFirs,
              uploadError: _uploadError,
              onUploadPressed: _pickAndUploadFir,
              onFirSelected: _selectFir,
            ),
      bottomNavigationBar: isWide ? null : const _BottomNavBar(),
    );
  }
}

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({
    required this.userName,
    required this.firs,
    required this.selectedFir,
    required this.isUploading,
    required this.isLoadingFirs,
    required this.uploadError,
    required this.onUploadPressed,
    required this.onFirSelected,
  });

  final String userName;
  final List<Map<String, dynamic>> firs;
  final Map<String, dynamic>? selectedFir;
  final bool isUploading;
  final bool isLoadingFirs;
  final String? uploadError;
  final VoidCallback onUploadPressed;
  final ValueChanged<Map<String, dynamic>> onFirSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 260,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppPalette.midnightNavy, AppPalette.courtroomBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    _BrandBadge(),
                    SizedBox(height: 16),
                    Text('CaseVision', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text('Barrister Workspace', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              SizedBox(height: 28),
              _SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', active: true),
              _SidebarItem(icon: Icons.upload_file_rounded, label: 'Upload FIR'),
              _SidebarItem(icon: Icons.document_scanner_outlined, label: 'Case Analysis'),
              _SidebarItem(icon: Icons.scale_outlined, label: 'Related Cases'),
              _SidebarItem(icon: Icons.smart_toy_outlined, label: 'AI Assistant'),
              _SidebarItem(icon: Icons.description_outlined, label: 'Reports'),
              _SidebarItem(icon: Icons.settings_outlined, label: 'Settings'),
              Spacer(),
              _SidebarFooter(),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(4, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBanner(userName: userName),
                const SizedBox(height: 18),
                _StatGrid(wide: true, firCount: firs.length, latestFir: selectedFir),
                const SizedBox(height: 18),
                _TopPanels(
                  wide: true,
                  latestFir: selectedFir,
                  isUploading: isUploading,
                  uploadError: uploadError,
                  onUploadPressed: onUploadPressed,
                ),
                const SizedBox(height: 18),
                _BottomPanels(wide: true, latestFir: selectedFir),
                const SizedBox(height: 18),
                _HistoryPanel(
                  firs: firs,
                  selectedFir: selectedFir,
                  isLoading: isLoadingFirs,
                  onFirSelected: onFirSelected,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard({
    required this.userName,
    required this.firs,
    required this.selectedFir,
    required this.isUploading,
    required this.isLoadingFirs,
    required this.uploadError,
    required this.onUploadPressed,
    required this.onFirSelected,
  });

  final String userName;
  final List<Map<String, dynamic>> firs;
  final Map<String, dynamic>? selectedFir;
  final bool isUploading;
  final bool isLoadingFirs;
  final String? uploadError;
  final VoidCallback onUploadPressed;
  final ValueChanged<Map<String, dynamic>> onFirSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroBanner(userName: userName),
          const SizedBox(height: 16),
          _StatGrid(wide: false, firCount: firs.length, latestFir: selectedFir),
          const SizedBox(height: 16),
          _TopPanels(
            wide: false,
            latestFir: selectedFir,
            isUploading: isUploading,
            uploadError: uploadError,
            onUploadPressed: onUploadPressed,
          ),
          const SizedBox(height: 16),
          _BottomPanels(wide: false, latestFir: selectedFir),
          const SizedBox(height: 16),
          _HistoryPanel(
            firs: firs,
            selectedFir: selectedFir,
            isLoading: isLoadingFirs,
            onFirSelected: onFirSelected,
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.midnightNavy, AppPalette.courtroomBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: AppPalette.gold.withValues(alpha: 0.22), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: AppPalette.gold, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text('Attorney-grade legal workspace', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppPalette.gold.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(999)),
            child: const Text('92.4% AI Accuracy', style: TextStyle(color: AppPalette.gold, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.wide, required this.firCount, required this.latestFir});

  final bool wide;
  final int firCount;
  final Map<String, dynamic>? latestFir;

  @override
  Widget build(BuildContext context) {
    final lawsCount = (latestFir?['predicted_laws'] as List?)?.length ?? 0;
    final casesCount = (latestFir?['related_cases'] as List?)?.length ?? 0;

    final stats = [
      _StatData('$firCount', 'Uploaded FIRs', Icons.file_upload_outlined, firCount > 0 ? '+1' : '—'),
      _StatData('$lawsCount', 'Laws Detected', Icons.menu_book_outlined, '—'),
      _StatData('$casesCount', 'Similar Cases', Icons.groups_outlined, '—'),
      const _StatData('92.4%', 'AI Accuracy', Icons.track_changes_outlined, '+6%'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: wide ? 4 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: wide ? 2.35 : 1.18,
      children: stats.map((data) => _StatTile(data: data)).toList(),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppPalette.gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
            child: Icon(data.icon, color: AppPalette.goldDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                Text(data.label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(data.delta, style: const TextStyle(fontSize: 11.5, color: AppPalette.goldDark, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPanels extends StatelessWidget {
  const _TopPanels({
    required this.wide,
    required this.latestFir,
    required this.isUploading,
    required this.uploadError,
    required this.onUploadPressed,
  });

  final bool wide;
  final Map<String, dynamic>? latestFir;
  final bool isUploading;
  final String? uploadError;
  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    final laws = (latestFir?['predicted_laws'] as List?)?.cast<String>() ?? [];
    final urduList = (latestFir?['urdu_explanation'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: wide ? 3 : 1,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: wide ? 1.15 : 0.98,
      children: [
        _PanelCard(
          title: 'Upload FIR',
          icon: Icons.cloud_upload_outlined,
          child: _UploadBox(
            isUploading: isUploading,
            errorMessage: uploadError,
            onPressed: onUploadPressed,
          ),
        ),
        _PanelCard(
          title: 'Detected Pakistani Laws',
          icon: Icons.menu_book_outlined,
          child: _LawList(laws: laws),
        ),
        _PanelCard(
          title: 'Asaan Urdu Wazahat',
          icon: Icons.translate_outlined,
          child: _UrduList(items: urduList),
        ),
      ],
    );
  }
}

class _BottomPanels extends StatelessWidget {
  const _BottomPanels({required this.wide, required this.latestFir});

  final bool wide;
  final Map<String, dynamic>? latestFir;

  @override
  Widget build(BuildContext context) {
    final summary = latestFir?['summary'] as String?;
    final cases = (latestFir?['related_cases'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: wide ? 2 : 1,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: wide ? 1.35 : 1.12,
      children: [
        _PanelCard(
          title: 'AI Summary',
          icon: Icons.auto_awesome_outlined,
          child: _SummaryText(summary: summary),
        ),
        _PanelCard(
          title: 'Related Case Studies',
          icon: Icons.gavel_outlined,
          child: _CaseList(cases: cases),
        ),
      ],
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({
    required this.firs,
    required this.selectedFir,
    required this.isLoading,
    required this.onFirSelected,
  });

  final List<Map<String, dynamic>> firs;
  final Map<String, dynamic>? selectedFir;
  final bool isLoading;
  final ValueChanged<Map<String, dynamic>> onFirSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.history, color: AppPalette.goldDark, size: 20),
              SizedBox(width: 8),
              Text('Upload History', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (firs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No FIRs uploaded yet.', style: TextStyle(color: Colors.black45)),
            )
          else
            Column(
              children: [
                for (final fir in firs) _HistoryTile(
                  fir: fir,
                  isSelected: selectedFir != null && selectedFir!['id'] == fir['id'],
                  onTap: () => onFirSelected(fir),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.fir, required this.isSelected, required this.onTap});

  final Map<String, dynamic> fir;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fileName = fir['file_name'] as String? ?? 'Untitled FIR';
    final createdAt = fir['created_at'] as String? ?? '';
    final status = fir['status'] as String? ?? 'uploaded';

    String formattedDate = createdAt;
    try {
      final parsed = DateTime.parse(createdAt);
      formattedDate = '${parsed.day}/${parsed.month}/${parsed.year} • ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      // Keep raw string if parsing fails.
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.gold.withValues(alpha: 0.14) : AppPalette.parchmentAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppPalette.goldDark : AppPalette.hairline,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: isSelected ? AppPalette.goldDark : Colors.black45,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? AppPalette.goldDark : Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(formattedDate, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppPalette.courtroomBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                status,
                style: const TextStyle(color: AppPalette.courtroomBlue, fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppPalette.goldDark, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.isUploading,
    required this.errorMessage,
    required this.onPressed,
  });

  final bool isUploading;
  final String? errorMessage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppPalette.gold.withValues(alpha: 0.35), width: 1.6),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppPalette.goldDark, size: 46),
                const SizedBox(height: 10),
                const Text('Drag & drop your FIR here', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('PDF, JPG, PNG'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: isUploading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.courtroomBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Browse File', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _LawList extends StatelessWidget {
  const _LawList({required this.laws});

  final List<String> laws;

  @override
  Widget build(BuildContext context) {
    if (laws.isEmpty) {
      return const Center(
        child: Text('Upload an FIR to see detected laws.', style: TextStyle(color: Colors.black45)),
      );
    }
    return Column(
      children: [
        for (final law in laws) ...[
          _MiniPill(title: law, subtitle: ''),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _UrduList extends StatelessWidget {
  const _UrduList({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Urdu explanation will appear here.', style: TextStyle(color: Colors.black45)),
      );
    }
    return Column(
      children: [
        for (final item in items) ...[
          _UrduCard(title: item['title'] as String? ?? '', text: item['text'] as String? ?? ''),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SummaryText extends StatelessWidget {
  const _SummaryText({required this.summary});

  final String? summary;

  @override
  Widget build(BuildContext context) {
    return Text(
      summary ?? 'Upload an FIR to generate an AI summary.',
      style: const TextStyle(height: 1.55),
    );
  }
}

class _CaseList extends StatelessWidget {
  const _CaseList({required this.cases});

  final List<Map<String, dynamic>> cases;

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) {
      return const Center(
        child: Text('Related cases will appear here.', style: TextStyle(color: Colors.black45)),
      );
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final c in cases)
          _CaseTile(
            title: c['title'] as String? ?? '',
            court: c['court'] as String? ?? '',
            year: c['year'] as String? ?? '',
          ),
      ],
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.parchmentAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
          ],
        ],
      ),
    );
  }
}

class _UrduCard extends StatelessWidget {
  const _UrduCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.parchmentAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppPalette.goldDark)),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

class _CaseTile extends StatelessWidget {
  const _CaseTile({required this.title, required this.court, required this.year});

  final String title;
  final String court;
  final String year;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.parchmentAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.hairline),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_outlined, color: AppPalette.goldDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(court, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
              ],
            ),
          ),
          Text(year, style: const TextStyle(color: AppPalette.goldDark, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppPalette.courtroomBlue,
      unselectedItemColor: Colors.black45,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.cloud_upload_outlined), label: 'Upload'),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI Assistant'),
        BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.icon, required this.label, this.active = false});

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: active ? AppPalette.courtroomBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Empowering Justice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('with AI & Law', style: TextStyle(color: Colors.white.withValues(alpha: 0.72))),
        ],
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.balance, size: 40, color: AppPalette.gold),
    );
  }
}

class _StatData {
  const _StatData(this.value, this.label, this.icon, this.delta);

  final String value;
  final String label;
  final IconData icon;
  final String delta;
}